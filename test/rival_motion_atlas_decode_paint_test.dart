import 'dart:ui' as ui;

import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/rival_motion_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(clearDecodedImagesCache);

  test(
    'all mapped rival motion atlases decode as valid 3x2 WebP atlases',
    () async {
      final assets = _allMappedMotionAssets();

      for (final entry in assets.entries) {
        final asset = entry.value;
        final data = await rootBundle.load(asset);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        expect(bytes.sublist(0, 4), const [82, 73, 70, 70], reason: asset);
        expect(bytes.sublist(8, 12), const [87, 69, 66, 80], reason: asset);

        final codec = await ui.instantiateImageCodec(bytes);
        ui.FrameInfo? frameInfo;
        try {
          frameInfo = await codec.getNextFrame();
          final image = frameInfo.image;
          expect(image.width, 1536, reason: asset);
          expect(image.height, 1024, reason: asset);

          final rgba = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          expect(rgba, isNotNull, reason: asset);
          final pixels = rgba!;
          expect(
            pixels.getUint8(3),
            lessThanOrEqualTo(1),
            reason: '$asset must keep the top-left atlas corner transparent',
          );

          const columns = 3;
          const rows = 2;
          const cellSize = 512;
          expect(image.width % columns, 0, reason: asset);
          expect(image.height % rows, 0, reason: asset);

          for (var frame = 0; frame < columns * rows; frame++) {
            final column = frame % columns;
            final row = frame ~/ columns;
            final left = column * cellSize;
            final top = row * cellSize;
            final reason = '$asset frame $frame';
            final crop = Rect.fromLTWH(
              left.toDouble(),
              top.toDouble(),
              cellSize.toDouble(),
              cellSize.toDouble(),
            );
            expect(crop.left, greaterThanOrEqualTo(0), reason: reason);
            expect(crop.top, greaterThanOrEqualTo(0), reason: reason);
            expect(crop.right, lessThanOrEqualTo(image.width), reason: reason);
            expect(
              crop.bottom,
              lessThanOrEqualTo(image.height),
              reason: reason,
            );
            expect(crop.width, 512, reason: reason);
            expect(crop.height, 512, reason: reason);

            var visibleSamples = 0;
            for (var y = top + 16; y < top + cellSize - 16; y += 8) {
              for (var x = left + 16; x < left + cellSize - 16; x += 8) {
                final alphaOffset = (y * image.width + x) * 4 + 3;
                if (pixels.getUint8(alphaOffset) > 8) visibleSamples++;
              }
            }
            expect(
              visibleSamples,
              greaterThan(0),
              reason: '$asset frame $frame must contain visible artwork',
            );
          }
        } finally {
          frameInfo?.image.dispose();
          codec.dispose();
        }
      }
    },
  );

  testWidgets('all mapped rivals paint through FighterArt', (tester) async {
    final assets = _allMappedMotionAssets();

    for (final entry in assets.entries) {
      await _paintAndExpectFrame(
        tester,
        encounterId: entry.key,
        asset: entry.value,
        motion: FighterMotion.idle,
        motionKey: 0,
        reducedMotion: true,
        expectedFrame: 0,
      );
    }
  });

  testWidgets(
    'all four champion atlases paint each of their six motion cells',
    (tester) async {
      const championIds = [8, 16, 24, 32];
      const probes = <_MotionFrameProbe>[
        _MotionFrameProbe('idle', FighterMotion.idle, 0, 0, true),
        _MotionFrameProbe('wind-up', FighterMotion.attack, 1, 1, false),
        _MotionFrameProbe('attack/cast', FighterMotion.spell, 2, 2, false),
        _MotionFrameProbe('hit recoil', FighterMotion.hit, 3, 3, false),
        _MotionFrameProbe('guard', FighterMotion.guard, 4, 4, false),
        _MotionFrameProbe('defeat', FighterMotion.defeat, 5, 5, false),
      ];

      expect(rivalMotionAtlasFrame(FighterMotion.attack, 0), 1);
      expect(rivalMotionAtlasFrame(FighterMotion.attack, .5), 2);
      expect(rivalMotionAtlasFrame(FighterMotion.spell, .5), 2);

      for (final encounterId in championIds) {
        final asset = rivalMotionAtlasAssetForEncounter(encounterId);
        expect(asset, isNotNull, reason: 'champion encounter $encounterId');

        for (final probe in probes) {
          expect(
            rivalMotionAtlasFrame(probe.motion, 0),
            probe.expectedFrame,
            reason: '${probe.name} mapping for encounter $encounterId',
          );
          await _paintAndExpectFrame(
            tester,
            encounterId: encounterId,
            asset: asset!,
            motion: probe.motion,
            motionKey: probe.motionKey,
            reducedMotion: probe.reducedMotion,
            expectedFrame: probe.expectedFrame,
            stateName: probe.name,
          );
        }
      }
    },
  );
}

Map<int, String> _allMappedMotionAssets() {
  final assets = <int, String>{};
  for (var encounterId = 1; encounterId <= 32; encounterId++) {
    final asset = rivalMotionAtlasAssetForEncounter(encounterId);
    expect(
      asset,
      isNotNull,
      reason: 'encounter $encounterId needs a motion atlas',
    );
    expect(asset, endsWith('.webp'), reason: 'encounter $encounterId');
    assets[encounterId] = asset!;
  }

  expect(assets, hasLength(32));
  expect(
    assets.values.toSet(),
    hasLength(32),
    reason: 'each rival needs its own atlas',
  );
  return assets;
}

Future<void> _paintAndExpectFrame(
  WidgetTester tester, {
  required int encounterId,
  required String asset,
  required FighterMotion motion,
  required int motionKey,
  required bool reducedMotion,
  required int expectedFrame,
  String? stateName,
}) async {
  final reason = stateName == null
      ? 'encounter $encounterId: $asset'
      : 'encounter $encounterId $stateName: $asset';
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: FighterArt(
            key: ValueKey('$asset:$encounterId:$motionKey:${motion.name}'),
            seed: encounterId,
            name: 'Rival $encounterId',
            family: 'maul',
            motionAtlasAsset: asset,
            motion: motion,
            motionKey: motionKey,
            reducedMotion: reducedMotion,
          ),
        ),
      ),
    ),
  );

  await _waitForBattleMotionPainter(tester, reason);
  _expectBattleMotionPainterFrame(tester, expectedFrame, reason);
  expect(find.byType(FighterArt), findsOneWidget, reason: reason);
  expect(tester.takeException(), isNull, reason: reason);
}

Future<void> _waitForBattleMotionPainter(
  WidgetTester tester,
  String reason,
) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    final painters = _battleMotionPainters(tester);
    if (painters.isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  expect(
    _battleMotionPainters(tester),
    hasLength(1),
    reason: '$reason must decode into the runtime battle atlas painter',
  );
}

List<CustomPainter> _battleMotionPainters(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((widget) => widget.painter)
    .whereType<CustomPainter>()
    .where(
      (painter) =>
          painter.runtimeType.toString().contains('BattleMotionAtlasPainter'),
    )
    .toList();

void _expectBattleMotionPainterFrame(
  WidgetTester tester,
  int expectedFrame,
  String reason,
) {
  final painters = _battleMotionPainters(tester);
  expect(painters, hasLength(1), reason: reason);
  final actualFrame = (painters.single as dynamic).index as int;
  expect(actualFrame, expectedFrame, reason: reason);
}

class _MotionFrameProbe {
  const _MotionFrameProbe(
    this.name,
    this.motion,
    this.motionKey,
    this.expectedFrame,
    this.reducedMotion,
  );

  final String name;
  final FighterMotion motion;
  final int motionKey;
  final int expectedFrame;
  final bool reducedMotion;
}
