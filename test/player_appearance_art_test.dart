import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/hero_weapon_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(clearDecodedImagesCache);

  test('body proportion IDs map to unique in-bounds atlas cells', () {
    const atlasSize = Size(1536, 1024);
    final frames = heroBodyProportionIds
        .map((id) => heroBodyAtlasCell(id, atlasSize))
        .toList();

    expect(heroBodyProportionIds, hasLength(3));
    expect(frames.toSet(), hasLength(heroBodyProportionIds.length));
    expect(heroBodyProportionIndex('body_01'), 0);
    _expectFramesInBounds(frames, atlasSize);
  });

  test(
    'removed color and hair choices are absent from the active selection',
    () {
      const defaultSelection = HeroAppearanceSelection();
      expect(defaultSelection.isDefault, isTrue);
      expect(
        const HeroAppearanceSelection(bodyProportionId: 'body_02').isDefault,
        isFalse,
      );
    },
  );

  test(
    'four origins resolve to separate bundled transparent atlases',
    () async {
      const origins = ['Kıyı', 'Ocak', 'Fırtına', 'Taç'];
      final paths = origins.map(heroCombatBaseAssetForOrigin).toList();
      expect(paths.toSet(), hasLength(origins.length));

      for (final path in paths) {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 1536, reason: path);
        expect(frame.image.height, 1024, reason: path);
        final pixels = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        expect(pixels, isNotNull, reason: path);
        expect(
          pixels!.getUint8(3),
          0,
          reason: 'atlas background should remain transparent: $path',
        );
        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  testWidgets('origin selection paints distinct character art', (tester) async {
    final origins = ['Kıyı', 'Ocak', 'Fırtına', 'Taç'];
    for (final size in [const Size(126, 156), const Size(180, 190)]) {
      final renders = <String>[];
      for (final origin in origins) {
        renders.addAll(
          await _renderSelections(
            tester,
            const [HeroAppearanceSelection()],
            origin: origin,
            size: size,
          ),
        );
      }
      _expectDistinctRenders(
        renders,
        origins,
        'origin at ${size.width}x${size.height}',
      );
    }
  });

  testWidgets('body proportions paint distinctly for each origin', (
    tester,
  ) async {
    for (final origin in ['Kıyı', 'Ocak', 'Fırtına', 'Taç']) {
      final bodyRenders = await _renderSelections(
        tester,
        heroBodyProportionIds.map(
          (id) => HeroAppearanceSelection(bodyProportionId: id),
        ),
        origin: origin,
      );
      _expectDistinctRenders(
        bodyRenders,
        heroBodyProportionIds,
        '$origin body',
      );
    }
  });

  testWidgets('all weapon families paint distinctly at battle scale', (
    tester,
  ) async {
    final families = HeroWeaponArt.supportedFamilies.toList();
    for (final size in [const Size(126, 156), const Size(180, 190)]) {
      final familyRenders = <String>[];
      for (final family in families) {
        familyRenders.addAll(
          await _renderSelections(
            tester,
            const [HeroAppearanceSelection()],
            family: family,
            size: size,
          ),
        );
      }
      expect(familyRenders, hasLength(families.length));
      _expectDistinctRenders(
        familyRenders,
        families,
        'weapon family at ${size.width}x${size.height}',
      );
    }
  });

  testWidgets('body proportion previews paint all origin atlas crops', (
    tester,
  ) async {
    for (final origin in ['Kıyı', 'Ocak', 'Fırtına', 'Taç']) {
      for (final id in heroBodyProportionIds) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox.square(
                  dimension: 64,
                  child: HeroAppearanceOptionPreview(
                    kind: HeroAppearanceOptionKind.body,
                    optionId: id,
                    origin: origin,
                  ),
                ),
              ),
            ),
          ),
        );
        final preview = find.byType(CustomPaint);
        await _waitForCustomPaint(tester, preview);
        await tester.pumpAndSettle();
        expect(preview, findsOneWidget, reason: '$origin/$id');
        expect(tester.takeException(), isNull, reason: '$origin/$id');
      }
    }
  });
}

void _expectDistinctRenders(
  List<String> renders,
  List<String> ids,
  String kind,
) {
  final duplicatePairs = <String>[];
  for (var left = 0; left < renders.length; left++) {
    for (var right = left + 1; right < renders.length; right++) {
      if (renders[left] == renders[right]) {
        duplicatePairs.add('${ids[left]}=${ids[right]}');
      }
    }
  }
  expect(
    renders.toSet().length,
    ids.length,
    reason: '$kind options rendered identically: ${duplicatePairs.join(', ')}',
  );
}

Future<void> _waitForCustomPaint(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 100 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  expect(finder, findsOneWidget, reason: 'art asset should finish loading');
}

void _expectFramesInBounds(List<Rect> frames, Size atlasSize) {
  for (final frame in frames) {
    expect(frame.left, greaterThanOrEqualTo(0));
    expect(frame.top, greaterThanOrEqualTo(0));
    expect(frame.width, greaterThan(0));
    expect(frame.height, greaterThan(0));
    expect(frame.right, lessThanOrEqualTo(atlasSize.width));
    expect(frame.bottom, lessThanOrEqualTo(atlasSize.height));
  }
}

Future<List<String>> _renderSelections(
  WidgetTester tester,
  Iterable<HeroAppearanceSelection> selections, {
  String family = 'shortSword',
  String origin = 'Kıyı',
  Size size = const Size(126, 156),
}) async {
  final rendered = <String>[];
  for (final selection in selections) {
    final key = UniqueKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox.fromSize(
                size: size,
                child: HeroCustomizationArt(
                  selection: selection,
                  family: family,
                  origin: origin,
                ),
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
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '$origin/$selection');
    final boundary =
        tester.renderObject(find.byKey(key)) as RenderRepaintBoundary;
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 4));
    expect(image, isNotNull);
    final byteData = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    expect(byteData, isNotNull);
    rendered.add(
      base64Encode(
        byteData!.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      ),
    );
    image!.dispose();
  }
  return rendered;
}
