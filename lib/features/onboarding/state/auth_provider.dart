// File: lib/state/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AppAuthProvider verwaltet den Firebase-User und Login-Status global.
class AppAuthProvider extends ChangeNotifier {
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
User? _user;

AppAuthProvider() {
_firebaseAuth.authStateChanges().listen((user) {
_user = user;
notifyListeners();
});
}

/// Aktueller User (null, wenn nicht eingeloggt)
User? get user => _user;

/// True, wenn ein User angemeldet ist
bool get isLoggedIn => _user != null;

/// Logout
Future signOut() async => _firebaseAuth.signOut();
}