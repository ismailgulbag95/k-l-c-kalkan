import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailOnceMigrationStorage extends MemorySaveStorage {
  bool failNextWrite = true;

  @override
  Future<void> write(GameSave save) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('simulated migration failure');
    }
    await super.write(save);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('failed save migration is visible and can be retried', (
    tester,
  ) async {
    final storage = _FailOnceMigrationStorage()
      ..value = const GameSave(
        schemaVersion: 9,
        hasHero: true,
        heroName: 'Kıyı',
        language: 'en',
      );
    final controller = GameController(storage: storage);
    await controller.initialize();

    expect(controller.schemaMigrationPending, isTrue);
    await tester.pumpWidget(GameRoot(controller: controller));
    await tester.pumpAndSettle();

    const message =
        'The save format could not be updated. Your current progress is intact.';
    expect(find.text(message), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(controller.schemaMigrationPending, isFalse);
    expect(controller.save.schemaVersion, 10);
    expect(storage.value?.schemaVersion, 10);
    expect(find.text(message), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
