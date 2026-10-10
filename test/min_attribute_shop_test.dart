import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ShopItem restrictedItem;

  setUp(() {
    restrictedItem = shopItems
        .where((item) => item.minAttribute != null)
        .firstOrNull!;
  });

  test(
    'purchase and equip reject a missing attribute requirement atomically',
    () async {
      final save = _saveForItem(
        restrictedItem,
        stats: Stats().withStat(
          restrictedItem.minAttribute!,
          restrictedItem.minAttributeValue - 1,
        ),
      );
      final storage = MemorySaveStorage()..value = save;
      final controller = GameController(storage: storage);
      await controller.initialize();
      final before = controller.save.toJson();

      expect(await controller.buyItem(restrictedItem), isNotNull);
      expect(controller.save.toJson(), before);
      expect(storage.value?.toJson(), before);

      final equippedSave = save.copyWith(
        ownedItems: {...save.ownedItems, restrictedItem.id},
      );
      storage.value = equippedSave;
      await controller.initialize();
      final beforeEquip = controller.save.toJson();
      expect(await controller.equip(restrictedItem.id), isNotNull);
      expect(controller.save.toJson(), beforeEquip);
      expect(storage.value?.toJson(), beforeEquip);

      controller.dispose();
    },
  );

  test('requirement threshold itself permits purchase', () async {
    final save = _saveForItem(
      restrictedItem,
      stats: Stats().withStat(
        restrictedItem.minAttribute!,
        restrictedItem.minAttributeValue,
      ),
    );
    final controller = GameController(
      storage: MemorySaveStorage()..value = save,
    );
    await controller.initialize();

    expect(await controller.buyItem(restrictedItem), isNull);
    expect(controller.save.ownedItems, contains(restrictedItem.id));
    expect(
      controller.save.equippedItems[restrictedItem.category],
      restrictedItem.id,
    );

    controller.dispose();
  });

  test(
    'respec unequips gear whose stat requirement is no longer met',
    () async {
      final save =
          _saveForItem(
            restrictedItem,
            stats: Stats().withStat(
              restrictedItem.minAttribute!,
              restrictedItem.minAttributeValue,
            ),
          ).copyWith(
            ownedItems: {restrictedItem.id},
            equippedItems: {restrictedItem.category: restrictedItem.id},
            rebirthCredits: 1,
          );
      final storage = MemorySaveStorage()..value = save;
      final controller = GameController(storage: storage);
      await controller.initialize();

      expect(await controller.redistributeStats(), isTrue);
      expect(controller.save.stats, const Stats());
      expect(controller.save.ownedItems, contains(restrictedItem.id));
      expect(
        controller.save.equippedItems.keys,
        isNot(contains(restrictedItem.category)),
      );
      expect(storage.value?.equippedItems, controller.save.equippedItems);

      final restored = GameController(storage: storage);
      await restored.initialize();
      await restored.startEncounter(1, seed: 6001);
      expect(restored.battle!.player.stats[restrictedItem.minAttribute!], 2);

      controller.dispose();
      restored.dispose();
    },
  );

  testWidgets('shop shows a localized minimum stat and disables purchase', (
    tester,
  ) async {
    final save = _saveForItem(
      restrictedItem,
      stats: Stats().withStat(
        restrictedItem.minAttribute!,
        restrictedItem.minAttributeValue - 1,
      ),
    );
    final controller = GameController(
      storage: MemorySaveStorage()..value = save,
    );
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
    final itemName = const GameLocalizations('tr')
        .text('content.item.${restrictedItem.id}.name');
    await tester.scrollUntilVisible(
      find.text(itemName),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final attributeName = const GameLocalizations('tr')
        .text('label.stat.${restrictedItem.minAttribute!.name}');
    expect(
      find.text('$attributeName ${restrictedItem.minAttributeValue} gerekli.'),
      findsOneWidget,
    );

    final itemCard = find
        .ancestor(of: find.text(itemName), matching: find.byType(GamePanel))
        .first;
    final buyButton = find.descendant(
      of: itemCard,
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(buyButton).onPressed, isNull);

    controller.dispose();
  });
}

GameSave _saveForItem(ShopItem item, {required Stats stats}) => GameSave(
  hasHero: true,
  level: 20,
  gold: 10000,
  stats: stats,
  completedMatches: {
    for (var id = 1; id < (item.act - 1) * 8 + 1; id++)
      'M${id.toString().padLeft(2, '0')}',
  },
);
