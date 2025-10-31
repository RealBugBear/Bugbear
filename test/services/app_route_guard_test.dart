import 'dart:io';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:free_base/features/onboarding/models/consent_state.dart';
import 'package:free_base/features/onboarding/state/consent_notifier.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/services/app_route_guard.dart';
import 'package:free_base/services/app_routes.dart';

void main() {
  late Directory tempDir;
  late Box<ConsentState> consentBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('guard_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(ConsentState.hiveTypeId)) {
      Hive.registerAdapter(ConsentStateAdapter());
    }
    consentBox = await Hive.openBox<ConsentState>('consent_box');
  });

  tearDown(() async {
    await consentBox.clear();
  });

  tearDownAll(() async {
    await consentBox.close();
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<ConsentNotifier> createNotifier({bool accepted = false}) async {
    final notifier = ConsentNotifier(consentBox, defaultLocale: 'de');
    if (accepted) {
      await notifier.accept(locale: 'de');
    }
    return notifier;
  }

  SessionState buildSessionState({bool onboardingComplete = false}) {
    final plannedFor = DateTime.now().add(const Duration(days: 1));
    return SessionState(
      phaseId: 'phase',
      exerciseIndex: 0,
      completedReps: 0,
      remainingSeconds: 8,
      startedAt: plannedFor,
      plannedFor: plannedFor,
      status: SessionStatus.planned,
      onboardingComplete: onboardingComplete,
    );
  }

  group('AppRouteGuard', () {
    test('redirects anonymous users to login for protected routes', () async {
      final consentNotifier = await createNotifier();
      final auth = MockFirebaseAuth();
      final guard = AppRouteGuard(
        auth: auth,
        consentNotifier: consentNotifier,
        loadSessionState: () async => null,
        consentRequired: true,
        userDataLoader: (_) async => const <String, dynamic>{},
      );

      final redirect = await guard.evaluateLocation(AppRoutePaths.dashboard);
      expect(redirect, AppRoutePaths.login);

      consentNotifier.dispose();
    });

    test('redirects to consent screen when consent is missing', () async {
      final consentNotifier = await createNotifier();
      final auth = MockFirebaseAuth(mockUser: MockUser(uid: 'u1'), signedIn: true);
      final guard = AppRouteGuard(
        auth: auth,
        consentNotifier: consentNotifier,
        loadSessionState: () async => buildSessionState(onboardingComplete: false),
        consentRequired: true,
        userDataLoader: (_) async => const <String, dynamic>{'role': 'member'},
      );

      final redirect = await guard.evaluateLocation(AppRoutePaths.dashboard);
      expect(redirect, AppRoutePaths.consent);

      consentNotifier.dispose();
    });

    test('redirects to training when onboarding is not complete', () async {
      final consentNotifier = await createNotifier(accepted: true);
      final auth = MockFirebaseAuth(mockUser: MockUser(uid: 'u2'), signedIn: true);
      final guard = AppRouteGuard(
        auth: auth,
        consentNotifier: consentNotifier,
        loadSessionState: () async => buildSessionState(onboardingComplete: false),
        consentRequired: true,
        userDataLoader: (_) async => const <String, dynamic>{
          'role': 'member',
          'firstSessionCompleted': false,
        },
      );

      final redirect = await guard.evaluateLocation(AppRoutePaths.dashboard);
      expect(redirect, AppRoutePaths.training);

      consentNotifier.dispose();
    });

    test('allows profile routes when onboarding is not complete', () async {
      final consentNotifier = await createNotifier(accepted: true);
      final auth = MockFirebaseAuth(mockUser: MockUser(uid: 'u2'), signedIn: true);
      final guard = AppRouteGuard(
        auth: auth,
        consentNotifier: consentNotifier,
        loadSessionState: () async => buildSessionState(onboardingComplete: false),
        consentRequired: true,
        userDataLoader: (_) async => const <String, dynamic>{
          'role': 'member',
          'firstSessionCompleted': false,
        },
      );

      final profileRedirect = await guard.evaluateLocation(AppRoutePaths.profile);
      expect(profileRedirect, isNull);

      final profileShopRedirect =
          await guard.evaluateLocation(AppRoutePaths.profileShop);
      expect(profileShopRedirect, isNull);

      final settingsRedirect = await guard.evaluateLocation(AppRoutePaths.settings);
      expect(settingsRedirect, AppRoutePaths.training);

      consentNotifier.dispose();
    });

    test('allows dashboard when consent and onboarding are complete', () async {
      final consentNotifier = await createNotifier(accepted: true);
      final auth = MockFirebaseAuth(mockUser: MockUser(uid: 'u3'), signedIn: true);
      final guard = AppRouteGuard(
        auth: auth,
        consentNotifier: consentNotifier,
        loadSessionState: () async => buildSessionState(onboardingComplete: true),
        consentRequired: true,
        userDataLoader: (_) async => const <String, dynamic>{
          'role': 'member',
          'firstSessionCompleted': true,
        },
      );

      final redirect = await guard.evaluateLocation(AppRoutePaths.dashboard);
      expect(redirect, isNull);

      final consentRedirect = await guard.evaluateLocation(AppRoutePaths.consent);
      expect(consentRedirect, AppRoutePaths.dashboard);

      consentNotifier.dispose();
    });
  });
}
