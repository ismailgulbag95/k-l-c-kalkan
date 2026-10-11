import 'package:ash_circuit/game/ui/design.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('game theme uses the bundled Noto Sans variable font', (
    tester,
  ) async {
    final font = await rootBundle.load('assets/fonts/NotoSans-Variable.ttf');

    expect(font.lengthInBytes, greaterThan(100000));
    expect(buildGameTheme().textTheme.bodyMedium?.fontFamily, 'Noto Sans');
  });
}
