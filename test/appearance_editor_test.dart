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
      'persists the active body shape and clears removed appearance values',
      () async {
        final initial = GameSave(
          hasHero: true,
          heroName: 'Kül Şampiyonu',
          appearance: 'Fırtına',
          headOptionId: 'head_02',
          skinToneId: 'skin_03',
          bodyProportionId: 'body_02',
          facialHairId: 'facial_hair_04',
          primaryAccentId: 'accent_06',
          secondaryAccentId: 'accent_07',
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
          await controller.updateHeroAppearance(bodyProportionId: 'body_03'),
          isTrue,
        );

        final expectedUnchangedFields =
            Map<String, dynamic>.from(initial.toJson())
              ..remove('headOptionId')
              ..remove('skinToneId')
              ..remove('bodyProportionId')
              ..remove('facialHairId')
              ..remove('primaryAccentId')
              ..remove('secondaryAccentId');
        final actualUnchangedFields =
            Map<String, dynamic>.from(controller.save.toJson())
              ..remove('headOptionId')
              ..remove('skinToneId')
              ..remove('bodyProportionId')
              ..remove('facialHairId')
              ..remove('primaryAccentId')
              ..remove('secondaryAccentId');

        expect(actualUnchangedFields, expectedUnchangedFields);
        expect(controller.save.headOptionId, 'head_01');
        expect(controller.save.skinToneId, 'skin_01');
        expect(controller.save.bodyProportionId, 'body_03');
        expect(controller.save.facialHairId, 'facial_hair_00');
        expect(controller.save.primaryAccentId, 'accent_01');
        expect(controller.save.secondaryAccentId, 'accent_02');

        final reloaded = GameController(storage: storage);
        await reloaded.initialize();
        expect(reloaded.save.headOptionId, 'head_01');
        expect(reloaded.save.skinToneId, 'skin_01');
        expect(reloaded.save.bodyProportionId, 'body_03');
        expect(reloaded.save.facialHairId, 'facial_hair_00');
        expect(reloaded.save.primaryAccentId, 'accent_01');
        expect(reloaded.save.secondaryAccentId, 'accent_02');
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
        await controller.updateHeroAppearance(bodyProportionId: 'body_03'),
        isFalse,
      );
      expect(controller.save, const GameSave());
      expect(storage.value, isNull);
      controller.dispose();
    });

    testWidgets('Fighter page opens an editor with live appearance preview', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
      for (final removedOption in [
        'Saç',
        'Saç biçimi',
        'Sakal',
        'Ten tonu',
        'Ten rengi',
        'Yüz kılı',
        'Renk vurgusu',
        'Ana renk vurgusu',
        'İkincil renk vurgusu',
      ]) {
        expect(find.text(removedOption), findsNothing, reason: removedOption);
      }

      final previewFinder = find.byKey(const ValueKey('appearance.preview'));
      Finder editorScrollable() => find
          .descendant(
            of: find.byType(AppearanceEditorPage),
            matching: find.byType(Scrollable),
          )
          .first;
      Future<void> reveal(Finder finder, double delta) => tester
          .scrollUntilVisible(finder, delta, scrollable: editorScrollable());
      HeroAppearanceSelection previewSelection() {
        final preview = tester.widget<SizedBox>(previewFinder);
        return (preview.child! as FighterArt).customization!;
      }

      final bodyChoice = find.byKey(const ValueKey('appearance.body.body_03'));
      await reveal(bodyChoice, 240);
      await tester.tap(bodyChoice);
      await tester.pumpAndSettle();
      expect(controller.save.bodyProportionId, 'body_03');
      expect(storage.value?.bodyProportionId, 'body_03');
      await reveal(previewFinder, -240);
      expect(previewSelection().bodyProportionId, 'body_03');
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(AppearanceEditorPage), findsNothing);
      expect(find.byType(FighterPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, 900));
      await tester.pumpAndSettle();
      expect(tester.widget<FighterArt>(find.byType(FighterArt)).origin, 'Kıyı');

      controller.dispose();
    });

    testWidgets(
      'CharacterCreator keeps body shape and origin but removes hair and color options',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = GameController(storage: MemorySaveStorage());
        await controller.initialize();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildGameTheme(),
            home: GameLocaleScope(
              languageCode: 'tr',
              child: Scaffold(body: CharacterCreator(controller: controller)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final removedOption in [
          'Saç',
          'Saç biçimi',
          'Sakal',
          'Ten tonu',
          'Ten rengi',
          'Yüz kılı',
          'Renk vurgusu',
          'Ana renk vurgusu',
          'İkincil renk vurgusu',
        ]) {
          expect(find.text(removedOption), findsNothing, reason: removedOption);
        }

        expect(
          find.byKey(const ValueKey('creator.body.body_01')),
          findsOneWidget,
        );

        final originChoice = find.widgetWithText(ChoiceChip, 'Ocak');
        expect(originChoice, findsOneWidget);
        for (final origin in ['Kıyı', 'Ocak', 'Fırtına', 'Taç']) {
          final choice = find.widgetWithText(ChoiceChip, origin);
          expect(choice, findsOneWidget, reason: origin);
          expect(
            find.descendant(
              of: choice,
              matching: find.byType(HeroAppearanceOptionPreview),
            ),
            findsOneWidget,
            reason: '$origin has a character preview',
          );
        }
        expect(
          heroCombatBaseAssetForOrigin(
            tester.widget<FighterArt>(find.byType(FighterArt)).origin,
          ),
          'assets/art/characters/hero_kiyi_combat_atlas_v2.png',
        );
        await tester.tap(originChoice);
        await tester.pumpAndSettle();
        final selectedFighter = tester.widget<FighterArt>(
          find.byType(FighterArt),
        );
        expect(selectedFighter.origin, 'Ocak');
        expect(
          heroCombatBaseAssetForOrigin(selectedFighter.origin),
          'assets/art/characters/hero_ocak_combat_atlas_v2.png',
        );

        controller.dispose();
      },
    );
  });
}
