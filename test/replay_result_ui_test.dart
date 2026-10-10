import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a cleared duel replay reports no payout for this run', (
    tester,
  ) async {
    final storage = MemorySaveStorage()
      ..value = GameSave(
        hasHero: true,
        gold: 250,
        xp: 90,
        reducedMotion: true,
        completedMatches: {'M01'},
      );
    final controller = GameController(storage: storage);
    await controller.initialize();
    final seed = await _seedForCampaignWin(controller);
    await controller.startEncounter(1, seed: seed);
    final engine = controller.battle!;
    engine.opponent.health = 1;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: BattlePage(controller: controller),
      ),
    );
    await _startBattle(tester);
    final quick = find.text('Hızlı vuruş').first;
    await tester.scrollUntilVisible(
      quick,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(quick);
    await tester.pumpAndSettle();

    expect(engine.snapshot.done, isTrue);
    expect(engine.snapshot.playerWon, isTrue);
    expect(find.text('Bu tekrar yeni bir ödül vermedi.'), findsOneWidget);
    expect(controller.save.gold, 250);
    expect(controller.save.xp, 90);
    final impactEvent = engine.snapshot.events.lastWhere(
      (event) => event.type == BattleEventType.attackHit,
    );
    final impact = tester.widget<BattleImpactEffect>(
      find.byType(BattleImpactEffect),
    );
    expect(impact.sequence, impactEvent.sequence);
    expect(impact.alignment, Alignment.centerRight);
    expect(impact.reducedMotion, isTrue);

    controller.dispose();
  });

  testWidgets(
    'a failed replay of a cleared contract offers working retry and exit actions',
    (tester) async {
      final storage = MemorySaveStorage()
        ..value = GameSave(
          hasHero: true,
          gold: 250,
          reducedMotion: true,
          completedContracts: {'C1-A'},
        );
      final controller = GameController(storage: storage);
      await controller.initialize();
      final seed = await _seedForContractLoss(controller);
      await controller.startContract('C1-A', seed: seed);
      final engine = controller.battle!;
      engine.player.health = 1;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: BattlePage(controller: controller),
        ),
      );
      await _startBattle(tester);
      for (var turn = 0; turn < 100 && !engine.snapshot.done; turn++) {
        final guard = find.text('Gard al').first;
        await tester.scrollUntilVisible(
          guard,
          220,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(guard);
        await tester.pumpAndSettle();
      }

      expect(engine.snapshot.done, isTrue);
      expect(engine.snapshot.playerWon, isFalse);
      expect(find.text('Bu tekrar yeni bir ödül vermedi.'), findsOneWidget);
      expect(find.text('Yeniden dene'), findsOneWidget);
      expect(find.text('Düelloyu bırak'), findsOneWidget);
      final latestHitEvent = engine.snapshot.events.reversed.firstWhere(
        (event) =>
            event.type == BattleEventType.attackHit ||
            event.type == BattleEventType.hazardHit ||
            event.type == BattleEventType.damageTaken,
      );
      final impact = tester.widget<BattleImpactEffect>(
        find.byType(BattleImpactEffect),
      );
      expect(impact.sequence, latestHitEvent.sequence);
      expect(impact.alignment, Alignment.centerLeft);

      await tester.tap(find.text('Yeniden dene'));
      await tester.pumpAndSettle();
      expect(find.text('HAMLENİ SEÇ'), findsOneWidget);
      expect(controller.activeContract?.id, 'C1-A');
      expect(controller.battle!.snapshot.done, isFalse);

      controller.dispose();
    },
  );
}

Future<int> _seedForCampaignWin(GameController controller) async {
  for (var seed = 1; seed < 500; seed++) {
    await controller.startEncounter(1, seed: seed);
    final engine = controller.battle!;
    engine.opponent.health = 1;
    engine.perform(BattleAction.quick);
    if (engine.snapshot.done && engine.snapshot.playerWon) return seed;
  }
  throw StateError('Could not find a deterministic campaign win seed.');
}

Future<int> _seedForContractLoss(GameController controller) async {
  for (var seed = 1; seed < 500; seed++) {
    await controller.startContract('C1-A', seed: seed);
    final engine = controller.battle!;
    engine.player.health = 1;
    for (var turn = 0; turn < 100 && !engine.snapshot.done; turn++) {
      engine.perform(BattleAction.guard);
    }
    if (engine.snapshot.done && !engine.snapshot.playerWon) return seed;
  }
  throw StateError('Could not find a deterministic contract loss seed.');
}

Future<void> _startBattle(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Düelloya başla'),
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Düelloya başla'));
  await tester.pumpAndSettle();
}
