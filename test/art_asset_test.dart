import 'dart:ui' as ui;

import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/data/intermission_decisions.dart';
import 'package:ash_circuit/game/domain/battle_engine.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:ash_circuit/game/ui/contract_art.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all runtime art assets are bundled and decodable', () async {
    final paths = <String>{
      ...arenas.map((arena) => arena.art),
      heroArtForAppearance('Kıyı')!,
      characterArtForEncounter(40)!,
      gameItemIconAtlasAsset,
      gameTieredItemIconAtlasAsset,
      battleEffectsAtlasAsset,
      storyEvidenceAtlasAsset,
      'assets/art/effects/metal_impact_spark.png',
      ...List<String>.generate(40, (index) {
        final encounterId = index + 1;
        return characterArtForEncounter(encounterId) ??
            rivalAtlasForEncounter(encounterId)!.asset;
      }),
      ...contractArtById.values,
      ...intermissionDecisions.map((decision) => decision.art),
    };

    expect(paths, hasLength(42));
    for (final path in paths) {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0), reason: path);
      expect(frame.image.height, greaterThan(0), reason: path);
      frame.image.dispose();
      codec.dispose();
    }
  });

  test(
    'combat effect atlas frames and action mapping cover each VFX',
    () async {
      expect(BattleEffectFrame.values, hasLength(8));
      expect(battleEffectsAtlasFrames, hasLength(8));

      final data = await rootBundle.load(battleEffectsAtlasAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1774);
      expect(frame.image.height, 887);
      final pixels = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      expect(
        pixels!.getUint8(3),
        0,
        reason: 'atlas corner must be transparent',
      );
      frame.image.dispose();
      codec.dispose();

      BattleEvent event(BattleEventType type, {BattleAction? action}) =>
          BattleEvent(sequence: 1, turn: 1, type: type, action: action);
      expect(
        battleEffectFrameForEvent(
          event(BattleEventType.guardRaised, action: BattleAction.guard),
        ),
        BattleEffectFrame.block.index,
      );
      expect(
        battleEffectFrameForEvent(
          event(BattleEventType.attackStarted, action: BattleAction.bow),
        ),
        BattleEffectFrame.arrow.index,
      );
      expect(
        battleEffectFrameForEvent(
          event(BattleEventType.spellCast, action: BattleAction.swiftBreeze),
        ),
        BattleEffectFrame.wind.index,
      );
      expect(
        battleEffectFrameForEvent(
          event(BattleEventType.spellCast, action: BattleAction.emberSpear),
        ),
        BattleEffectFrame.fire.index,
      );
      expect(
        battleEffectFrameForEvent(
          event(BattleEventType.spellCast, action: BattleAction.tideWard),
        ),
        BattleEffectFrame.tide.index,
      );
    },
  );

  testWidgets('battle effect widget paints every atlas frame', (tester) async {
    for (final effect in BattleEffectFrame.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BattleImpactEffect(
                sequence: effect.index + 1,
                alignment: Alignment.center,
                reducedMotion: false,
                frame: effect.index,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsOneWidget, reason: effect.name);
      expect(tester.takeException(), isNull, reason: effect.name);
    }
  });

  test(
    'Champions Road rival atlas has the expected 4x2 source layout',
    () async {
      final data = await rootBundle.load(
        'assets/art/rivals/champions_road_atlas.png',
      );
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1536);
      expect(frame.image.height, 1024);
      frame.image.dispose();
      codec.dispose();
    },
  );

  test(
    'Champions Road atlas keeps all eight rival panels visually distinct',
    () async {
      final data = await rootBundle.load(
        'assets/art/rivals/champions_road_atlas.png',
      );
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final pixels = (await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      const columns = 4;
      const cellWidth = 384;
      const cellHeight = 512;
      final fingerprints = <int>{};

      for (var cell = 0; cell < 8; cell++) {
        final column = cell % columns;
        final row = cell ~/ columns;
        var fingerprint = 0x811c9dc5;
        for (
          var y = row * cellHeight + 32;
          y < (row + 1) * cellHeight - 20;
          y += 3
        ) {
          for (
            var x = column * cellWidth + 30;
            x < (column + 1) * cellWidth - 30;
            x += 3
          ) {
            final offset = (y * frame.image.width + x) * 4;
            for (var channel = 0; channel < 3; channel++) {
              fingerprint =
                  ((fingerprint ^ pixels[offset + channel]) * 0x01000193) &
                  0xffffffff;
            }
          }
        }
        fingerprints.add(fingerprint);
      }

      expect(fingerprints, hasLength(8));
      frame.image.dispose();
      codec.dispose();
    },
  );

  test('shop catalog items and spells map to valid unique icon frames', () {
    expect(
      shopItems
          .where((item) => item.id.endsWith('_1'))
          .map(shopItemIconFrame)
          .toSet(),
      equals({0, 1, 2, 3, 4, 5, 6, 7}),
    );
    expect(
      shopItems
          .where((item) => !item.id.endsWith('_1'))
          .map(shopItemIconFrame)
          .toSet(),
      equals(List<int>.generate(24, (index) => index + 16).toSet()),
    );
    expect(shopItems.map(shopItemIconFrame).toSet(), hasLength(32));
    expect(spells.map((spell) => spellIconFrame(spell.action)), [
      8,
      9,
      10,
      11,
      12,
      13,
    ]);
    expect(gameItemIconAtlasFrames, hasLength(16));
    expect(gameTieredItemIconAtlasFrames, hasLength(24));
    for (final rect in gameItemIconAtlasFrames) {
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(1254));
      expect(rect.bottom, lessThanOrEqualTo(1254));
    }
    for (final rect in gameTieredItemIconAtlasFrames) {
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(1536));
      expect(rect.bottom, lessThanOrEqualTo(1024));
    }
  });

  testWidgets('shop icons paint each catalog tier frame', (tester) async {
    for (final item in shopItems) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ItemAtlasIcon(frame: shopItemIconFrame(item), size: 44),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsOneWidget, reason: item.id);
      expect(tester.takeException(), isNull, reason: item.id);
    }
  });
}
