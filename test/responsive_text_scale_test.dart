import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'character creation remains layout-safe at 200% text on narrow and tablet widths',
    (tester) async {
      final controller = GameController(storage: MemorySaveStorage());
      await controller.initialize();

      try {
        for (final width in [320.0, 600.0]) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          await tester.pumpWidget(
            GameLocaleScope(
              languageCode: 'en',
              child: MaterialApp(
                theme: buildGameTheme(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, 800),
                    textScaler: TextScaler.linear(2),
                  ),
                  child: CharacterCreator(controller: controller),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(CharacterCreator), findsOneWidget);
          expect(tester.takeException(), isNull, reason: 'width=$width');
        }
      } finally {
        controller.dispose();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    },
  );

  testWidgets('legacy skin tone values do not enter the active art selection', (
    tester,
  ) async {
    final controller = GameController(
      storage: MemorySaveStorage()
        ..value = const GameSave(
          hasHero: true,
          skinToneId: 'skin_08',
          language: 'en',
        ),
    );
    await controller.initialize();

    try {
      await tester.pumpWidget(
        GameLocaleScope(
          languageCode: 'en',
          child: MaterialApp(
            theme: buildGameTheme(),
            home: Scaffold(body: FighterPage(controller: controller)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hero = tester.widget<FighterArt>(find.byType(FighterArt).first);
      expect(hero.customization?.isDefault, isTrue);
      expect(tester.takeException(), isNull);
    } finally {
      controller.dispose();
    }
  });
}
