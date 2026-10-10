import 'dart:ui' as ui;

import 'package:ash_circuit/game/data/intermission_decisions.dart';
import 'package:ash_circuit/game/data/story_evidence.dart';
import 'package:ash_circuit/game/ui/design.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all intermission decisions have unique, decodable bundled art',
    () async {
      expect(intermissionDecisions, hasLength(4));
      expect(
        intermissionDecisions.map((decision) => decision.id).toSet(),
        hasLength(4),
      );
      expect(
        intermissionDecisions.map((decision) => decision.art).toSet(),
        hasLength(4),
      );

      for (final decision in intermissionDecisions) {
        final asset = await rootBundle.load(decision.art);
        final codec = await ui.instantiateImageCodec(
          asset.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0), reason: decision.art);
        expect(frame.image.height, greaterThan(0), reason: decision.art);
        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  test(
    'story evidence entries map to the four cells in a bundled atlas',
    () async {
      expect(storyEvidenceEntries, hasLength(4));
      expect(
        storyEvidenceEntries.map((entry) => entry.id).toSet(),
        hasLength(4),
      );
      expect(storyEvidenceEntries.map((entry) => entry.frame).toSet(), {
        0,
        1,
        2,
        3,
      });

      final asset = await rootBundle.load(storyEvidenceAtlasAsset);
      final codec = await ui.instantiateImageCodec(asset.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1254);
      expect(frame.image.height, 1254);
      frame.image.dispose();
      codec.dispose();
    },
  );
}
