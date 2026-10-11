import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailOnceStorage extends MemorySaveStorage {
  bool failNextWrite = false;
  int writeCount = 0;
  int? failOnWriteNumber;

  @override
  Future<void> write(GameSave save) async {
    writeCount++;
    if (failNextWrite || writeCount == failOnWriteNumber) {
      failNextWrite = false;
      failOnWriteNumber = null;
      throw StateError('simulated save failure');
    }
    await super.write(save);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pending lifecycle checkpoint shows a distinct retry banner', (
    tester,
  ) async {
    const initial = GameSave(hasHero: true, heroName: 'Kıyı', language: 'en');
    final storage = _FailOnceStorage()..value = initial;
    final controller = GameController(storage: storage);
    await controller.initialize();
    await controller.startEncounter(1, seed: 83);
    expect(controller.battle!.perform(BattleAction.quick), isNull);

    await tester.pumpWidget(_battleApp(controller, resume: true));
    storage.failNextWrite = true;
    expect(await controller.persistActiveBattleCheckpoint(), isFalse);
    await tester.pumpAndSettle();

    const message =
        'The latest fight progress is not saved yet. Retry before leaving.';
    expect(find.text(message), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(controller.battleCheckpointWritePending, isFalse);
    expect(find.text(message), findsNothing);
    expect(
      controller.save.battleCheckpoint!['engine'],
      controller.battle!.toCheckpointJson(),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets(
    'failed result save retries the same result and commits rewards once',
    (tester) async {
      const initial = GameSave(
        hasHero: true,
        heroName: 'Kıyı',
        gold: 500,
        language: 'en',
      );
      final storage = _FailOnceStorage()..value = initial;
      final controller = GameController(storage: storage);
      await controller.initialize();
      await controller.startEncounter(1, seed: 84);

      for (
        var turn = 0;
        turn < 40 && !controller.battle!.snapshot.done;
        turn++
      ) {
        final engine = controller.battle!;
        engine.player.health = engine.player.maxHealth;
        engine.player.effort = engine.player.maxEffort;
        engine.opponent.health = 1;
        expect(await controller.performAction(BattleAction.quick), isNull);
      }
      expect(controller.battle!.snapshot.done, isTrue);
      final encounter = controller.activeEncounter!;
      final saveBeforeResolution = controller.save.toJson();
      storage.failOnWriteNumber = storage.writeCount + 1;

      await tester.pumpWidget(_battleApp(controller, resume: true));
      await tester.pumpAndSettle();

      const failureMessage =
          'The duel result could not be saved. Retry will save the same result and rewards safely.';
      expect(find.text(failureMessage), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
      expect(controller.save.toJson(), saveBeforeResolution);
      expect(storage.value?.toJson(), saveBeforeResolution);
      expect(controller.save.battleCheckpoint, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(controller.save.completedMatches, contains(encounter.key));
      expect(controller.save.gold, initial.gold + encounter.gold);
      expect(controller.save.xp, initial.xp + encounter.xp);
      expect(controller.save.battleCheckpoint, isNull);
      expect(find.text('Victory'), findsOneWidget);
      expect(find.text('Return to league'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );
}

Widget _battleApp(GameController controller, {bool resume = false}) =>
    MaterialApp(
      theme: buildGameTheme(),
      home: GameLocaleScope(
        languageCode: 'en',
        child: BattlePage(controller: controller, resumeFromCheckpoint: resume),
      ),
    );
