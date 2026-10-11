import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/intermission_decisions.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/balance.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

Stats _startingStats() => const Stats(
  might: 4,
  agility: 4,
  vitality: 4,
  guard: 2,
  stamina: 2,
  arcana: 2,
);

void _winFirstEncounter(GameController game) {
  final engine = game.battle!;
  for (var i = 0; i < 40 && !engine.snapshot.done; i++) {
    engine.player.health = engine.player.maxHealth;
    engine.player.effort = engine.player.maxEffort;
    engine.opponent.health = 1;
    engine.perform(BattleAction.quick);
  }
  expect(engine.snapshot.done, isTrue);
  expect(engine.snapshot.playerWon, isTrue);
}

void main() {
  group('audio routing', () {
    test('selects music for menu, chapters, champions and postgame', () {
      expect(
        GameAudioService.musicTrackFor(
          hasHero: false,
          campaignComplete: false,
          chapter: 1,
        ),
        'menu_theme',
      );
      expect(
        GameAudioService.musicTrackFor(
          hasHero: true,
          campaignComplete: false,
          chapter: 3,
        ),
        'chapter_3',
      );
      expect(
        GameAudioService.musicTrackFor(
          hasHero: true,
          campaignComplete: false,
          chapter: 1,
          encounter: getEncounter(8),
        ),
        'champion_1',
      );
      expect(
        GameAudioService.musicTrackFor(
          hasHero: true,
          campaignComplete: true,
          chapter: 4,
        ),
        'champions_road',
      );
    });

    test('maps typed combat events to original sound cues', () {
      BattleEvent event(BattleEventType type, {BattleAction? action}) =>
          BattleEvent(sequence: 0, turn: 1, type: type, action: action);

      expect(
        GameAudioService.sfxForBattleEvent(
          event(BattleEventType.attackStarted, action: BattleAction.heavy),
        ),
        'attack_heavy',
      );
      expect(
        GameAudioService.sfxForBattleEvent(event(BattleEventType.attackHit)),
        'hit',
      );
      expect(
        GameAudioService.sfxForBattleEvent(event(BattleEventType.battleWon)),
        'victory',
      );
    });
  });

  group('content and profile', () {
    test('publishes the complete campaign and catalogue counts', () {
      expect(mainEncounters, hasLength(32));
      expect(contracts, hasLength(16));
      expect(arenas, hasLength(6));
      expect(
        shopItems.where((item) => item.category == 'weapon'),
        hasLength(12),
      );
      expect(shopItems.where((item) => item.category == 'bow'), hasLength(4));
      expect(
        shopItems.where(
          (item) => ['head', 'body', 'boots'].contains(item.category),
        ),
        hasLength(12),
      );
      expect(
        shopItems.where((item) => item.category == 'talisman'),
        hasLength(4),
      );
      expect(spells, hasLength(6));
      expect(contracts.map((contract) => contract.id).toSet(), hasLength(16));
    });

    test(
      'headgear resistance reduces status proc chance and follows the mirror',
      () {
        expect(
          [
            for (var tier = 1; tier <= 4; tier++)
              shopItems
                  .firstWhere((item) => item.id == 'helm_$tier')
                  .statusResistance,
          ],
          [3, 5, 7, 9],
        );
        expect(GameBalance.statusChance(100, 9), 91);
        expect(GameBalance.statusChance(30, 9), 21);
        expect(GameBalance.statusChance(15, 30), 0);
        expect(GameBalance.statusChance(30, -10), 30);

        final save = GameSave(equippedItems: const {'head': 'helm_4'});
        expect(Combatant.player(save).statusResistance, 9);
        expect(Combatant.mirror(save).statusResistance, 9);
      },
    );

    test('versioned save round-trips sets, stats and equipped gear', () {
      final save = GameSave(
        hasHero: true,
        heroName: 'Kıyı Kahramanı',
        level: 7,
        xp: 1100,
        gold: 315,
        stats: _startingStats(),
        completedMatches: {'M01', 'M02'},
        audienceBestScores: {'M01': 2},
        intermissionChoices: {'I04': 'training:precision'},
        ownedItems: {'sword_1', 'spell_emberSpear'},
        equippedItems: {'weapon': 'sword_1'},
        headOptionId: 'head_05',
        skinToneId: 'skin_06',
        bodyProportionId: 'body_03',
        facialHairId: 'facial_hair_03',
        musicVolume: 0.42,
        sfxVolume: 0.83,
        vibrationEnabled: false,
        seenStoryEvidence: {'E04', 'E12'},
      );
      final decoded = GameSave.fromJson(save.toJson());
      expect(decoded.encode(), save.encode());
      expect(decoded.stats.agility, 4);
      expect(decoded.stats.precision, 2);
      expect(decoded.completedMatches, containsAll(['M01', 'M02']));
      expect(decoded.equippedItems['weapon'], 'sword_1');
      expect(decoded.audienceBestScores['M01'], 2);
      expect(decoded.intermissionChoices['I04'], 'training:precision');
      expect(decoded.headOptionId, 'head_05');
      expect(decoded.skinToneId, 'skin_06');
      expect(decoded.bodyProportionId, 'body_03');
      expect(decoded.facialHairId, 'facial_hair_03');
      expect(decoded.seenStoryEvidence, {'E04', 'E12'});
    });

    test(
      'migrates a version one save without losing campaign progress',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave.fromJson({
            'schemaVersion': 1,
            'hasHero': true,
            'heroName': 'Eski Şampiyon',
            'level': 6,
            'gold': 420,
            'completedMatches': ['M01', 'M02'],
            'stats': _startingStats().toJson(),
          });
        final game = GameController(storage: storage);
        await game.initialize();

        expect(game.save.schemaVersion, 10);
        expect(game.save.heroName, 'Eski Şampiyon');
        expect(game.save.level, 6);
        expect(game.save.gold, 420);
        expect(game.save.completedMatches, containsAll(['M01', 'M02']));
        expect(game.save.audienceBestScores, isEmpty);
        expect(storage.value?.schemaVersion, 10);
        game.dispose();
      },
    );

    test(
      'migrates a version two save and preserves its audience record',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave.fromJson({
            'schemaVersion': 2,
            'hasHero': true,
            'heroName': 'Eski Şampiyon',
            'level': 8,
            'gold': 510,
            'completedMatches': ['M01', 'M02'],
            'audienceBestScores': {'M01': 3},
            'stats': _startingStats().toJson()..remove('precision'),
          });
        final game = GameController(storage: storage);
        await game.initialize();

        expect(game.save.schemaVersion, 10);
        expect(game.save.stats.precision, 2);
        expect(game.save.audienceBestScores['M01'], 3);
        expect(game.save.completedMatches, containsAll(['M01', 'M02']));
        expect(storage.value?.schemaVersion, 10);
        game.dispose();
      },
    );

    test('migrates version four audio controls with safe defaults', () async {
      final storage = MemorySaveStorage()
        ..value = GameSave.fromJson({
          'schemaVersion': 4,
          'hasHero': true,
          'heroName': 'Eski Şampiyon',
          'gold': 550,
          'sfxEnabled': false,
          'stats': _startingStats().toJson(),
        });
      final game = GameController(storage: storage);
      await game.initialize();

      expect(game.save.schemaVersion, 10);
      expect(game.save.heroName, 'Eski Şampiyon');
      expect(game.save.gold, 550);
      expect(game.save.sfxEnabled, isFalse);
      expect(game.save.musicVolume, 0.65);
      expect(game.save.sfxVolume, 0.75);
      expect(game.save.vibrationEnabled, isTrue);

      await game.updateSettings(
        musicVolume: 1.4,
        sfxVolume: -0.2,
        vibrationEnabled: false,
        skipBattleAnimations: true,
        textScale: 2.5,
        battleAnimationSpeed: 0.5,
      );
      expect(game.save.musicVolume, 1.0);
      expect(game.save.sfxVolume, 0.0);
      expect(game.save.vibrationEnabled, isFalse);
      expect(game.save.skipBattleAnimations, isTrue);
      expect(game.save.textScale, 2.0);
      expect(game.save.battleAnimationSpeed, 1.0);
      expect(storage.value?.schemaVersion, 10);
      game.dispose();
    });

    test(
      'migrates a version nine save with accent and accessibility settings',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave.fromJson({
            'schemaVersion': 9,
            'hasHero': true,
            'primaryAccentId': 'accent_06',
            'secondaryAccentId': 'accent_08',
            'skipBattleAnimations': true,
            'textScale': 1.5,
            'battleAnimationSpeed': 2.0,
            'stats': _startingStats().toJson(),
          });
        final game = GameController(storage: storage);
        await game.initialize();

        expect(game.save.schemaVersion, 10);
        expect(game.save.primaryAccentId, 'accent_06');
        expect(game.save.secondaryAccentId, 'accent_08');
        expect(game.save.skipBattleAnimations, isTrue);
        expect(game.save.textScale, 1.5);
        expect(game.save.battleAnimationSpeed, 2.0);
        expect(storage.value?.schemaVersion, 10);
        game.dispose();
      },
    );

    test(
      'migrates version five saves with backward-compatible cosmetics',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave.fromJson({
            'schemaVersion': 5,
            'hasHero': true,
            'heroName': 'Eski Şampiyon',
            'appearance': 'Kıyı',
            'level': 9,
            'gold': 725,
            'completedMatches': ['M01', 'M02', 'M03'],
            'equippedItems': {'weapon': 'sword_2', 'body': 'coat_2'},
            'stats': _startingStats().toJson(),
          });
        final game = GameController(storage: storage);
        await game.initialize();

        expect(game.save.schemaVersion, 10);
        expect(game.save.heroName, 'Eski Şampiyon');
        expect(game.save.appearance, 'Kıyı');
        expect(game.save.level, 9);
        expect(game.save.gold, 725);
        expect(game.save.completedMatches, containsAll(['M01', 'M02', 'M03']));
        expect(game.save.equippedItems, {
          'weapon': 'sword_2',
          'body': 'coat_2',
        });
        expect(game.save.headOptionId, 'head_01');
        expect(game.save.skinToneId, 'skin_01');
        expect(game.save.bodyProportionId, 'body_01');
        expect(game.save.facialHairId, 'facial_hair_00');
        expect(storage.value?.schemaVersion, 10);
        game.dispose();
      },
    );

    test('migrates version six saves by preserving cosmetics and defaulting facial hair', () async {
      final storage = MemorySaveStorage()
        ..value = GameSave.fromJson({
          'schemaVersion': 6,
          'hasHero': true,
          'heroName': 'Eski Şampiyon',
          'level': 12,
          'gold': 960,
          'headOptionId': 'head_07',
          'skinToneId': 'skin_04',
          'bodyProportionId': 'body_02',
          'completedMatches': ['M01', 'M02', 'M03', 'M04'],
          'equippedItems': {'weapon': 'sword_3'},
          'stats': _startingStats().toJson(),
        });
      final game = GameController(storage: storage);
      await game.initialize();

      expect(game.save.schemaVersion, 10);
      expect(game.save.heroName, 'Eski Şampiyon');
      expect(game.save.level, 12);
      expect(game.save.gold, 960);
      expect(game.save.headOptionId, 'head_07');
      expect(game.save.skinToneId, 'skin_04');
      expect(game.save.bodyProportionId, 'body_02');
      expect(game.save.facialHairId, 'facial_hair_00');
      expect(
        game.save.completedMatches,
        containsAll(['M01', 'M02', 'M03', 'M04']),
      );
      expect(game.save.equippedItems['weapon'], 'sword_3');
      expect(storage.value?.schemaVersion, 10);
      game.dispose();
    });

    test(
      'intermission choice is first-clear only, persisted and one-time',
      () async {
        final storage = MemorySaveStorage();
        final game = GameController(storage: storage);
        await game.initialize();
        await game.createHero(name: 'Ateş', stats: _startingStats());

        expect(game.pendingIntermissionDecision, isNull);
        for (var id = 1; id <= 4; id++) {
          await game.startEncounter(id, seed: id);
          _winFirstEncounter(game);
          await game.resolveBattle();
          if (id < 4) expect(game.pendingIntermissionDecision, isNull);
        }

        expect(game.pendingIntermissionDecision?.id, 'I04');
        final pointsBeforeChoice = game.save.unspentStatPoints;
        expect(
          await game.chooseIntermissionReward(
            'I04',
            reward: IntermissionReward.training,
            stat: Stat.precision,
          ),
          isTrue,
        );
        expect(game.save.stats.precision, 3);
        expect(game.save.unspentStatPoints, pointsBeforeChoice);
        expect(game.save.intermissionChoices['I04'], 'training:precision');
        expect(game.pendingIntermissionDecision, isNull);
        expect(
          await game.chooseIntermissionReward(
            'I04',
            reward: IntermissionReward.sponsorship,
          ),
          isFalse,
        );

        final reloaded = GameController(storage: storage);
        await reloaded.initialize();
        expect(reloaded.save.stats.precision, 3);
        expect(reloaded.save.intermissionChoices['I04'], 'training:precision');
        expect(reloaded.pendingIntermissionDecision, isNull);
        game.dispose();
        reloaded.dispose();
      },
    );

    test(
      'intermission sponsorship pays the four chapter amounts once',
      () async {
        final game = GameController(
          storage: MemorySaveStorage()
            ..value = GameSave(
              gold: 10,
              completedMatches: {'M04', 'M12', 'M20', 'M28'},
            ),
        );
        await game.initialize();

        for (final decision in intermissionDecisions) {
          expect(game.pendingIntermissionDecision?.id, decision.id);
          expect(
            await game.chooseIntermissionReward(
              decision.id,
              reward: IntermissionReward.sponsorship,
            ),
            isTrue,
          );
        }

        expect(game.save.gold, 850);
        expect(game.save.intermissionChoices, hasLength(4));
        expect(game.pendingIntermissionDecision, isNull);
        game.dispose();
      },
    );

    test(
      'story evidence unlocks in order and persists when acknowledged',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave(completedMatches: {'M04', 'M12'});
        final game = GameController(storage: storage);
        await game.initialize();

        expect(game.pendingStoryEvidence?.id, 'E04');
        expect(await game.markStoryEvidenceSeen('E04'), isTrue);
        expect(game.pendingStoryEvidence?.id, 'E12');

        game.dispose();
        final reloaded = GameController(storage: storage);
        await reloaded.initialize();
        expect(reloaded.save.seenStoryEvidence, {'E04'});
        expect(reloaded.pendingStoryEvidence?.id, 'E12');
        expect(await reloaded.markStoryEvidenceSeen('E12'), isTrue);
        expect(reloaded.pendingStoryEvidence, isNull);
        expect(storage.value?.seenStoryEvidence, {'E04', 'E12'});
        reloaded.dispose();
      },
    );

    test(
      'an intermission choice cannot be claimed before its final is won',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave(completedMatches: {'M01', 'M02', 'M03'});
        final game = GameController(storage: storage);
        await game.initialize();

        expect(game.pendingIntermissionDecision, isNull);
        expect(
          await game.chooseIntermissionReward(
            'I04',
            reward: IntermissionReward.sponsorship,
          ),
          isFalse,
        );
        expect(game.save.gold, GameBalance.startingGold);
        game.dispose();
      },
    );

    test(
      'a prior-schema save with a cleared final exposes its missed choice',
      () async {
        final storage = MemorySaveStorage()
          ..value = GameSave.fromJson({
            'schemaVersion': 3,
            'hasHero': true,
            'completedMatches': ['M01', 'M02', 'M03', 'M04'],
            'stats': _startingStats().toJson(),
          });
        final game = GameController(storage: storage);
        await game.initialize();

        expect(game.save.schemaVersion, 10);
        expect(game.pendingIntermissionDecision?.id, 'I04');
        expect(storage.value?.schemaVersion, 10);
        game.dispose();
      },
    );

    test('a contract win cannot unlock an intermission decision', () async {
      final game = GameController(
        storage: MemorySaveStorage()
          ..value = GameSave(completedMatches: {'M01', 'M02', 'M03'}),
      );
      await game.initialize();
      await game.startContract('C1-A', seed: 5);
      _winFirstEncounter(game);
      await game.resolveBattle();

      expect(game.save.completedMatches, isNot(contains('M04')));
      expect(game.pendingIntermissionDecision, isNull);
      game.dispose();
    });

    test('new gladiator must distribute exactly six points and starts unlocked at match one', () async {
      final game = GameController(storage: MemorySaveStorage());
      await game.initialize();
      expect(game.unlockedThrough, 1);
      expect(
        () => game.createHero(name: 'invalid', stats: const Stats()),
        throwsArgumentError,
      );
      await game.createHero(name: 'Ateş', stats: _startingStats());
      expect(game.save.hasHero, isTrue);
      expect(game.save.gold, 160);
      expect(game.isEncounterUnlocked(1), isTrue);
      expect(game.isEncounterUnlocked(2), isFalse);
      game.dispose();
    });

    test(
      'first purchased weapon equips and rejects a duplicate purchase',
      () async {
        final game = GameController(storage: MemorySaveStorage());
        await game.initialize();
        await game.createHero(name: 'Ateş', stats: _startingStats());
        final sword = shopItems.firstWhere((item) => item.id == 'sword_1');
        expect(await game.buyItem(sword), isNull);
        expect(game.save.equippedItems['weapon'], 'sword_1');
        expect(game.save.gold, 0);
        expect(await game.buyItem(sword), isNotNull);
        game.dispose();
      },
    );
  });

  group('battle rules', () {
    test('audience note evaluates visible rules deterministically', () {
      final metrics = BattleMetrics()
        ..audienceActionFamilies.addAll(['attack', 'defense'])
        ..answeredAttackIntent = true
        ..rangeChanges = 1;
      expect(evaluateAudienceReport(getEncounter(1), metrics).score, 3);
      expect(audienceRuleLabels(getEncounter(1)), hasLength(3));

      final hazardMetrics = BattleMetrics()
        ..audienceActionFamilies.addAll(['attack', 'positioning'])
        ..answeredAttackIntent = true
        ..hazardDamageTaken = 1;
      expect(evaluateAudienceReport(getEncounter(7), hazardMetrics).score, 2);
      hazardMetrics.hazardDamageTaken = 0;
      expect(evaluateAudienceReport(getEncounter(7), hazardMetrics).score, 3);
    });

    test('records tactical choices and answers to shown attacks', () {
      BattleEngine? engine;
      for (var seed = 1; seed < 50; seed++) {
        final candidate = BattleEngine(
          save: GameSave(hasHero: true, stats: _startingStats()),
          encounter: getEncounter(1),
          seed: seed,
        );
        if ([
          BattleAction.quick,
          BattleAction.heavy,
          BattleAction.sweep,
          BattleAction.bow,
          BattleAction.emberSpear,
          BattleAction.ashBurst,
        ].contains(candidate.snapshot.opponentIntent)) {
          engine = candidate;
          break;
        }
      }
      expect(engine, isNotNull);
      final battle = engine!;
      battle.opponent.health = 100000;
      expect(battle.perform(BattleAction.guard), isNull);
      expect(battle.metrics.audienceActionFamilies, contains('defense'));
      expect(battle.metrics.answeredAttackIntent, isTrue);
    });

    test(
      'counts weapon-family and bow range penalties for contract checks',
      () {
        final engine = BattleEngine(
          save: GameSave(hasHero: true, stats: _startingStats()),
          encounter: getEncounter(1),
          seed: 2,
        )..distance = RangeBand.far;
        engine.opponent.health = 100000;
        expect(engine.perform(BattleAction.quick), isNull);
        expect(engine.metrics.rangePenaltyAttacks, 1);
      },
    );

    test('preview exposes hit chance, action cost and bow ammunition', () {
      final save = GameSave(
        hasHero: true,
        stats: _startingStats(),
        ownedItems: {'bow_1', 'spell_emberSpear'},
        equippedItems: {'bow': 'bow_1'},
      );
      final engine = BattleEngine(
        save: save,
        encounter: getEncounter(1),
        seed: 19,
      );
      final quick = engine.preview(BattleAction.quick);
      final bow = engine.preview(BattleAction.bow);
      final spell = engine.preview(BattleAction.emberSpear);
      expect(quick.hitChance, 85);
      expect(quick.cost, '5 efor');
      expect(bow.canUse, isTrue);
      expect(bow.cost, '6 efor · 1 fişek');
      expect(engine.player.ammo, 3);
      expect(spell.canUse, isTrue);
      expect(spell.cost, '8 mana');
    });

    test('precision improves hit chance independently of agility', () {
      BattleEngine engineWith(int precision) => BattleEngine(
        save: GameSave(
          hasHero: true,
          stats: _startingStats().copyWith(precision: precision),
        ),
        encounter: getEncounter(1),
        seed: 23,
      );

      final standard = engineWith(2);
      final precise = engineWith(5);
      expect(precise.player.stats.agility, standard.player.stats.agility);
      expect(
        precise.hitChance(precise.player, precise.opponent, BattleAction.quick),
        89,
      );
      expect(
        precise.hitChance(
              precise.player,
              precise.opponent,
              BattleAction.quick,
            ) -
            standard.hitChance(
              standard.player,
              standard.opponent,
              BattleAction.quick,
            ),
        4,
      );
    });

    test('agility lowers the effort cost of changing distance', () {
      final engine = BattleEngine(
        save: GameSave(
          hasHero: true,
          stats: _startingStats().copyWith(agility: 8),
        ),
        encounter: getEncounter(1),
        seed: 23,
      );

      expect(GameBalance.movementEffortCost(2), 4);
      expect(GameBalance.movementEffortCost(8), 3);
      expect(GameBalance.movementEffortCost(14), 2);
      expect(GameBalance.movementEffortCost(20), 1);
      expect(engine.preview(BattleAction.openDistance).cost, '3 efor');
    });

    test('preview disables distance changes at the arena boundaries', () {
      final engine = BattleEngine(
        save: GameSave(hasHero: true, stats: _startingStats()),
        encounter: getEncounter(1),
        seed: 7,
      );

      engine.distance = RangeBand.close;
      expect(engine.preview(BattleAction.closeDistance).canUse, isFalse);
      expect(engine.preview(BattleAction.openDistance).canUse, isTrue);
      expect(engine.perform(BattleAction.closeDistance), isNotNull);
      expect(engine.metrics.turn, 0);

      engine.distance = RangeBand.far;
      expect(engine.preview(BattleAction.openDistance).canUse, isFalse);
      expect(engine.preview(BattleAction.closeDistance).canUse, isTrue);
    });

    test('battle emits ordered typed events for presentation systems', () {
      final engine = BattleEngine(
        save: GameSave(hasHero: true, stats: _startingStats()),
        encounter: getEncounter(1),
        seed: 31,
      );
      engine.opponent.health = 100000;
      final eventCountBefore = engine.snapshot.events.length;

      expect(engine.perform(BattleAction.openDistance), isNull);

      final events = engine.snapshot.events;
      expect(
        events.map((event) => event.sequence),
        orderedEquals(List<int>.generate(events.length, (index) => index)),
      );
      final turnEvents = events.skip(eventCountBefore).toList();
      expect(turnEvents.first.type, BattleEventType.turnStarted);
      expect(
        turnEvents.any((event) => event.type == BattleEventType.actionStarted),
        isTrue,
      );
      expect(
        turnEvents.where((event) => event.type == BattleEventType.rangeChanged),
        isNotEmpty,
      );
      final playerMove = turnEvents.firstWhere(
        (event) =>
            event.type == BattleEventType.rangeChanged &&
            event.actor == BattleActor.player,
      );
      expect(playerMove.action, BattleAction.openDistance);
      expect(playerMove.amount, RangeBand.values.indexOf(engine.distance));
      expect(turnEvents.last.type, BattleEventType.turnEnded);
      expect(
        turnEvents.every((event) => event.turn == engine.metrics.turn),
        isTrue,
      );
    });

    test('phase transition log names the current phase', () {
      final engine = BattleEngine(
        save: GameSave(hasHero: true, stats: _startingStats()),
        encounter: getEncounter(32),
        seed: 8,
      );

      engine.opponent.health = 1;
      engine.perform(BattleAction.guard);
      expect(
        engine.snapshot.log.any((line) => line.contains('ikinci faza geçti')),
        isTrue,
      );

      engine.opponent.health = (engine.opponent.maxHealth / 3).floor() - 1;
      engine.perform(BattleAction.guard);
      expect(
        engine.snapshot.log.any((line) => line.contains('üçüncü faza geçti')),
        isTrue,
      );
    });

    test('fixed seed produces the same combat log', () {
      String play(int seed) {
        final engine = BattleEngine(
          save: GameSave(hasHero: true, stats: _startingStats()),
          encounter: getEncounter(1),
          seed: seed,
        );
        for (var i = 0; i < 40 && !engine.snapshot.done; i++) {
          engine.player.health = engine.player.maxHealth;
          engine.player.effort = engine.player.maxEffort;
          engine.opponent.health = 1;
          engine.perform(BattleAction.quick);
        }
        return engine.snapshot.log.join('\n');
      }

      expect(play(577), play(577));
      expect(play(578), isNot(play(577)));
    });

    test(
      'guard blocks most damage and arena hazards are avoidable by moving',
      () {
        final save = GameSave(hasHero: true, stats: _startingStats());
        final guarded = BattleEngine(
          save: save,
          encounter: getEncounter(1),
          seed: 7,
        );
        final exposed = BattleEngine(
          save: save,
          encounter: getEncounter(1),
          seed: 7,
        );
        guarded.opponent.health = 100000;
        exposed.opponent.health = 100000;
        var guardedDamage = 0;
        var exposedDamage = 0;
        for (var i = 0; i < 20 && exposedDamage == 0; i++) {
          guarded.player.health = 100000;
          exposed.player.health = 100000;
          guarded.player.guarding = true;
          guarded.perform(BattleAction.quick);
          exposed.perform(BattleAction.quick);
          guardedDamage += 100000 - guarded.player.health;
          exposedDamage += 100000 - exposed.player.health;
        }
        expect(guardedDamage, greaterThan(0));
        expect(guardedDamage, lessThan(exposedDamage));

        final hazard = BattleEngine(
          save: save,
          encounter: getEncounter(7),
          seed: 5,
        );
        expect(hazard.snapshot.telegraphedHazard, isFalse);
        hazard.perform(BattleAction.quick);
        hazard.perform(BattleAction.quick);
        expect(hazard.snapshot.telegraphedHazard, isTrue);
        hazard.perform(BattleAction.openDistance);
        expect(hazard.metrics.hazardDamageTaken, 0);
      },
    );
  });

  group('campaign economy', () {
    test('loss support tops up on the first victory and replay pays no repeat reward', () async {
      final game = GameController(storage: MemorySaveStorage());
      await game.initialize();
      await game.createHero(name: 'Ateş', stats: _startingStats());

      await game.startEncounter(1, seed: 99);
      final loss = game.battle!;
      for (var i = 0; i < 30 && !loss.snapshot.done; i++) {
        loss.player.health = 1;
        loss.player.effort = loss.player.maxEffort;
        loss.perform(BattleAction.guard);
      }
      expect(loss.snapshot.done, isTrue);
      expect(loss.snapshot.playerWon, isFalse);
      await game.resolveBattle();
      expect(game.save.gold, 196);
      expect(game.save.lossSupportPaid, contains('M01'));
      expect(game.save.audienceBestScores, isEmpty);

      await game.startEncounter(1, seed: 1);
      _winFirstEncounter(game);
      game.battle!.metrics.audienceActionFamilies.addAll(['attack', 'defense']);
      game.battle!.metrics.answeredAttackIntent = true;
      game.battle!.metrics.rangeChanges = 1;
      await game.resolveBattle();
      expect(game.save.gold, 280);
      expect(game.save.xp, 180);
      expect(game.save.level, 2);
      expect(game.save.completedMatches, contains('M01'));
      expect(game.save.audienceBestScores['M01'], 3);
      expect(game.audienceScoreForChapter(1), 3);
      expect(game.hasAudienceCrest(1), isFalse);
      expect(game.unlockedThrough, 2);

      await game.startEncounter(1, seed: 2);
      _winFirstEncounter(game);
      await game.resolveBattle();
      expect(game.save.gold, 280);
      expect(game.save.xp, 180);
      expect(game.save.audienceBestScores['M01'], 3);
      game.dispose();
    });

    test(
      'contract reward is one-time and does not grant main match XP',
      () async {
        final storage = MemorySaveStorage();
        final game = GameController(storage: storage);
        await game.initialize();
        await game.createHero(name: 'Ateş', stats: _startingStats());
        final startGold = game.save.gold;
        await game.startContract('C1-A', seed: 3);
        _winFirstEncounter(game);
        game.battle!.metrics.receivedStatus = false;
        await game.resolveBattle();
        expect(game.save.completedContracts, contains('C1-A'));
        expect(game.save.gold, startGold + 60);
        expect(game.save.xp, 0);
        expect(game.save.completedMatches, isEmpty);
        expect(game.save.audienceBestScores, isEmpty);
        await game.startContract('C1-A', seed: 4);
        _winFirstEncounter(game);
        game.battle!.metrics.receivedStatus = false;
        await game.resolveBattle();
        expect(game.save.gold, startGold + 60);
        game.dispose();
      },
    );
  });
}
