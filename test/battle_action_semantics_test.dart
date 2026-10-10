import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';

import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

String _buildExpectedSemanticLabel({
  required BuildContext context,
  required BattleAction action,
  required ActionPreview preview,
  String? badge,
}) {
  final actionName = gameText(context, 'label.action.${action.name}');
  final costText = gameText(context, preview.costMessage.id, {
    ...preview.costMessage.arguments,
  });
  final statsText = preview.hitChance > 0
      ? '${preview.hitChance}% · ~${preview.estimatedDamage}'
      : null;
  final badgeText = (badge != null && badge.isNotEmpty) ? badge : null;
  return [actionName, costText, ?statsText, ?badgeText].join(', ');
}

void main() {
  group('Battle action tile accessibility semantics', () {
    testWidgets(
      'exposes single button semantics for usable, badged, and disabled actions in Turkish',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final handle = tester.ensureSemantics();
        final storage = MemorySaveStorage()
          ..value = const GameSave(hasHero: true, gold: 250, language: 'tr');
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.createHero(
          name: 'Kıyı Savaşçısı',
          stats: const Stats(
            might: 4,
            agility: 4,
            vitality: 4,
            guard: 2,
            stamina: 2,
            arcana: 2,
          ),
        );
        await controller.startEncounter(1, seed: 17);
        final engine = controller.battle!;
        engine.player.ammo = 3;

        await tester.pumpWidget(
          GameLocaleScope(
            languageCode: 'tr',
            child: MaterialApp(
              theme: buildGameTheme(),
              home: BattlePage(
                key: const ValueKey('battle_open_tr'),
                controller: controller,
                resumeFromCheckpoint: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Usable action: Hızlı vuruş (Quick strike)
        final quickFinder = find.bySemanticsLabel(RegExp(r'^Hızlı vuruş'));
        expect(quickFinder, findsOneWidget);
        final quickNode = tester.getSemantics(quickFinder);
        final quickData = quickNode.getSemanticsData();
        final quickPreview = engine.preview(BattleAction.quick);
        final expectedQuickLabel = _buildExpectedSemanticLabel(
          context: tester.element(quickFinder),
          action: BattleAction.quick,
          preview: quickPreview,
        );

        expect(quickData.label, expectedQuickLabel);
        expect(quickData.value, isEmpty);
        expect(quickData.flagsCollection.isButton, isTrue);
        expect(quickData.flagsCollection.isEnabled, Tristate.isTrue);
        expect(quickData.hasAction(SemanticsAction.tap), isTrue);
        expect(quickNode.childrenCount, 0);

        // 2. Action with ammo badge: Menzilli atış (Ranged shot / Bow)
        final bowFinder = find.bySemanticsLabel(RegExp(r'^Menzilli atış'));
        expect(bowFinder, findsOneWidget);
        final bowNode = tester.getSemantics(bowFinder);
        final bowData = bowNode.getSemanticsData();
        final bowPreview = engine.preview(BattleAction.bow);
        final expectedBowLabel = _buildExpectedSemanticLabel(
          context: tester.element(bowFinder),
          action: BattleAction.bow,
          preview: bowPreview,
          badge: '3 fişek',
        );

        expect(bowData.label, expectedBowLabel);
        expect(bowData.value, isEmpty);
        expect(bowData.flagsCollection.isButton, isTrue);
        expect(bowData.flagsCollection.isEnabled, Tristate.isTrue);
        expect(bowData.hasAction(SemanticsAction.tap), isTrue);
        expect(bowNode.childrenCount, 0);

        // 3. Unavailable action: Yaklaş (Move closer) when distance is already close
        engine.distance = RangeBand.close;
        await tester.pumpWidget(
          GameLocaleScope(
            languageCode: 'tr',
            child: MaterialApp(
              theme: buildGameTheme(),
              home: BattlePage(
                key: const ValueKey('battle_close_tr'),
                controller: controller,
                resumeFromCheckpoint: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final closeFinder = find.bySemanticsLabel(RegExp(r'^Yaklaş'));
        expect(closeFinder, findsOneWidget);
        final closeNode = tester.getSemantics(closeFinder);
        final closeData = closeNode.getSemanticsData();
        final closePreview = engine.preview(BattleAction.closeDistance);
        final expectedCloseLabel = _buildExpectedSemanticLabel(
          context: tester.element(closeFinder),
          action: BattleAction.closeDistance,
          preview: closePreview,
        );

        expect(closePreview.canUse, isFalse);
        expect(closeData.label, expectedCloseLabel);
        expect(closeData.value, isEmpty);
        expect(closeData.flagsCollection.isButton, isTrue);
        expect(closeData.flagsCollection.isEnabled, Tristate.isFalse);
        expect(closeData.hasAction(SemanticsAction.tap), isFalse);
        expect(closeNode.childrenCount, 0);

        handle.dispose();
        controller.dispose();
      },
    );

    testWidgets(
      'exposes single button semantics for usable, badged, and disabled actions in English',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final handle = tester.ensureSemantics();
        final storage = MemorySaveStorage()
          ..value = const GameSave(hasHero: true, gold: 250, language: 'en');
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.createHero(
          name: 'Coast Fighter',
          stats: const Stats(
            might: 4,
            agility: 4,
            vitality: 4,
            guard: 2,
            stamina: 2,
            arcana: 2,
          ),
        );
        await controller.startEncounter(1, seed: 17);
        final engine = controller.battle!;
        engine.player.ammo = 3;

        await tester.pumpWidget(
          GameLocaleScope(
            languageCode: 'en',
            child: MaterialApp(
              theme: buildGameTheme(),
              home: BattlePage(
                key: const ValueKey('battle_open_en'),
                controller: controller,
                resumeFromCheckpoint: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Usable action: Quick strike
        final quickFinder = find.bySemanticsLabel(RegExp(r'^Quick strike'));
        expect(quickFinder, findsOneWidget);
        final quickNode = tester.getSemantics(quickFinder);
        final quickData = quickNode.getSemanticsData();
        final quickPreview = engine.preview(BattleAction.quick);
        final expectedQuickLabel = _buildExpectedSemanticLabel(
          context: tester.element(quickFinder),
          action: BattleAction.quick,
          preview: quickPreview,
        );

        expect(quickData.label, expectedQuickLabel);
        expect(quickData.value, isEmpty);
        expect(quickData.flagsCollection.isButton, isTrue);
        expect(quickData.flagsCollection.isEnabled, Tristate.isTrue);
        expect(quickData.hasAction(SemanticsAction.tap), isTrue);
        expect(quickNode.childrenCount, 0);

        // 2. Action with ammo badge: Ranged shot (Bow with 3 arrows)
        final bowFinder = find.bySemanticsLabel(RegExp(r'^Ranged shot'));
        expect(bowFinder, findsOneWidget);
        final bowNode = tester.getSemantics(bowFinder);
        final bowData = bowNode.getSemanticsData();
        final bowPreview = engine.preview(BattleAction.bow);
        final expectedBowLabel = _buildExpectedSemanticLabel(
          context: tester.element(bowFinder),
          action: BattleAction.bow,
          preview: bowPreview,
          badge: '3 arrows',
        );

        expect(bowData.label, expectedBowLabel);
        expect(bowData.value, isEmpty);
        expect(bowData.flagsCollection.isButton, isTrue);
        expect(bowData.flagsCollection.isEnabled, Tristate.isTrue);
        expect(bowData.hasAction(SemanticsAction.tap), isTrue);
        expect(bowNode.childrenCount, 0);

        // 3. Unavailable action: Move closer when distance is already close
        engine.distance = RangeBand.close;
        await tester.pumpWidget(
          GameLocaleScope(
            languageCode: 'en',
            child: MaterialApp(
              theme: buildGameTheme(),
              home: BattlePage(
                key: const ValueKey('battle_close_en'),
                controller: controller,
                resumeFromCheckpoint: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final closeFinder = find.bySemanticsLabel(RegExp(r'^Move closer'));
        expect(closeFinder, findsOneWidget);
        final closeNode = tester.getSemantics(closeFinder);
        final closeData = closeNode.getSemanticsData();
        final closePreview = engine.preview(BattleAction.closeDistance);
        final expectedCloseLabel = _buildExpectedSemanticLabel(
          context: tester.element(closeFinder),
          action: BattleAction.closeDistance,
          preview: closePreview,
        );

        expect(closePreview.canUse, isFalse);
        expect(closeData.label, expectedCloseLabel);
        expect(closeData.value, isEmpty);
        expect(closeData.flagsCollection.isButton, isTrue);
        expect(closeData.flagsCollection.isEnabled, Tristate.isFalse);
        expect(closeData.hasAction(SemanticsAction.tap), isFalse);
        expect(closeNode.childrenCount, 0);

        handle.dispose();
        controller.dispose();
      },
    );

    testWidgets(
      'verifies primary battle action semantics are traversed in the same order as the action Wrap list',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final handle = tester.ensureSemantics();
        final storage = MemorySaveStorage()
          ..value = const GameSave(hasHero: true, gold: 250, language: 'tr');
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.createHero(
          name: 'Kıyı Savaşçısı',
          stats: const Stats(
            might: 4,
            agility: 4,
            vitality: 4,
            guard: 2,
            stamina: 2,
            arcana: 2,
          ),
        );
        await controller.startEncounter(1, seed: 17);
        final engine = controller.battle!;
        engine.player.ammo = 3;

        await tester.pumpWidget(
          GameLocaleScope(
            languageCode: 'tr',
            child: MaterialApp(
              theme: buildGameTheme(),
              home: BattlePage(
                key: const ValueKey('battle_traversal_order'),
                controller: controller,
                resumeFromCheckpoint: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The exact expected order of action buttons rendered in the Wrap list:
        // [quick, heavy, guard, sweep, bow, closeDistance, openDistance, shoreStep]
        final expectedActionNamesInWrapOrder = <String>[
          'Hızlı vuruş',
          'Güçlü vuruş',
          'Gard al',
          'Çelme',
          'Menzilli atış',
          'Yaklaş',
          'Uzaklaş',
          'Kıyı Sıçrayışı',
        ];

        final traversedActionNames = tester.semantics
            .simulatedAccessibilityTraversal()
            .where((node) => node.flagsCollection.isButton)
            .map(
              (node) => expectedActionNamesInWrapOrder
                  .where((name) => node.label.startsWith(name))
                  .firstOrNull,
            )
            .whereType<String>()
            .toList();

        expect(traversedActionNames, expectedActionNamesInWrapOrder);

        handle.dispose();
        controller.dispose();
      },
    );

    testWidgets(
      'reflects enabled and tap state when onTap is null (processing turn) vs non-null',
      (tester) async {
        final handle = tester.ensureSemantics();
        final engine = BattleEngine(
          save: const GameSave(),
          encounter: getEncounter(1),
          seed: 17,
        );

        var tapped = false;
        await tester.pumpWidget(
          GameLocaleScope(
            languageCode: 'tr',
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    BattleActionTile(
                      engine: engine,
                      action: BattleAction.quick,
                      onTap: () => tapped = true,
                    ),
                    BattleActionTile(
                      engine: engine,
                      action: BattleAction.quick,
                      onTap: null, // Disabled during processing turn
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final tiles = find.bySemanticsLabel(RegExp(r'^Hızlı vuruş'));
        expect(tiles, findsNWidgets(2));

        // Enabled tile (onTap non-null and preview.canUse true)
        final enabledNode = tester.getSemantics(tiles.at(0));
        final enabledData = enabledNode.getSemanticsData();
        expect(enabledData.flagsCollection.isButton, isTrue);
        expect(enabledData.flagsCollection.isEnabled, Tristate.isTrue);
        expect(enabledData.hasAction(SemanticsAction.tap), isTrue);
        expect(enabledNode.childrenCount, 0);

        await tester.tap(tiles.at(0));
        expect(tapped, isTrue);

        // Disabled tile (onTap null)
        final disabledNode = tester.getSemantics(tiles.at(1));
        final disabledData = disabledNode.getSemanticsData();
        expect(disabledData.flagsCollection.isButton, isTrue);
        expect(disabledData.flagsCollection.isEnabled, Tristate.isFalse);
        expect(disabledData.hasAction(SemanticsAction.tap), isFalse);
        expect(disabledNode.childrenCount, 0);

        handle.dispose();
      },
    );
  });
}
