import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:flutter_test/flutter_test.dart';

const _testStats = Stats(
  might: 4,
  agility: 4,
  vitality: 4,
  guard: 2,
  stamina: 2,
  arcana: 2,
);

typedef _Replay = ({
  List<String> events,
  List<String> log,
  bool done,
  bool playerWon,
  int playerHealth,
  int opponentHealth,
});

_Replay _playDeterministicEncounter(int seed) {
  final engine = BattleEngine(
    save: GameSave(hasHero: true, stats: _testStats),
    encounter: getEncounter(1),
    seed: seed,
  );

  for (var turn = 0; turn < 40 && !engine.snapshot.done; turn++) {
    engine.player.health = engine.player.maxHealth;
    engine.player.effort = engine.player.maxEffort;
    engine.opponent.health = 1;
    engine.perform(BattleAction.quick);
  }

  return (
    events: engine.snapshot.events.map(_eventSignature).toList(),
    log: engine.snapshot.log,
    done: engine.snapshot.done,
    playerWon: engine.snapshot.playerWon,
    playerHealth: engine.player.health,
    opponentHealth: engine.opponent.health,
  );
}

String _eventSignature(BattleEvent event) => [
  event.sequence,
  event.turn,
  event.type.name,
  event.actor?.name,
  event.target?.name,
  event.action?.name,
  event.status?.name,
  event.amount,
  event.healthDamage,
  event.shieldAbsorbed,
].join('|');

void _winBattle(BattleEngine engine) {
  for (var turn = 0; turn < 40 && !engine.snapshot.done; turn++) {
    engine.player.health = engine.player.maxHealth;
    engine.player.effort = engine.player.maxEffort;
    engine.opponent.health = 1;
    engine.perform(BattleAction.quick);
  }
  expect(engine.snapshot.done, isTrue);
  expect(engine.snapshot.playerWon, isTrue);
}

void main() {
  group('deterministic combat event contract', () {
    test(
      'a fixed seed reproduces the full event sequence and terminal result',
      () {
        final first = _playDeterministicEncounter(577);
        final replay = _playDeterministicEncounter(577);

        expect(replay.events, equals(first.events));
        expect(replay.log, equals(first.log));
        expect(replay.done, isTrue);
        expect(replay.playerWon, isTrue);
        expect(replay.playerHealth, first.playerHealth);
        expect(replay.opponentHealth, first.opponentHealth);
        expect(first.events.last, contains('|battleWon|'));
      },
    );

    test('terminal event agrees with the battle result for both outcomes', () {
      final winner = BattleEngine(
        save: GameSave(hasHero: true, stats: _testStats),
        encounter: getEncounter(1),
        seed: 578,
      );
      _winBattle(winner);

      expect(winner.snapshot.events.last.type, BattleEventType.battleWon);
      expect(winner.snapshot.events.last.actor, BattleActor.player);
      expect(
        winner.snapshot.events.where(
          (event) => event.type == BattleEventType.battleLost,
        ),
        isEmpty,
      );

      const attackIntents = {
        BattleAction.quick,
        BattleAction.heavy,
        BattleAction.sweep,
        BattleAction.bow,
        BattleAction.emberSpear,
        BattleAction.ashBurst,
      };
      BattleEngine? loser;
      for (var seed = 0; seed < 256 && loser == null; seed++) {
        final candidate = BattleEngine(
          save: GameSave(hasHero: true, stats: _testStats),
          encounter: getEncounter(1),
          seed: seed,
        );
        if (!attackIntents.contains(candidate.snapshot.opponentIntent)) {
          continue;
        }
        candidate.player.health = 1;
        candidate.perform(BattleAction.guard);
        if (candidate.snapshot.done && !candidate.snapshot.playerWon) {
          loser = candidate;
        }
      }

      expect(loser, isNotNull, reason: 'a seeded opponent attack should land');
      final loss = loser!;
      expect(loss.snapshot.events.last.type, BattleEventType.battleLost);
      expect(loss.snapshot.events.last.actor, BattleActor.opponent);
      expect(loss.snapshot.done, isTrue);
      expect(loss.snapshot.playerWon, isFalse);
      expect(
        loss.snapshot.events.where(
          (event) => event.type == BattleEventType.battleWon,
        ),
        isEmpty,
      );
    });

    test('hit and damage events match the opponent health change', () {
      BattleEngine? hitBattle;
      for (var seed = 0; seed < 128 && hitBattle == null; seed++) {
        final candidate = BattleEngine(
          save: GameSave(hasHero: true, stats: _testStats),
          encounter: getEncounter(1),
          seed: seed,
        );
        candidate.opponent.health = 100000;
        final before = candidate.opponent.health;
        candidate.perform(BattleAction.quick);
        final events = candidate.snapshot.events;
        if (events.any(
          (event) =>
              event.type == BattleEventType.attackHit &&
              event.actor == BattleActor.player &&
              event.target == BattleActor.opponent,
        )) {
          hitBattle = candidate;
          expect(candidate.opponent.health, lessThan(before));
        }
      }

      expect(hitBattle, isNotNull, reason: 'a seeded quick attack should hit');
      final engine = hitBattle!;
      final hit = engine.snapshot.events.lastWhere(
        (event) =>
            event.type == BattleEventType.attackHit &&
            event.actor == BattleActor.player &&
            event.target == BattleActor.opponent,
      );
      final damage = engine.snapshot.events.lastWhere(
        (event) =>
            event.type == BattleEventType.damageTaken &&
            event.target == BattleActor.opponent,
      );

      expect(damage.amount, hit.amount);
      expect(damage.healthDamage, hit.amount);
      expect(damage.shieldAbsorbed, 0);
    });

    test(
      'an opponent guard visible in the battle log has a typed guard event',
      () {
        BattleEngine? guardingOpponent;
        for (var seed = 0; seed < 256 && guardingOpponent == null; seed++) {
          final candidate = BattleEngine(
            save: GameSave(hasHero: true, stats: _testStats),
            encounter: getEncounter(3),
            seed: seed,
          );
          if (candidate.snapshot.opponentIntent != BattleAction.guard) continue;
          candidate.opponent.health = 100000;
          candidate.perform(BattleAction.guard);
          final opponentGuarded = candidate.snapshot.log.any(
            (line) =>
                line.contains('gard aldı.') &&
                line.startsWith(candidate.opponent.name),
          );
          if (opponentGuarded && candidate.opponent.guarding) {
            guardingOpponent = candidate;
          }
        }

        expect(
          guardingOpponent,
          isNotNull,
          reason: 'a seeded shield rival should complete its guard intent',
        );
        expect(
          guardingOpponent!.snapshot.events.where(
            (event) =>
                event.type == BattleEventType.guardRaised &&
                event.actor == BattleActor.opponent,
          ),
          hasLength(1),
        );
      },
    );
  });

  test(
    'resolving a completed battle twice does not spend a supply twice',
    () async {
      final storage = MemorySaveStorage()
        ..value = GameSave(hasHero: true, stats: _testStats, healingSalves: 2);
      final game = GameController(storage: storage);
      await game.initialize();
      await game.startEncounter(1, seed: 6401);

      final engine = game.battle!;
      engine.player.health = engine.player.maxHealth - 1;
      expect(engine.perform(BattleAction.salve), isNull);
      expect(engine.metrics.salveUsed, isTrue);
      _winBattle(engine);

      final resolutions = await Future.wait([
        game.resolveBattle(),
        game.resolveBattle(),
      ]);
      expect(resolutions.map((result) => result?.won), [true, true]);
      expect(game.save.healingSalves, 1);
      final goldAfterFirstResolution = game.save.gold;
      final xpAfterFirstResolution = game.save.xp;

      final repeatedResolution = await game.resolveBattle();
      expect(repeatedResolution?.won, isTrue);
      expect(game.save.healingSalves, 1);
      expect(game.save.gold, goldAfterFirstResolution);
      expect(game.save.xp, xpAfterFirstResolution);
      game.dispose();
    },
  );

  group('hero motion atlas frame mapping', () {
    test('action atlas poses map to eight unique row-major cells', () {
      final frames = HeroActionPose.values.map(heroActionAtlasFrame).toList();

      expect(frames, [0, 1, 2, 3, 4, 5, 6, 7]);
      expect(frames.toSet(), hasLength(8));
    });

    test('attack advances through wind-up and slash, then returns to idle', () {
      expect(heroMotionAtlasFrame(FighterMotion.attack, 0), 1);
      expect(heroMotionAtlasFrame(FighterMotion.attack, .34), 2);
      expect(heroMotionAtlasFrame(FighterMotion.attack, .81), 2);
      expect(heroMotionAtlasFrame(FighterMotion.attack, .82), 0);
    });

    test('hit and guard reactions return to idle after their pulse', () {
      expect(heroMotionAtlasFrame(FighterMotion.hit, .5), 3);
      expect(heroMotionAtlasFrame(FighterMotion.hit, 1), 0);
      expect(heroMotionAtlasFrame(FighterMotion.guard, .5), 4);
      expect(heroMotionAtlasFrame(FighterMotion.guard, 1), 0);
      expect(heroMotionAtlasFrame(FighterMotion.defeat, .5), 3);
    });

    test('victory remains visible and unrepresented motions use idle', () {
      expect(heroMotionAtlasFrame(FighterMotion.victory, 1), 5);
      expect(heroMotionAtlasFrame(FighterMotion.spell, .5), 0);
      expect(heroMotionAtlasFrame(FighterMotion.dodge, .5), 0);
    });
  });
}
