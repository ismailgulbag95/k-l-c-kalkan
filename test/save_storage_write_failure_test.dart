import 'package:ash_circuit/game/data/save_storage.dart';
import 'package:ash_circuit/game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _primaryKey = 'ash_circuit.save.v1';
const _backupKey = 'ash_circuit.save.backup.v1';

class _ControlledPreferencesStore extends InMemorySharedPreferencesStore {
  _ControlledPreferencesStore(
    Map<String, Object> initialData, {
    this.rejectedKeySuffix,
    this.thrownKeySuffix,
    this.writeException,
  }) : super.withData(initialData);

  final String? rejectedKeySuffix;
  final String? thrownKeySuffix;
  final Object? writeException;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (thrownKeySuffix != null &&
        key.endsWith(thrownKeySuffix!) &&
        writeException != null) {
      throw writeException!;
    }
    if (rejectedKeySuffix != null && key.endsWith(rejectedKeySuffix!)) {
      return false;
    }
    return super.setValue(valueType, key, value);
  }
}

class _Fixture {
  const _Fixture({required this.preferences, required this.storage});

  final SharedPreferences preferences;
  final PreferencesSaveStorage storage;
}

Future<_Fixture> _createFixture({
  Map<String, Object> initialValues = const {},
  String? rejectedKeySuffix,
  String? thrownKeySuffix,
  Object? writeException,
}) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final seededStore = SharedPreferencesStorePlatform.instance;
  final store = _ControlledPreferencesStore(
    await seededStore.getAll(),
    rejectedKeySuffix: rejectedKeySuffix,
    thrownKeySuffix: thrownKeySuffix,
    writeException: writeException,
  );
  SharedPreferencesStorePlatform.instance = store;
  final preferences = await SharedPreferences.getInstance();
  return _Fixture(
    preferences: preferences,
    storage: PreferencesSaveStorage(preferences: preferences),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'backup rejection leaves existing primary and backup recoverable',
    () async {
      const current = GameSave(hasHero: true, heroName: 'Mevcut', gold: 120);
      const oldBackup = GameSave(hasHero: true, heroName: 'Önceki', gold: 80);
      const next = GameSave(hasHero: true, heroName: 'Yeni', gold: 200);
      final fixture = await _createFixture(
        initialValues: {
          _primaryKey: current.encode(),
          _backupKey: oldBackup.encode(),
        },
        rejectedKeySuffix: _backupKey,
      );

      await expectLater(
        fixture.storage.write(next),
        throwsA(isA<StateError>()),
      );

      expect(fixture.preferences.getString(_primaryKey), current.encode());
      expect(fixture.preferences.getString(_backupKey), oldBackup.encode());
      expect((await fixture.storage.read())?.heroName, current.heroName);
    },
  );

  test('primary rejection keeps the previous primary recoverable', () async {
    const current = GameSave(hasHero: true, heroName: 'Mevcut', gold: 120);
    const oldBackup = GameSave(hasHero: true, heroName: 'Önceki', gold: 80);
    const next = GameSave(hasHero: true, heroName: 'Yeni', gold: 200);
    final fixture = await _createFixture(
      initialValues: {
        _primaryKey: current.encode(),
        _backupKey: oldBackup.encode(),
      },
      rejectedKeySuffix: _primaryKey,
    );

    await expectLater(fixture.storage.write(next), throwsA(isA<StateError>()));

    expect(fixture.preferences.getString(_primaryKey), current.encode());
    expect(fixture.preferences.getString(_backupKey), oldBackup.encode());
    expect((await fixture.storage.read())?.heroName, current.heroName);
  });

  test(
    'backup exception reloads cache and rethrows the original exception',
    () async {
      const current = GameSave(hasHero: true, heroName: 'Mevcut', gold: 120);
      const oldBackup = GameSave(hasHero: true, heroName: 'Önceki', gold: 80);
      const next = GameSave(hasHero: true, heroName: 'Yeni', gold: 200);
      final failure = Exception('backup platform failure');
      final fixture = await _createFixture(
        initialValues: {
          _primaryKey: current.encode(),
          _backupKey: oldBackup.encode(),
        },
        thrownKeySuffix: _backupKey,
        writeException: failure,
      );

      await expectLater(fixture.storage.write(next), throwsA(same(failure)));

      expect(fixture.preferences.getString(_primaryKey), current.encode());
      expect(fixture.preferences.getString(_backupKey), oldBackup.encode());
      expect((await fixture.storage.read())?.heroName, current.heroName);
    },
  );

  test(
    'primary exception restores backup, reloads cache, and rethrows original',
    () async {
      const current = GameSave(hasHero: true, heroName: 'Mevcut', gold: 120);
      const oldBackup = GameSave(hasHero: true, heroName: 'Önceki', gold: 80);
      const next = GameSave(hasHero: true, heroName: 'Yeni', gold: 200);
      final failure = Exception('primary platform failure');
      final fixture = await _createFixture(
        initialValues: {
          _primaryKey: current.encode(),
          _backupKey: oldBackup.encode(),
        },
        thrownKeySuffix: _primaryKey,
        writeException: failure,
      );

      await expectLater(fixture.storage.write(next), throwsA(same(failure)));

      expect(fixture.preferences.getString(_primaryKey), current.encode());
      expect(fixture.preferences.getString(_backupKey), oldBackup.encode());
      expect((await fixture.storage.read())?.heroName, current.heroName);
    },
  );

  test(
    'initial primary rejection is reported and does not create a save',
    () async {
      const next = GameSave(hasHero: true, heroName: 'Yeni', gold: 200);
      final fixture = await _createFixture(rejectedKeySuffix: _primaryKey);

      await expectLater(
        fixture.storage.write(next),
        throwsA(isA<StateError>()),
      );

      expect(fixture.preferences.getString(_primaryKey), isNull);
      expect(fixture.preferences.getString(_backupKey), isNull);
      expect(await fixture.storage.read(), isNull);
    },
  );

  test('successful write stores the previous primary as backup', () async {
    const current = GameSave(hasHero: true, heroName: 'Mevcut', gold: 120);
    const next = GameSave(hasHero: true, heroName: 'Yeni', gold: 200);
    final fixture = await _createFixture(
      initialValues: {_primaryKey: current.encode()},
    );

    await fixture.storage.write(next);

    expect(fixture.preferences.getString(_backupKey), current.encode());
    expect(fixture.preferences.getString(_primaryKey), next.encode());
    expect((await fixture.storage.read())?.heroName, next.heroName);
  });

  test(
    'failed write after backup recovery preserves the recoverable backup',
    () async {
      const backup = GameSave(hasHero: true, heroName: 'Yedek', gold: 90);
      const next = GameSave(hasHero: true, heroName: 'Yeni', gold: 200);
      final fixture = await _createFixture(
        initialValues: {_primaryKey: '{not-json', _backupKey: backup.encode()},
        rejectedKeySuffix: _primaryKey,
      );

      await expectLater(
        fixture.storage.write(next),
        throwsA(isA<StateError>()),
      );

      expect(fixture.preferences.getString(_primaryKey), '{not-json');
      expect(fixture.preferences.getString(_backupKey), backup.encode());
      expect((await fixture.storage.read())?.heroName, backup.heroName);
    },
  );
}
