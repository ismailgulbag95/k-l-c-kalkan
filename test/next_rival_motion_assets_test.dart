import 'dart:ui' as ui;

import 'package:ash_circuit/game/ui/design.dart';
import 'package:ash_circuit/game/ui/rival_motion_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _expectedMotionAssets = <int, String>{
  5: 'assets/art/characters/halatci_sefa_motion.png',
  6: 'assets/art/characters/pasli_kanca_motion.png',
  7: 'assets/art/characters/fener_bekcisi_motion.png',
  9: 'assets/art/characters/curuf_tasiyici_motion.png',
  10: 'assets/art/characters/zincirci_motion.png',
  11: 'assets/art/characters/ors_muhafizi_motion.png',
  12: 'assets/art/characters/sozlesmeli_duellocu_motion.png',
  13: 'assets/art/characters/koz_golgesi_motion.png',
  14: 'assets/art/characters/kizil_ocak_sefi_motion.png',
  15: 'assets/art/characters/kukurt_matronu_motion.png',
  17: 'assets/art/characters/menzil_avcisi_motion.png',
  18: 'assets/art/characters/ayna_kilic_motion.png',
  19: 'assets/art/characters/gelgit_muhurcusu_motion.png',
  20: 'assets/art/characters/firtina_avcisi_motion.png',
  21: 'assets/art/characters/ruzgar_seyircisi_motion.png',
  22: 'assets/art/characters/kiyi_orakcisi_motion.png',
  23: 'assets/art/characters/gelgit_yargici_motion.png',
  25: 'assets/art/characters/tac_muhafizi_motion.png',
  26: 'assets/art/characters/golge_duellocu_motion.png',
  27: 'assets/art/characters/sancak_cadisi_motion.png',
  28: 'assets/art/characters/demir_cellat_motion.png',
  29: 'assets/art/characters/tahtsiz_varis_motion.png',
  30: 'assets/art/characters/kul_komutani_motion.png',
  31: 'assets/art/characters/muhur_kirici_motion.png',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ordinary rivals map to stable motion atlases', () {
    for (final entry in _expectedMotionAssets.entries) {
      expect(rivalMotionAtlasAssetForEncounter(entry.key), entry.value);
    }
    expect(
      rivalMotionAtlasAssetForEncounter(24),
      'assets/art/characters/observatory_priest_motion.png',
    );
    expect(
      rivalMotionAtlasAssetForEncounter(32),
      'assets/art/characters/circle_master_motion.png',
    );
    expect(rivalMotionAtlasAssetForEncounter(8), contains('fener_champion'));
  });

  testWidgets('each next rival motion atlas decodes and paints', (
    tester,
  ) async {
    for (final entry in _expectedMotionAssets.entries) {
      final asset = entry.value;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FighterArt(
                seed: entry.key,
                name: 'Opponent ${entry.key}',
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

      final decoded = await tester.runAsync(() async {
        final data = await rootBundle.load(asset);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        expect(bytes.sublist(0, 8), const [
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
        ], reason: '$asset should be a PNG');
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final size = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
        final rgba = (await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        final cellCornerAlphas = <int>[];
        for (var row = 0; row < 2; row++) {
          for (var column = 0; column < 3; column++) {
            final left = column * 512;
            final right = left + 511;
            final top = row * 512;
            final bottom = top + 511;
            for (final y in [top, bottom]) {
              for (final x in [left, right]) {
                cellCornerAlphas.add(
                  rgba.getUint8((y * size.width.toInt() + x) * 4 + 3),
                );
              }
            }
          }
        }
        frame.image.dispose();
        codec.dispose();
        return (size, cellCornerAlphas);
      });

      expect(decoded?.$1, const Size(1536, 1024), reason: asset);
      expect(
        decoded?.$2,
        everyElement(lessThan(8)),
        reason: '$asset outer corners of all six cells should be transparent',
      );
      expect(find.byType(FighterArt), findsOneWidget, reason: asset);
      expect(tester.takeException(), isNull, reason: asset);
    }
  });
}
