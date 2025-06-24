import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Sicherer Speicher für Login-Status (DSGVO-konform)
class SecureStorageService {
  static const _keyLoggedIn = 'logged_in';
  static const _keyEncryption = 'encryption_key';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Speichert, ob der User eingeloggt ist
  Future<void> setLoggedIn(bool value) async {
    await _storage.write(key: _keyLoggedIn, value: value.toString());
  }

  /// Liest den Login-Status
  Future<bool> get isLoggedIn async {
    final val = await _storage.read(key: _keyLoggedIn);
    return val == 'true';
  }

  /// Entfernt den gespeicherten Login-Status (bei Logout)
  Future<void> clear() async {
    await _storage.delete(key: _keyLoggedIn);
  }

  /// Persists the given Hive encryption key.
  Future<void> writeEncryptionKey(List<int> key) async {
    await _storage.write(
      key: _keyEncryption,
      value: base64UrlEncode(key),
    );
  }

  /// Reads the stored Hive encryption key if available.
  Future<List<int>?> readEncryptionKey() async {
    final stored = await _storage.read(key: _keyEncryption);
    return stored != null ? base64Url.decode(stored) : null;
  }

  /// Returns the persisted Hive encryption key or generates a new one if absent.
  /// The key is kept in [FlutterSecureStorage] so it can be reused on subsequent
  /// launches of the app.
  Future<List<int>> getEncryptionKey() async {
    final existing = await readEncryptionKey();
    if (existing != null) return existing;

    final key = Hive.generateSecureKey();
    await writeEncryptionKey(key);
    return key;
  }
}
