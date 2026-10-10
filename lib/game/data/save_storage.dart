import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

abstract interface class SaveStorage {
  Future<GameSave?> read();
  Future<void> write(GameSave save);
  Future<void> clear();
}

class PreferencesSaveStorage implements SaveStorage {
  PreferencesSaveStorage({SharedPreferences? this._preferences});

  static const _key = 'ash_circuit.save.v1';
  static const _backupKey = 'ash_circuit.save.backup.v1';
  final SharedPreferences? _preferences;
  Future<SharedPreferences> get _prefs async =>
      _preferences ?? SharedPreferences.getInstance();

  @override
  Future<GameSave?> read() async {
    final prefs = await _prefs;
    for (final key in [_key, _backupKey]) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return GameSave.fromJson(decoded);
      } on Object {
        continue;
      }
    }
    return null;
  }

  @override
  Future<void> write(GameSave save) async {
    final prefs = await _prefs;
    final current = prefs.getString(_key);
    if (current != null && _isValidSave(current)) {
      await prefs.setString(_backupKey, current);
    }
    await prefs.setString(_key, save.encode());
  }

  bool _isValidSave(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return false;
      GameSave.fromJson(decoded);
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
    await prefs.remove(_backupKey);
  }
}

class MemorySaveStorage implements SaveStorage {
  GameSave? value;
  bool corruptPrimary = false;
  GameSave? backup;

  @override
  Future<GameSave?> read() async => corruptPrimary ? backup : value;

  @override
  Future<void> write(GameSave save) async {
    backup = value;
    value = save;
    corruptPrimary = false;
  }

  @override
  Future<void> clear() async {
    value = null;
    backup = null;
  }
}
