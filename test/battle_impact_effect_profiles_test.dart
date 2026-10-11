import 'package:ash_circuit/game/ui/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('battle impact effect motion profiles', () {
    const profiles =
        <
          ({
            BattleEffectFrame frame,
            int atlasIndex,
            int durationMs,
            Curve curve,
            double startScale,
            double endScale,
            double peakOpacity,
          })
        >[
          (
            frame: BattleEffectFrame.impact,
            atlasIndex: 0,
            durationMs: 360,
            curve: Curves.easeOutCubic,
            startScale: .72,
            endScale: 1.25,
            peakOpacity: .96,
          ),
          (
            frame: BattleEffectFrame.dust,
            atlasIndex: 1,
            durationMs: 620,
            curve: Curves.easeOutQuad,
            startScale: .56,
            endScale: 1.18,
            peakOpacity: .58,
          ),
          (
            frame: BattleEffectFrame.block,
            atlasIndex: 2,
            durationMs: 300,
            curve: Curves.easeOutCubic,
            startScale: .82,
            endScale: .96,
            peakOpacity: .88,
          ),
          (
            frame: BattleEffectFrame.arrow,
            atlasIndex: 3,
            durationMs: 360,
            curve: Curves.easeOutQuart,
            startScale: .94,
            endScale: 1.08,
            peakOpacity: .9,
          ),
          (
            frame: BattleEffectFrame.healing,
            atlasIndex: 4,
            durationMs: 680,
            curve: Curves.easeInOutSine,
            startScale: .72,
            endScale: 1.12,
            peakOpacity: .78,
          ),
          (
            frame: BattleEffectFrame.wind,
            atlasIndex: 5,
            durationMs: 560,
            curve: Curves.easeOutSine,
            startScale: .68,
            endScale: 1.18,
            peakOpacity: .82,
          ),
          (
            frame: BattleEffectFrame.fire,
            atlasIndex: 6,
            durationMs: 500,
            curve: Curves.easeOutCubic,
            startScale: .78,
            endScale: 1.1,
            peakOpacity: 1,
          ),
          (
            frame: BattleEffectFrame.tide,
            atlasIndex: 7,
            durationMs: 720,
            curve: Curves.easeInOutCubic,
            startScale: .62,
            endScale: 1.14,
            peakOpacity: .8,
          ),
        ];

    for (final row in profiles) {
      test('${row.frame.name} uses its typed atlas motion profile', () {
        final typedProfile = battleEffectMotionProfileFor(row.frame);
        final indexedProfile = battleEffectMotionProfileForAtlasIndex(
          row.atlasIndex,
        );

        for (final profile in [typedProfile, indexedProfile]) {
          expect(profile.duration, Duration(milliseconds: row.durationMs));
          expect(profile.curve, same(row.curve));
          expect(profile.startScale, row.startScale);
          expect(profile.endScale, row.endScale);
          expect(profile.peakOpacity, row.peakOpacity);
          expect(
            profile.scaleAt(.5),
            closeTo(
              row.startScale +
                  (row.endScale - row.startScale) * row.curve.transform(.5),
              1e-9,
            ),
          );
          expect(profile.opacityAt(0), 0);
          expect(profile.opacityAt(.5), closeTo(row.peakOpacity, 1e-9));
          expect(profile.opacityAt(1), 0);
        }
      });
    }

    test('unknown atlas indices fall back to the impact profile', () {
      final impact = battleEffectMotionProfileFor(BattleEffectFrame.impact);

      for (final index in [-1, BattleEffectFrame.values.length, 999]) {
        final profile = battleEffectMotionProfileForAtlasIndex(index);
        expect(profile.duration, impact.duration);
        expect(profile.curve, same(impact.curve));
        expect(profile.startScale, impact.startScale);
        expect(profile.endScale, impact.endScale);
        expect(profile.peakOpacity, impact.peakOpacity);
      }
    });

    test('progress is clamped at its endpoints', () {
      final profile = battleEffectMotionProfileFor(BattleEffectFrame.tide);

      expect(profile.scaleAt(-1), profile.startScale);
      expect(profile.scaleAt(2), profile.endScale);
      expect(profile.opacityAt(-1), 0);
      expect(profile.opacityAt(2), 0);
    });
  });
}
