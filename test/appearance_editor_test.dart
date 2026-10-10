import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('post-creation appearance editing', () {
    test(
      'persists cosmetic IDs without mutating campaign progression',
      () async {
        final initial = GameSave(
          hasHero: true,
          heroName: 'Kül Şampiyonu',
          appearance: 'Fırtına',
          headOptionId: 'head_02',
          skinToneId: 'skin_03',
          bodyProportionId: 'body_02',
          facialHairId: 'facial_hair_04',
          level: 12,
          xp: 6430,
          gold: 875,
          unspentStatPoints: 4,
          unspentMasteryPoints: 2,
          stats: const Stats(
            might: 8,
            agility: 7,
            precision: 6,
            vitality: 9,
            guard: 5,
            stamina: 6,
            arcana: 4,
          ),
          completedMatches: {'M01', 'M02', 'M03', 'M04'},
          audienceBestScores: {'M01': 3, 'M02': 2},
          lossSupportPaid: {'M05'},
          completedContracts: {'contract_01'},
          ownedItems: {'sword_4', 'coat_3', 'spell_emberSpear'},
          equippedItems: {'weapon': 'sword_4', 'body': 'coat_3'},
          healingSalves: 2,
          effortTonics: 1,
          masteries: {'front_1', 'duel_1'},
          rebirthCredits: 1,
          championsRunBest: 2,
          storyBeat: 3,
          intermissionChoices: {'I04': 'training:precision'},
          language: 'en',
        );
        final storage = MemorySaveStorage()..value = initial;
        final controller = GameController(storage: storage);
        await controller.initialize();

        expect(
          await controller.updateHeroAppearance(
            headOptionId: 'head_08',
            skinToneId: 'skin_07',
            bodyProportionId: 'body_03',
            facialHairId: 'facial_hair_02',
          ),
          isTrue,
        );

        final expectedUnchangedFields =
            Map<String, dynamic>.from(initial.toJson())
              ..remove('headOptionId')
              ..remove('skinToneId')
              ..remove('bodyProportionId')
              ..remove('facialHairId');
        final actualUnchangedFields =
            Map<String, dynamic>.from(controller.save.toJson())
              ..remove('headOptionId')
              ..remove('skinToneId')
              ..remove('bodyProportionId')
              ..remove('facialHairId');

        expect(actualUnchangedFields, expectedUnchangedFields);
        expect(controller.save.headOptionId, 'head_08');
        expect(controller.save.skinToneId, 'skin_07');
        expect(controller.save.bodyProportionId, 'body_03');
        expect(controller.save.facialHairId, 'facial_hair_02');

        final reloaded = GameController(storage: storage);
        await reloaded.initialize();
        expect(reloaded.save.headOptionId, 'head_08');
        expect(reloaded.save.skinToneId, 'skin_07');
        expect(reloaded.save.bodyProportionId, 'body_03');
        expect(reloaded.save.facialHairId, 'facial_hair_02');
        expect(reloaded.save.completedMatches, initial.completedMatches);
        expect(reloaded.save.equippedItems, initial.equippedItems);
        expect(reloaded.save.xp, initial.xp);
        expect(reloaded.save.stats.toJson(), initial.stats.toJson());

        controller.dispose();
        reloaded.dispose();
      },
    );

    test('does not create or replace appearance for a missing hero', () async {
      final storage = MemorySaveStorage();
      final controller = GameController(storage: storage);
      await controller.initialize();

      expect(
        await controller.updateHeroAppearance(
          headOptionId: 'head_08',
          skinToneId: 'skin_08',
          bodyProportionId: 'body_03',
          facialHairId: 'facial_hair_04',
        ),
        isFalse,
      );
      expect(controller.save, const GameSave());
      expect(storage.value, isNull);
      controller.dispose();
    });

    testWidgets('Fighter page opens an editor with live appearance preview', (
      tester,
    ) async {
      final storage = MemorySaveStorage();
      final controller = GameController(storage: storage);
      await controller.initialize();
      await controller.createHero(
        name: 'Kıyı',
        stats: const Stats(
          might: 4,
          agility: 4,
          vitality: 4,
          guard: 2,
          stamina: 2,
          arcana: 2,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: GameLocaleScope(
            languageCode: 'tr',
            child: Scaffold(body: FighterPage(controller: controller)),
          ),
        ),
      );

      final editButton = find.text('Görünüşü düzenle');
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.byType(AppearanceEditorPage), findsOneWidget);

      final headChoice = find.byKey(const ValueKey('appearance.head.head_05'));
      await tester.ensureVisible(headChoice);
      await tester.tap(headChoice);
      await tester.pumpAndSettle();
      expect(controller.save.headOptionId, 'head_05');
      expect(storage.value?.headOptionId, 'head_05');
      expect(
        tester
            .widget<HeroCustomizationArt>(find.byType(HeroCustomizationArt))
            .selection
            .headOptionId,
        'head_05',
      );

      final skinChoice = find.byKey(const ValueKey('appearance.skin.skin_06'));
      await tester.ensureVisible(skinChoice);
      await tester.tap(skinChoice);
      await tester.pumpAndSettle();
      expect(controller.save.skinToneId, 'skin_06');
      expect(storage.value?.skinToneId, 'skin_06');
      expect(
        tester
            .widget<HeroCustomizationArt>(find.byType(HeroCustomizationArt))
            .selection
            .skinToneId,
        'skin_06',
      );

      final bodyChoice = find.byKey(const ValueKey('appearance.body.body_03'));
      await tester.ensureVisible(bodyChoice);
      await tester.tap(bodyChoice);
      await tester.pumpAndSettle();
      expect(controller.save.bodyProportionId, 'body_03');
      expect(storage.value?.bodyProportionId, 'body_03');
      expect(
        tester
            .widget<HeroCustomizationArt>(find.byType(HeroCustomizationArt))
            .selection
            .bodyProportionId,
        'body_03',
      );

      final facialHairChoice = find.byKey(
        const ValueKey('appearance.facialHair.facial_hair_03'),
      );
      await tester.ensureVisible(facialHairChoice);
      await tester.tap(facialHairChoice);
      await tester.pumpAndSettle();
      expect(controller.save.facialHairId, 'facial_hair_03');
      expect(storage.value?.facialHairId, 'facial_hair_03');
      expect(
        tester
            .widget<HeroCustomizationArt>(find.byType(HeroCustomizationArt))
            .selection
            .facialHairId,
        'facial_hair_03',
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(AppearanceEditorPage), findsNothing);
      expect(find.byType(FighterPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, 900));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FighterArt>(find.byType(FighterArt))
            .customization
            ?.facialHairId,
        'facial_hair_03',
      );

      controller.dispose();
    });
  });
}
