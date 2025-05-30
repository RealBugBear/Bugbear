import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bugbear_app/features/onboarding/services/secure_storage_service.dart';

/// SplashScreen: Prüft verschlüsselten Login-Status + Firebase-Auth
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Optionales kurzes Branding-Delay
    await Future.delayed(const Duration(milliseconds: 500));

    final loggedIn = await _secureStorage.isLoggedIn;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (loggedIn && firebaseUser != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
