import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _save = GameSave(
  hasHero: true,
  level: 20,
  stats: Stats(
    might: 8,
    agility: 8,
    precision: 8,
    vitality: 20,
    guard: 8,
    stamina: 20,
    arcana: 10,
  ),
);

Combatant _durableOpponent() => Combatant(
  name: 'Dayanıklı Rakip',
  stats: const Stats(
    might: 1,
    agility: 1,
    precision: 1,
    vitality: 1,
    guard: 40,
    stamina: 30,
    arcana: 20,
  ),
  level: 1,
  maxHealth: 10000,
  maxEffort: 40,
  maxMana: 100,
  weaponPower: 1,
  family: WeaponFamily.spear,
  armor: 100,
  ammo: 0,
  aiStyle: true,
);

BattleEngine _battle(int encounterId, {int seed = 1}) => BattleEngine(
  save: _save,
  encounter: getEncounter(encounterId),
  seed: seed,
  opponentOverride: _durableOpponent(),
);

int _hazardResolutions(BattleEngine battle) => battle.snapshot.events
    .where(
      (event) =>
          event.type == BattleEventType.hazardHit ||
          event.type == BattleEventType.hazardAvoided,
    )
    .length;

void main() {
  group('encounter hazard schedules', () {
    test('every encounter with an active hazard has a typed schedule', () {
      final activeHazards = mainEncounters.where(
        (encounter) => encounter.hazard.isNotEmpty,
      );

      expect(activeHazards, isNotEmpty);
      expect(
        activeHazards.every((encounter) => encounter.hazardSchedule != null),
        isTrue,
      );
    });

    test('a one-time event warns and resolves only once', () {
      for (final encounterId in [4, 20]) {
        final battle = _battle(encounterId);

        for (var turn = 0; turn < 12; turn++) {
          battle.player.health = 100000;
          battle.perform(BattleAction.guard);
        }

        expect(
          battle.snapshot.events
              .where((event) => event.type == BattleEventType.hazardWarned)
              .map((event) => event.amount),
          [1],
          reason: 'encounter $encounterId',
        );
        expect(
          battle.snapshot.events
              .where((event) => event.type == BattleEventType.hazardAvoided)
              .map((event) => event.turn),
          [3],
          reason: 'encounter $encounterId',
        );
        expect(_hazardResolutions(battle), 1, reason: 'encounter $encounterId');
      }
    });

    test('two-turn warnings follow the encounter cadence', () {
      final battle = _battle(7);
      final telegraphsAfterTurn = <bool>[];

      for (var turn = 0; turn < 7; turn++) {
        battle.perform(BattleAction.guard);
        telegraphsAfterTurn.add(battle.snapshot.telegraphedHazard);
      }

      expect(telegraphsAfterTurn, [
        true,
        true,
        false,
        false,
        true,
        true,
        false,
      ]);
      expect(
        battle.snapshot.events
            .where((event) => event.type == BattleEventType.hazardWarned)
            .map((event) => event.amount),
        [2, 1, 2, 1],
      );
      expect(
        battle.snapshot.events
            .where((event) => event.type == BattleEventType.hazardAvoided)
            .map((event) => event.turn),
        [3, 7],
      );
    });

    test('one-turn warnings stay distinct from two-turn warnings', () {
      final battle = _battle(9);
      final telegraphsAfterTurn = <bool>[];

      for (var turn = 0; turn < 3; turn++) {
        battle.perform(BattleAction.guard);
        telegraphsAfterTurn.add(battle.snapshot.telegraphedHazard);
      }

      expect(telegraphsAfterTurn, [false, true, false]);
      expect(
        battle.snapshot.events
            .where((event) => event.type == BattleEventType.hazardWarned)
            .map((event) => event.amount),
        [1],
      );
      expect(_hazardResolutions(battle), 1);
    });

    test(
      'encounter 19 uses a two-action warning window before its field resolves',
      () {
        final encounter = getEncounter(19);
        final schedule = encounter.hazardSchedule!;
        expect(schedule.warningTurns, 2);
        expect(schedule.impactsAfterTurn(2), isFalse);
        expect(schedule.impactsAfterTurn(3), isTrue);
        expect(schedule.warningTurnsRemainingOn(1), isNull);
        expect(schedule.warningTurnsRemainingOn(2), 2);
        expect(schedule.warningTurnsRemainingOn(3), 1);
      },
    );
  });

  group('champion phase tactics', () {
    test('every campaign champion has a tactic profile for each phase', () {
      for (final encounterId in [8, 16, 24, 32]) {
        final encounter = getEncounter(encounterId);
        expect(encounter.phaseTactics, hasLength(encounter.phaseCount));
        expect(
          encounter.phaseTactics.every(
            (profile) =>
                profile.taughtTactics.isNotEmpty &&
                profile.intentSequence.isNotEmpty,
          ),
          isTrue,
          reason: 'encounter $encounterId',
        );
      }
    });

    test('phase change keeps the pending enemy intent and telegraphs its new sequence', () {
      final battle = _battle(8, seed: 23);
      expect(battle.snapshot.opponentIntent, BattleAction.heavy);
      battle.opponent.health = 4000;

      battle.perform(BattleAction.guard);

      expect(battle.snapshot.phase, 2);
      expect(
        battle.snapshot.events.any(
          (event) =>
              event.type == BattleEventType.actionStarted &&
              event.actor == BattleActor.player &&
              event.action == BattleAction.guard,
        ),
        isTrue,
      );
      expect(
        battle.snapshot.events.any(
          (event) =>
              event.type == BattleEventType.attackStarted &&
              event.actor == BattleActor.opponent &&
              event.action == BattleAction.heavy,
        ),
        isTrue,
      );
      expect(battle.snapshot.opponentIntent, BattleAction.guard);
      expect(battle.snapshot.intentMessage.id, 'battle.intent.guard');
      expect(
        battle.snapshot.messages.any(
          (message) => message.id == 'battle.log.phaseChange',
        ),
        isTrue,
      );
      final tacticMessage = battle.snapshot.messages.firstWhere(
        (message) => message.id == 'battle.log.phaseTactics',
      );
      expect(tacticMessage.arguments['tactics'], [TaughtTactic.shielded]);
    });

    test(
      'phase sequence is seed-independent and resumes at its saved index',
      () {
        final first = _battle(8, seed: 3);
        final second = _battle(8, seed: 91);
        for (final battle in [first, second]) {
          battle.opponent.health = 4000;
          battle.perform(BattleAction.guard);
        }

        expect(first.snapshot.opponentIntent, BattleAction.guard);
        expect(second.snapshot.opponentIntent, BattleAction.guard);
        final restored = BattleEngine.restoreFromCheckpoint(
          save: _save,
          encounter: getEncounter(8),
          checkpoint: first.toCheckpointJson(),
          opponentOverride: _durableOpponent(),
        );
        expect(
          restored.snapshot.messages
              .firstWhere((message) => message.id == 'battle.log.phaseTactics')
              .arguments['tactics'],
          [TaughtTactic.shielded],
        );

        first.perform(BattleAction.guard);
        restored.perform(BattleAction.guard);

        expect(first.snapshot.opponentIntent, BattleAction.quick);
        expect(restored.snapshot.opponentIntent, BattleAction.quick);
      },
    );

    test(
      'mastery trial variants keep their source schedules and phase profiles',
      () async {
        final controller = GameController(
          storage: MemorySaveStorage()
            ..value = const GameSave(
              championsRunBest: 7,
              completedMatches: {'M32'},
            ),
        );
        await controller.initialize();

        await controller.startChampionsRoad(3, seed: 33);
        expect(
          controller.activeEncounter!.phaseTactics,
          getEncounter(8).phaseTactics,
        );
        expect(
          controller.activeEncounter!.tacticsForPhase(2),
          same(getEncounter(8).phaseTactics[1]),
        );

        await controller.startChampionsRoad(5, seed: 55);
        expect(
          controller.activeEncounter!.hazardSchedule,
          same(getEncounter(22).hazardSchedule),
        );

        await controller.startChampionsRoad(8, seed: 88);
        expect(controller.activeEncounter!.phaseCount, 2);
        expect(controller.activeEncounter!.phaseTactics, isEmpty);
        expect(controller.activeEncounter!.tacticsForPhase(3), isNull);
        controller.dispose();
      },
    );
  });
}
