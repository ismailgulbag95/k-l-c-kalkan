import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gear resale', () {
    test(
      'sells owned unequipped gear once for half its listed price',
      () async {
        final initial = GameSave(
          hasHero: true,
          gold: 7,
          ownedItems: {'coat_1', 'sword_1'},
          equippedItems: {'weapon': 'sword_1'},
        );
        final storage = MemorySaveStorage()..value = initial;
        final controller = GameController(storage: storage);
        await controller.initialize();
        final item = shopItems.firstWhere((entry) => entry.id == 'coat_1');

        expect(await controller.sellItem(item.id), isNull);
        expect(controller.save.gold, 7 + item.price ~/ 2);
        expect(controller.save.gold, greaterThanOrEqualTo(0));
        expect(controller.save.ownedItems, {'sword_1'});
        expect(controller.save.equippedItems, {'weapon': 'sword_1'});
        expect(storage.value?.gold, controller.save.gold);
        expect(storage.value?.ownedItems, {'sword_1'});

        final reloaded = GameController(storage: storage);
        await reloaded.initialize();
        expect(reloaded.save.gold, controller.save.gold);
        expect(reloaded.save.ownedItems, {'sword_1'});

        expect(await controller.sellItem(item.id), isNotNull);
        expect(controller.save.gold, 7 + item.price ~/ 2);
        expect(storage.value?.gold, controller.save.gold);

        controller.dispose();
        reloaded.dispose();
      },
    );

    test(
      'rejects unknown, unowned, and equipped items without mutation',
      () async {
        final initial = GameSave(
          hasHero: true,
          gold: 275,
          ownedItems: {'sword_1'},
          equippedItems: {'weapon': 'sword_1'},
        );
        final storage = MemorySaveStorage()..value = initial;
        final controller = GameController(storage: storage);
        await controller.initialize();
        final before = controller.save.toJson();

        for (final id in ['not_in_catalog', 'coat_1', 'sword_1']) {
          expect(await controller.sellItem(id), isNotNull, reason: id);
          expect(controller.save.toJson(), before, reason: id);
          expect(storage.value?.toJson(), before, reason: id);
        }

        controller.dispose();
      },
    );

    test('sale clamps a damaged negative balance to zero', () async {
      final storage = MemorySaveStorage()
        ..value = GameSave(hasHero: true, gold: -100, ownedItems: {'coat_1'});
      final controller = GameController(storage: storage);
      await controller.initialize();

      expect(await controller.sellItem('coat_1'), isNull);
      expect(controller.save.gold, 0);
      expect(controller.save.ownedItems, isEmpty);
      expect(storage.value?.gold, 0);

      controller.dispose();
    });

    testWidgets('shop offers selling owned gear and confirms the payout', (
      tester,
    ) async {
      final storage = MemorySaveStorage()
        ..value = GameSave(hasHero: true, gold: 20, ownedItems: {'coat_1'});
      final controller = GameController(storage: storage);
      await controller.initialize();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: Scaffold(
            body: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => ShopPage(controller: controller),
            ),
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('EKİPMAN SATIŞI'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Kuşanılmamış ekipmanını alış fiyatının yarısına satabilirsin.',
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('60 Sikke'),
        140,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('60 Sikke'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Sat'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Sat'));
      await tester.pumpAndSettle();

      expect(controller.save.gold, 80);
      expect(controller.save.ownedItems, isEmpty);
      expect(find.text('60 Sikke envanterine eklendi.'), findsOneWidget);

      controller.dispose();
    });
  });
}
