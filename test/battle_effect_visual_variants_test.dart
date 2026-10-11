import 'dart:ui' as ui;

import 'package:ash_circuit/game/ui/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> _createTestImage([int width = 16, int height = 16]) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const arenaIds = <String>['kul', 'kor', 'firtina', 'gelgit', 'tac', 'halka'];

  const weaponFamilies = <String>['shortSword', 'maul', 'spear', 'bow'];

  const weaponProminentFrames = <BattleEffectFrame>[
    BattleEffectFrame.impact,
    BattleEffectFrame.dust,
    BattleEffectFrame.block,
    BattleEffectFrame.arrow,
  ];

  const ambientElementalFrames = <BattleEffectFrame>[
    BattleEffectFrame.healing,
    BattleEffectFrame.wind,
    BattleEffectFrame.fire,
    BattleEffectFrame.tide,
  ];

  group('battle effect visual variant mappings', () {
    test('all weapon families map to their own combat motif', () {
      expect(
        battleWeaponEffectMotifFor('shortSword'),
        BattleWeaponEffectMotif.blade,
      );
      expect(
        battleWeaponEffectMotifFor('maul'),
        BattleWeaponEffectMotif.impact,
      );
      expect(
        battleWeaponEffectMotifFor('spear'),
        BattleWeaponEffectMotif.thrust,
      );
      expect(battleWeaponEffectMotifFor('bow'), BattleWeaponEffectMotif.volley);
      expect(
        battleWeaponEffectMotifFor('unknown'),
        BattleWeaponEffectMotif.neutral,
      );
    });

    test('all arenas map to their own environmental motif', () {
      const motifs = <String, BattleArenaEffectMotif>{
        'kul': BattleArenaEffectMotif.ash,
        'kor': BattleArenaEffectMotif.ember,
        'firtina': BattleArenaEffectMotif.storm,
        'gelgit': BattleArenaEffectMotif.tide,
        'tac': BattleArenaEffectMotif.crown,
        'halka': BattleArenaEffectMotif.circuit,
      };

      for (final entry in motifs.entries) {
        expect(battleArenaEffectMotifFor(entry.key), entry.value);
      }
      expect(
        battleArenaEffectMotifFor('unknown'),
        BattleArenaEffectMotif.neutral,
      );
    });

    test(
      'resolved visual variants carry both shape motifs into the painter',
      () {
        final variant = battleEffectVisualVariantFor(
          arenaId: 'gelgit',
          weaponFamily: 'spear',
          effectFrame: BattleEffectFrame.impact,
        );

        expect(variant.weaponMotif, BattleWeaponEffectMotif.thrust);
        expect(variant.arenaMotif, BattleArenaEffectMotif.tide);

        final painter = BattleEffectMotifPainter(variant);
        expect(
          painter.shouldRepaint(BattleEffectMotifPainter(variant)),
          isFalse,
        );
        expect(
          painter.shouldRepaint(
            BattleEffectMotifPainter(
              battleEffectVisualVariantFor(
                arenaId: 'kor',
                weaponFamily: 'spear',
                effectFrame: BattleEffectFrame.impact,
              ),
            ),
          ),
          isTrue,
        );
      },
    );

    test(
      'isWeaponProminentEffectFrame partitions all 8 atlas frames correctly',
      () {
        for (final frame in weaponProminentFrames) {
          expect(
            isWeaponProminentEffectFrame(frame),
            isTrue,
            reason: '${frame.name} must be weapon-prominent',
          );
        }
        for (final frame in ambientElementalFrames) {
          expect(
            isWeaponProminentEffectFrame(frame),
            isFalse,
            reason: '${frame.name} must be ambient/elemental (arena-prominent)',
          );
        }
      },
    );

    test('all 6 arenas and 4 weapon families produce distinct visual variants for weapon effects', () {
      for (final frame in weaponProminentFrames) {
        for (final arena in arenaIds) {
          final tintsForWeapons = <String, Color>{};
          for (final weapon in weaponFamilies) {
            final variant = battleEffectVisualVariantFor(
              arenaId: arena,
              weaponFamily: weapon,
              effectFrame: frame,
            );
            expect(variant.tint, isNotNull);
            expect(variant.arenaId, arena);
            expect(variant.weaponFamily, weapon);
            expect(variant.frame, frame);
            tintsForWeapons[weapon] = variant.tint;
          }
          // Changing weapon family must yield distinct colors for the same arena.
          final uniqueColors = tintsForWeapons.values.toSet();
          expect(
            uniqueColors.length,
            weaponFamilies.length,
            reason:
                'Each weapon family must have distinct tint in arena $arena for ${frame.name}',
          );
        }
      }
    });

    test(
      'both arena and weapon inputs affect weapon-prominent effect tints',
      () {
        for (final weapon in weaponFamilies) {
          final tintsAcrossArenas = <String, Color>{};
          for (final arena in arenaIds) {
            final tint = battleEffectTintFor(
              arenaId: arena,
              weaponFamily: weapon,
              effectFrame: BattleEffectFrame.impact,
            );
            tintsAcrossArenas[arena] = tint;
          }
          // Changing arena must affect the result for the same weapon.
          final uniqueArenaColors = tintsAcrossArenas.values.toSet();
          expect(
            uniqueArenaColors.length,
            arenaIds.length,
            reason:
                'Arena environment must affect weapon impact tint for $weapon',
          );
        }
      },
    );

    test('all 6 arenas produce distinct ambient/elemental tints with weapon influence', () {
      for (final frame in ambientElementalFrames) {
        for (final weapon in weaponFamilies) {
          final tintsForArenas = <String, Color>{};
          for (final arena in arenaIds) {
            final variant = battleEffectVisualVariantFor(
              arenaId: arena,
              weaponFamily: weapon,
              effectFrame: frame,
            );
            expect(variant.tint, isNotNull);
            tintsForArenas[arena] = variant.tint;
          }
          final uniqueColors = tintsForArenas.values.toSet();
          expect(
            uniqueColors.length,
            arenaIds.length,
            reason:
                'Each arena must yield a distinct ambient tint for ${frame.name} with $weapon',
          );
        }
      }
    });

    test('weapon input affects ambient/elemental effect tints', () {
      for (final arena in arenaIds) {
        final tintsForWeapons = <String, Color>{};
        for (final weapon in weaponFamilies) {
          final tint = battleEffectTintFor(
            arenaId: arena,
            weaponFamily: weapon,
            effectFrame: BattleEffectFrame.fire,
          );
          tintsForWeapons[weapon] = tint;
        }
        final uniqueColors = tintsForWeapons.values.toSet();
        expect(
          uniqueColors.length,
          weaponFamilies.length,
          reason:
              'Weapon identity must affect elemental fire tint in arena $arena',
        );
      }
    });

    test(
      'case-insensitive arena and weapon names map to identical variants',
      () {
        final canonical = battleEffectVisualVariantFor(
          arenaId: 'kul',
          weaponFamily: 'shortSword',
          effectFrame: BattleEffectFrame.impact,
        );
        final lowercase = battleEffectVisualVariantFor(
          arenaId: 'KUL',
          weaponFamily: 'shortsword',
          effectFrame: BattleEffectFrame.impact,
        );
        expect(lowercase.tint, canonical.tint);
      },
    );
  });

  group('battle effect visual variant determinism', () {
    test('calling battleEffectVisualVariantFor repeatedly yields identical results across all combinations', () {
      for (final arena in arenaIds) {
        for (final weapon in weaponFamilies) {
          for (final frame in BattleEffectFrame.values) {
            final first = battleEffectVisualVariantFor(
              arenaId: arena,
              weaponFamily: weapon,
              effectFrame: frame,
            );
            final second = battleEffectVisualVariantFor(
              arenaId: arena,
              weaponFamily: weapon,
              effectFrame: frame,
            );
            final third = battleEffectVisualVariantFor(
              arenaId: arena,
              weaponFamily: weapon,
              frame: frame.index,
            );

            expect(first, equals(second));
            expect(first.tint, equals(second.tint));
            expect(first.tint, equals(third.tint));
            expect(first.hashCode, equals(second.hashCode));
          }
        }
      }
    });

    test('battleEffectTintFor matches battleEffectVisualVariantFor.tint identically', () {
      for (final arena in arenaIds) {
        for (final weapon in weaponFamilies) {
          final tint = battleEffectTintFor(
            arenaId: arena,
            weaponFamily: weapon,
            effectFrame: BattleEffectFrame.block,
          );
          final variant = battleEffectVisualVariantFor(
            arenaId: arena,
            weaponFamily: weapon,
            effectFrame: BattleEffectFrame.block,
          );
          expect(tint, variant.tint);
        }
      }
    });
  });

  group('unknown-value safe fallback', () {
    test('unknown arena id safely uses neutral arena defaults', () {
      final knownShortSword = battleEffectVisualVariantFor(
        arenaId: 'unknown_arena_id',
        weaponFamily: 'shortSword',
        effectFrame: BattleEffectFrame.impact,
      );
      final nullArenaShortSword = battleEffectVisualVariantFor(
        arenaId: null,
        weaponFamily: 'shortSword',
        effectFrame: BattleEffectFrame.impact,
      );

      expect(knownShortSword.tint, nullArenaShortSword.tint);
      expect(knownShortSword.tint, isNotNull);
    });

    test('unknown weapon family safely uses neutral weapon defaults', () {
      final knownArenaUnknownWeapon = battleEffectVisualVariantFor(
        arenaId: 'kor',
        weaponFamily: 'unrecognized_weapon_family',
        effectFrame: BattleEffectFrame.impact,
      );
      final knownArenaNullWeapon = battleEffectVisualVariantFor(
        arenaId: 'kor',
        weaponFamily: null,
        effectFrame: BattleEffectFrame.impact,
      );

      expect(knownArenaUnknownWeapon.tint, knownArenaNullWeapon.tint);
      expect(knownArenaUnknownWeapon.tint, isNotNull);
    });

    test(
      'both unknown arena and weapon safely yield neutral default variant',
      () {
        final unknownBoth = battleEffectVisualVariantFor(
          arenaId: 'totally_unknown',
          weaponFamily: 'also_unknown',
          effectFrame: BattleEffectFrame.impact,
        );
        final nullBoth = battleEffectVisualVariantFor(
          arenaId: null,
          weaponFamily: null,
          effectFrame: BattleEffectFrame.impact,
        );

        expect(unknownBoth.tint, nullBoth.tint);
        expect(unknownBoth.tint, isNotNull);
      },
    );

    test(
      'out-of-range frame indices safely resolve to impact frame without error',
      () {
        final negative = battleEffectVisualVariantFor(
          arenaId: 'firtina',
          weaponFamily: 'bow',
          frame: -99,
        );
        final overFlow = battleEffectVisualVariantFor(
          arenaId: 'firtina',
          weaponFamily: 'bow',
          frame: 999,
        );
        final baseImpact = battleEffectVisualVariantFor(
          arenaId: 'firtina',
          weaponFamily: 'bow',
          effectFrame: BattleEffectFrame.impact,
        );

        expect(negative.frame, BattleEffectFrame.impact);
        expect(negative.tint, baseImpact.tint);
        expect(overFlow.frame, BattleEffectFrame.impact);
        expect(overFlow.tint, baseImpact.tint);
      },
    );
  });

  group('painter tint propagation', () {
    test(
      'BattleEffectAtlasPainter stores and exposes tint and visual variant',
      () async {
        final image = await _createTestImage();
        const testTint = Color(0xFFE26D48);

        final painterWithTint = BattleEffectAtlasPainter(
          image,
          0,
          battleEffectsAtlasFrames,
          tint: testTint,
        );
        expect(painterWithTint.tint, testTint);
        expect(painterWithTint.effectiveTint, testTint);
        expect(painterWithTint.effectiveBlendMode, BlendMode.modulate);

        const variant = BattleEffectVisualVariant(
          tint: Color(0xFF63B4E6),
          blendMode: BlendMode.srcATop,
        );
        final painterWithVariant = BattleEffectAtlasPainter(
          image,
          0,
          battleEffectsAtlasFrames,
          visualVariant: variant,
        );
        expect(painterWithVariant.visualVariant, variant);
        expect(painterWithVariant.effectiveTint, variant.tint);
        expect(painterWithVariant.effectiveBlendMode, BlendMode.srcATop);

        image.dispose();
      },
    );

    test('BattleEffectAtlasPainter shouldRepaint responds to tint and frame changes', () async {
      final image = await _createTestImage();
      final p1 = BattleEffectAtlasPainter(
        image,
        0,
        battleEffectsAtlasFrames,
        tint: const Color(0xFF112233),
      );
      final pSame = BattleEffectAtlasPainter(
        image,
        0,
        battleEffectsAtlasFrames,
        tint: const Color(0xFF112233),
      );
      final pDifferentTint = BattleEffectAtlasPainter(
        image,
        0,
        battleEffectsAtlasFrames,
        tint: const Color(0xFF445566),
      );
      final pDifferentFrame = BattleEffectAtlasPainter(
        image,
        1,
        battleEffectsAtlasFrames,
        tint: const Color(0xFF112233),
      );

      expect(p1.shouldRepaint(pSame), isFalse);
      expect(p1.shouldRepaint(pDifferentTint), isTrue);
      expect(p1.shouldRepaint(pDifferentFrame), isTrue);

      image.dispose();
    });

    test(
      'BattleImpactEffect resolves an explicit tint to its visual variant',
      () {
        const explicitTint = Color(0xFF993322);
        const effect = BattleImpactEffect(
          sequence: 1,
          alignment: Alignment.center,
          reducedMotion: false,
          frame: 0,
          tint: explicitTint,
        );

        expect(effect.resolvedVariant?.tint, explicitTint);
        expect(effect.resolvedVariant?.frame, BattleEffectFrame.impact);
      },
    );

    test('BattleImpactEffect resolves arena and weapon tint inputs', () {
      const targetArena = 'kor';
      const targetWeapon = 'shortSword';
      const targetFrame = 0;
      const effect = BattleImpactEffect(
        sequence: 1,
        alignment: Alignment.center,
        reducedMotion: false,
        frame: targetFrame,
        arenaId: targetArena,
        weaponFamily: targetWeapon,
      );
      final expectedVariant = battleEffectVisualVariantFor(
        arenaId: targetArena,
        weaponFamily: targetWeapon,
        frame: targetFrame,
      );

      expect(effect.resolvedVariant, expectedVariant);
    });

    testWidgets(
      'BattleImpactEffect honors reduced motion and ignores pointer input',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: BattleImpactEffect(
                  sequence: 1,
                  alignment: Alignment.center,
                  reducedMotion: true,
                  arenaId: 'kul',
                  weaponFamily: 'bow',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final effectPointer = find.descendant(
          of: find.byType(BattleImpactEffect),
          matching: find.byType(IgnorePointer),
        );
        expect(effectPointer, findsNothing);

        // Now enable motion.
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: BattleImpactEffect(
                  sequence: 2,
                  alignment: Alignment.center,
                  reducedMotion: false,
                  arenaId: 'kul',
                  weaponFamily: 'bow',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(effectPointer, findsOneWidget);
      },
    );
  });
}
