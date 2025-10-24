import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:free_base/features/onboarding/services/secure_storage_service.dart';
import 'package:free_base/services/app_routes.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final cachedLogin = await _secureStorage.isLoggedIn;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (firebaseUser != null && cachedLogin) {
      context.goNamed(AppRouteNames.dashboard);
    } else {
      context.goNamed(AppRouteNames.login);
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
