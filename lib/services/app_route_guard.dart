import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:free_base/features/onboarding/state/consent_notifier.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/services/app_routes.dart';

class AppRouteGuard {
  AppRouteGuard({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required ConsentNotifier consentNotifier,
    required Future<SessionState?> Function() loadSessionState,
    bool consentRequired = true,
    Future<Map<String, dynamic>> Function(String uid)? userDataLoader,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _consentNotifier = consentNotifier,
        _loadSessionState = loadSessionState,
        _consentRequired = consentRequired,
        _userDataLoader = userDataLoader ??
            ((uid) async {
              final doc = (firestore ?? FirebaseFirestore.instance)
                  .collection('users')
                  .doc(uid);
              final snapshot = await doc.get();
              return snapshot.data() ?? const <String, dynamic>{};
            });

  final FirebaseAuth _auth;
  final ConsentNotifier _consentNotifier;
  final Future<SessionState?> Function() _loadSessionState;
  final bool _consentRequired;
  final Future<Map<String, dynamic>> Function(String uid) _userDataLoader;
  Map<String, dynamic>? _cachedUserData;
  bool _isFetching = false;

  static const _publicRoutes = <String>{
    AppRoutePaths.splash,
    AppRoutePaths.login,
    AppRoutePaths.register,
    AppRoutePaths.consent,
  };

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    return _resolveRedirect(state.matchedLocation);
  }

  @visibleForTesting
  Future<String?> evaluateLocation(String location) {
    return _resolveRedirect(location);
  }

  Future<String?> _resolveRedirect(String location) async {
    final user = _auth.currentUser;

    if (user == null) {
      if (_isPublic(location)) {
        return null;
      }
      return AppRoutePaths.login;
    }

    if (_consentRequired) {
      final hasConsent = _consentNotifier.hasAccepted;
      if (!hasConsent && location != AppRoutePaths.consent) {
        return AppRoutePaths.consent;
      }
      if (hasConsent && location == AppRoutePaths.consent) {
        return AppRoutePaths.dashboard;
      }
    }

    final data = await _loadUserData(user.uid);
    final role = (data['role'] as String?)?.trim();
    final firstSessionCompleted = (data['firstSessionCompleted'] as bool?) ?? false;
    final localSession = await _loadSessionState();
    final onboardingComplete =
        (localSession?.onboardingComplete ?? false) || firstSessionCompleted;

    if ((role == null || role.isEmpty) && location != AppRoutePaths.roleSelection) {
      return AppRoutePaths.roleSelection;
    }

    if (_requiresOnboardingComplete(location) && !onboardingComplete) {
      if (location != AppRoutePaths.training) {
        return AppRoutePaths.training;
      }
    }

    if (location == AppRoutePaths.roleSelection && role != null && role.isNotEmpty) {
      return AppRoutePaths.dashboard;
    }

    return null;
  }

  bool _isPublic(String location) {
    return _publicRoutes.contains(location);
  }

  bool _requiresOnboardingComplete(String location) {
    if (location == AppRoutePaths.training ||
        location == AppRoutePaths.trainingCompleted ||
        location == AppRoutePaths.dashboard ||
        location == AppRoutePaths.consent ||
        location == AppRoutePaths.profile ||
        location.startsWith('${AppRoutePaths.profile}/') ||
        location.startsWith(AppRoutePaths.questionnaireIntro) ||
        location.startsWith(AppRoutePaths.questionnaire)) {
      return false;
    }
    if (location.startsWith(AppRoutePaths.training)) {
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> _loadUserData(String uid) async {
    if (_cachedUserData != null) {
      return _cachedUserData!;
    }
    if (_isFetching) {
      while (_isFetching) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return _cachedUserData ?? const <String, dynamic>{};
    }

    try {
      _isFetching = true;
      _cachedUserData = await _userDataLoader(uid);
    } finally {
      _isFetching = false;
    }
    return _cachedUserData!;
  }

  void reset() {
    _cachedUserData = null;
  }
}
