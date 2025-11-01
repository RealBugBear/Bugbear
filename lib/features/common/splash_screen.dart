import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/common/dashboard_route_args.dart';
import 'package:free_base/features/onboarding/services/secure_storage_service.dart';
import 'package:free_base/features/onboarding/state/consent_notifier.dart';
import 'package:free_base/features/training/services/session_repository.dart';
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
      final consentNotifier = context.read<ConsentNotifier>();
      if (!consentNotifier.hasAccepted) {
        context.goNamed(AppRouteNames.consent);
        return;
      }

      final sessionRepository = context.read<SessionRepository>();
      final sessionState = await sessionRepository.load();
      if (!mounted) return;

      final onboardingComplete = sessionState?.onboardingComplete ?? false;
      if (!onboardingComplete) {
        context.goNamed(
          AppRouteNames.dashboard,
          extra: const DashboardRouteArgs(),
        );
        return;
      }

      context.goNamed(
        AppRouteNames.dashboard,
        extra: const DashboardRouteArgs(),
      );
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
