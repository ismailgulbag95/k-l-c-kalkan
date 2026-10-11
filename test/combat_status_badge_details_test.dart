import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/game_glyphs.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _startBattle(WidgetTester tester) async {
  final startButton = find.byWidgetPredicate(
    (w) => w is Text && (w.data == 'Düelloya başla' || w.data == 'Start duel'),
  );
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isNotEmpty) {
    try {
      await tester.scrollUntilVisible(
        startButton,
        150,
        scrollable: scrollable.first,
      );
    } catch (_) {}
  }
  if (startButton.evaluate().isNotEmpty) {
    await tester.tap(startButton.first);
    await tester.pumpAndSettle();
  }
}

void main() {
  group('CombatStatusBadge visible details and accessibility semantics', () {
    testWidgets(
      'renders visible details and semantics for multi-stack status with one turn remaining in Turkish',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            GameLocaleScope(
              languageCode: 'tr',
              child: MaterialApp(
                theme: buildGameTheme(),
                home: const Scaffold(
                  body: Center(
                    child: CombatStatusBadge(
                      status: StatusKind.bleed,
                      stacks: 2,
                      remainingTurns: 1,
                    ),
                  ),
                ),
              ),
            ),
          );

          // Visible presentation: glyph, status name, and compact stack/turn details
          expect(
            find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.statusBleed,
            ),
            findsOneWidget,
          );
          expect(find.text('Kanama'), findsOneWidget);
          expect(find.text('×2 · 1 tur'), findsOneWidget);

          // Screen-reader semantics label
          expect(
            find.bySemanticsLabel('Kanama, 2 kademe, 1 tur kaldı'),
            findsOneWidget,
          );
          final semantics = tester.getSemantics(find.byType(CombatStatusBadge));
          expect(
            semantics.getSemanticsData().label,
            'Kanama, 2 kademe, 1 tur kaldı',
          );
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets(
      'renders visible details and semantics for multi-stack status with one turn remaining in English',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            GameLocaleScope(
              languageCode: 'en',
              child: MaterialApp(
                theme: buildGameTheme(),
                home: const Scaffold(
                  body: Center(
                    child: CombatStatusBadge(
                      status: StatusKind.bleed,
                      stacks: 2,
                      remainingTurns: 1,
                    ),
                  ),
                ),
              ),
            ),
          );

          // Visible presentation: glyph, status name, and compact stack/turn details
          expect(
            find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.statusBleed,
            ),
            findsOneWidget,
          );
          expect(find.text('Bleed'), findsOneWidget);
          expect(find.text('×2 · 1 turn'), findsOneWidget);

          // Screen-reader semantics label
          expect(
            find.bySemanticsLabel('Bleed, 2 stacks, 1 turn remaining'),
            findsOneWidget,
          );
          final semantics = tester.getSemantics(find.byType(CombatStatusBadge));
          expect(
            semantics.getSemanticsData().label,
            'Bleed, 2 stacks, 1 turn remaining',
          );
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets(
      'renders multi-stack burn and single-stack broken guard details in both locales',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          // Turkish Burn (multi-stack 3, 1 turn remaining)
          await tester.pumpWidget(
            GameLocaleScope(
              languageCode: 'tr',
              child: MaterialApp(
                theme: buildGameTheme(),
                home: const Scaffold(
                  body: Column(
                    children: [
                      CombatStatusBadge(
                        status: StatusKind.burn,
                        stacks: 3,
                        remainingTurns: 1,
                      ),
                      CombatStatusBadge(
                        status: StatusKind.brokenGuard,
                        stacks: 1,
                        remainingTurns: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          expect(find.text('Yanma'), findsOneWidget);
          expect(find.text('×3 · 1 tur'), findsOneWidget);
          expect(
            find.bySemanticsLabel('Yanma, 3 kademe, 1 tur kaldı'),
            findsOneWidget,
          );

          expect(find.text('Kırık gard'), findsOneWidget);
          expect(find.text('1 tur'), findsOneWidget);
          expect(
            find.bySemanticsLabel('Kırık gard, 1 tur kaldı'),
            findsOneWidget,
          );

          // English Burn (multi-stack 3, 1 turn remaining)
          await tester.pumpWidget(
            GameLocaleScope(
              languageCode: 'en',
              child: MaterialApp(
                theme: buildGameTheme(),
                home: const Scaffold(
                  body: Column(
                    children: [
                      CombatStatusBadge(
                        status: StatusKind.burn,
                        stacks: 3,
                        remainingTurns: 1,
                      ),
                      CombatStatusBadge(
                        status: StatusKind.brokenGuard,
                        stacks: 1,
                        remainingTurns: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          expect(find.text('Burn'), findsOneWidget);
          expect(find.text('×3 · 1 turn'), findsOneWidget);
          expect(
            find.bySemanticsLabel('Burn, 3 stacks, 1 turn remaining'),
            findsOneWidget,
          );

          expect(find.text('Broken guard'), findsOneWidget);
          expect(find.text('1 turn'), findsOneWidget);
          expect(
            find.bySemanticsLabel('Broken guard, 1 turn remaining'),
            findsOneWidget,
          );
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets(
      'BattlePage fighter-status call sites display multi-stack status with one turn remaining without layout overflow at 360x800 in both locales',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final (
              lang,
              playerStatusText,
              playerDetailsText,
              playerSemantics,
              opponentStatusText,
              opponentDetailsText,
              opponentSemantics,
            )
            in [
              (
                'tr',
                'Kanama',
                '×2 · 1 tur',
                'Kanama, 2 kademe, 1 tur kaldı',
                'Yanma',
                '×2 · 1 tur',
                'Yanma, 2 kademe, 1 tur kaldı',
              ),
              (
                'en',
                'Bleed',
                '×2 · 1 turn',
                'Bleed, 2 stacks, 1 turn remaining',
                'Burn',
                '×2 · 1 turn',
                'Burn, 2 stacks, 1 turn remaining',
              ),
            ]) {
          final handle = tester.ensureSemantics();
          final storage = MemorySaveStorage()
            ..value = GameSave(
              hasHero: true,
              heroName: 'Cenk Ustası',
              language: lang,
              reducedMotion: true,
            );
          final controller = GameController(storage: storage);
          await controller.initialize();
          await controller.startEncounter(1);
          final engine = controller.battle!;

          // Player has multi-stack bleed with one turn remaining
          engine.player.statuses[StatusKind.bleed] = 2;
          engine.player.statusTurnsRemaining[StatusKind.bleed] = 1;

          // Opponent has multi-stack burn with one turn remaining
          engine.opponent.statuses[StatusKind.burn] = 2;
          engine.opponent.statusTurnsRemaining[StatusKind.burn] = 1;

          try {
            await tester.pumpWidget(
              GameLocaleScope(
                languageCode: lang,
                child: MaterialApp(
                  theme: buildGameTheme(),
                  home: BattlePage(
                    key: ValueKey('battle-$lang'),
                    controller: controller,
                  ),
                ),
              ),
            );
            await _startBattle(tester);

            // 1. Verify responsive wrapping intact: no layout/RenderFlex overflow exceptions
            expect(tester.takeException(), isNull);

            // 2. Player status badge details and semantics
            expect(find.text(playerStatusText), findsOneWidget);
            expect(find.text(playerDetailsText), findsAtLeastNWidgets(1));
            expect(find.bySemanticsLabel(playerSemantics), findsOneWidget);

            // 3. Opponent status badge details and semantics
            expect(find.text(opponentStatusText), findsOneWidget);
            expect(find.text(opponentDetailsText), findsAtLeastNWidgets(1));
            expect(find.bySemanticsLabel(opponentSemantics), findsOneWidget);
          } finally {
            handle.dispose();
            controller.dispose();
          }
        }
      },
    );
  });
}
