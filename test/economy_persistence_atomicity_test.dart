import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

class FailOnceSaveStorage implements SaveStorage {
  FailOnceSaveStorage({this.value});

  GameSave? value;
  bool shouldFail = false;
  int writeCount = 0;

  @override
  Future<GameSave?> read() async => value;

  @override
  Future<void> write(GameSave save) async {
    writeCount++;
    if (shouldFail) {
      shouldFail = false;
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
  group('economy persistence atomicity', () {
    test('failed purchase preserves gold, inventory, and equipment in memory and storage, and retry succeeds with auto-equip without double charge', () async {
      const initial = GameSave(
        hasHero: true,
        gold: 300,
        ownedItems: {},
        equippedItems: {},
      );
      final storage = FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');
      expect(sword.price, 160);
      expect(sword.category, 'weapon');

      storage.shouldFail = true;
      final purchaseFailure = await controller.buyItem(sword);

      expect(purchaseFailure, isNotNull);
      expect(purchaseFailure, contains('Kayıt yazılamadı'));
      expect(controller.save.gold, 300);
      expect(controller.save.ownedItems, isEmpty);
      expect(controller.save.equippedItems, isEmpty);
      expect(storage.value?.gold, 300);
      expect(storage.value?.ownedItems, isEmpty);
      expect(storage.value?.equippedItems, isEmpty);
      expect(storage.writeCount, 1);

      final retryResult = await controller.buyItem(sword);

      expect(retryResult, isNull);
      expect(controller.save.gold, 140);
      expect(controller.save.ownedItems, {'sword_1'});
      expect(controller.save.equippedItems, {'weapon': 'sword_1'});
      expect(storage.value?.gold, 140);
      expect(storage.value?.ownedItems, {'sword_1'});
      expect(storage.value?.equippedItems, {'weapon': 'sword_1'});
      expect(storage.writeCount, 2);

      final duplicatePurchase = await controller.buyItem(sword);
      expect(duplicatePurchase, 'Bu eşya zaten envanterinde.');
      expect(controller.save.gold, 140);
      expect(storage.value?.gold, 140);
      expect(storage.writeCount, 2);

      controller.dispose();
    });

    test('failed sale preserves gold, inventory, and equipment in memory and storage, and retry succeeds with 50%-floor resale without duplicate resale', () async {
      const initial = GameSave(
        hasHero: true,
        gold: 50,
        ownedItems: {'coat_1'},
        equippedItems: {},
      );
      final storage = FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final coat = shopItems.firstWhere((entry) => entry.id == 'coat_1');
      expect(coat.price, 120);
      final expectedResale = coat.price ~/ 2;
      expect(expectedResale, 60);

      storage.shouldFail = true;
      final saleFailure = await controller.sellItem('coat_1');

      expect(saleFailure, isNotNull);
      expect(saleFailure, contains('Kayıt yazılamadı'));
      expect(controller.save.gold, 50);
      expect(controller.save.ownedItems, {'coat_1'});
      expect(controller.save.equippedItems, isEmpty);
      expect(storage.value?.gold, 50);
      expect(storage.value?.ownedItems, {'coat_1'});
      expect(storage.value?.equippedItems, isEmpty);
      expect(storage.writeCount, 1);

      final retryResult = await controller.sellItem('coat_1');

      expect(retryResult, isNull);
      expect(controller.save.gold, 50 + expectedResale);
      expect(controller.save.ownedItems, isEmpty);
      expect(storage.value?.gold, 110);
      expect(storage.value?.ownedItems, isEmpty);
      expect(storage.writeCount, 2);

      final duplicateSale = await controller.sellItem('coat_1');
      expect(duplicateSale, 'Eşya envanterinde değil.');
      expect(controller.save.gold, 110);
      expect(storage.value?.gold, 110);
      expect(storage.writeCount, 2);

      controller.dispose();
    });

    test('successful purchase auto-equips when slot is empty, but preserves existing equipment when slot is occupied', () async {
      const initial = GameSave(
        hasHero: true,
        gold: 500,
        ownedItems: {'maul_1'},
        equippedItems: {'weapon': 'maul_1'},
      );
      final storage = FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');
      final helm = shopItems.firstWhere((entry) => entry.id == 'helm_1');

      expect(await controller.buyItem(sword), isNull);
      expect(controller.save.equippedItems['weapon'], 'maul_1');
      expect(controller.save.ownedItems, containsAll({'maul_1', 'sword_1'}));

      expect(await controller.buyItem(helm), isNull);
      expect(controller.save.equippedItems['head'], 'helm_1');
      expect(controller.save.equippedItems['weapon'], 'maul_1');

      controller.dispose();
    });

    test('sale applies 50%-floor resale and clamps negative starting balance to zero', () async {
      const initial = GameSave(
        hasHero: true,
        gold: -100,
        ownedItems: {'coat_1'},
        equippedItems: {},
      );
      final storage = FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      expect(await controller.sellItem('coat_1'), isNull);
      expect(controller.save.gold, 0);
      expect(controller.save.ownedItems, isEmpty);
      expect(storage.value?.gold, 0);

      controller.dispose();
    });

    test('concurrent shop transactions do not double charge or allow negative balance', () async {
      const initial = GameSave(
        hasHero: true,
        gold: 200,
        ownedItems: {},
        equippedItems: {},
      );
      final storage = FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere(
        (entry) => entry.id == 'sword_1',
      ); // 160
      final maul = shopItems.firstWhere((entry) => entry.id == 'maul_1'); // 190

      final results = await Future.wait([
        controller.buyItem(sword),
        controller.buyItem(maul),
      ]);

      final successes = results.where((r) => r == null).length;
      final failures = results.where((r) => r == 'Yeterli Sikke yok.').length;

      expect(successes, 1);
      expect(failures, 1);
      expect(controller.save.gold, greaterThanOrEqualTo(0));
      expect(controller.save.ownedItems.length, 1);
      expect(storage.value?.gold, controller.save.gold);
      expect(storage.value?.ownedItems, controller.save.ownedItems);

      controller.dispose();
    });

    test('concurrent shop transaction where first fails persistence does not corrupt the second operation', () async {
      const initial = GameSave(
        hasHero: true,
        gold: 300,
        ownedItems: {},
        equippedItems: {},
      );
      final storage = FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere(
        (entry) => entry.id == 'sword_1',
      ); // 160
      final maul = shopItems.firstWhere((entry) => entry.id == 'maul_1'); // 190

      storage.shouldFail = true;

      final results = await Future.wait([
        controller.buyItem(sword),
        controller.buyItem(maul),
      ]);

      expect(results[0], contains('Kayıt yazılamadı'));
      expect(results[1], isNull);

      expect(controller.save.ownedItems, {'maul_1'});
      expect(controller.save.gold, 300 - 190);
      expect(storage.value?.ownedItems, {'maul_1'});
      expect(storage.value?.gold, 110);
      expect(storage.writeCount, 2);

      controller.dispose();
    });
  });
}
