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
  group('shop and settings persistence concurrency', () {
    test('purchase and concurrent updateSettings both survive in memory and storage', () async {
      const initial = GameSave(
        schemaVersion: 9,
        hasHero: true,
        gold: 300,
        ownedItems: {},
        equippedItems: {},
        sfxEnabled: true,
        musicVolume: 0.65,
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

      final settingsFuture = controller.updateSettings(
        sfxEnabled: false,
        musicVolume: 0.2,
      );

      writeGate.complete();
      final purchaseResult = await purchaseFuture;
      await settingsFuture;

      expect(purchaseResult, isNull);

      expect(controller.save.gold, 140);
      expect(controller.save.ownedItems, contains('sword_1'));
      expect(controller.save.sfxEnabled, isFalse);
      expect(controller.save.musicVolume, 0.2);

      final reloaded = await storage.read();
      expect(reloaded, isNotNull);
      expect(reloaded!.gold, 140);
      expect(reloaded.ownedItems, contains('sword_1'));
      expect(reloaded.sfxEnabled, isFalse);
      expect(reloaded.musicVolume, 0.2);

      expect(controller.save.gold, storage.value?.gold);
      expect(controller.save.ownedItems, storage.value?.ownedItems);
      expect(controller.save.equippedItems, storage.value?.equippedItems);
      expect(controller.save.sfxEnabled, storage.value?.sfxEnabled);
      expect(controller.save.musicVolume, storage.value?.musicVolume);

      controller.dispose();
    });

    test(
      'sale and concurrent updateSettings both survive in memory and storage',
      () async {
        const initial = GameSave(
          schemaVersion: 9,
          hasHero: true,
          gold: 50,
          ownedItems: {'coat_1'},
          equippedItems: {},
          sfxEnabled: true,
        );
        final storage = GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();

        final coat = shopItems.firstWhere((entry) => entry.id == 'coat_1');
        expect(coat.price, 120);
        final expectedResale = coat.price ~/ 2;

        final writeEntered = Completer<void>();
        final writeGate = Completer<void>();
        storage.writeEnteredCompleter = writeEntered;
        storage.writeGateCompleter = writeGate;

        final saleFuture = controller.sellItem('coat_1');
        await writeEntered.future;

        final settingsFuture = controller.updateSettings(sfxEnabled: false);

        writeGate.complete();
        final saleResult = await saleFuture;
        await settingsFuture;

        expect(saleResult, isNull);

        expect(controller.save.gold, 50 + expectedResale);
        expect(controller.save.ownedItems, isEmpty);
        expect(controller.save.sfxEnabled, isFalse);

        final reloaded = await storage.read();
        expect(reloaded, isNotNull);
        expect(reloaded!.gold, 110);
        expect(reloaded.ownedItems, isEmpty);
        expect(reloaded.sfxEnabled, isFalse);

        expect(controller.save.gold, storage.value?.gold);
        expect(controller.save.ownedItems, storage.value?.ownedItems);
        expect(controller.save.sfxEnabled, storage.value?.sfxEnabled);

        controller.dispose();
      },
    );

    test('failed purchase with concurrent updateSettings preserves economy rollback while saving settings', () async {
      const initial = GameSave(
        schemaVersion: 9,
        hasHero: true,
        gold: 300,
        ownedItems: {},
        equippedItems: {},
        sfxEnabled: true,
      );
      final storage = GatedSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();

      final sword = shopItems.firstWhere((entry) => entry.id == 'sword_1');

      final writeEntered = Completer<void>();
      final writeGate = Completer<void>();
      storage.writeEnteredCompleter = writeEntered;
      storage.writeGateCompleter = writeGate;
      storage.shouldFail = true;

      final purchaseFuture = controller.buyItem(sword);
      await writeEntered.future;

      final settingsFuture = controller.updateSettings(sfxEnabled: false);

      writeGate.complete();
      final purchaseResult = await purchaseFuture;
      await settingsFuture;

      expect(purchaseResult, isNotNull);
      expect(purchaseResult, contains('Kayıt yazılamadı'));

      expect(controller.save.gold, 300);
      expect(controller.save.ownedItems, isEmpty);
      expect(controller.save.sfxEnabled, isFalse);

      final reloaded = await storage.read();
      expect(reloaded, isNotNull);
      expect(reloaded!.gold, 300);
      expect(reloaded.ownedItems, isEmpty);
      expect(reloaded.sfxEnabled, isFalse);

      expect(controller.save.gold, storage.value?.gold);
      expect(controller.save.ownedItems, storage.value?.ownedItems);
      expect(controller.save.sfxEnabled, storage.value?.sfxEnabled);

      controller.dispose();
    });
  });
}
