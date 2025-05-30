import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sicherer Speicher für Login-Status (DSGVO-konform)
class SecureStorageService {
  static const _keyLoggedIn = 'logged_in';
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
}
