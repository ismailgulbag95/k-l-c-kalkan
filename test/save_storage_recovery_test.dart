import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('writing after backup recovery preserves the valid backup', () async {
    const backup = GameSave(
      hasHero: true,
      heroName: 'Yedek Dövüşçü',
      level: 5,
      gold: 321,
    );
    SharedPreferences.setMockInitialValues({
      'ash_circuit.save.v1': '{not-json',
      'ash_circuit.save.backup.v1': backup.encode(),
    });

    final preferences = await SharedPreferences.getInstance();
    final storage = PreferencesSaveStorage(preferences: preferences);
    final recovered = await storage.read();
    expect(recovered?.heroName, backup.heroName);

    final updated = recovered!.copyWith(gold: 430);
    await storage.write(updated);

    expect(
      preferences.getString('ash_circuit.save.backup.v1'),
      backup.encode(),
    );
    expect((await storage.read())?.gold, 430);
  });
}
