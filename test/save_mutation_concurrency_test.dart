import 'dart:async';

import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

class GatedSaveStorage implements SaveStorage {
  GatedSaveStorage({this.value});

  GameSave? value;
  Completer<void>? writeEnteredCompleter;
  Completer<void>? writeGateCompleter;
  bool shouldFail = false;
  int writeCount = 0;

  @override
  Future<GameSave?> read() async => value;

  @override
  Future<void> write(GameSave save) async {
    writeCount++;
    if (writeEnteredCompleter != null && !writeEnteredCompleter!.isCompleted) {
      writeEnteredCompleter!.complete();
    }
    if (writeGateCompleter != null) {
      await writeGateCompleter!.future;
    }
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
  group('save mutation FIFO concurrency invariant', () {
    test(
      'purchase and concurrent spendStat both survive in memory and storage',
      () async {
        const initial = GameSave(
          schemaVersion: 9,
          hasHero: true,
          gold: 300,
          ownedItems: {},
          equippedItems: {},
          unspentStatPoints: 2,
          stats: Stats(might: 2),
        );
        final storage = GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();

        final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');
        expect(sword.price, 160);

        final writeEntered = Completer<void>();
        final writeGate = Completer<void>();
        storage.writeEnteredCompleter = writeEntered;
        storage.writeGateCompleter = writeGate;

        final purchaseFuture = controller.buyItem(sword);
        await writeEntered.future;

        final statFuture = controller.spendStat(Stat.might);

        writeGate.complete();
        final purchaseResult = await purchaseFuture;
        final statResult = await statFuture;

        expect(purchaseResult, isNull);
        expect(statResult, isTrue);

        expect(controller.save.gold, 140);
        expect(controller.save.ownedItems, contains('sword_1'));
        expect(controller.save.stats[Stat.might], 3);
        expect(controller.save.unspentStatPoints, 1);

        final reloaded = await storage.read();
        expect(reloaded, isNotNull);
        expect(reloaded!.gold, 140);
        expect(reloaded.ownedItems, contains('sword_1'));
        expect(reloaded.stats[Stat.might], 3);
        expect(reloaded.unspentStatPoints, 1);

        controller.dispose();
      },
    );

    test('purchase and concurrent updateHeroAppearance both survive in memory and storage', () async {
      const initial = GameSave(
        schemaVersion: 9,
        hasHero: true,
        gold: 300,
        ownedItems: {},
        equippedItems: {},
        headOptionId: 'head_01',
        skinToneId: 'skin_01',
        bodyProportionId: 'body_01',
        facialHairId: 'facial_hair_00',
      );
      final storage = GatedSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');

      final writeEntered = Completer<void>();
      final writeGate = Completer<void>();
      storage.writeEnteredCompleter = writeEntered;
      storage.writeGateCompleter = writeGate;

      final purchaseFuture = controller.buyItem(sword);
      await writeEntered.future;

      final appearanceFuture = controller.updateHeroAppearance(
        headOptionId: 'head_02',
        skinToneId: 'skin_02',
        bodyProportionId: 'body_02',
        facialHairId: 'facial_hair_01',
      );

      writeGate.complete();
      final purchaseResult = await purchaseFuture;
      final appearanceResult = await appearanceFuture;

      expect(purchaseResult, isNull);
      expect(appearanceResult, isTrue);

      expect(controller.save.gold, 140);
      expect(controller.save.ownedItems, contains('sword_1'));
      expect(controller.save.headOptionId, 'head_02');
      expect(controller.save.skinToneId, 'skin_02');

      final reloaded = await storage.read();
      expect(reloaded, isNotNull);
      expect(reloaded!.gold, 140);
      expect(reloaded.ownedItems, contains('sword_1'));
      expect(reloaded.headOptionId, 'head_02');
      expect(reloaded.skinToneId, 'skin_02');

      controller.dispose();
    });

    test('purchase interleavings with buySpell, buyConsumable, and equip all survive and agree', () async {
      const initial = GameSave(
        schemaVersion: 9,
        hasHero: true,
        gold: 500,
        level: 5,
        ownedItems: {},
        equippedItems: {},
        healingSalves: 0,
      );
      final storage = GatedSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');
      expect(sword.price, 160);

      final writeEntered = Completer<void>();
      final writeGate = Completer<void>();
      storage.writeEnteredCompleter = writeEntered;
      storage.writeGateCompleter = writeGate;

      final purchaseFuture = controller.buyItem(sword);
      await writeEntered.future;

      final spellFuture = controller.buySpell(BattleAction.emberSpear);
      final consumableFuture = controller.buyConsumable(salve: true);
      final equipFuture = controller.equip('sword_1');

      writeGate.complete();
      final purchaseResult = await purchaseFuture;
      final spellResult = await spellFuture;
      final consumableResult = await consumableFuture;
      final equipResult = await equipFuture;

      expect(purchaseResult, isNull);
      expect(spellResult, isNull);
      expect(consumableResult, isNull);
      expect(equipResult, isNull);

      // 500 - 160 (sword) - 140 (emberSpear) - 55 (salve) = 145
      expect(controller.save.gold, 145);
      expect(
        controller.save.ownedItems,
        containsAll({'sword_1', 'spell_emberSpear'}),
      );
      expect(controller.save.healingSalves, 1);
      expect(controller.save.equippedItems['weapon'], 'sword_1');

      final reloaded = await storage.read();
      expect(reloaded, isNotNull);
      expect(reloaded!.gold, 145);
      expect(reloaded.ownedItems, containsAll({'sword_1', 'spell_emberSpear'}));
      expect(reloaded.healingSalves, 1);
      expect(reloaded.equippedItems['weapon'], 'sword_1');

      expect(controller.save.gold, storage.value?.gold);
      expect(controller.save.ownedItems, storage.value?.ownedItems);
      expect(controller.save.healingSalves, storage.value?.healingSalves);
      expect(controller.save.equippedItems, storage.value?.equippedItems);

      controller.dispose();
    });

    test('shop pending plus startEncounter serializes and battle context has shop change', () async {
      const initial = GameSave(
        schemaVersion: 9,
        hasHero: true,
        gold: 300,
        ownedItems: {},
        equippedItems: {},
      );
      final storage = GatedSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');

      final writeEntered = Completer<void>();
      final writeGate = Completer<void>();
      storage.writeEnteredCompleter = writeEntered;
      storage.writeGateCompleter = writeGate;

      final purchaseFuture = controller.buyItem(sword);
      await writeEntered.future;

      final encounterFuture = controller.startEncounter(1, seed: 42);

      writeGate.complete();
      await purchaseFuture;
      await encounterFuture;

      expect(controller.save.gold, 140);
      expect(controller.save.ownedItems, contains('sword_1'));
      expect(controller.battle, isNotNull);
      expect(controller.battle!.save.ownedItems, contains('sword_1'));
      expect(controller.save.battleCheckpoint, isNotNull);

      final checkpoint = controller.save.battleCheckpoint!;
      final battleSaveData = checkpoint['battleSave'] as Map<String, dynamic>;
      expect(
        (battleSaveData['ownedItems'] as List).cast<String>(),
        contains('sword_1'),
      );

      final reloaded = await storage.read();
      expect(reloaded, isNotNull);
      expect(reloaded!.gold, 140);
      expect(reloaded.ownedItems, contains('sword_1'));
      expect(reloaded.battleCheckpoint, isNotNull);

      controller.dispose();
    });

    test('failed purchase preserves economy rollback and allows queue recovery for next mutation', () async {
      const initial = GameSave(
        schemaVersion: 9,
        hasHero: true,
        gold: 300,
        unspentStatPoints: 2,
        stats: Stats(might: 2),
      );
      final storage = GatedSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');

      storage.shouldFail = true;
      final purchaseResult = await controller.buyItem(sword);

      expect(purchaseResult, isNotNull);
      expect(purchaseResult, contains('Kayıt yazılamadı'));
      expect(controller.save.gold, 300);
      expect(controller.save.ownedItems, isEmpty);

      final statResult = await controller.spendStat(Stat.might);
      expect(statResult, isTrue);
      expect(controller.save.stats[Stat.might], 3);
      expect(controller.save.unspentStatPoints, 1);
      expect(controller.save.gold, 300);

      final reloaded = await storage.read();
      expect(reloaded!.stats[Stat.might], 3);
      expect(reloaded.unspentStatPoints, 1);
      expect(reloaded.gold, 300);

      controller.dispose();
    });

    test('storage failure on non-shop mutation throws and queue recovers for next mutation', () async {
      const initial = GameSave(
        schemaVersion: 9,
        hasHero: true,
        gold: 300,
        unspentStatPoints: 2,
        stats: Stats(might: 2),
      );
      final storage = GatedSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      storage.shouldFail = true;
      await expectLater(
        controller.spendStat(Stat.might),
        throwsA(isA<Exception>()),
      );

      expect(controller.save.stats[Stat.might], 3);
      expect(controller.save.unspentStatPoints, 1);

      final uncommitted = await storage.read();
      expect(uncommitted, isNotNull);
      expect(uncommitted!.stats[Stat.might], 2);
      expect(uncommitted.unspentStatPoints, 2);

      final statResult = await controller.spendStat(Stat.might);
      expect(statResult, isTrue);
      expect(controller.save.stats[Stat.might], 4);
      expect(controller.save.unspentStatPoints, 0);

      final reloaded = await storage.read();
      expect(reloaded, isNotNull);
      expect(reloaded!.stats[Stat.might], 4);
      expect(reloaded.unspentStatPoints, 0);

      controller.dispose();
    });
  });
}
