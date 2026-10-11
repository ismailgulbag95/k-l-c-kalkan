import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

abstract interface class SaveStorage {
  Future<GameSave?> read();
  Future<void> write(GameSave save);
  Future<void> clear();
}

class PreferencesSaveStorage implements SaveStorage {
  PreferencesSaveStorage({this._preferences});

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
    final previousBackup = prefs.getString(_backupKey);
    var backupUpdated = false;
    if (current != null && _isValidSave(current)) {
      bool backupWritten;
      try {
        backupWritten = await prefs.setString(_backupKey, current);
      } on Object {
        await _reloadAfterFailedWrite(prefs);
        rethrow;
      }
      if (!backupWritten) {
        await _reloadAfterFailedWrite(prefs);
        throw StateError('Failed to write save backup.');
      }
      backupUpdated = true;
    }
    bool primaryWritten;
    try {
      primaryWritten = await prefs.setString(_key, save.encode());
    } on Object {
      await _restoreBackupAfterFailedWrite(prefs, previousBackup);
      await _reloadAfterFailedWrite(prefs);
      rethrow;
    }
    if (!primaryWritten) {
      var backupRestored = true;
      if (backupUpdated) {
        backupRestored = await _restoreBackupAfterFailedWrite(
          prefs,
          previousBackup,
        );
      }
      await _reloadAfterFailedWrite(prefs);
      throw StateError(
        backupRestored
            ? 'Failed to write save.'
            : 'Failed to write save and restore save backup.',
      );
    }
  }

  Future<bool> _restoreBackupAfterFailedWrite(
    SharedPreferences prefs,
    String? previousBackup,
  ) async {
    try {
      if (previousBackup == null) {
        return await prefs.remove(_backupKey);
      }
      return await prefs.setString(_backupKey, previousBackup);
    } on Object {
      // The primary write failure remains the error reported to the caller.
      return false;
    }
  }

  Future<void> _reloadAfterFailedWrite(SharedPreferences prefs) async {
    // SharedPreferences updates its in-process cache before the platform write
    // completes, so discard a failed write's value before exposing its error.
    try {
      await prefs.reload();
    } on Object {
      // Preserve the storage write failure as the reported error.
    }
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
    final previousPrimary = prefs.getString(_key);
    final previousBackup = prefs.getString(_backupKey);

    bool backupRemoved;
    try {
      backupRemoved = await prefs.remove(_backupKey);
    } on Object {
      await _restoreBackupAfterFailedWrite(prefs, previousBackup);
      await _reloadAfterFailedWrite(prefs);
      rethrow;
    }
    if (!backupRemoved) {
      final backupRestored = await _restoreBackupAfterFailedWrite(
        prefs,
        previousBackup,
      );
      await _reloadAfterFailedWrite(prefs);
      throw StateError(
        backupRestored
            ? 'Failed to clear save backup.'
            : 'Failed to clear and restore save backup.',
      );
    }

    bool primaryRemoved;
    try {
      primaryRemoved = await prefs.remove(_key);
    } on Object {
      await _restoreBackupAfterFailedWrite(
        prefs,
        previousPrimary ?? previousBackup,
      );
      await _reloadAfterFailedWrite(prefs);
      rethrow;
    }
    if (!primaryRemoved) {
      final recoveryValue = previousPrimary ?? previousBackup;
      final backupRestored = recoveryValue == null
          ? true
          : await _restoreBackupAfterFailedWrite(prefs, recoveryValue);
      await _reloadAfterFailedWrite(prefs);
      throw StateError(
        backupRestored
            ? 'Failed to clear save.'
            : 'Failed to clear save and restore save backup.',
      );
    }
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
