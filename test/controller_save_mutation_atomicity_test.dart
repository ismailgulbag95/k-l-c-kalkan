import 'dart:async';

import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _StorageGate {
  _StorageGate({this.fail = true});

  final bool fail;
  final entered = Completer<void>();
  final releaseSignal = Completer<void>();

  void release() => releaseSignal.complete();
}

class _GatedSaveStorage implements SaveStorage {
  _GatedSaveStorage({this.value});

  GameSave? value;
  int writeCount = 0;
  int clearCount = 0;
  _StorageGate? _nextWriteGate;
  _StorageGate? _nextClearGate;

  _StorageGate gateNextWrite({bool fail = true}) {
    final gate = _StorageGate(fail: fail);
    _nextWriteGate = gate;
    return gate;
  }

  _StorageGate gateNextClear({bool fail = true}) {
    final gate = _StorageGate(fail: fail);
    _nextClearGate = gate;
    return gate;
  }

  @override
  Future<GameSave?> read() async => value;

  @override
  Future<void> write(GameSave save) async {
    writeCount++;
    final gate = _nextWriteGate;
    _nextWriteGate = null;
    await _waitAtGate(gate);
    value = save;
  }

  @override
  Future<void> clear() async {
    clearCount++;
    final gate = _nextClearGate;
    _nextClearGate = null;
    await _waitAtGate(gate);
    value = null;
  }

  Future<void> _waitAtGate(_StorageGate? gate) async {
    if (gate == null) return;
    gate.entered.complete();
    await gate.releaseSignal.future;
    if (gate.fail) throw Exception('Simulated storage write error');
  }
}

void main() {
  group('controller durable save mutation atomicity', () {
    test(
      'story evidence remains pending until its seen marker persists',
      () async {
        const initial = GameSave(hasHero: true, completedMatches: {'M04'});
        final storage = _GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        expect(controller.pendingStoryEvidence?.id, 'E04');
        var notifications = 0;
        controller.addListener(() => notifications++);

        final gate = storage.gateNextWrite();
        final markFuture = controller.markStoryEvidenceSeen('E04');
        await gate.entered.future;
        expect(controller.save.toJson(), initial.toJson());
        expect(controller.pendingStoryEvidence?.id, 'E04');
        expect(notifications, 0);
        gate.release();
        await expectLater(markFuture, throwsA(isA<Exception>()));

        expect(controller.save.toJson(), initial.toJson());
        expect(storage.value?.toJson(), initial.toJson());
        expect(controller.pendingStoryEvidence?.id, 'E04');
        expect(notifications, 0);
        expect(await controller.markStoryEvidenceSeen('E04'), isTrue);
        expect(controller.save.seenStoryEvidence, {'E04'});
        expect(controller.pendingStoryEvidence, isNull);
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);
        expect(notifications, 1);
        expect(await controller.markStoryEvidenceSeen('E04'), isFalse);
        expect(storage.writeCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );

    test('hero creation commits only after the save write succeeds', () async {
      const initial = GameSave();
      final storage = _GatedSaveStorage(value: initial);
      final controller = GameController(storage: storage);
      await controller.initialize();
      var notifications = 0;
      controller.addListener(() => notifications++);

      final gate = storage.gateNextWrite();
      final createFuture = controller.createHero(
        name: 'Kıyı',
        stats: const Stats(might: 4, agility: 4, vitality: 4),
      );
      await gate.entered.future;
      expect(controller.save.toJson(), initial.toJson());
      expect(controller.save.hasHero, isFalse);
      expect(notifications, 0);
      gate.release();
      await expectLater(createFuture, throwsA(isA<Exception>()));

      expect(controller.save.toJson(), initial.toJson());
      expect(storage.value?.toJson(), initial.toJson());
      expect(notifications, 0);
      await controller.createHero(
        name: 'Kıyı',
        stats: const Stats(might: 4, agility: 4, vitality: 4),
      );
      expect(controller.save.hasHero, isTrue);
      expect(controller.save.heroName, 'Kıyı');
      expect(storage.value?.toJson(), controller.save.toJson());
      expect(storage.writeCount, 2);
      expect(notifications, 1);

      controller.dispose();
    });

    test(
      'appearance changes roll back on failed writes and retry cleanly',
      () async {
        const initial = GameSave(hasHero: true);
        final storage = _GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        var notifications = 0;
        controller.addListener(() => notifications++);

        final gate = storage.gateNextWrite();
        final updateFuture = controller.updateHeroAppearance(
          bodyProportionId: 'body_02',
        );
        await gate.entered.future;
        expect(controller.save.toJson(), initial.toJson());
        expect(notifications, 0);
        gate.release();
        await expectLater(updateFuture, throwsA(isA<Exception>()));

        expect(controller.save.toJson(), initial.toJson());
        expect(storage.value?.toJson(), initial.toJson());
        expect(notifications, 0);
        expect(
          await controller.updateHeroAppearance(bodyProportionId: 'body_02'),
          isTrue,
        );
        expect(controller.save.headOptionId, 'head_01');
        expect(controller.save.skinToneId, 'skin_01');
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );

    test(
      'stat spending does not consume progression before persistence',
      () async {
        const initial = GameSave(
          hasHero: true,
          unspentStatPoints: 1,
          stats: Stats(might: 2),
        );
        final storage = _GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        var notifications = 0;
        controller.addListener(() => notifications++);

        final gate = storage.gateNextWrite();
        final spendFuture = controller.spendStat(Stat.might);
        await gate.entered.future;
        expect(controller.save.toJson(), initial.toJson());
        expect(notifications, 0);
        gate.release();
        await expectLater(spendFuture, throwsA(isA<Exception>()));

        expect(controller.save.toJson(), initial.toJson());
        expect(storage.value?.toJson(), initial.toJson());
        expect(notifications, 0);
        expect(await controller.spendStat(Stat.might), isTrue);
        expect(controller.save.stats[Stat.might], 3);
        expect(controller.save.unspentStatPoints, 0);
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);
        expect(notifications, 1);
        expect(await controller.spendStat(Stat.might), isFalse);
        expect(storage.writeCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );

    test(
      'redistribution preserves build and rebirth credit when write fails',
      () async {
        const initial = GameSave(
          hasHero: true,
          stats: Stats(might: 4, agility: 3),
          unspentStatPoints: 2,
          rebirthCredits: 1,
        );
        final storage = _GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        var notifications = 0;
        controller.addListener(() => notifications++);

        final gate = storage.gateNextWrite();
        final redistributeFuture = controller.redistributeStats();
        await gate.entered.future;
        expect(controller.save.toJson(), initial.toJson());
        expect(notifications, 0);
        gate.release();
        await expectLater(redistributeFuture, throwsA(isA<Exception>()));

        expect(controller.save.toJson(), initial.toJson());
        expect(storage.value?.toJson(), initial.toJson());
        expect(notifications, 0);
        expect(await controller.redistributeStats(), isTrue);
        expect(controller.save.stats, const Stats());
        expect(controller.save.unspentStatPoints, 5);
        expect(controller.save.rebirthCredits, 0);
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);
        expect(notifications, 1);
        expect(await controller.redistributeStats(), isFalse);
        expect(storage.writeCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );

    test(
      'mastery unlock remains available for retry after write failure',
      () async {
        const initial = GameSave(hasHero: true, unspentMasteryPoints: 1);
        final storage = _GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        var notifications = 0;
        controller.addListener(() => notifications++);

        final gate = storage.gateNextWrite();
        final unlockFuture = controller.unlockMastery('front_1');
        await gate.entered.future;
        expect(controller.save.toJson(), initial.toJson());
        expect(notifications, 0);
        gate.release();
        await expectLater(unlockFuture, throwsA(isA<Exception>()));

        expect(controller.save.toJson(), initial.toJson());
        expect(storage.value?.toJson(), initial.toJson());
        expect(notifications, 0);
        expect(await controller.unlockMastery('front_1'), isTrue);
        expect(controller.save.masteries, {'front_1'});
        expect(controller.save.unspentMasteryPoints, 0);
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);
        expect(notifications, 1);
        expect(await controller.unlockMastery('front_1'), isFalse);
        expect(storage.writeCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );

    test(
      'settings remain unchanged until their candidate is persisted',
      () async {
        const initial = GameSave(
          hasHero: true,
          sfxEnabled: true,
          musicVolume: 0.65,
          sfxVolume: 0.7,
          vibrationEnabled: true,
          reducedMotion: false,
          language: 'tr',
        );
        final storage = _GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        var notifications = 0;
        controller.addListener(() => notifications++);

        final gate = storage.gateNextWrite();
        final settingsFuture = controller.updateSettings(
          sfxEnabled: false,
          musicVolume: 1.5,
          sfxVolume: 0.2,
          vibrationEnabled: false,
          reducedMotion: true,
          language: 'en',
        );
        await gate.entered.future;
        expect(controller.save.toJson(), initial.toJson());
        expect(notifications, 0);
        gate.release();
        await expectLater(settingsFuture, throwsA(isA<Exception>()));

        expect(controller.save.toJson(), initial.toJson());
        expect(storage.value?.toJson(), initial.toJson());
        expect(notifications, 0);
        await controller.updateSettings(
          sfxEnabled: false,
          musicVolume: 1.5,
          sfxVolume: 0.2,
          vibrationEnabled: false,
          reducedMotion: true,
          language: 'en',
        );
        expect(controller.save.sfxEnabled, isFalse);
        expect(controller.save.musicVolume, 1.0);
        expect(controller.save.sfxVolume, 0.2);
        expect(controller.save.vibrationEnabled, isFalse);
        expect(controller.save.reducedMotion, isTrue);
        expect(controller.save.language, 'en');
        expect(storage.value?.toJson(), controller.save.toJson());
        expect(storage.writeCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );

    test(
      'campaign reset waits for clear and keeps campaign on clear failure',
      () async {
        const initial = GameSave(
          hasHero: true,
          heroName: 'Kül Muhafızı',
          gold: 900,
          completedMatches: {'M01'},
        );
        final storage = _GatedSaveStorage(value: initial);
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1, seed: 42);
        final activeBattle = controller.battle;
        final activeEncounter = controller.activeEncounter;
        final saveBeforeReset = controller.save.toJson();
        var notifications = 0;
        controller.addListener(() => notifications++);

        final gate = storage.gateNextClear();
        final resetFuture = controller.resetCampaign();
        await gate.entered.future;
        expect(controller.save.toJson(), saveBeforeReset);
        expect(controller.battle, same(activeBattle));
        expect(controller.activeEncounter, same(activeEncounter));
        expect(notifications, 0);
        gate.release();
        await expectLater(resetFuture, throwsA(isA<Exception>()));

        expect(controller.save.toJson(), saveBeforeReset);
        expect(storage.value?.toJson(), saveBeforeReset);
        expect(controller.battle, same(activeBattle));
        expect(controller.activeEncounter, same(activeEncounter));
        expect(storage.clearCount, 1);
        expect(notifications, 0);

        await controller.resetCampaign();
        expect(controller.save.toJson(), const GameSave().toJson());
        expect(storage.value, isNull);
        expect(controller.battle, isNull);
        expect(controller.activeEncounter, isNull);
        expect(controller.activeContract, isNull);
        expect(storage.clearCount, 2);
        expect(notifications, 1);

        controller.dispose();
      },
    );
  });
}
