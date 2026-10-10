import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all runtime audio assets are bundled and structurally valid', () async {
    final paths = <String>{
      for (final name in [
        'menu_theme',
        'chapter_1',
        'chapter_2',
        'chapter_3',
        'chapter_4',
        'champion_1',
        'champion_2',
        'champion_3',
        'champion_4',
        'champions_road',
      ])
        'assets/audio/music/$name.mp3',
      for (var chapter = 1; chapter <= 4; chapter++)
        'assets/audio/stingers/intermission_$chapter.mp3',
      for (final name in [
        'harbor',
        'forge',
        'observatory',
        'tide',
        'fortress',
        'crown_ring',
      ])
        'assets/audio/ambience/$name.wav',
      for (final name in [
        'ui_confirm',
        'ui_back',
        'battle_start',
        'attack_quick',
        'attack_heavy',
        'arrow',
        'spell',
        'block',
        'hit',
        'miss',
        'status',
        'hazard',
        'heal',
        'victory',
        'defeat',
        'reward',
        'level_up',
        'contract',
      ])
        'assets/audio/sfx/$name.wav',
    };

    expect(paths, hasLength(38));
    for (final path in paths) {
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      expect(bytes.length, greaterThan(1024), reason: path);
      if (path.endsWith('.wav')) {
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF', reason: path);
        expect(
          String.fromCharCodes(bytes.sublist(8, 12)),
          'WAVE',
          reason: path,
        );
      } else {
        expect(String.fromCharCodes(bytes.sublist(0, 3)), 'ID3', reason: path);
      }
    }
  });
}
