import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _strongStats = Stats(
  might: 20,
  agility: 20,
  vitality: 20,
  guard: 20,
  stamina: 20,
  arcana: 20,
);

class _FailOnceSaveStorage extends MemorySaveStorage {
  var failuresRemaining = 1;

  @override
  Future<void> write(GameSave save) async {
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('simulated storage failure');
    }
    await super.write(save);
  }
}

String _matchKey(int id) => 'M${id.toString().padLeft(2, '0')}';

GameSave _completedCampaignSave({int gold = 1000}) => GameSave(
  hasHero: true,
  level: 20,
  stats: _strongStats,
  gold: gold,
  completedMatches: Set<String>.from(
    List.generate(32, (index) => _matchKey(index + 1)),
  ),
);

void _winBattle(BattleEngine engine, {Contract? contract}) {
  for (var turn = 0; turn < 80 && !engine.snapshot.done; turn++) {
    engine.player.health = engine.player.maxHealth;
    engine.player.effort = engine.player.maxEffort;
    engine.player.mana = engine.player.maxMana;
    engine.opponent.health = 1;
    final action = switch (contract?.rule) {
      ContractRule.noHazardDamage when engine.snapshot.telegraphedHazard =>
        BattleAction.guard,
      ContractRule.noRangePenalty when engine.distance == RangeBand.close =>
        BattleAction.openDistance,
      _ => BattleAction.quick,
    };
    engine.perform(action);
  }
  expect(engine.snapshot.done, isTrue);
  expect(engine.snapshot.playerWon, isTrue);
}

void _contractAction(BattleEngine engine, BattleAction action) {
  engine.player.health = engine.player.maxHealth;
  engine.player.effort = engine.player.maxEffort;
  engine.player.mana = engine.player.maxMana;
  expect(engine.perform(action), isNull, reason: 'action ${action.name}');
}

void _earnContractCondition(Contract contract, BattleEngine engine) {
  switch (contract.rule) {
    case ContractRule.sweepOrSpell:
      engine.opponent.health = engine.opponent.maxHealth;
      _contractAction(engine, BattleAction.sweep);
    case ContractRule.applyStatus:
      for (
        var attempt = 0;
        attempt < 8 && !engine.metrics.appliedStatusWithSpell;
        attempt++
      ) {
        if (!engine.snapshot.done) {
          engine.opponent.health = engine.opponent.maxHealth;
          _contractAction(engine, BattleAction.ashBurst);
        }
      }
    case ContractRule.noRangePenalty:
      if (engine.distance == RangeBand.close) {
        _contractAction(engine, BattleAction.openDistance);
      }
    case ContractRule.guardTwoSpells:
      for (
        var attempt = 0;
        attempt < 100 && engine.metrics.spellGuards < 2;
        attempt++
      ) {
        if (engine.snapshot.done) break;
        engine.opponent.health = engine.opponent.maxHealth;
        _contractAction(engine, BattleAction.guard);
      }
    case ContractRule.noHazardDamage:
      while (engine.metrics.turn < 2 && !engine.snapshot.done) {
        engine.opponent.health = engine.opponent.maxHealth;
        _contractAction(engine, BattleAction.quick);
      }
      if (engine.snapshot.telegraphedHazard && !engine.snapshot.done) {
        engine.opponent.health = engine.opponent.maxHealth;
        _contractAction(engine, BattleAction.guard);
      }
    case ContractRule.statusEachPhase:
      for (
        var attempt = 0;
        attempt < 8 && !engine.metrics.statusPhases.contains(1);
        attempt++
      ) {
        engine.opponent.health = engine.opponent.maxHealth ~/ 2 + 1;
        _contractAction(engine, BattleAction.ashBurst);
      }
      for (
        var attempt = 0;
        attempt < 8 && !engine.metrics.statusPhases.contains(2);
        attempt++
      ) {
        if (engine.snapshot.done) break;
        engine.opponent.health = engine.opponent.maxHealth;
        _contractAction(engine, BattleAction.ashBurst);
      }
    case ContractRule.noStatus ||
        ContractRule.shortSword ||
        ContractRule.maxThreeGuards ||
        ContractRule.noBleed ||
        ContractRule.finishWithinEightTurns ||
        ContractRule.noRangeChange ||
        ContractRule.finishAboveHalfHealth ||
        ContractRule.selectedWeapon:
      break;
  }
}

void main() {
  group('campaign content and progression', () {
    test('campaign and postgame opponents resolve to their intended art', () {
      for (var id = 1; id <= 32; id++) {
        if (id % 8 == 0) {
          expect(characterArtForEncounter(id), isNotNull, reason: 'match $id');
          expect(rivalAtlasForEncounter(id), isNull, reason: 'match $id');
        } else {
          final art = rivalAtlasForEncounter(id);
          expect(art, isNotNull, reason: 'match $id');
          expect(art!.asset, contains('devre${(id - 1) ~/ 8 + 1}_atlas.webp'));
          expect(art.index, (id - 1) % 8);
        }
      }
      for (var stage = 1; stage <= 8; stage++) {
        final encounterId = 32 + stage;
        final portrait = characterArtForEncounter(encounterId);
        final atlas = rivalAtlasForEncounter(encounterId);
        expect(portrait ?? atlas?.asset, isNotNull, reason: 'stage $stage');

        if (encounterId == 40) {
          expect(portrait, 'assets/art/characters/ayna_dovuscu.webp');
          expect(atlas, isNull);
          continue;
        }

        expect(portrait, isNull, reason: 'stage $stage uses its own rival art');
        expect(
          atlas?.asset,
          'assets/art/rivals/champions_road_atlas.png',
          reason: 'stage $stage has a dedicated postgame atlas',
        );
        expect(atlas?.index, stage - 1, reason: 'stage $stage frame');
      }
      expect(
        characterArtForEncounter(40),
        'assets/art/characters/ayna_dovuscu.webp',
      );
      expect(
        characterArtForEncounter(32),
        'assets/art/characters/cember_ustasi.webp',
      );
    });

    test('all main encounters have valid ordered chapter and arena links', () {
      expect(mainEncounters, hasLength(32));
      expect(
        mainEncounters.map((encounter) => encounter.id),
        List<int>.generate(32, (index) => index + 1),
      );

      for (var chapter = 1; chapter <= 4; chapter++) {
        final encounters = mainEncounters
            .where((encounter) => encounter.chapter == chapter)
            .toList();
        expect(encounters, hasLength(8));
        expect(
          encounters
              .take(3)
              .every((encounter) => encounter.kind == EncounterKind.regular),
          isTrue,
        );
        expect(encounters[3].kind, EncounterKind.intermediateFinal);
        expect(encounters[4].kind, EncounterKind.regular);
        expect(
          encounters
              .skip(5)
              .take(2)
              .every((encounter) => encounter.kind == EncounterKind.elite),
          isTrue,
        );
        expect(encounters.last.kind, EncounterKind.champion);
      }
      expect(
        mainEncounters
            .where(
              (encounter) => encounter.kind == EncounterKind.intermediateFinal,
            )
            .map((encounter) => encounter.id),
        {4, 12, 20, 28},
      );

      final arenaIds = arenas.map((arena) => arena.id).toSet();
      expect(arenaIds, hasLength(6));
      for (final encounter in mainEncounters) {
        expect(arenaIds, contains(encounter.arenaId));
        expect(encounter.gold, greaterThan(0));
        expect(encounter.xp, greaterThan(0));
      }
    });

    test(
      'every optional contract has a unique id and valid main-match target',
      () {
        expect(contracts, hasLength(16));
        expect(contracts.map((contract) => contract.id).toSet(), hasLength(16));
        expect(
          contracts.map((contract) => contract.rule).toSet(),
          containsAll(ContractRule.values),
        );
        for (final contract in contracts) {
          expect(contract.targetId, inInclusiveRange(1, 32));
          expect(getEncounter(contract.targetId).id, contract.targetId);
          expect(contract.reward, greaterThan(0));
        }
      },
    );

    test(
      'new save completes all 32 ordered matches, then unlocks eight stages',
      () async {
        final storage = MemorySaveStorage();
        var game = GameController(storage: storage);
        await game.initialize();
        await game.createHero(
          name: 'Kıyı',
          stats: const Stats(
            might: 4,
            agility: 4,
            vitality: 4,
            guard: 2,
            stamina: 2,
            arcana: 2,
          ),
        );

        for (var id = 1; id <= 32; id++) {
          await game.startEncounter(id, seed: 2000 + id);
          expect(game.activeEncounter?.id, id);
          if (id < 32) {
            await expectLater(
              () => game.startEncounter(id + 1),
              throwsA(isA<StateError>()),
            );
          }
          _winBattle(game.battle!);
          await game.resolveBattle();

          expect(game.save.completedMatches, contains(_matchKey(id)));
          expect(game.save.gold, greaterThanOrEqualTo(0));
          expect(game.campaignComplete, id == 32);
          expect(game.unlockedThrough, id < 32 ? id + 1 : 32);

          if (id == 8) {
            game.dispose();
            game = GameController(storage: storage);
            await game.initialize();
            expect(game.unlockedThrough, 9);
            expect(game.save.completedMatches, contains('M08'));
          }
        }

        await game.startChampionsRoad(1, seed: 9);
        await expectLater(
          () => game.startChampionsRoad(2, seed: 9),
          throwsA(isA<StateError>()),
        );

        final campaignGold = game.save.gold;
        final campaignXp = game.save.xp;
        for (var stage = 1; stage <= 8; stage++) {
          await game.startChampionsRoad(stage, seed: 3000 + stage);
          final variant = game.activeEncounter!;
          expect(variant.id, 32 + stage);
          expect(variant.kind, EncounterKind.postgame);
          expect(variant.gold, 0);
          expect(variant.xp, 0);
          _winBattle(game.battle!);
          await game.resolveBattle();
          expect(game.save.completedMatches, contains(_matchKey(32 + stage)));
          expect(game.save.championsRunBest, stage);
          expect(game.save.gold, campaignGold);
          expect(game.save.xp, campaignXp);
        }
        game.dispose();
      },
    );

    test(
      'final Champions Road duel mirrors the equipped player build',
      () async {
        final storage = MemorySaveStorage()
          ..value = _completedCampaignSave().copyWith(
            championsRunBest: 7,
            stats: const Stats(
              might: 5,
              agility: 7,
              precision: 18,
              vitality: 10,
              guard: 8,
              stamina: 12,
              arcana: 9,
            ),
            equippedItems: const {
              'weapon': 'sword_4',
              'bow': 'bow_4',
              'head': 'helm_4',
              'body': 'coat_4',
              'boots': 'boots_4',
              'talisman': 'charm_4',
            },
            masteries: const {'duel_3'},
          );
        final game = GameController(storage: storage);
        await game.initialize();

        await game.startChampionsRoad(8, seed: 90210);
        final firstRun = game.battle!;
        final player = firstRun.player;
        final mirror = firstRun.opponent;
        final expected = Stats(
          might: player.stats.might.clamp(2, 20).toInt(),
          agility: player.stats.agility.clamp(2, 20).toInt(),
          precision: player.stats.precision.clamp(2, 20).toInt(),
          vitality: player.stats.vitality.clamp(2, 20).toInt(),
          guard: player.stats.guard.clamp(2, 20).toInt(),
          stamina: player.stats.stamina.clamp(2, 20).toInt(),
          arcana: player.stats.arcana.clamp(2, 20).toInt(),
        );

        expect(game.activeEncounter!.id, 40);
        expect(game.activeEncounter!.name, 'Ayna Dövüşçü');
        expect(game.activeEncounter!.phaseCount, 2);
        expect(mirror.name, 'Ayna Dövüşçü');
        expect(mirror.aiStyle, isTrue);
        expect(mirror.level, 20);
        expect(mirror.stats.might, expected.might);
        expect(mirror.stats.agility, expected.agility);
        expect(mirror.stats.precision, expected.precision);
        expect(mirror.stats.vitality, expected.vitality);
        expect(mirror.stats.guard, expected.guard);
        expect(mirror.stats.stamina, expected.stamina);
        expect(mirror.stats.arcana, expected.arcana);
        expect(mirror.family, WeaponFamily.bow);
        expect(mirror.weaponPower, player.bowPower);
        expect(mirror.bowPower, player.bowPower);
        expect(mirror.ammo, player.ammo);
        expect(mirror.armor, player.armor);
        expect(mirror.masteries, {'duel_3'});
        expect(game.activeEncounter!.weaponFamily, mirror.family);
        expect(game.activeEncounter!.weaponPower, mirror.weaponPower);

        final openingIntent = firstRun.snapshot.opponentIntent;
        await game.startChampionsRoad(8, seed: 90210);
        final replay = game.battle!;
        expect(replay.snapshot.opponentIntent, openingIntent);
        firstRun.perform(BattleAction.guard);
        replay.perform(BattleAction.guard);
        expect(
          replay.snapshot.opponentIntent,
          firstRun.snapshot.opponentIntent,
        );
        expect(replay.opponent.health, firstRun.opponent.health);
        expect(replay.opponent.ammo, firstRun.opponent.ammo);
        expect(replay.player.health, firstRun.player.health);
        game.dispose();
      },
    );

    test(
      'all contract success rules award once and a failed rule gives no reward',
      () async {
        for (final contract in contracts) {
          final weaponId = contract.rule == ContractRule.noRangePenalty
              ? 'spear_4'
              : 'sword_4';
          final storage = MemorySaveStorage()
            ..value = _completedCampaignSave().copyWith(
              ownedItems: {weaponId, 'spell_ashBurst'},
              equippedItems: {'weapon': weaponId},
            );
          final game = GameController(storage: storage);
          await game.initialize();
          final initialGold = game.save.gold;
          final initialXp = game.save.xp;
          await game.startContract(contract.id, seed: 4100 + contract.targetId);
          final engine = game.battle!;
          _earnContractCondition(contract, engine);
          _winBattle(engine, contract: contract);
          await game.resolveBattle();

          expect(game.save.completedContracts, contains(contract.id));
          expect(game.save.gold, initialGold + contract.reward);
          expect(game.save.xp, initialXp);
          expect(game.save.completedMatches, hasLength(32));
          expect(game.save.audienceBestScores, isEmpty);
          game.dispose();
        }

        final storage = MemorySaveStorage()
          ..value = _completedCampaignSave().copyWith(
            ownedItems: {'sword_4'},
            equippedItems: {'weapon': 'sword_4'},
          );
        final game = GameController(storage: storage);
        await game.initialize();
        await game.startContract('C1-C', seed: 5103);
        final failedEngine = game.battle!;
        for (var turn = 0; turn < 4; turn++) {
          failedEngine.player.health = failedEngine.player.maxHealth;
          failedEngine.opponent.health = failedEngine.opponent.maxHealth;
          expect(failedEngine.perform(BattleAction.guard), isNull);
        }
        expect(failedEngine.metrics.playerGuards, 4);
        _winBattle(game.battle!);
        await game.resolveBattle();
        expect(game.save.completedContracts, isNot(contains('C1-C')));
        expect(game.save.gold, 1000);
        game.dispose();
      },
    );
  });

  group('ranged combat and consumables', () {
    test('four bow tiers start with 3/4/5/6 shots and reject dry fire', () {
      for (var tier = 1; tier <= 4; tier++) {
        final id = 'bow_$tier';
        final save = GameSave(
          hasHero: true,
          stats: _strongStats,
          ownedItems: {id},
          equippedItems: {'bow': id},
        );
        final engine = BattleEngine(
          save: save,
          encounter: getEncounter(1),
          seed: 6000 + tier,
        );
        final capacity = tier + 2;
        expect(engine.player.ammo, capacity);
        expect(engine.preview(BattleAction.bow).cost, '6 efor · 1 fişek');
        engine.opponent.health = 1000000;
        engine.player.health = 1000000;

        for (var shot = 1; shot <= capacity; shot++) {
          expect(engine.preview(BattleAction.bow).canUse, isTrue);
          expect(engine.perform(BattleAction.bow), isNull);
          expect(engine.player.ammo, capacity - shot);
        }
        expect(engine.preview(BattleAction.bow).canUse, isFalse);
        expect(engine.perform(BattleAction.bow), isNotNull);
        expect(engine.player.ammo, 0);
      }
    });

    test(
      'purchases enforce level, act, price and consumable inventory limits',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave(hasHero: true, level: 20, gold: 5000);
        final game = GameController(storage: storage);
        await game.initialize();

        final locked = await game.buyItem(
          shopItems.firstWhere((item) => item.id == 'sword_2'),
        );
        expect(locked, isNotNull);
        expect(game.save.gold, 5000);

        final weapon = shopItems.firstWhere((item) => item.id == 'sword_1');
        expect(await game.buyItem(weapon), isNull);
        expect(game.save.gold, 4840);
        expect(game.save.equippedItems['weapon'], 'sword_1');
        expect(await game.buyItem(weapon), isNotNull);
        expect(game.save.gold, 4840);

        for (var count = 0; count < 3; count++) {
          expect(await game.buyConsumable(salve: true), isNull);
        }
        final goldAtCap = game.save.gold;
        expect(await game.buyConsumable(salve: true), isNotNull);
        expect(game.save.healingSalves, 3);
        expect(game.save.gold, goldAtCap);
        expect(await game.buyConsumable(salve: false), isNull);
        expect(game.save.effortTonics, 1);
        game.dispose();

        final poorStorage = MemorySaveStorage()
          ..value = GameSave(hasHero: true, level: 1, gold: 0);
        final poorGame = GameController(storage: poorStorage);
        await poorGame.initialize();
        expect(
          await poorGame.buyItem(
            shopItems.firstWhere((item) => item.id == 'maul_1'),
          ),
          isNotNull,
        );
        expect(poorGame.save.gold, 0);
        poorGame.dispose();
      },
    );

    test(
      'a belt item can be used once per match and only used stock is spent',
      () async {
        final storage = MemorySaveStorage();
        final game = GameController(storage: storage);
        await game.initialize();
        await game.createHero(
          name: 'Ateş',
          stats: const Stats(
            might: 4,
            agility: 4,
            vitality: 4,
            guard: 2,
            stamina: 2,
            arcana: 2,
          ),
        );
        expect(await game.buyConsumable(salve: true), isNull);
        expect(await game.buyConsumable(salve: false), isNull);

        await game.startEncounter(1, seed: 7001);
        final first = game.battle!;
        first.player.health = first.player.maxHealth - 1;
        expect(first.perform(BattleAction.salve), isNull);
        expect(
          first.snapshot.log,
          contains(contains('şifa merhemi kullandı: +1 sağlık')),
        );
        expect(first.metrics.salveUsed, isTrue);
        expect(first.preview(BattleAction.tonic).canUse, isFalse);
        expect(first.perform(BattleAction.tonic), isNotNull);
        _winBattle(first);
        await game.resolveBattle();
        expect(game.save.healingSalves, 0);
        expect(game.save.effortTonics, 1);

        await game.startEncounter(1, seed: 7002);
        final second = game.battle!;
        second.player.effort = 0;
        expect(second.perform(BattleAction.tonic), isNull);
        expect(second.player.effort, 14);
        expect(second.metrics.tonicUsed, isTrue);
        _winBattle(second);
        await game.resolveBattle();
        expect(game.save.effortTonics, 0);
        game.dispose();
      },
    );
  });

  group('offline persistence', () {
    test(
      'a failed schema migration keeps the recovered campaign in memory',
      () async {
        final storage = _FailOnceSaveStorage()
          ..value = const GameSave(
            schemaVersion: 8,
            hasHero: true,
            heroName: 'Kül Muhafızı',
            level: 9,
            gold: 1234,
          );
        final game = GameController(storage: storage);

        await game.initialize();

        expect(game.ready, isTrue);
        expect(game.save.hasHero, isTrue);
        expect(game.save.heroName, 'Kül Muhafızı');
        expect(game.save.level, 9);
        expect(game.save.gold, 1234);
        expect(game.save.schemaVersion, 9);
        expect(game.lastError, contains('Kayıt yazılamadı'));

        await game.updateSettings(reducedMotion: true);

        expect(storage.value?.heroName, 'Kül Muhafızı');
        expect(storage.value?.schemaVersion, 9);
        expect(storage.value?.reducedMotion, isTrue);
        expect(game.lastError, isNull);
        game.dispose();
      },
    );

    test('a failed write does not block later save commits', () async {
      final storage = _FailOnceSaveStorage();
      final game = GameController(storage: storage);
      await game.initialize();

      await expectLater(
        game.createHero(
          name: 'Kıyı',
          stats: const Stats(might: 4, agility: 4, vitality: 4),
        ),
        throwsStateError,
      );
      await game.updateSettings(reducedMotion: true);

      expect(storage.value?.hasHero, isTrue);
      expect(storage.value?.reducedMotion, isTrue);
      expect(game.lastError, isNull);
      game.dispose();
    });

    test('controller reload resumes at the saved next match', () async {
      final storage = MemorySaveStorage();
      final game = GameController(storage: storage);
      await game.initialize();
      await game.createHero(
        name: 'Kıyı',
        stats: const Stats(
          might: 4,
          agility: 4,
          vitality: 4,
          guard: 2,
          stamina: 2,
          arcana: 2,
        ),
      );
      await game.startEncounter(1, seed: 8001);
      _winBattle(game.battle!);
      await game.resolveBattle();
      game.dispose();

      final reloaded = GameController(storage: storage);
      await reloaded.initialize();
      expect(reloaded.save.completedMatches, contains('M01'));
      expect(reloaded.unlockedThrough, 2);
      expect(reloaded.nextEncounter.id, 2);
      reloaded.dispose();
    });

    test('an interrupted encounter restores its full turn state and continues deterministically', () async {
      final storage = MemorySaveStorage();
      final game = GameController(storage: storage);
      await game.initialize();
      await game.createHero(
        name: 'Kıyı',
        stats: const Stats(
          might: 4,
          agility: 4,
          vitality: 4,
          guard: 2,
          stamina: 2,
          arcana: 2,
        ),
      );
      await game.startEncounter(1, seed: 8123);
      expect(game.performAction(BattleAction.guard), isNull);
      await game.persistActiveBattleCheckpoint();

      final uninterrupted = game.battle!;
      final reloaded = GameController(storage: storage);
      await reloaded.initialize();
      final resumed = reloaded.battle!;
      expect(reloaded.restoredBattleFromSave, isTrue);
      expect(reloaded.activeEncounter?.id, 1);
      expect(resumed.metrics.turn, uninterrupted.metrics.turn);
      expect(resumed.player.health, uninterrupted.player.health);
      expect(resumed.player.effort, uninterrupted.player.effort);
      expect(resumed.opponent.health, uninterrupted.opponent.health);
      expect(resumed.snapshot.distance, uninterrupted.snapshot.distance);
      expect(
        resumed.snapshot.opponentIntent,
        uninterrupted.snapshot.opponentIntent,
      );
      expect(
        resumed.snapshot.events.length,
        uninterrupted.snapshot.events.length,
      );

      expect(game.performAction(BattleAction.guard), isNull);
      expect(reloaded.performAction(BattleAction.guard), isNull);
      expect(resumed.metrics.turn, uninterrupted.metrics.turn);
      expect(resumed.player.health, uninterrupted.player.health);
      expect(resumed.opponent.health, uninterrupted.opponent.health);
      expect(resumed.snapshot.distance, uninterrupted.snapshot.distance);
      expect(
        resumed.snapshot.opponentIntent,
        uninterrupted.snapshot.opponentIntent,
      );
      expect(
        resumed.snapshot.events.map((event) => event.type).toList(),
        uninterrupted.snapshot.events.map((event) => event.type).toList(),
      );

      game.dispose();
      reloaded.dispose();
    });

    test(
      'resolving a battle removes its active checkpoint from the save',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave(hasHero: true, stats: _strongStats);
        final game = GameController(storage: storage);
        await game.initialize();
        await game.startEncounter(1, seed: 8124);
        _winBattle(game.battle!);
        expect(game.save.battleCheckpoint, isNotNull);
        await game.resolveBattle();
        expect(game.save.battleCheckpoint, isNull);
        game.dispose();
      },
    );

    test(
      'contract and Champions Road checkpoints restore their context',
      () async {
        final contractStorage = MemorySaveStorage()
          ..value = _completedCampaignSave();
        final contractGame = GameController(storage: contractStorage);
        await contractGame.initialize();
        await contractGame.startContract('C1-A', seed: 8125);
        expect(contractGame.performAction(BattleAction.guard), isNull);
        await contractGame.persistActiveBattleCheckpoint();
        final reloadedContract = GameController(storage: contractStorage);
        await reloadedContract.initialize();
        expect(reloadedContract.activeContract?.id, 'C1-A');
        expect(reloadedContract.activeEncounter?.id, 1);
        expect(reloadedContract.battle?.metrics.turn, 1);
        contractGame.dispose();
        reloadedContract.dispose();

        final roadStorage = MemorySaveStorage()
          ..value = _completedCampaignSave();
        final roadGame = GameController(storage: roadStorage);
        await roadGame.initialize();
        await roadGame.startChampionsRoad(1, seed: 8126);
        expect(roadGame.performAction(BattleAction.guard), isNull);
        await roadGame.persistActiveBattleCheckpoint();
        final reloadedRoad = GameController(storage: roadStorage);
        await reloadedRoad.initialize();
        expect(reloadedRoad.activeContract, isNull);
        expect(reloadedRoad.activeEncounter?.id, 33);
        expect(reloadedRoad.battle?.metrics.turn, 1);
        roadGame.dispose();
        reloadedRoad.dispose();
      },
    );

    test(
      'SharedPreferences storage recovers a corrupt primary from backup',
      () async {
        final previous = GameSave(
          hasHero: true,
          heroName: 'Yedek Dövüşçü',
          level: 5,
          gold: 321,
          stats: _strongStats,
        );
        SharedPreferences.setMockInitialValues({
          'ash_circuit.save.v1': '{not-json',
          'ash_circuit.save.backup.v1': previous.encode(),
        });

        final recovered = await PreferencesSaveStorage().read();
        expect(recovered?.heroName, 'Yedek Dövüşçü');
        expect(recovered?.gold, 321);
        expect(recovered?.level, 5);
      },
    );
  });
}
