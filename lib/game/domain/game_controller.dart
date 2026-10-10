import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/content.dart';
import '../data/intermission_decisions.dart';
import '../data/save_storage.dart';
import '../data/story_evidence.dart';
import 'battle_engine.dart';
import 'balance.dart';
import 'models.dart';

class GameController extends ChangeNotifier {
  GameController({SaveStorage? storage})
    : _storage = storage ?? PreferencesSaveStorage();

  final SaveStorage _storage;
  GameSave _save = const GameSave();
  BattleEngine? battle;
  Encounter? activeEncounter;
  Contract? activeContract;
  bool ready = false;
  String? lastError;
  Future<void> _mutationQueue = Future.value();
  int _pendingMutations = 0;
  BattleEngine? _lastResolvedBattle;
  BattleResolution? _lastBattleResolution;
  bool _restoredBattleFromSave = false;

  GameSave get save => _save;
  bool get restoredBattleFromSave => _restoredBattleFromSave;
  bool get campaignComplete => _save.completedMatches.contains('M32');

  bool consumeRestoredBattleFlag() {
    final restored = _restoredBattleFromSave;
    _restoredBattleFromSave = false;
    return restored;
  }

  IntermissionDecision? get pendingIntermissionDecision {
    for (final decision in intermissionDecisions) {
      if (_save.completedMatches.contains(decision.encounterKey) &&
          !_save.intermissionChoices.containsKey(decision.id)) {
        return decision;
      }
    }
    return null;
  }

  StoryEvidenceEntry? get pendingStoryEvidence {
    for (final entry in storyEvidenceEntries) {
      if (_save.completedMatches.contains(entry.encounterKey) &&
          !_save.seenStoryEvidence.contains(entry.id)) {
        return entry;
      }
    }
    return null;
  }

  Future<T> _enqueueMutation<T>(Future<T> Function() action) {
    _pendingMutations++;
    final completer = Completer<T>();
    _mutationQueue = _mutationQueue.whenComplete(() async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        _pendingMutations--;
      }
    });
    return completer.future;
  }

  Future<void> _writeStorage(GameSave save) async {
    try {
      await _storage.write(save);
      lastError = null;
    } catch (error) {
      lastError = 'Kayıt yazılamadı: $error';
      rethrow;
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.clear();
      lastError = null;
    } catch (error) {
      lastError = 'Kayıt yazılamadı: $error';
      rethrow;
    }
  }

  Future<bool> markStoryEvidenceSeen(String id) {
    return _enqueueMutation(() async {
      StoryEvidenceEntry? entry;
      for (final candidate in storyEvidenceEntries) {
        if (candidate.id == id) {
          entry = candidate;
          break;
        }
      }
      if (entry == null ||
          !_save.completedMatches.contains(entry.encounterKey) ||
          _save.seenStoryEvidence.contains(entry.id)) {
        return false;
      }
      _save = _save.copyWith(
        seenStoryEvidence: {..._save.seenStoryEvidence, entry.id},
      );
      notifyListeners();
      await _writeStorage(_save);
      return true;
    });
  }

  int audienceScoreForChapter(int chapter) => mainEncounters
      .where((encounter) => encounter.chapter == chapter)
      .fold<int>(
        0,
        (total, encounter) =>
            total + (_save.audienceBestScores[encounter.key] ?? 0),
      );

  bool hasAudienceCrest(int chapter) => audienceScoreForChapter(chapter) >= 16;

  Future<void> initialize() async {
    try {
      _save = await _storage.read() ?? const GameSave();
    } on Object catch (error) {
      lastError = 'Kayıt yüklenemedi: $error';
      _save = const GameSave();
    }
    if (_save.schemaVersion < 9) {
      _save = _save.copyWith(schemaVersion: 9);
      try {
        await _writeStorage(_save);
      } on Object {
        // Keep the recovered save in memory; a later write can finish migration.
        // _writeStorage records the error for the recovery UI before it is caught.
      }
    }
    _restoreActiveBattle();
    ready = true;
    notifyListeners();
  }

  void _restoreActiveBattle() {
    final checkpoint = _save.battleCheckpoint;
    if (checkpoint == null) return;
    try {
      final mode = checkpoint['mode'];
      final engineData = checkpoint['engine'];
      if (engineData is! Map) throw const FormatException('Eksik dövüş kaydı');
      final engineCheckpoint = Map<String, dynamic>.from(engineData);
      final battleSaveData = checkpoint['battleSave'];
      final battleSave = battleSaveData is Map
          ? GameSave.fromJson(Map<String, dynamic>.from(battleSaveData))
          : _save.copyWith(clearBattleCheckpoint: true);
      if (!battleSave.hasHero) {
        throw const FormatException('Dövüşçü kaydı eksik');
      }
      Combatant? opponentOverride;
      if (mode == 'contract') {
        final contractId = checkpoint['contractId'];
        final contract = contracts.firstWhere(
          (entry) => entry.id == contractId,
        );
        if (!isEncounterUnlocked(contract.targetId)) {
          throw const FormatException(
            'Sözleşme düellosu artık erişilebilir değil',
          );
        }
        activeContract = contract;
        activeEncounter = getEncounter(contract.targetId);
      } else if (mode == 'championsRoad') {
        final stage = checkpoint['stage'];
        if (stage is! num || stage.toInt() < 1 || stage.toInt() > 8) {
          throw const FormatException('Ustalık sınaması kaydı geçersiz');
        }
        final built = _buildChampionsRoadEncounter(
          stage.toInt(),
          save: battleSave,
        );
        activeEncounter = built.encounter;
        opponentOverride = built.mirror;
      } else if (mode == 'encounter') {
        final id = checkpoint['encounterId'];
        if (id is! num ||
            id.toInt() < 1 ||
            id.toInt() > 32 ||
            !isEncounterUnlocked(id.toInt())) {
          throw const FormatException('Kampanya düellosu kaydı geçersiz');
        }
        activeEncounter = getEncounter(id.toInt());
      } else {
        throw const FormatException('Dövüş kaydı türü tanınmıyor');
      }
      battle = BattleEngine.restoreFromCheckpoint(
        save: battleSave,
        encounter: activeEncounter!,
        checkpoint: engineCheckpoint,
        opponentOverride: opponentOverride,
      );
      _restoredBattleFromSave = true;
    } on Object catch (error) {
      activeEncounter = null;
      activeContract = null;
      battle = null;
      _save = _save.copyWith(clearBattleCheckpoint: true);
      lastError = 'Dövüş kaydı açılamadı: $error';
      unawaited(_storage.write(_save).catchError((Object _) {}));
    }
  }

  Future<void> createHero({
    required String name,
    required Stats stats,
    String appearance = 'Kıyı',
    String headOptionId = 'head_01',
    String skinToneId = 'skin_01',
    String bodyProportionId = 'body_01',
    String facialHairId = 'facial_hair_00',
  }) {
    final candidateName = name.trim();
    final normalized = candidateName.isEmpty
        ? 'Kıyı Dövüşçüsü'
        : candidateName.substring(0, candidateName.length.clamp(0, 20));
    final distributed = Stat.values.fold<int>(
      0,
      (sum, stat) => sum + (stats[stat] - 2),
    );
    if (distributed != 6 ||
        Stat.values.any((stat) => stats[stat] < 2 || stats[stat] > 5)) {
      throw ArgumentError(
        'Başlangıçta tam 6 puan dağıtılmalı; nitelikler 2–5 arasında olmalı.',
      );
    }
    return _enqueueMutation(() async {
      _save = GameSave(
        hasHero: true,
        heroName: normalized,
        appearance: appearance,
        headOptionId: headOptionId,
        skinToneId: skinToneId,
        bodyProportionId: bodyProportionId,
        facialHairId: facialHairId,
        stats: stats,
        gold: GameBalance.startingGold,
      );
      notifyListeners();
      await _writeStorage(_save);
    });
  }

  Future<bool> updateHeroAppearance({
    required String headOptionId,
    required String skinToneId,
    required String bodyProportionId,
    required String facialHairId,
  }) {
    return _enqueueMutation(() async {
      if (!_save.hasHero) return false;
      if (_save.headOptionId == headOptionId &&
          _save.skinToneId == skinToneId &&
          _save.bodyProportionId == bodyProportionId &&
          _save.facialHairId == facialHairId) {
        return true;
      }

      _save = _save.copyWith(
        headOptionId: headOptionId,
        skinToneId: skinToneId,
        bodyProportionId: bodyProportionId,
        facialHairId: facialHairId,
      );
      notifyListeners();
      await _writeStorage(_save);
      return true;
    });
  }

  int get unlockedThrough {
    var unlocked = 1;
    while (unlocked < 32 &&
        _save.completedMatches.contains(_matchKey(unlocked))) {
      unlocked++;
    }
    return unlocked;
  }

  Encounter get nextEncounter => getEncounter(unlockedThrough.clamp(1, 32));

  bool isEncounterUnlocked(int id) =>
      id <= unlockedThrough || _save.completedMatches.contains(_matchKey(id));

  void _setupEncounterBattle(int id, int? seed) {
    if (id < 1 || id > 32 || !isEncounterUnlocked(id)) {
      throw StateError('Bu düello henüz açılmadı.');
    }
    activeEncounter = getEncounter(id);
    activeContract = null;
    battle = BattleEngine(
      save: _save,
      encounter: activeEncounter!,
      seed: seed ?? DateTime.now().microsecondsSinceEpoch,
    );
    _save = _buildBattleCheckpointSave(mode: 'encounter', encounterId: id);
  }

  Future<void> startEncounter(int id, {int? seed}) {
    if (_pendingMutations == 0) {
      _setupEncounterBattle(id, seed);
      final candidate = _save;
      notifyListeners();
      return _enqueueMutation(() async {
        try {
          await _writeStorage(candidate);
        } catch (_) {}
      });
    }
    return _enqueueMutation(() async {
      _setupEncounterBattle(id, seed);
      final candidate = _save;
      try {
        await _writeStorage(candidate);
      } catch (_) {}
      notifyListeners();
    });
  }

  void _setupContractBattle(String contractId, int? seed) {
    final contract = contracts.firstWhere((entry) => entry.id == contractId);
    if (!isEncounterUnlocked(contract.targetId)) {
      throw StateError('Sözleşmenin hedef düellosu henüz açılmadı.');
    }
    activeContract = contract;
    activeEncounter = getEncounter(contract.targetId);
    battle = BattleEngine(
      save: _save,
      encounter: activeEncounter!,
      seed: seed ?? DateTime.now().microsecondsSinceEpoch,
    );
    _save = _buildBattleCheckpointSave(
      mode: 'contract',
      contractId: contractId,
    );
  }

  Future<void> startContract(String contractId, {int? seed}) {
    if (_pendingMutations == 0) {
      _setupContractBattle(contractId, seed);
      final candidate = _save;
      notifyListeners();
      return _enqueueMutation(() async {
        try {
          await _writeStorage(candidate);
        } catch (_) {}
      });
    }
    return _enqueueMutation(() async {
      _setupContractBattle(contractId, seed);
      final candidate = _save;
      try {
        await _writeStorage(candidate);
      } catch (_) {}
      notifyListeners();
    });
  }

  void _setupChampionsRoadBattle(int stage, int? seed) {
    if (!campaignComplete) {
      throw StateError('Şampiyonlar Yolu finalden sonra açılır.');
    }
    if (stage < 1 || stage > 8) throw RangeError.range(stage, 1, 8);
    if (stage > _save.championsRunBest + 1) {
      throw StateError('Önceki ustalık sınamasını tamamla.');
    }
    final built = _buildChampionsRoadEncounter(stage);
    activeEncounter = built.encounter;
    activeContract = null;
    battle = BattleEngine(
      save: _save,
      encounter: activeEncounter!,
      seed: seed ?? DateTime.now().microsecondsSinceEpoch,
      opponentOverride: built.mirror,
    );
    _save = _buildBattleCheckpointSave(mode: 'championsRoad', stage: stage);
  }

  Future<void> startChampionsRoad(int stage, {int? seed}) {
    if (_pendingMutations == 0) {
      _setupChampionsRoadBattle(stage, seed);
      final candidate = _save;
      notifyListeners();
      return _enqueueMutation(() async {
        try {
          await _writeStorage(candidate);
        } catch (_) {}
      });
    }
    return _enqueueMutation(() async {
      _setupChampionsRoadBattle(stage, seed);
      final candidate = _save;
      try {
        await _writeStorage(candidate);
      } catch (_) {}
      notifyListeners();
    });
  }

  ({Encounter encounter, Combatant? mirror}) _buildChampionsRoadEncounter(
    int stage, {
    GameSave? save,
  }) {
    final runSave = save ?? _save;
    final variants = <int>[6, 14, 8, 16, 22, 24, 30, 32];
    final original = getEncounter(variants[stage - 1]);
    final mirror = stage == 8 ? Combatant.mirror(runSave) : null;
    final mirroredStats = mirror?.stats;
    final variant = Encounter(
      id: 32 + stage,
      name: mirror == null
          ? '${original.name} · Ustalık Sınaması'
          : 'Ayna Dövüşçü',
      arenaId: original.arenaId,
      chapter: original.chapter,
      level: 20,
      kind: EncounterKind.postgame,
      archetype: mirror == null ? original.archetype : _mirrorArchetype(mirror),
      gold: 0,
      xp: 0,
      might: mirroredStats?.might ?? original.might + 2,
      agility: mirroredStats?.agility ?? original.agility + 2,
      precision: mirroredStats?.precision ?? original.effectivePrecision + 2,
      vitality: mirroredStats?.vitality ?? original.vitality + 2,
      guard: mirroredStats?.guard ?? original.guard + 1,
      stamina: mirroredStats?.stamina ?? original.stamina + 1,
      arcana: mirroredStats?.arcana ?? original.arcana + 2,
      weaponPower: mirror?.weaponPower ?? original.weaponPower + 3,
      weaponFamily: mirror?.family ?? original.weaponFamily,
      phaseCount: mirror == null ? original.phaseCount : 2,
      phaseRecoveryFraction: mirror == null
          ? null
          : GameBalance.mirrorPhaseRecoveryFraction,
      hazard: original.hazard,
    );
    return (encounter: variant, mirror: mirror);
  }

  GameSave _buildBattleCheckpointSave({
    required String mode,
    int? encounterId,
    String? contractId,
    int? stage,
  }) {
    final engine = battle;
    if (engine == null) return _save;
    return _save.copyWith(
      battleCheckpoint: {
        'version': 1,
        'mode': mode,
        if (encounterId != null) 'encounterId': encounterId,
        if (contractId != null) 'contractId': contractId,
        if (stage != null) 'stage': stage,
        'battleSave': engine.save
            .copyWith(clearBattleCheckpoint: true)
            .toJson(),
        'engine': engine.toCheckpointJson(),
      },
    );
  }

  Future<void> persistActiveBattleCheckpoint() {
    if (battle == null || activeEncounter == null || battle!.snapshot.done) {
      return Future.value();
    }
    return _enqueueMutation(() async {
      if (battle == null || activeEncounter == null || battle!.snapshot.done) {
        return;
      }
      final checkpoint = _save.battleCheckpoint;
      if (checkpoint == null) return;
      final updated = Map<String, dynamic>.from(checkpoint);
      updated['engine'] = battle!.toCheckpointJson();
      final candidate = _save.copyWith(battleCheckpoint: updated);
      _save = candidate;
      try {
        await _writeStorage(candidate);
      } catch (_) {}
    });
  }

  String _mirrorArchetype(Combatant mirror) {
    if (mirror.family == WeaponFamily.bow) return 'menzilci';
    if (mirror.stats.arcana >= mirror.stats.might &&
        mirror.stats.arcana >= mirror.stats.precision) {
      return 'büyücü';
    }
    return switch (mirror.family) {
      WeaponFamily.shortSword =>
        mirror.stats.agility >= mirror.stats.might ? 'çevik' : 'vurucu',
      WeaponFamily.maul => 'ağır vurucu',
      WeaponFamily.spear => 'mızrakçı',
      WeaponFamily.bow => 'menzilci',
    };
  }

  String? performAction(BattleAction action) {
    final engine = battle;
    if (engine == null) return 'Aktif düello yok.';
    final error = engine.perform(action);
    if (error == null) {
      final previousCheckpoint = _save.battleCheckpoint;
      if (previousCheckpoint != null) {
        final candidate = _save.copyWith(
          battleCheckpoint: {
            ...previousCheckpoint,
            'engine': engine.toCheckpointJson(),
          },
        );
        _save = candidate;
        _enqueueMutation(() async {
          if (_save.battleCheckpoint != null && battle == engine) {
            try {
              await _writeStorage(candidate);
            } catch (_) {}
          }
        });
      }
      notifyListeners();
    }
    return error;
  }

  Future<BattleResolution?> resolveBattle() {
    final engine = battle;
    final encounter = activeEncounter;
    if (engine == null || encounter == null || !engine.snapshot.done) {
      return Future.value(null);
    }
    if (identical(engine, _lastResolvedBattle)) {
      return Future.value(_lastBattleResolution);
    }
    return _enqueueMutation(() async {
      if (identical(engine, _lastResolvedBattle)) {
        return _lastBattleResolution;
      }
      final result = BattleResolution(
        won: engine.snapshot.playerWon,
        playerHealth: engine.player.health,
        turns: engine.metrics.turn,
        metrics: engine.metrics,
        audienceReport: evaluateAudienceReport(encounter, engine.metrics),
      );
      var next = _save;
      if (engine.metrics.salveUsed) {
        next = next.copyWith(
          healingSalves: (next.healingSalves - 1).clamp(0, 99),
        );
      }
      if (engine.metrics.tonicUsed) {
        next = next.copyWith(
          effortTonics: (next.effortTonics - 1).clamp(0, 99),
        );
      }
      final encounterKey = encounter.key;
      final contract = activeContract;
      if (result.won &&
          contract == null &&
          encounter.id >= 1 &&
          encounter.id <= 32 &&
          encounter.kind != EncounterKind.postgame) {
        final previousScore = next.audienceBestScores[encounterKey] ?? 0;
        final bestScore = result.audienceReport.score > previousScore
            ? result.audienceReport.score
            : previousScore;
        next = next.copyWith(
          audienceBestScores: {
            ...next.audienceBestScores,
            encounterKey: bestScore,
          },
        );
      }
      if (result.won && contract != null) {
        if (!_save.completedContracts.contains(contract.id) &&
            _contractSucceeded(contract, result, engine)) {
          next = next.copyWith(
            completedContracts: {...next.completedContracts, contract.id},
            gold: next.gold + contract.reward,
          );
        }
      } else if (result.won) {
        final isFirstClear = !_save.completedMatches.contains(encounterKey);
        if (isFirstClear && encounter.kind != EncounterKind.postgame) {
          final previousSupport = _save.lossSupportPaid.contains(encounterKey)
              ? GameBalance.firstLossGold(encounter.gold)
              : 0;
          final goldAward = encounter.gold - previousSupport;
          next = next.copyWith(
            completedMatches: {...next.completedMatches, encounterKey},
            gold: next.gold + goldAward,
            xp: next.xp + encounter.xp,
          );
          next = _applyLevelUps(next);
          if (encounter.isChampion) {
            next = next.copyWith(
              rebirthCredits: next.rebirthCredits + 1,
              storyBeat: encounter.chapter,
            );
          }
          if (encounter.id == 32) next = next.copyWith(storyBeat: 5);
        } else if (encounter.kind == EncounterKind.postgame) {
          final stage = encounter.id - 32;
          next = next.copyWith(
            completedMatches: {...next.completedMatches, encounterKey},
            championsRunBest: stage > next.championsRunBest
                ? stage
                : next.championsRunBest,
          );
        }
      } else if (contract == null &&
          encounter.kind != EncounterKind.postgame &&
          !_save.completedMatches.contains(encounterKey) &&
          !_save.lossSupportPaid.contains(encounterKey)) {
        final support = GameBalance.firstLossGold(encounter.gold);
        next = next.copyWith(
          gold: next.gold + support,
          lossSupportPaid: {...next.lossSupportPaid, encounterKey},
        );
      }
      final candidate = next.copyWith(clearBattleCheckpoint: true);
      _save = candidate;
      _lastResolvedBattle = engine;
      _lastBattleResolution = result;
      notifyListeners();
      await _writeStorage(_save);
      return result;
    });
  }

  Future<bool> chooseIntermissionReward(
    String decisionId, {
    required IntermissionReward reward,
    Stat? stat,
  }) {
    return _enqueueMutation(() async {
      IntermissionDecision? decision;
      for (final entry in intermissionDecisions) {
        if (entry.id == decisionId) {
          decision = entry;
          break;
        }
      }
      if (decision == null ||
          !_save.completedMatches.contains(decision.encounterKey) ||
          _save.intermissionChoices.containsKey(decision.id)) {
        return false;
      }

      late final GameSave updated;
      late final String recordedChoice;
      if (reward == IntermissionReward.training) {
        if (stat == null || _save.stats[stat] >= 20) return false;
        updated = _save.copyWith(
          stats: _save.stats.withStat(stat, _save.stats[stat] + 1),
        );
        recordedChoice = 'training:${stat.name}';
      } else {
        if (stat != null) return false;
        updated = _save.copyWith(gold: _save.gold + decision.sponsorshipGold);
        recordedChoice = 'sponsorship';
      }

      _save = updated.copyWith(
        intermissionChoices: {
          ..._save.intermissionChoices,
          decision.id: recordedChoice,
        },
      );
      notifyListeners();
      await _writeStorage(_save);
      return true;
    });
  }

  bool _contractSucceeded(
    Contract contract,
    BattleResolution result,
    BattleEngine engine,
  ) {
    final m = result.metrics;
    return switch (contract.rule) {
      ContractRule.noStatus => !m.receivedStatus,
      ContractRule.shortSword =>
        _itemFamily(_save.weaponId) == WeaponFamily.shortSword,
      ContractRule.maxThreeGuards => m.playerGuards <= 3,
      ContractRule.noHazardDamage => m.hazardDamageTaken == 0,
      ContractRule.noBleed => !m.receivedBleed,
      ContractRule.sweepOrSpell => m.usedSweepOrSpell,
      ContractRule.applyStatus => m.appliedStatusWithSpell,
      ContractRule.noRangePenalty => m.rangePenaltyAttacks == 0,
      ContractRule.guardTwoSpells => m.spellGuards >= 2,
      ContractRule.finishWithinEightTurns => m.turn <= 8,
      ContractRule.noRangeChange => m.rangeChanges == 0,
      ContractRule.finishAboveHalfHealth =>
        result.playerHealth >= engine.player.maxHealth * .5,
      ContractRule.statusEachPhase => m.statusPhases.length >= 2,
      ContractRule.selectedWeapon =>
        _itemFamily(_save.weaponId) == engine.player.family,
    };
  }

  WeaponFamily? _itemFamily(String? id) {
    for (final item in shopItems) {
      if (item.id == id) return item.family;
    }
    return id == null ? WeaponFamily.shortSword : null;
  }

  GameSave _applyLevelUps(GameSave source) {
    var updated = source;
    while (updated.level < 20 &&
        updated.xp >= _xpThreshold(updated.level + 1)) {
      updated = updated.copyWith(
        level: updated.level + 1,
        unspentStatPoints: updated.unspentStatPoints + 2,
      );
      if ([3, 6, 9, 12, 15, 18, 20].contains(updated.level)) {
        updated = updated.copyWith(
          unspentMasteryPoints: updated.unspentMasteryPoints + 1,
        );
      }
    }
    return updated;
  }

  int _xpThreshold(int targetLevel) => GameBalance.xpThreshold(targetLevel);

  Future<bool> spendStat(Stat stat) {
    return _enqueueMutation(() async {
      if (_save.unspentStatPoints <= 0 || _save.stats[stat] >= 20) return false;
      _save = _save.copyWith(
        stats: _save.stats.withStat(stat, _save.stats[stat] + 1),
        unspentStatPoints: _save.unspentStatPoints - 1,
      );
      notifyListeners();
      await _writeStorage(_save);
      return true;
    });
  }

  Future<bool> redistributeStats() {
    return _enqueueMutation(() async {
      if (_save.rebirthCredits <= 0) return false;
      final spent = Stat.values.fold<int>(
        0,
        (sum, stat) => sum + (_save.stats[stat] - 2),
      );
      const resetStats = Stats();
      final equipped = Map<String, String>.from(_save.equippedItems);
      equipped.removeWhere((_, itemId) {
        final item = shopItems.where((entry) => entry.id == itemId).firstOrNull;
        return item != null && !_meetsMinimumAttribute(item, resetStats);
      });
      _save = _save.copyWith(
        stats: const Stats(),
        equippedItems: equipped,
        unspentStatPoints: _save.unspentStatPoints + spent,
        rebirthCredits: _save.rebirthCredits - 1,
      );
      notifyListeners();
      await _writeStorage(_save);
      return true;
    });
  }

  Future<bool> unlockMastery(String id) {
    return _enqueueMutation(() async {
      const tiers = {
        'front_1': 1,
        'front_2': 2,
        'front_3': 3,
        'duel_1': 1,
        'duel_2': 2,
        'duel_3': 3,
        'seal_1': 1,
        'seal_2': 2,
        'seal_3': 3,
      };
      if (!tiers.containsKey(id) ||
          _save.masteries.contains(id) ||
          _save.unspentMasteryPoints <= 0) {
        return false;
      }
      final tier = tiers[id]!;
      if (tier > 1) {
        final previous = '${id.substring(0, id.length - 1)}${tier - 1}';
        if (!_save.masteries.contains(previous)) return false;
      }
      _save = _save.copyWith(
        masteries: {..._save.masteries, id},
        unspentMasteryPoints: _save.unspentMasteryPoints - 1,
      );
      notifyListeners();
      await _writeStorage(_save);
      return true;
    });
  }

  bool _meetsMinimumAttribute(ShopItem item, [Stats? stats]) {
    final requiredAttribute = item.minAttribute;
    return requiredAttribute == null ||
        (stats ?? _save.stats)[requiredAttribute] >= item.minAttributeValue;
  }

  String _minimumAttributeError(ShopItem item) {
    final attribute = item.minAttribute!;
    final name = switch (attribute) {
      Stat.might => 'Kuvvet',
      Stat.agility => 'Çeviklik',
      Stat.precision => 'İsabet',
      Stat.arcana => 'Büyü',
      Stat.vitality => 'Canlılık',
      Stat.guard => 'Gard',
      Stat.stamina => 'Dayanıklılık',
    };
    return 'Bu eşya için $name ${item.minAttributeValue} gerekli.';
  }

  Future<String?> buyItem(ShopItem item) {
    return _enqueueMutation(() async {
      if (!_save.hasHero) return 'Önce dövüşçünü oluştur.';
      if (_save.level < item.level) {
        return 'Bu eşya için seviye ${item.level} gerekli.';
      }
      if (item.act > unlockedAct) return 'Bu katalog henüz açılmadı.';
      if (_save.ownedItems.contains(item.id)) {
        return 'Bu eşya zaten envanterinde.';
      }
      if (!_meetsMinimumAttribute(item)) return _minimumAttributeError(item);
      if (_save.gold < item.price) return 'Yeterli Sikke yok.';

      var candidate = _save.copyWith(
        gold: _save.gold - item.price,
        ownedItems: {..._save.ownedItems, item.id},
      );
      if (candidate.equippedItems[item.category] == null) {
        candidate = candidate.copyWith(
          equippedItems: {...candidate.equippedItems, item.category: item.id},
        );
      }
      try {
        await _writeStorage(candidate);
      } catch (error) {
        return lastError ?? 'Kayıt yazılamadı: $error';
      }
      _save = candidate;
      notifyListeners();
      return null;
    });
  }

  Future<String?> sellItem(String itemId) {
    return _enqueueMutation(() async {
      final item = shopItems.where((entry) => entry.id == itemId).firstOrNull;
      if (item == null) return 'Bu eşya dükkân kataloğunda bulunamadı.';
      if (!_save.ownedItems.contains(itemId)) {
        return 'Eşya envanterinde değil.';
      }
      if (_save.equippedItems[item.category] == itemId) {
        return 'Kuşanılmış eşya satılamaz.';
      }

      final resaleValue = item.price ~/ 2;
      final newBalance = _save.gold + resaleValue;
      final candidate = _save.copyWith(
        gold: newBalance < 0 ? 0 : newBalance,
        ownedItems: {..._save.ownedItems}..remove(itemId),
      );
      try {
        await _writeStorage(candidate);
      } catch (error) {
        return lastError ?? 'Kayıt yazılamadı: $error';
      }
      _save = candidate;
      notifyListeners();
      return null;
    });
  }

  Future<String?> buySpell(BattleAction action) {
    return _enqueueMutation(() async {
      spells.firstWhere((entry) => entry.action == action);
      final id = 'spell_${action.name}';
      if (_save.ownedItems.contains(id)) return 'Bu yetenek zaten öğrenildi.';
      final chapter =
          action == BattleAction.emberSpear || action == BattleAction.ashBurst
          ? 1
          : action == BattleAction.tideWard ||
                action == BattleAction.saltCleanse
          ? 2
          : 3;
      final price = GameBalance.spellPrices[chapter - 1];
      if (_save.gold < price) return 'Yeterli Sikke yok.';
      if (_save.level <
          (chapter == 1
              ? 1
              : chapter == 2
              ? 7
              : 13)) {
        return 'Devre katalogu henüz açılmadı.';
      }
      _save = _save.copyWith(
        gold: _save.gold - price,
        ownedItems: {..._save.ownedItems, id},
      );
      notifyListeners();
      await _writeStorage(_save);
      return null;
    });
  }

  Future<String?> buyConsumable({required bool salve}) {
    return _enqueueMutation(() async {
      final price = getConsumablePrice(unlockedAct, salve: salve);
      final inventory = salve ? _save.healingSalves : _save.effortTonics;
      if (inventory >= 3) {
        return 'Bu sarf eşyasından en fazla 3 tane taşıyabilirsin.';
      }
      if (_save.gold < price) return 'Yeterli Sikke yok.';
      _save = _save.copyWith(
        gold: _save.gold - price,
        healingSalves: salve ? _save.healingSalves + 1 : _save.healingSalves,
        effortTonics: salve ? _save.effortTonics : _save.effortTonics + 1,
      );
      notifyListeners();
      await _writeStorage(_save);
      return null;
    });
  }

  Future<String?> equip(String itemId) {
    return _enqueueMutation(() async {
      if (!_save.ownedItems.contains(itemId)) return 'Eşya envanterinde değil.';
      final item = shopItems.where((entry) => entry.id == itemId).firstOrNull;
      if (item == null) return 'Bu eşya dükkân kataloğunda bulunamadı.';
      if (!_meetsMinimumAttribute(item)) return _minimumAttributeError(item);
      _save = _save.copyWith(
        equippedItems: {..._save.equippedItems, item.category: itemId},
      );
      notifyListeners();
      await _writeStorage(_save);
      return null;
    });
  }

  int get unlockedAct =>
      campaignComplete ? 4 : ((unlockedThrough - 1) ~/ 8 + 1).clamp(1, 4);

  Future<void> updateSettings({
    bool? sfxEnabled,
    double? musicVolume,
    double? sfxVolume,
    bool? vibrationEnabled,
    bool? reducedMotion,
    String? language,
  }) {
    return _enqueueMutation(() async {
      _save = _save.copyWith(
        sfxEnabled: sfxEnabled,
        musicVolume: musicVolume?.clamp(0.0, 1.0).toDouble(),
        sfxVolume: sfxVolume?.clamp(0.0, 1.0).toDouble(),
        vibrationEnabled: vibrationEnabled,
        reducedMotion: reducedMotion,
        language: language,
      );
      notifyListeners();
      await _writeStorage(_save);
    });
  }

  Future<void> resetCampaign() {
    return _enqueueMutation(() async {
      _save = const GameSave();
      battle = null;
      activeEncounter = null;
      activeContract = null;
      notifyListeners();
      await _clearStorage();
    });
  }

  String _matchKey(int id) => 'M${id.toString().padLeft(2, '0')}';
}
