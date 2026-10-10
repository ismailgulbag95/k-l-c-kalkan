import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/game_glyphs.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameGlyph rendering', () {
    testWidgets('every glyph kind renders without throwing exceptions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (final kind in GameGlyphKind.values) ...[
                    GameGlyph(kind, selected: false),
                    GameGlyph(kind, selected: true),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.byType(GameGlyph),
        findsNWidgets(GameGlyphKind.values.length * 2),
      );
    });

    testWidgets('honors custom size, strokeWidth, and IconTheme sizing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: const Scaffold(
            body: Column(
              children: [
                GameGlyph(
                  GameGlyphKind.coin,
                  size: 38,
                  color: GamePalette.gold,
                  strokeWidth: 2.2,
                ),
                IconTheme(
                  data: IconThemeData(size: 28, color: GamePalette.teal),
                  child: GameGlyph(GameGlyphKind.weapon),
                ),
              ],
            ),
          ),
        ),
      );

      final customGlyphSize = tester.getSize(
        find.byWidgetPredicate(
          (w) => w is GameGlyph && w.kind == GameGlyphKind.coin,
        ),
      );
      expect(customGlyphSize, const Size(38, 38));

      final themedGlyphSize = tester.getSize(
        find.byWidgetPredicate(
          (w) => w is GameGlyph && w.kind == GameGlyphKind.weapon,
        ),
      );
      expect(themedGlyphSize, const Size(28, 28));
    });
  });

  group('GameGlyph semantics', () {
    testWidgets(
      'provides stable default semantic labels when used standalone',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    GameGlyph(GameGlyphKind.coin),
                    GameGlyph(GameGlyphKind.health),
                    GameGlyph(GameGlyphKind.stamina),
                    GameGlyph(GameGlyphKind.weapon),
                    GameGlyph(GameGlyphKind.armor),
                    GameGlyph(GameGlyphKind.magic),
                    GameGlyph(GameGlyphKind.supply),
                  ],
                ),
              ),
            ),
          );

          expect(find.bySemanticsLabel('Altın'), findsOneWidget);
          expect(find.bySemanticsLabel('SAĞLIK'), findsOneWidget);
          expect(find.bySemanticsLabel('EFOR'), findsOneWidget);
          expect(find.bySemanticsLabel('Silah'), findsOneWidget);
          expect(find.bySemanticsLabel('Zırh'), findsOneWidget);
          expect(find.bySemanticsLabel('MANA'), findsOneWidget);
          expect(find.bySemanticsLabel('Sarf'), findsOneWidget);
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets('supports custom semanticLabel override', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: GameGlyph(GameGlyphKind.coin, semanticLabel: 'Kese altını'),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Kese altını'), findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('excludeFromSemantics suppresses glyph semantic node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: GameGlyph(GameGlyphKind.coin, excludeFromSemantics: true),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Altın'), findsNothing);
      } finally {
        handle.dispose();
      }
    });
  });

  group('GameHub NavigationBar integration', () {
    testWidgets(
      'renders custom glyph widgets in NavigationBar while preserving labels and selection behavior',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final storage = MemorySaveStorage();
        final controller = GameController(storage: storage);
        await controller.initialize();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildGameTheme(),
            home: GameHub(controller: controller),
          ),
        );
        await tester.pumpAndSettle();

        final hubElement = tester.element(find.byType(GameHub));
        final leagueLabel = gameText(hubElement, 'ui.nav.league');
        final fighterLabel = gameText(hubElement, 'ui.nav.fighter');
        final shopLabel = gameText(hubElement, 'ui.nav.shop');
        final contractsLabel = gameText(hubElement, 'ui.nav.contracts');
        final settingsLabel = gameText(hubElement, 'ui.nav.settings');

        // Authoritative destination labels are fully preserved.
        expect(find.text(leagueLabel), findsOneWidget);
        expect(find.text(fighterLabel), findsOneWidget);
        expect(find.text(shopLabel), findsOneWidget);
        expect(find.text(contractsLabel), findsOneWidget);
        expect(find.text(settingsLabel), findsOneWidget);

        // NavigationBar contains custom GameGlyph instances instead of Material Icons.
        final navBarGlyphs = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byType(GameGlyph),
        );
        expect(navBarGlyphs, findsAtLeastNWidgets(5));

        // Verify specific kinds are represented in the destinations.
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.campaign,
            ),
          ),
          findsAtLeastNWidgets(1),
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.fighter,
            ),
          ),
          findsAtLeastNWidgets(1),
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.shop,
            ),
          ),
          findsAtLeastNWidgets(1),
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.champions,
            ),
          ),
          findsAtLeastNWidgets(1),
        );
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.settings,
            ),
          ),
          findsAtLeastNWidgets(1),
        );

        // Header guard emblem glyph is also rendered safely.
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.guard,
            ),
          ),
          findsOneWidget,
        );

        // Switching tabs updates the selected destination without regression.
        await tester.tap(find.text(fighterLabel));
        await tester.pumpAndSettle();

        expect(find.byType(FighterPage), findsOneWidget);

        // Fighter page supply resource glyph is rendered.
        expect(
          find.descendant(
            of: find.byType(FighterPage),
            matching: find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.supply,
            ),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'NavigationBar destinations avoid duplicate screen-reader labels from glyphs',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final handle = tester.ensureSemantics();
        try {
          final storage = MemorySaveStorage();
          final controller = GameController(storage: storage);
          await controller.initialize();
          addTearDown(controller.dispose);

          await tester.pumpWidget(
            MaterialApp(
              theme: buildGameTheme(),
              home: GameHub(controller: controller),
            ),
          );
          await tester.pumpAndSettle();

          // Glyph instances inside NavigationBar must be excluded from semantics
          // to avoid duplicate announcements against authoritative destination labels.
          final navBarGlyphs = tester.widgetList<GameGlyph>(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.byType(GameGlyph),
            ),
          );
          expect(navBarGlyphs, isNotEmpty);
          for (final glyph in navBarGlyphs) {
            expect(glyph.excludeFromSemantics, isTrue);
          }
        } finally {
          handle.dispose();
        }
      },
    );
  });
}
