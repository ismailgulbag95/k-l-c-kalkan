import 'dart:ui' as ui;

import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/rival_motion_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('early rivals map to stable dedicated motion atlases', () {
    expect(
      [
        1,
        2,
        3,
        4,
        8,
        16,
        24,
        32,
      ].map(rivalMotionAtlasAssetForEncounter).toList(),
      const [
        'assets/art/characters/iskele_kabadayisi_motion.png',
        'assets/art/characters/halat_kosucusu_motion.png',
        'assets/art/characters/kapi_bekcisi_motion.png',
        'assets/art/characters/tuz_kahini_motion.png',
        'assets/art/characters/fener_champion_motion.png',
        'assets/art/characters/brass_guardian_motion.png',
        'assets/art/characters/observatory_priest_motion.png',
        'assets/art/characters/circle_master_motion.png',
      ],
    );
    expect(
      rivalMotionAtlasAssetForEncounter(5),
      'assets/art/characters/halatci_sefa_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(6),
      'assets/art/characters/pasli_kanca_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(7),
      'assets/art/characters/fener_bekcisi_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(9),
      'assets/art/characters/curuf_tasiyici_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(10),
      'assets/art/characters/zincirci_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(11),
      'assets/art/characters/ors_muhafizi_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(12),
      'assets/art/characters/sozlesmeli_duellocu_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(13),
      'assets/art/characters/koz_golgesi_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(14),
      'assets/art/characters/kizil_ocak_sefi_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(15),
      'assets/art/characters/kukurt_matronu_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(17),
      'assets/art/characters/menzil_avcisi_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(18),
      'assets/art/characters/ayna_kilic_motion.png',
    );
    expect(rivalMotionAtlasAssetForEncounter(0), isNull);
    expect(rivalMotionAtlasAssetForEncounter(19), isNull);
    expect(rivalMotionAtlasFrame(FighterMotion.attack, 0.1), 1);
    expect(rivalMotionAtlasFrame(FighterMotion.attack, 0.5), 2);
    expect(rivalMotionAtlasFrame(FighterMotion.hit, 0.5), 3);
    expect(rivalMotionAtlasFrame(FighterMotion.guard, 0.5), 4);
    expect(rivalMotionAtlasFrame(FighterMotion.spell, 0.5), 2);
    expect(rivalMotionAtlasFrame(FighterMotion.spell, 1), 0);
    expect(rivalMotionAtlasFrame(FighterMotion.defeat, 1), 5);
  });

  testWidgets('each early rival atlas decodes and paints through FighterArt', (
    tester,
  ) async {
    for (final encounterId in [1, 2, 3, 4]) {
      final asset = rivalMotionAtlasAssetForEncounter(encounterId)!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FighterArt(
                seed: encounterId,
                name: 'Opponent $encounterId',
                family: 'maul',
                motionAtlasAsset: asset,
                motion: FighterMotion.idle,
                reducedMotion: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final decodedSize = await tester.runAsync(() async {
        final data = await rootBundle.load(asset);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        final frame = await codec.getNextFrame();
        final size = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
        final rgba = (await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        final cornerAlpha = rgba.getUint8(3);
        frame.image.dispose();
        codec.dispose();
        return (size, cornerAlpha);
      });
      expect(decodedSize?.$1, const Size(1536, 1024), reason: asset);
      expect(
        decodedSize?.$2,
        0,
        reason: '$asset must keep a transparent corner',
      );
      expect(find.byType(FighterArt), findsOneWidget, reason: asset);
      expect(tester.takeException(), isNull, reason: asset);
    }
  });
}
