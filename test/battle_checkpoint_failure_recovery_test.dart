import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailOnceStorage extends MemorySaveStorage {
  bool failNextWrite = false;
  int writeCount = 0;

  @override
  Future<void> write(GameSave save) async {
    writeCount++;
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('simulated save failure');
    }
    await super.write(save);
  }
}

void main() {
  group('battle checkpoint persistence recovery', () {
    test(
      'a failed battle start leaves no live battle and can be retried',
      () async {
        const initial = GameSave(hasHero: true, heroName: 'Kıyı');
        final storage = _FailOnceStorage()..value = initial;
        final controller = GameController(storage: storage);
        await controller.initialize();
        final initialSave = controller.save.toJson();

        storage.failNextWrite = true;
        await expectLater(
          controller.startEncounter(1, seed: 73),
          throwsA(isA<StateError>()),
        );

        expect(controller.save.toJson(), initialSave);
        expect(controller.battle, isNull);
        expect(controller.activeEncounter, isNull);
        expect(storage.value?.toJson(), initialSave);
        expect(controller.lastError, contains('Kayıt yazılamadı'));

        await controller.startEncounter(1, seed: 73);
        expect(controller.battle, isNotNull);
        expect(controller.activeEncounter?.id, 1);
        expect(controller.save.battleCheckpoint, isNotNull);
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);

        controller.dispose();
      },
    );

    test(
      'a failed action is not applied and the same action retries once',
      () async {
        const initial = GameSave(hasHero: true, heroName: 'Kıyı');
        final storage = _FailOnceStorage()..value = initial;
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1, seed: 74);

        final originalEngine = controller.battle!;
        final originalCheckpoint = originalEngine.toCheckpointJson();
        final originalSave = controller.save.toJson();
        storage.failNextWrite = true;

        final failedAction = await controller.performAction(BattleAction.quick);
        expect(failedAction, startsWith('Kayıt yazılamadı:'));
        expect(controller.battle, same(originalEngine));
        expect(controller.battle!.toCheckpointJson(), originalCheckpoint);
        expect(controller.save.toJson(), originalSave);
        expect(storage.value?.toJson(), originalSave);

        expect(await controller.performAction(BattleAction.quick), isNull);
        final retriedEngine = controller.battle!;
        expect(retriedEngine, isNot(same(originalEngine)));
        expect(retriedEngine.metrics.turn, 1);
        expect(
          controller.save.battleCheckpoint!['engine'],
          retriedEngine.toCheckpointJson(),
        );
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 3);

        controller.dispose();
      },
    );

    test(
      'checkpoint-backed actions preserve uninterrupted combat state',
      () async {
        const initial = GameSave(hasHero: true, heroName: 'Kıyı');
        final storage = _FailOnceStorage()..value = initial;
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1, seed: 76);

        final initialEngine = controller.battle!;
        final uninterrupted = BattleEngine.restoreFromCheckpoint(
          save: initialEngine.save,
          encounter: getEncounter(1),
          checkpoint: initialEngine.toCheckpointJson(),
        );

        for (final action in const [
          BattleAction.guard,
          BattleAction.quick,
          BattleAction.heavy,
          BattleAction.guard,
          BattleAction.quick,
          BattleAction.ashBurst,
          BattleAction.guard,
          BattleAction.quick,
        ]) {
          final expectedError = uninterrupted.perform(action);
          expect(await controller.performAction(action), expectedError);
          expect(
            controller.battle!.toCheckpointJson(),
            uninterrupted.toCheckpointJson(),
          );
          if (uninterrupted.snapshot.done) break;
        }

        controller.dispose();
      },
    );

    test('lifecycle checkpoint failure is visible and retry does not replay actions', () async {
      const initial = GameSave(hasHero: true, heroName: 'Kıyı');
      final storage = _FailOnceStorage()..value = initial;
      final controller = GameController(storage: storage);
      await controller.initialize();
      await controller.startEncounter(1, seed: 75);

      final engine = controller.battle!;
      final checkpointBeforeAction = controller.save.battleCheckpoint!;
      expect(engine.perform(BattleAction.quick), isNull);
      final turnsAfterAction = engine.metrics.turn;
      storage.failNextWrite = true;

      expect(await controller.persistActiveBattleCheckpoint(), isFalse);
      expect(controller.battleCheckpointWritePending, isTrue);
      expect(controller.lastError, contains('Kayıt yazılamadı'));
      expect(controller.battle, same(engine));
      expect(controller.save.battleCheckpoint, checkpointBeforeAction);
      expect(storage.value?.toJson(), controller.save.toJson());

      expect(await controller.persistActiveBattleCheckpoint(), isTrue);
      expect(controller.battleCheckpointWritePending, isFalse);
      expect(controller.battle, same(engine));
      expect(engine.metrics.turn, turnsAfterAction);
      expect(
        controller.save.battleCheckpoint!['engine'],
        engine.toCheckpointJson(),
      );
      expect(storage.value?.toJson(), controller.save.toJson());

      controller.dispose();
    });
  });
}
