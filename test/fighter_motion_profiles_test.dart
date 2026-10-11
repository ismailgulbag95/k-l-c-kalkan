import 'package:ash_circuit/game/ui/design.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const expected =
      <FighterMotion, (int durationMs, Curve curve, double amplitude)>{
        FighterMotion.idle: (0, Curves.linear, 1),
        FighterMotion.attack: (420, Curves.easeOutCubic, 1),
        FighterMotion.hit: (360, Curves.easeOutQuart, .9),
        FighterMotion.dodge: (460, Curves.easeOutCubic, 1.15),
        FighterMotion.guard: (300, Curves.easeOutSine, .75),
        FighterMotion.spell: (680, Curves.easeInOutCubic, 1.1),
        FighterMotion.status: (520, Curves.easeInOutSine, .8),
        FighterMotion.heal: (700, Curves.easeOutCubic, 1.05),
        FighterMotion.resource: (560, Curves.easeOutSine, .9),
        FighterMotion.move: (320, Curves.easeOutQuad, 1),
        FighterMotion.phase: (620, Curves.easeInOutCubic, 1.15),
        FighterMotion.victory: (760, Curves.easeOutBack, 1.1),
        FighterMotion.defeat: (900, Curves.easeInCubic, 1),
      };

  test('every fighter motion has a deterministic animation profile', () {
    expect(expected.keys.toSet(), FighterMotion.values.toSet());

    for (final entry in expected.entries) {
      final profile = fighterMotionProfileFor(entry.key);
      expect(profile.duration, Duration(milliseconds: entry.value.$1));
      expect(profile.curve, same(entry.value.$2));
      expect(profile.amplitude, entry.value.$3);
    }
  });

  test('idle profile keeps the current no-motion fallback safe', () {
    final profile = fighterMotionProfileFor(FighterMotion.idle);

    expect(profile.duration, Duration.zero);
    expect(profile.amplitude, 1);
  });
}
