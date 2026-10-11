import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EquippedGearAppearance DTO and helpers', () {
    test(
      'constructs cleanly and fromMap extracts only head, body, and boots',
      () {
        const empty = EquippedGearAppearance();
        expect(empty.isEmpty, isTrue);
        expect(empty.isNotEmpty, isFalse);
        expect(empty.hasVisibleGear, isFalse);
        expect(empty.head, isNull);
        expect(empty.body, isNull);
        expect(empty.boots, isNull);

        final fromNull = EquippedGearAppearance.fromMap(null);
        expect(fromNull.isEmpty, isTrue);

        final fromEmptyMap = EquippedGearAppearance.fromMap({});
        expect(fromEmptyMap.isEmpty, isTrue);

        final fullMap = {
          'head': 'helm_2',
          'body': 'coat_3',
          'boots': 'boots_1',
          'weapon': 'sword_2',
          'talisman': 'charm_1',
        };
        final gear = EquippedGearAppearance.fromMap(fullMap);
        expect(gear.isEmpty, isFalse);
        expect(gear.isNotEmpty, isTrue);
        expect(gear.hasVisibleGear, isTrue);
        expect(gear.head, 'helm_2');
        expect(gear.headItemId, 'helm_2');
        expect(gear.body, 'coat_3');
        expect(gear.bodyItemId, 'coat_3');
        expect(gear.boots, 'boots_1');
        expect(gear.bootsItemId, 'boots_1');
      },
    );

    test(
      'correctly identifies known and unknown gear IDs without throwing',
      () {
        for (var tier = 1; tier <= 4; tier++) {
          expect(isKnownHeadGearId('helm_$tier'), isTrue);
          expect(isKnownBodyGearId('coat_$tier'), isTrue);
          expect(isKnownBootsGearId('boots_$tier'), isTrue);
          expect(isKnownGearId('helm_$tier'), isTrue);
          expect(isKnownGearId('coat_$tier'), isTrue);
          expect(isKnownGearId('boots_$tier'), isTrue);
        }

        expect(isKnownHeadGearId('helm_99'), isFalse);
        expect(isKnownBodyGearId('invalid_coat'), isFalse);
        expect(isKnownBootsGearId(''), isFalse);
        expect(isKnownGearId(null), isFalse);

        const unknownGear = EquippedGearAppearance(
          head: 'helm_999',
          body: 'unknown_coat',
          boots: 'bad_boots',
        );
        expect(unknownGear.isEmpty, isFalse);
        expect(unknownGear.hasVisibleGear, isFalse);
      },
    );

    test('supports value equality and hash code', () {
      const gearA = EquippedGearAppearance(head: 'helm_1', body: 'coat_2');
      const gearB = EquippedGearAppearance(head: 'helm_1', body: 'coat_2');
      const gearC = EquippedGearAppearance(head: 'helm_1', body: 'coat_3');

      expect(gearA, equals(gearB));
      expect(gearA.hashCode, equals(gearB.hashCode));
      expect(gearA, isNot(equals(gearC)));
    });
  });

  group('FighterGearPainter safety and painter contracts', () {
    test('FighterGearPainter paints safely for empty and unknown gear', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const painter = FighterGearPainter(
        gear: EquippedGearAppearance(
          head: 'unknown_head',
          body: 'unknown_body',
          boots: 'unknown_boots',
        ),
      );

      expect(
        () => painter.paint(canvas, const Size(126, 156)),
        returnsNormally,
      );
      recorder.endRecording().dispose();
    });

    test('FighterGearPainter shouldRepaint reflects gear changes', () {
      const painter1 = FighterGearPainter(
        gear: EquippedGearAppearance(head: 'helm_1'),
      );
      const painter2 = FighterGearPainter(
        gear: EquippedGearAppearance(head: 'helm_1'),
      );
      const painter3 = FighterGearPainter(
        gear: EquippedGearAppearance(head: 'helm_2'),
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painter3), isTrue);
    });
  });

  group('Visual equipment layers render distinctly and safely', () {
    testWidgets(
      'visual equipment layers render distinctly and safely across slots, tiers, and combinations',
      (tester) async {
        // 1. Empty and unknown gear render existing art without throwing
        final emptyKey = UniqueKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  key: emptyKey,
                  width: 126,
                  height: 156,
                  child: HeroCustomizationArt(
                    selection: const HeroAppearanceSelection(),
                    gear: const EquippedGearAppearance(
                      head: 'unknown_helm',
                      body: 'invalid_armor',
                      boots: 'phantom_boots',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final emptyArt = find.descendant(
          of: find.byKey(emptyKey),
          matching: find.byType(CustomPaint),
        );
        await _waitForCustomPaint(tester, emptyArt);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(HeroCustomizationArt), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 2. Each visual slot produces an actual pixel difference
        final baseRender = await _captureArt(
          tester,
          gear: const EquippedGearAppearance(),
        );
        final helmRender = await _captureArt(
          tester,
          gear: const EquippedGearAppearance(head: 'helm_1'),
        );
        final coatRender = await _captureArt(
          tester,
          gear: const EquippedGearAppearance(body: 'coat_1'),
        );
        final bootsRender = await _captureArt(
          tester,
          gear: const EquippedGearAppearance(boots: 'boots_1'),
        );

        expect(
          _rendersDiffer(baseRender, helmRender),
          isTrue,
          reason: 'Equipping head_1 must alter the rendered hero image',
        );
        expect(
          _rendersDiffer(baseRender, coatRender),
          isTrue,
          reason: 'Equipping coat_1 must alter the rendered hero image',
        );
        expect(
          _rendersDiffer(baseRender, bootsRender),
          isTrue,
          reason: 'Equipping boots_1 must alter the rendered hero image',
        );
        expect(
          _rendersDiffer(helmRender, coatRender),
          isTrue,
          reason: 'Head and body gear must render in distinct areas/shapes',
        );

        // 3. Different tiers in each slot produce distinct renders
        final helmRenders = <String>[];
        for (var tier = 1; tier <= 4; tier++) {
          helmRenders.add(
            await _captureArt(
              tester,
              gear: EquippedGearAppearance(head: 'helm_$tier'),
            ),
          );
        }
        expect(
          helmRenders.toSet().length,
          4,
          reason: 'All 4 helm tiers must be visually distinct',
        );

        final coatRenders = <String>[];
        for (var tier = 1; tier <= 4; tier++) {
          coatRenders.add(
            await _captureArt(
              tester,
              gear: EquippedGearAppearance(body: 'coat_$tier'),
            ),
          );
        }
        expect(
          coatRenders.toSet().length,
          4,
          reason: 'All 4 coat tiers must be visually distinct',
        );

        final bootsRenders = <String>[];
        for (var tier = 1; tier <= 4; tier++) {
          bootsRenders.add(
            await _captureArt(
              tester,
              gear: EquippedGearAppearance(boots: 'boots_$tier'),
            ),
          );
        }
        expect(
          bootsRenders.toSet().length,
          4,
          reason: 'All 4 boots tiers must be visually distinct',
        );

        // 4. Combinations of slots compose cleanly
        final tier1Set = await _captureArt(
          tester,
          gear: const EquippedGearAppearance(
            head: 'helm_1',
            body: 'coat_1',
            boots: 'boots_1',
          ),
        );
        final tier4Set = await _captureArt(
          tester,
          gear: const EquippedGearAppearance(
            head: 'helm_4',
            body: 'coat_4',
            boots: 'boots_4',
          ),
        );
        final mixedSet = await _captureArt(
          tester,
          gear: const EquippedGearAppearance(
            head: 'helm_2',
            body: 'coat_4',
            boots: 'boots_1',
          ),
        );

        expect(
          _rendersDiffer(tier1Set, tier4Set),
          isTrue,
          reason: 'Tier 1 full set must differ from tier 4 full set',
        );
        expect(
          _rendersDiffer(tier1Set, mixedSet),
          isTrue,
          reason: 'Mixed set must differ from tier 1 set',
        );
        expect(
          _rendersDiffer(tier4Set, mixedSet),
          isTrue,
          reason: 'Mixed set must differ from tier 4 set',
        );

        // 5. FighterArt honors cosmetics, reduced-motion, and rival isolation
        final customKey = UniqueKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  key: customKey,
                  child: FighterArt(
                    seed: 4,
                    name: 'Kuzeyli',
                    isPlayer: true,
                    customization: const HeroAppearanceSelection(
                      bodyProportionId: 'body_02',
                    ),
                    gear: const EquippedGearAppearance(
                      head: 'helm_3',
                      body: 'coat_3',
                      boots: 'boots_3',
                    ),
                    motion: FighterMotion.guard,
                    motionKey: 1,
                    reducedMotion: true,
                  ),
                ),
              ),
            ),
          ),
        );
        final customArt = find.descendant(
          of: find.byKey(customKey),
          matching: find.byType(CustomPaint),
        );
        await _waitForCustomPaint(tester, customArt);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(HeroCustomizationArt), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Non-player rival FighterArt does not render player gear
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: FighterArt(
                  seed: 12,
                  name: 'Rakip',
                  isPlayer: false,
                  portraitAsset: 'assets/art/characters/hero_kulak.webp',
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(HeroCustomizationArt), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('BattlePage live callsite integration', () {
    testWidgets(
      'BattlePage player fighter reflects equipped gear without throwing',
      (tester) async {
        final storage = MemorySaveStorage()
          ..value = const GameSave(
            hasHero: true,
            heroName: 'Zırhlı Kahraman',
            appearance: 'origin_mountains',
            stats: Stats(
              might: 4,
              agility: 4,
              vitality: 4,
              guard: 2,
              stamina: 2,
              arcana: 2,
            ),
            equippedItems: {
              'head': 'helm_2',
              'body': 'coat_3',
              'boots': 'boots_1',
            },
          );
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1, seed: 42);

        await tester.pumpWidget(
          MaterialApp(
            home: BattlePage(
              controller: controller,
              resumeFromCheckpoint: true,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Find the player FighterArt
        final playerArtFinder = find.byWidgetPredicate(
          (widget) =>
              widget is FighterArt &&
              widget.isPlayer &&
              widget.gear.hasVisibleGear,
        );
        expect(playerArtFinder, findsOneWidget);

        final fighterWidget = tester.widget<FighterArt>(playerArtFinder);
        expect(fighterWidget.gear.head, 'helm_2');
        expect(fighterWidget.gear.body, 'coat_3');
        expect(fighterWidget.gear.boots, 'boots_1');
        expect(tester.takeException(), isNull);
        controller.dispose();
      },
    );

    testWidgets(
      'BattlePage player fighter safely handles unknown equipped items',
      (tester) async {
        final storage = MemorySaveStorage()
          ..value = const GameSave(
            hasHero: true,
            heroName: 'Bilinmeyen Zırh',
            appearance: 'origin_mountains',
            stats: Stats(
              might: 4,
              agility: 4,
              vitality: 4,
              guard: 2,
              stamina: 2,
              arcana: 2,
            ),
            equippedItems: {
              'head': 'helm_unknown_99',
              'body': 'coat_invalid',
              'boots': 'boots_unknown',
            },
          );
        final controller = GameController(storage: storage);
        await controller.initialize();
        await controller.startEncounter(1, seed: 99);

        await tester.pumpWidget(
          MaterialApp(
            home: BattlePage(
              controller: controller,
              resumeFromCheckpoint: true,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final playerArtFinder = find.byWidgetPredicate(
          (widget) => widget is FighterArt && widget.isPlayer,
        );
        expect(playerArtFinder, findsOneWidget);
        expect(tester.takeException(), isNull);
        controller.dispose();
      },
    );
  });
}

Future<void> _waitForCustomPaint(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 80 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
  }
  expect(
    finder,
    findsAtLeastNWidgets(1),
    reason: 'art asset should finish loading',
  );
}

Future<String> _captureArt(
  WidgetTester tester, {
  HeroAppearanceSelection selection = const HeroAppearanceSelection(),
  EquippedGearAppearance gear = const EquippedGearAppearance(),
}) async {
  final key = UniqueKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: 126,
              height: 156,
              child: HeroCustomizationArt(selection: selection, gear: gear),
            ),
          ),
        ),
      ),
    ),
  );
  final composedArt = find.descendant(
    of: find.byKey(key),
    matching: find.byType(CustomPaint),
  );
  await _waitForCustomPaint(tester, composedArt);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  expect(tester.takeException(), isNull);
  final boundary =
      tester.renderObject(find.byKey(key)) as RenderRepaintBoundary;
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 4));
  expect(image, isNotNull);
  final byteData = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  expect(byteData, isNotNull);
  final encoded = base64Encode(
    byteData!.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    ),
  );
  image!.dispose();
  return encoded;
}

bool _rendersDiffer(String first, String second) {
  if (first == second) return false;
  final firstBytes = base64Decode(first);
  final secondBytes = base64Decode(second);
  if (firstBytes.length != secondBytes.length) return true;
  for (var i = 0; i < firstBytes.length; i++) {
    if (firstBytes[i] != secondBytes[i]) return true;
  }
  return false;
}
