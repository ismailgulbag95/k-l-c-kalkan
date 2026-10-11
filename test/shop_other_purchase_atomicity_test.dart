import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/balance.dart';
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
  group('shop mutation persistence atomicity', () {
    test('failed spell purchase rolls back and retry commits once', () async {
      const initial = GameSave(hasHero: true, level: 5, gold: 500);
      final storage = _FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();
      var notifications = 0;
      controller.addListener(() => notifications++);

      storage.failNextWrite = true;
      expect(
        await controller.buySpell(BattleAction.emberSpear),
        startsWith('Kayıt yazılamadı:'),
      );

      expect(controller.save.toJson(), initial.toJson());
      expect(storage.value?.toJson(), initial.toJson());
      expect(controller.lastError, contains('Kayıt yazılamadı'));
      expect(storage.writeCount, 1);
      expect(notifications, 0);

      expect(await controller.buySpell(BattleAction.emberSpear), isNull);
      expect(controller.save.gold, 500 - GameBalance.spellPrices.first);
      expect(controller.save.ownedItems, {'spell_emberSpear'});
      expect(storage.value?.toJson(), controller.save.toJson());
      expect(storage.writeCount, 2);
      expect(notifications, 1);
      final purchasedSpell = controller.save.toJson();

      final duplicateResult = await controller.buySpell(
        BattleAction.emberSpear,
      );
      expect(duplicateResult, 'Bu yetenek zaten öğrenildi.');
      expect(controller.save.toJson(), purchasedSpell);
      expect(storage.writeCount, 2);
      expect(notifications, 1);

      controller.dispose();
    });

    test(
      'failed consumable purchase rolls back, retries to cap once',
      () async {
        const initial = GameSave(hasHero: true, gold: 500, healingSalves: 2);
        final storage = _FailOnceSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        var notifications = 0;
        controller.addListener(() => notifications++);
        final price = GameBalance.consumablePrice(1, salve: true);

        storage.failNextWrite = true;
        expect(
          await controller.buyConsumable(salve: true),
          startsWith('Kayıt yazılamadı:'),
        );

        expect(controller.save.toJson(), initial.toJson());
        expect(storage.value?.toJson(), initial.toJson());
        expect(controller.lastError, contains('Kayıt yazılamadı'));
        expect(storage.writeCount, 1);
        expect(notifications, 0);

        expect(await controller.buyConsumable(salve: true), isNull);
        expect(controller.save.gold, 500 - price);
        expect(controller.save.healingSalves, 3);
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);
        expect(notifications, 1);
        final cappedSave = controller.save.toJson();

        final cappedResult = await controller.buyConsumable(salve: true);
        expect(
          cappedResult,
          'Bu sarf eşyasından en fazla 3 tane taşıyabilirsin.',
        );
        expect(controller.save.toJson(), cappedSave);
        expect(storage.writeCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );

    test('failed equip rolls back and retry commits once', () async {
      const initial = GameSave(
        hasHero: true,
        gold: 500,
        ownedItems: {'sword_1', 'maul_1', 'unknown_item'},
        equippedItems: {'weapon': 'maul_1'},
      );
      final storage = _FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();
      var notifications = 0;
      controller.addListener(() => notifications++);

      storage.failNextWrite = true;
      expect(
        await controller.equip('sword_1'),
        startsWith('Kayıt yazılamadı:'),
      );

      expect(controller.save.toJson(), initial.toJson());
      expect(storage.value?.toJson(), initial.toJson());
      expect(controller.lastError, contains('Kayıt yazılamadı'));
      expect(storage.writeCount, 1);
      expect(notifications, 0);

      expect(await controller.equip('sword_1'), isNull);
      expect(controller.save.equippedItems, {'weapon': 'sword_1'});
      expect(controller.save.gold, initial.gold);
      expect(storage.value?.toJson(), controller.save.toJson());
      expect(storage.writeCount, 2);
      expect(notifications, 1);
      final equippedSave = controller.save.toJson();

      // Equipping the same item again is idempotent and does not write.
      expect(await controller.equip('sword_1'), isNull);
      expect(controller.save.toJson(), equippedSave);
      expect(storage.writeCount, 2);
      expect(notifications, 1);

      final unknownResult = await controller.equip('unknown_item');
      final unownedResult = await controller.equip('coat_1');
      expect(unknownResult, 'Bu eşya dükkân kataloğunda bulunamadı.');
      expect(unownedResult, 'Eşya envanterinde değil.');
      expect(controller.save.toJson(), equippedSave);
      expect(storage.writeCount, 2);
      expect(controller.save.equippedItems, {'weapon': 'sword_1'});
      expect(notifications, 1);

      controller.dispose();
    });

    test('invalid and insufficient purchases do not write or mutate', () async {
      const initial = GameSave(
        hasHero: true,
        gold: 0,
        ownedItems: {'spell_emberSpear'},
        healingSalves: 3,
      );
      final storage = _FailOnceSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();
      var notifications = 0;
      controller.addListener(() => notifications++);

      expect(
        await controller.buySpell(BattleAction.emberSpear),
        'Bu yetenek zaten öğrenildi.',
      );
      expect(
        await controller.buySpell(BattleAction.ashBurst),
        'Yeterli Sikke yok.',
      );
      await expectLater(
        controller.buySpell(BattleAction.quick),
        throwsA(isA<StateError>()),
      );
      expect(
        await controller.buyConsumable(salve: true),
        'Bu sarf eşyasından en fazla 3 tane taşıyabilirsin.',
      );
      expect(
        await controller.buyConsumable(salve: false),
        'Yeterli Sikke yok.',
      );

      expect(controller.save.toJson(), initial.toJson());
      expect(storage.value?.toJson(), initial.toJson());
      expect(storage.writeCount, 0);
      expect(notifications, 0);

      controller.dispose();
    });
  });
}
