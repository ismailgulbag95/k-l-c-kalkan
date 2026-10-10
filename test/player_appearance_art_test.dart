import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ash_circuit/game/ui/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appearance IDs map to unique in-bounds atlas cells', () {
    const headAtlasSize = Size(1774, 887);
    const bodyAtlasSize = Size(1536, 1024);
    const facialHairAtlasSize = Size(1536, 1024);

    final headFrames = heroHeadOptionIds
        .map((id) => heroHeadAtlasCell(id, headAtlasSize))
        .toList();
    final bodyFrames = heroBodyProportionIds
        .map((id) => heroBodyAtlasCell(id, bodyAtlasSize))
        .toList();
    final facialHairFrames = heroFacialHairIds
        .map((id) => heroFacialHairAtlasCell(id, facialHairAtlasSize))
        .toList();

    expect(heroHeadOptionIds, hasLength(8));
    expect(heroSkinToneIds, hasLength(8));
    expect(heroBodyProportionIds, hasLength(3));
    expect(heroFacialHairIds, hasLength(5));
    expect(headFrames.toSet(), hasLength(heroHeadOptionIds.length));
    expect(bodyFrames.toSet(), hasLength(heroBodyProportionIds.length));
    expect(facialHairFrames.toSet(), hasLength(heroFacialHairIds.length));
    expect(
      heroSkinToneIds.map(heroSkinToneColor).toSet(),
      hasLength(heroSkinToneIds.length),
    );

    _expectFramesInBounds(headFrames, headAtlasSize);
    _expectFramesInBounds(bodyFrames, bodyAtlasSize);
    _expectFramesInBounds(facialHairFrames, facialHairAtlasSize);
    expect(heroHeadOptionIndex('head_01'), 0);
    expect(heroBodyProportionIndex('body_01'), 0);
    expect(heroFacialHairIndex('facial_hair_00'), 0);
    expect(heroSkinToneColor('skin_01'), heroSkinToneColors['skin_01']);
  });

  test('appearance atlas PNGs are bundled and decodable', () async {
    const paths = [
      'assets/art/characters/hero_head_layers.png',
      'assets/art/characters/hero_body_layers.png',
      'assets/art/characters/hero_facial_hair_layers.png',
    ];

    for (final path in paths) {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0), reason: path);
      expect(frame.image.height, greaterThan(0), reason: path);
      frame.image.dispose();
      codec.dispose();
    }
  });

  testWidgets('every appearance choice composes as a distinct render', (
    tester,
  ) async {
    final headRenders = await _renderSelections(
      tester,
      heroHeadOptionIds.map((id) => HeroAppearanceSelection(headOptionId: id)),
    );
    final skinRenders = await _renderSelections(
      tester,
      heroSkinToneIds.map((id) => HeroAppearanceSelection(skinToneId: id)),
    );
    final bodyRenders = await _renderSelections(
      tester,
      heroBodyProportionIds.map(
        (id) => HeroAppearanceSelection(bodyProportionId: id),
      ),
    );
    final facialHairRenders = await _renderSelections(
      tester,
      heroFacialHairIds.map((id) => HeroAppearanceSelection(facialHairId: id)),
    );

    _expectDistinctRenders(headRenders, heroHeadOptionIds, 'head');
    _expectDistinctRenders(skinRenders, heroSkinToneIds, 'skin');
    _expectDistinctRenders(bodyRenders, heroBodyProportionIds, 'body');
    _expectDistinctRenders(facialHairRenders, heroFacialHairIds, 'facial hair');
    final cleanShaven = base64Decode(facialHairRenders.first);
    for (var index = 1; index < facialHairRenders.length; index++) {
      expect(
        _regionDiffers(cleanShaven, base64Decode(facialHairRenders[index])),
        isTrue,
        reason: '${heroFacialHairIds[index]} must be visible on the face',
      );
    }
  });

  testWidgets('appearance option previews paint every atlas crop', (
    tester,
  ) async {
    for (final (kind, ids) in [
      (HeroAppearanceOptionKind.head, heroHeadOptionIds),
      (HeroAppearanceOptionKind.body, heroBodyProportionIds),
      (HeroAppearanceOptionKind.facialHair, heroFacialHairIds),
    ]) {
      for (final id in ids) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox.square(
                  dimension: 64,
                  child: HeroAppearanceOptionPreview(kind: kind, optionId: id),
                ),
              ),
            ),
          ),
        );
        final preview = find.byType(CustomPaint);
        await _waitForCustomPaint(tester, preview);
        await tester.pumpAndSettle();

        expect(preview, findsOneWidget, reason: id);
        expect(tester.takeException(), isNull, reason: id);
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

bool _regionDiffers(List<int> first, List<int> second) {
  const imageWidth = 504;
  const left = 168;
  const top = 0;
  const width = 168;
  const height = 136;
  for (var y = top; y < top + height; y++) {
    for (var x = left; x < left + width; x++) {
      final offset = (y * imageWidth + x) * 4;
      for (var channel = 0; channel < 4; channel++) {
        if (first[offset + channel] != second[offset + channel]) return true;
      }
    }
  }
  return false;
}

Future<void> _waitForCustomPaint(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 25 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
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
  Iterable<HeroAppearanceSelection> selections,
) async {
  final rendered = <String>[];
  for (final selection in selections) {
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
                child: HeroCustomizationArt(selection: selection),
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

    final exception = tester.takeException();
    expect(exception, isNull, reason: selection.toString());
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
