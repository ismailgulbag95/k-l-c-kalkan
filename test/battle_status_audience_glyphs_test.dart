import 'dart:ui' show CheckedState;

import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/game_glyphs.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _startBattle(WidgetTester tester) async {
  final startButton = find.text('Düelloya başla');
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
  group('New GameGlyph kinds rendering', () {
    const newKinds = [
      GameGlyphKind.statusStagger,
      GameGlyphKind.statusBleed,
      GameGlyphKind.statusBurn,
      GameGlyphKind.statusBrokenGuard,
      GameGlyphKind.audienceTactics,
      GameGlyphKind.audienceAnswerAttack,
      GameGlyphKind.audienceAvoidHazard,
      GameGlyphKind.audienceChangeRange,
    ];

    testWidgets('all 8 new glyph kinds render without throwing exceptions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (final kind in newKinds) ...[
                    GameGlyph(kind, selected: false, size: 24),
                    GameGlyph(kind, selected: true, size: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(GameGlyph), findsNWidgets(newKinds.length * 2));
    });

    testWidgets('honors custom sizes, strokeWidth, and themes for new glyphs', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: const Scaffold(
            body: Column(
              children: [
                GameGlyph(
                  GameGlyphKind.statusBleed,
                  size: 14,
                  color: GamePalette.rust,
                  strokeWidth: 1.5,
                ),
                GameGlyph(
                  GameGlyphKind.audienceTactics,
                  size: 32,
                  color: GamePalette.gold,
                  strokeWidth: 2.2,
                ),
              ],
            ),
          ),
        ),
      );

      final bleedSize = tester.getSize(
        find.byWidgetPredicate(
          (w) => w is GameGlyph && w.kind == GameGlyphKind.statusBleed,
        ),
      );
      expect(bleedSize, const Size(14, 14));

      final tacticsSize = tester.getSize(
        find.byWidgetPredicate(
          (w) => w is GameGlyph && w.kind == GameGlyphKind.audienceTactics,
        ),
      );
      expect(tacticsSize, const Size(32, 32));
    });
  });

  group('Status and audience glyph mapping helpers', () {
    test('glyphForStatusKind maps all StatusKind values and safe fallback', () {
      expect(
        glyphForStatusKind(StatusKind.stagger),
        GameGlyphKind.statusStagger,
      );
      expect(glyphForStatusKind(StatusKind.bleed), GameGlyphKind.statusBleed);
      expect(glyphForStatusKind(StatusKind.burn), GameGlyphKind.statusBurn);
      expect(
        glyphForStatusKind(StatusKind.brokenGuard),
        GameGlyphKind.statusBrokenGuard,
      );
      expect(glyphForStatusKind(null), GameGlyphKind.statusStagger);
      expect(
        glyphForStatusKind(null, fallback: GameGlyphKind.guard),
        GameGlyphKind.guard,
      );
    });

    test('glyphForStatusId maps status string identifiers and fallbacks', () {
      expect(glyphForStatusId('stagger'), GameGlyphKind.statusStagger);
      expect(glyphForStatusId('bleed'), GameGlyphKind.statusBleed);
      expect(glyphForStatusId('burn'), GameGlyphKind.statusBurn);
      expect(glyphForStatusId('brokenGuard'), GameGlyphKind.statusBrokenGuard);
      expect(glyphForStatusId('label.status.bleed'), GameGlyphKind.statusBleed);
      expect(glyphForStatusId('unknown'), GameGlyphKind.statusStagger);
      expect(
        glyphForStatusId('unknown', fallback: GameGlyphKind.weapon),
        GameGlyphKind.weapon,
      );
    });

    test('glyphForStatus supports both StatusKind and string inputs', () {
      expect(glyphForStatus(StatusKind.burn), GameGlyphKind.statusBurn);
      expect(glyphForStatus('bleed'), GameGlyphKind.statusBleed);
      expect(glyphForStatus(123), GameGlyphKind.statusStagger);
      expect(
        glyphForStatus(null, fallback: GameGlyphKind.guard),
        GameGlyphKind.guard,
      );
    });

    test(
      'audienceGlyphForMessageId maps audience criteria with safe fallback',
      () {
        expect(
          audienceGlyphForMessageId('battle.audience.tactics'),
          GameGlyphKind.audienceTactics,
        );
        expect(
          audienceGlyphForMessageId('battle.audience.answerAttack'),
          GameGlyphKind.audienceAnswerAttack,
        );
        expect(
          audienceGlyphForMessageId('battle.audience.avoidHazard'),
          GameGlyphKind.audienceAvoidHazard,
        );
        expect(
          audienceGlyphForMessageId('battle.audience.changeRange'),
          GameGlyphKind.audienceChangeRange,
        );
        expect(
          audienceGlyphForMessageId('battle.audience.unknownObjective'),
          GameGlyphKind.arena,
        );
        expect(
          audienceGlyphForMessageId(
            'unknown',
            fallback: GameGlyphKind.champions,
          ),
          GameGlyphKind.champions,
        );
        expect(
          glyphForAudienceRule('battle.audience.tactics'),
          GameGlyphKind.audienceTactics,
        );
        expect(
          tryAudienceGlyphForMessageId('battle.audience.tactics'),
          GameGlyphKind.audienceTactics,
        );
        expect(tryAudienceGlyphForMessageId('unknown'), isNull);
      },
    );
  });

  group('New GameGlyph default semantic labels', () {
    testWidgets('resolves localized labels with GameLocaleScope context', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const GameLocaleScope(
            languageCode: 'tr',
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    GameGlyph(GameGlyphKind.statusStagger),
                    GameGlyph(GameGlyphKind.statusBleed),
                    GameGlyph(GameGlyphKind.statusBurn),
                    GameGlyph(GameGlyphKind.statusBrokenGuard),
                    GameGlyph(GameGlyphKind.audienceTactics),
                    GameGlyph(GameGlyphKind.audienceAnswerAttack),
                    GameGlyph(GameGlyphKind.audienceAvoidHazard),
                    GameGlyph(GameGlyphKind.audienceChangeRange),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Sendeleme'), findsOneWidget);
        expect(find.bySemanticsLabel('Kanama'), findsOneWidget);
        expect(find.bySemanticsLabel('Yanma'), findsOneWidget);
        expect(find.bySemanticsLabel('Kırık gard'), findsOneWidget);
        expect(
          find.bySemanticsLabel('En az iki farklı taktik yaklaşım kullan'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(
            'Gösterilen saldırı niyetine gardla karşılık ver',
          ),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Arena tehlikesinden hasar almadan çık'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Mesafeyi en az bir kez değiştir'),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    test('provides clean static fallback labels without context', () {
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.statusStagger),
        'Sendeleme',
      );
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.statusBleed),
        'Kanama',
      );
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.statusBurn),
        'Yanma',
      );
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.statusBrokenGuard),
        'Kırık gard',
      );
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.audienceTactics),
        'En az iki farklı taktik yaklaşım kullan',
      );
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.audienceAnswerAttack),
        'Gösterilen saldırı niyetine gardla karşılık ver',
      );
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.audienceAvoidHazard),
        'Arena tehlikesinden hasar almadan çık',
      );
      expect(
        defaultGlyphSemanticLabel(null, GameGlyphKind.audienceChangeRange),
        'Mesafeyi en az bir kez değiştir',
      );
    });
  });

  group('BattlePage live battle stage status badges', () {
    testWidgets(
      'renders compact status badges for active player and opponent statuses with accessible single label',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final handle = tester.ensureSemantics();
        final storage = MemorySaveStorage()
          ..value = const GameSave(
            hasHero: true,
            heroName: 'Cenk Ustası',
            gold: 100,
            xp: 50,
            reducedMotion: true,
          );
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1);
        final engine = controller.battle!;

        // Add active status effects to player and opponent
        engine.player.statuses[StatusKind.bleed] = 2;
        engine.player.statuses[StatusKind.burn] = 1;
        engine.opponent.statuses[StatusKind.stagger] = 1;
        engine.opponent.statuses[StatusKind.brokenGuard] = 1;

        try {
          await tester.pumpWidget(
            GameLocaleScope(
              languageCode: 'tr',
              child: MaterialApp(
                theme: buildGameTheme(),
                home: BattlePage(controller: controller),
              ),
            ),
          );
          await _startBattle(tester);

          // Both player status badges rendered
          expect(
            find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.statusBleed,
            ),
            findsOneWidget,
          );
          expect(
            find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.statusBurn,
            ),
            findsOneWidget,
          );
          expect(find.text('Kanama'), findsOneWidget);
          expect(find.text('Yanma'), findsOneWidget);

          // Both opponent status badges rendered
          expect(
            find.byWidgetPredicate(
              (w) => w is GameGlyph && w.kind == GameGlyphKind.statusStagger,
            ),
            findsOneWidget,
          );
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is GameGlyph && w.kind == GameGlyphKind.statusBrokenGuard,
            ),
            findsOneWidget,
          );
          expect(find.text('Sendeleme'), findsOneWidget);
          expect(find.text('Kırık gard'), findsOneWidget);

          // Exposes each status label once for screen readers (no duplicate announcements)
          expect(find.bySemanticsLabel('Kanama'), findsOneWidget);
          expect(find.bySemanticsLabel('Yanma'), findsOneWidget);
          expect(find.bySemanticsLabel('Sendeleme'), findsOneWidget);
          expect(find.bySemanticsLabel('Kırık gard'), findsOneWidget);

          // Existing fighter portraits and names are preserved
          expect(find.byType(FighterArt), findsNWidgets(2));
          expect(find.text('Cenk Ustası'), findsAtLeastNWidgets(1));
        } finally {
          handle.dispose();
          controller.dispose();
        }
      },
    );

    testWidgets(
      'at 360x800 mobile viewport, both fighters show two active status badges without layout overflow or overlapping FighterArt or distance/phase pill',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final handle = tester.ensureSemantics();
        final storage = MemorySaveStorage()
          ..value = const GameSave(
            hasHero: true,
            heroName: 'Cenk Ustası',
            gold: 100,
            xp: 50,
            reducedMotion: true,
          );
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1);
        final engine = controller.battle!;

        // Both fighters have two active statuses
        engine.player.statuses[StatusKind.bleed] = 2;
        engine.player.statuses[StatusKind.burn] = 1;
        engine.opponent.statuses[StatusKind.stagger] = 1;
        engine.opponent.statuses[StatusKind.brokenGuard] = 1;

        try {
          await tester.pumpWidget(
            GameLocaleScope(
              languageCode: 'tr',
              child: MaterialApp(
                theme: buildGameTheme(),
                home: BattlePage(controller: controller),
              ),
            ),
          );
          await _startBattle(tester);

          // 1. Verify no layout or RenderFlex exceptions occurred
          expect(tester.takeException(), isNull);

          // 2. All 4 status badges are present and labels are visible
          expect(find.text('Kanama'), findsOneWidget);
          expect(find.text('Yanma'), findsOneWidget);
          expect(find.text('Sendeleme'), findsOneWidget);
          expect(find.text('Kırık gard'), findsOneWidget);

          final badgeFinders = find.byType(CombatStatusBadge);
          expect(badgeFinders, findsNWidgets(4));

          // 3. Distance/phase pill and FighterArt portraits are rendered
          final distancePhaseFinder = find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).borderRadius ==
                    BorderRadius.circular(99),
          );
          expect(distancePhaseFinder, findsOneWidget);
          final pillRect = tester.getRect(distancePhaseFinder);

          final fighterFinders = find.byType(FighterArt);
          expect(fighterFinders, findsNWidgets(2));
          final playerFighterRect = tester.getRect(fighterFinders.at(0));
          final opponentFighterRect = tester.getRect(fighterFinders.at(1));

          // 4. Status badges do not intersect or obscure either FighterArt bounds or distance/phase pill
          for (final badgeElement in badgeFinders.evaluate()) {
            final badgeRect = tester.getRect(
              find.byWidget(badgeElement.widget),
            );
            expect(
              badgeRect.overlaps(pillRect),
              isFalse,
              reason:
                  'Status badge at $badgeRect must not intersect distance/phase pill at $pillRect',
            );
            expect(
              badgeRect.overlaps(playerFighterRect),
              isFalse,
              reason:
                  'Status badge at $badgeRect must not intersect player FighterArt at $playerFighterRect',
            );
            expect(
              badgeRect.overlaps(opponentFighterRect),
              isFalse,
              reason:
                  'Status badge at $badgeRect must not intersect opponent FighterArt at $opponentFighterRect',
            );
          }

          // 5. Accessible single screen-reader label per badge intact
          expect(find.bySemanticsLabel('Kanama'), findsOneWidget);
          expect(find.bySemanticsLabel('Yanma'), findsOneWidget);
          expect(find.bySemanticsLabel('Sendeleme'), findsOneWidget);
          expect(find.bySemanticsLabel('Kırık gard'), findsOneWidget);
        } finally {
          handle.dispose();
          controller.dispose();
        }
      },
    );
  });

  group(
    'Audience result rule rows glyph selection and accessible semantics',
    () {
      testWidgets(
        'renders criterion-specific glyph, completed/incomplete visual icons, and checked semantics',
        (tester) async {
          final handle = tester.ensureSemantics();

          final sampleRules = [
            const AudienceRule(
              'En az iki farklı taktik yaklaşım kullan',
              true,
              message: BattleMessage('battle.audience.tactics'),
            ),
            const AudienceRule(
              'Gösterilen saldırı niyetine gardla karşılık ver',
              false,
              message: BattleMessage('battle.audience.answerAttack'),
            ),
            const AudienceRule(
              'Arena tehlikesinden hasar almadan çık',
              true,
              message: BattleMessage('battle.audience.avoidHazard'),
            ),
            const AudienceRule(
              'Mesafeyi en az bir kez değiştir',
              false,
              message: BattleMessage('battle.audience.changeRange'),
            ),
            const AudienceRule(
              'Özel Koşul',
              true,
              message: BattleMessage('battle.audience.customRule'),
            ),
          ];

          try {
            await tester.pumpWidget(
              GameLocaleScope(
                languageCode: 'tr',
                child: MaterialApp(
                  theme: buildGameTheme(),
                  home: Scaffold(
                    body: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            for (final rule in sampleRules)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.5,
                                ),
                                child: Semantics(
                                  container: true,
                                  checked: rule.completed,
                                  label: gameText(context, rule.message.id),
                                  child: ExcludeSemantics(
                                    child: Row(
                                      children: [
                                        GameGlyph(
                                          audienceGlyphForMessageId(
                                            rule.message.id,
                                          ),
                                          size: 14,
                                          color: rule.completed
                                              ? GamePalette.teal
                                              : GamePalette.muted,
                                          selected: rule.completed,
                                          excludeFromSemantics: true,
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(
                                          rule.completed
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: rule.completed
                                              ? GamePalette.teal
                                              : GamePalette.muted,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            gameText(context, rule.message.id),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );

            // 1. Verify specific glyphs are rendered
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w is GameGlyph && w.kind == GameGlyphKind.audienceTactics,
              ),
              findsOneWidget,
            );
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w is GameGlyph &&
                    w.kind == GameGlyphKind.audienceAnswerAttack,
              ),
              findsOneWidget,
            );
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w is GameGlyph &&
                    w.kind == GameGlyphKind.audienceAvoidHazard,
              ),
              findsOneWidget,
            );
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w is GameGlyph &&
                    w.kind == GameGlyphKind.audienceChangeRange,
              ),
              findsOneWidget,
            );

            // 2. Unknown message ID retains safe generic fallback (arena glyph)
            expect(
              find.byWidgetPredicate(
                (w) => w is GameGlyph && w.kind == GameGlyphKind.arena,
              ),
              findsOneWidget,
            );

            // 3. Visual completion state preserved with icons
            expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
            expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));

            // 4. Accessible semantics: exposes criterion and completion state without relying on color alone
            final tacticsFinder = find.bySemanticsLabel(
              'En az iki farklı taktik yaklaşım kullan',
            );
            expect(tacticsFinder, findsOneWidget);
            final tacticsData = tester
                .getSemantics(tacticsFinder)
                .getSemanticsData();
            expect(tacticsData.flagsCollection.isChecked, CheckedState.isTrue);

            final answerAttackFinder = find.bySemanticsLabel(
              'Gösterilen saldırı niyetine gardla karşılık ver',
            );
            expect(answerAttackFinder, findsOneWidget);
            final answerAttackData = tester
                .getSemantics(answerAttackFinder)
                .getSemanticsData();
            expect(
              answerAttackData.flagsCollection.isChecked,
              CheckedState.isFalse,
            );
          } finally {
            handle.dispose();
          }
        },
      );
    },
  );
}
