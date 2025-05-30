import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'secure_storage_service.dart';

/// AuthService kümmert sich um Anmeldung/Registrierung
/// und sichert den Login-Status verschlüsselt.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Stream der Authentifizierungszustände
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Anmeldung mit E-Mail und Passwort
  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Login-Flag setzen
    await _secureStorage.setLoggedIn(true);
    return cred;
  }

  /// Registrierung mit E-Mail, Passwort und optionalem Nickname.
  /// Speichert in Firestore nur die nötigen PII.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? nickname,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    final data = <String, dynamic>{
      'email': user.email,
      if (nickname != null) 'nickname': nickname,
    };
    await _db.collection('users').doc(user.uid).set(data);
    // Login-Flag setzen
    await _secureStorage.setLoggedIn(true);
    return cred;
  }

  /// Abmelden und gespeicherten Login-Status löschen
  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.clear();
  }
}
