import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void _setTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _localizedHome(Widget child, String languageCode) => GameLocaleScope(
  languageCode: languageCode,
  child: MaterialApp(theme: buildGameTheme(), home: child),
);

void main() {
  testWidgets('creator and appearance back buttons have localized labels', (
    tester,
  ) async {
    _setTestViewport(tester);
    final semantics = tester.ensureSemantics();
    final storage = MemorySaveStorage()
      ..value = const GameSave(hasHero: true, language: 'tr');
    final controller = GameController(storage: storage);
    await controller.initialize();

    try {
      await tester.pumpWidget(
        _localizedHome(CharacterCreator(controller: controller), 'tr'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Geri dön'), findsOneWidget);

      await tester.pumpWidget(
        _localizedHome(AppearanceEditorPage(controller: controller), 'en'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    } finally {
      semantics.dispose();
      controller.dispose();
    }
  });

  testWidgets('mastery unlock icon exposes the selected node name', (
    tester,
  ) async {
    _setTestViewport(tester);
    final semantics = tester.ensureSemantics();
    final storage = MemorySaveStorage()
      ..value = const GameSave(
        hasHero: true,
        heroName: 'Kıyı Savaşçısı',
        language: 'tr',
        unspentMasteryPoints: 1,
      );
    final controller = GameController(storage: storage);
    await controller.initialize();

    try {
      await tester.pumpWidget(
        _localizedHome(
          Scaffold(body: FighterPage(controller: controller)),
          'tr',
        ),
      );
      final masteryTitle = find.text('Sağlam duruş');
      await tester.scrollUntilVisible(
        masteryTitle,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final unlock = find.bySemanticsLabel(
        'Sağlam duruş ustalığının kilidini aç',
      );
      expect(unlock, findsOneWidget);
      expect(
        tester.getSemantics(unlock).getSemanticsData().flagsCollection.isButton,
        isTrue,
      );
    } finally {
      semantics.dispose();
      controller.dispose();
    }
  });

  testWidgets('battle briefing and active battle icons are labeled', (
    tester,
  ) async {
    _setTestViewport(tester);
    final semantics = tester.ensureSemantics();
    final storage = MemorySaveStorage()
      ..value = const GameSave(
        hasHero: true,
        heroName: 'Coast Fighter',
        language: 'en',
      );
    final controller = GameController(storage: storage);
    await controller.initialize();
    await controller.startEncounter(1, seed: 17);

    try {
      await tester.pumpWidget(
        _localizedHome(BattlePage(controller: controller), 'en'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Go back'), findsOneWidget);

      final startDuel = find.text('Start duel');
      await tester.ensureVisible(startDuel);
      await tester.tap(startDuel);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Leave duel'), findsOneWidget);
    } finally {
      semantics.dispose();
      controller.dispose();
    }
  });
}
