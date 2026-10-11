import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/balance.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailOnceStorage extends MemorySaveStorage {
  bool failNextWrite = false;

  @override
  Future<void> write(GameSave save) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('simulated save failure');
    }
    await super.write(save);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('spell purchase shows a localized retry action', (tester) async {
    const initial = GameSave(
      hasHero: true,
      level: 20,
      gold: 1000,
      language: 'en',
    );
    final storage = _FailOnceStorage()..value = initial;
    final controller = GameController(storage: storage);
    await controller.initialize();
    storage.failNextWrite = true;

    await _openShop(tester, controller);
    await tester.tap(find.text('Spells'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Learn').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The save could not be written. The action was not applied; retry safely.',
      ),
      findsOneWidget,
    );
    await _tapRetry(tester);
    expect(controller.save.ownedItems, contains('spell_emberSpear'));
    expect(controller.save.gold, 1000 - GameBalance.spellPrices.first);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('consumable purchase retries the uncommitted operation once', (
    tester,
  ) async {
    const initial = GameSave(hasHero: true, gold: 1000, language: 'en');
    final storage = _FailOnceStorage()..value = initial;
    final controller = GameController(storage: storage);
    await controller.initialize();
    storage.failNextWrite = true;

    await _openShop(tester, controller);
    await tester.tap(find.text('Supplies'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Purchase').first);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBarAction), findsOneWidget);
    await _tapRetry(tester);
    expect(controller.save.healingSalves, 1);
    expect(
      controller.save.gold,
      1000 - GameBalance.consumablePrice(1, salve: true),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('equip failure exposes retry and commits only once', (
    tester,
  ) async {
    const initial = GameSave(
      hasHero: true,
      gold: 500,
      language: 'en',
      ownedItems: {'sword_1'},
    );
    final storage = _FailOnceStorage()..value = initial;
    final controller = GameController(storage: storage);
    await controller.initialize();
    storage.failNextWrite = true;

    await _openShop(tester, controller);
    await tester.tap(find.text('Weapons'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Equip').first);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBarAction), findsOneWidget);
    await _tapRetry(tester);
    expect(controller.save.equippedItems['weapon'], 'sword_1');
    expect(controller.save.gold, initial.gold);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('equipment purchase failure exposes retry', (tester) async {
    const initial = GameSave(
      hasHero: true,
      level: 20,
      gold: 500,
      language: 'en',
    );
    final storage = _FailOnceStorage()..value = initial;
    final controller = GameController(storage: storage);
    await controller.initialize();
    storage.failNextWrite = true;

    await _openShop(tester, controller);
    await tester.tap(find.text('Weapons'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Buy').first);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBarAction), findsOneWidget);
    expect(controller.save.ownedItems, isNot(contains('sword_1')));
    await _tapRetry(tester);
    expect(controller.save.ownedItems, contains('sword_1'));
    expect(controller.save.gold, initial.gold - 160);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _openShop(WidgetTester tester, GameController controller) async {
  await tester.pumpWidget(GameRoot(controller: controller));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Shop').first);
  await tester.pumpAndSettle();
}

Future<void> _tapRetry(WidgetTester tester) async {
  expect(find.byType(SnackBarAction), findsOneWidget);
  await tester.tap(find.byType(SnackBarAction));
  await tester.pump();
  await tester.pumpAndSettle();
}
