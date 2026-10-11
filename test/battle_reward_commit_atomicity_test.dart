import 'package:ash_circuit/game/data/intermission_decisions.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailOnceSaveStorage implements SaveStorage {
  _FailOnceSaveStorage({this.value});

  GameSave? value;
  bool failNextWrite = false;
  int writeCount = 0;

  @override
  Future<GameSave?> read() async => value;

  @override
  Future<void> write(GameSave save) async {
    writeCount++;
    if (failNextWrite) {
      failNextWrite = false;
      throw Exception('Simulated storage write error');
    }
    value = save;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  group('battle reward persistence atomicity', () {
    test(
      'failed battle resolution rolls back, then rewards only once',
      () async {
        const initial = GameSave(hasHero: true, gold: 500, healingSalves: 2);
        final storage = _FailOnceSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1, seed: 411);

        final engine = controller.battle!;
        final encounter = controller.activeEncounter!;
        engine.player.health = engine.player.maxHealth - 1;
        expect(engine.perform(BattleAction.salve), isNull);
        _winBattle(engine);
        expect(engine.metrics.salveUsed, isTrue);

        final saveBeforeResolution = controller.save.toJson();
        final writesBeforeResolution = storage.writeCount;
        var notifications = 0;
        controller.addListener(() => notifications++);

        storage.failNextWrite = true;
        await expectLater(
          controller.resolveBattle(),
          throwsA(isA<Exception>()),
        );

        expect(controller.save.toJson(), saveBeforeResolution);
        expect(storage.value?.toJson(), saveBeforeResolution);
        expect(controller.save.healingSalves, 2);
        expect(controller.save.completedMatches, isEmpty);
        expect(controller.save.battleCheckpoint, isNotNull);
        expect(controller.battle, same(engine));
        expect(controller.lastError, contains('Kayıt yazılamadı'));
        expect(storage.writeCount, writesBeforeResolution + 1);
        expect(notifications, 0);

        final resolution = await controller.resolveBattle();
        expect(resolution, isNotNull);
        expect(resolution!.won, isTrue);
        expect(controller.save.gold, initial.gold + encounter.gold);
        expect(controller.save.xp, initial.xp + encounter.xp);
        expect(controller.save.healingSalves, 1);
        expect(controller.save.completedMatches, contains(encounter.key));
        expect(controller.save.battleCheckpoint, isNull);
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, writesBeforeResolution + 2);
        expect(notifications, 1);

        final committedSave = controller.save.toJson();
        final repeatedResolution = await controller.resolveBattle();
        expect(repeatedResolution, same(resolution));
        expect(controller.save.toJson(), committedSave);
        expect(controller.save.gold, initial.gold + encounter.gold);
        expect(controller.save.xp, initial.xp + encounter.xp);
        expect(controller.save.healingSalves, 1);
        expect(storage.writeCount, writesBeforeResolution + 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );
  });

  group('intermission reward persistence atomicity', () {
    test(
      'failed reward choices roll back and retry without duplicate reward',
      () async {
        await _verifyIntermissionRewardRetry(
          reward: IntermissionReward.training,
          stat: Stat.precision,
          expectedChoice: 'training:precision',
        );
        await _verifyIntermissionRewardRetry(
          reward: IntermissionReward.sponsorship,
          expectedChoice: 'sponsorship',
        );
      },
    );
  });
}

Future<void> _verifyIntermissionRewardRetry({
  required IntermissionReward reward,
  Stat? stat,
  required String expectedChoice,
}) async {
  const initial = GameSave(
    hasHero: true,
    gold: 500,
    completedMatches: {'M01', 'M02', 'M03', 'M04'},
  );
  final storage = _FailOnceSaveStorage(value: initial);
  final controller = GameController(storage: storage);
  await controller.initialize();
  expect(controller.pendingIntermissionDecision?.id, 'I04');
  final decision = controller.pendingIntermissionDecision!;
  var notifications = 0;
  controller.addListener(() => notifications++);

  storage.failNextWrite = true;
  await expectLater(
    controller.chooseIntermissionReward(
      decision.id,
      reward: reward,
      stat: stat,
    ),
    throwsA(isA<Exception>()),
  );

  expect(controller.save.toJson(), initial.toJson());
  expect(storage.value?.toJson(), initial.toJson());
  expect(controller.lastError, contains('Kayıt yazılamadı'));
  expect(storage.writeCount, 1);
  expect(notifications, 0);

  expect(
    await controller.chooseIntermissionReward(
      decision.id,
      reward: reward,
      stat: stat,
    ),
    isTrue,
  );
  expect(controller.save.intermissionChoices[decision.id], expectedChoice);
  expect(controller.pendingIntermissionDecision, isNull);
  if (reward == IntermissionReward.training) {
    final trainingStat = stat!;
    expect(
      controller.save.stats[trainingStat],
      initial.stats[trainingStat] + 1,
    );
    expect(controller.save.gold, initial.gold);
  } else {
    expect(controller.save.gold, initial.gold + decision.sponsorshipGold);
    expect(controller.save.stats, initial.stats);
  }
  expect(storage.value?.toJson(), controller.save.toJson());
  expect(storage.writeCount, 2);
  expect(notifications, 1);

  final committedSave = controller.save.toJson();
  expect(
    await controller.chooseIntermissionReward(
      decision.id,
      reward: reward,
      stat: stat,
    ),
    isFalse,
  );
  expect(controller.save.toJson(), committedSave);
  expect(storage.writeCount, 2);
  expect(notifications, 1);

  controller.dispose();
}

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
