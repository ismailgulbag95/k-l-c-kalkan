import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/game_controller.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _primaryKey = 'ash_circuit.save.v1';
const _backupKey = 'ash_circuit.save.backup.v1';
const _platformPrimaryKey = 'flutter.$_primaryKey';
const _platformBackupKey = 'flutter.$_backupKey';

class _ClearControlledStore extends InMemorySharedPreferencesStore {
  _ClearControlledStore(super.data) : super.withData();

  bool rejectPrimaryRemovalOnce = false;
  bool rejectBackupRemovalOnce = false;

  @override
  Future<bool> remove(String key) async {
    if (key == _platformPrimaryKey && rejectPrimaryRemovalOnce) {
      rejectPrimaryRemovalOnce = false;
      return false;
    }
    if (key == _platformBackupKey && rejectBackupRemovalOnce) {
      rejectBackupRemovalOnce = false;
      return false;
    }
    return super.remove(key);
  }
}

class _Fixture {
  const _Fixture({
    required this.preferences,
    required this.storage,
    required this.store,
  });

  final SharedPreferences preferences;
  final PreferencesSaveStorage storage;
  final _ClearControlledStore store;
}

Future<_Fixture> _createFixture(GameSave primary, GameSave backup) async {
  SharedPreferences.setMockInitialValues({
    _primaryKey: primary.encode(),
    _backupKey: backup.encode(),
  });
  final seed = SharedPreferencesStorePlatform.instance;
  final store = _ClearControlledStore(await seed.getAll());
  SharedPreferencesStorePlatform.instance = store;
  final preferences = await SharedPreferences.getInstance();
  return _Fixture(
    preferences: preferences,
    storage: PreferencesSaveStorage(preferences: preferences),
    store: store,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a false backup removal fails and can be retried', () async {
    const current = GameSave(hasHero: true, heroName: 'Mevcut', gold: 120);
    const backup = GameSave(hasHero: true, heroName: 'Yedek', gold: 80);
    final fixture = await _createFixture(current, backup);
    fixture.store.rejectBackupRemovalOnce = true;

    await expectLater(fixture.storage.clear(), throwsA(isA<StateError>()));
    expect(fixture.preferences.getString(_primaryKey), current.encode());
    expect(fixture.preferences.getString(_backupKey), backup.encode());
    expect((await fixture.storage.read())?.heroName, current.heroName);

    await fixture.storage.clear();
    expect(await fixture.storage.read(), isNull);
  });

  test('reset stays uncommitted after a false primary removal, then retry clears it', () async {
    const current = GameSave(
      hasHero: true,
      heroName: 'Kül Muhafızı',
      gold: 900,
      completedMatches: {'M01'},
    );
    const backup = GameSave(hasHero: true, heroName: 'Önceki', gold: 700);
    final fixture = await _createFixture(current, backup);
    final controller = GameController(storage: fixture.storage);
    await controller.initialize();
    fixture.store.rejectPrimaryRemovalOnce = true;

    await expectLater(controller.resetCampaign(), throwsA(isA<StateError>()));
    expect(controller.save.toJson(), current.toJson());
    expect((await fixture.storage.read())?.toJson(), current.toJson());

    await controller.resetCampaign();
    expect(controller.save.toJson(), const GameSave().toJson());
    expect(await fixture.storage.read(), isNull);

    controller.dispose();
  });
}
