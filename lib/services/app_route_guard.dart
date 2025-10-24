import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:free_base/services/app_routes.dart';

class AppRouteGuard {
  AppRouteGuard({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  Map<String, dynamic>? _cachedUserData;
  bool _isFetching = false;

  static const _publicRoutes = <String>{
    AppRoutePaths.splash,
    AppRoutePaths.login,
    AppRoutePaths.register,
  };

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;
    final user = _auth.currentUser;

    if (user == null) {
      if (_isPublic(location)) {
        return null;
      }
      return AppRoutePaths.login;
    }

    final data = await _loadUserData(user.uid);
    final role = (data['role'] as String?)?.trim();
    final firstSessionCompleted = (data['firstSessionCompleted'] as bool?) ?? false;

    if ((role == null || role.isEmpty) && location != AppRoutePaths.roleSelection) {
      return AppRoutePaths.roleSelection;
    }

    if (_requiresFirstSession(location) && !firstSessionCompleted) {
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

  bool _requiresFirstSession(String location) {
    if (location == AppRoutePaths.training ||
        location == AppRoutePaths.trainingCompleted ||
        location == AppRoutePaths.dashboard ||
        // Calendar should remain reachable from the bottom navigation
        // even before completing the onboarding session.
        location.startsWith(AppRoutePaths.calendar) ||
        location.startsWith(AppRoutePaths.moroTraining)) {
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
      final doc = await _firestore.collection('users').doc(uid).get();
      _cachedUserData = doc.data() ?? const <String, dynamic>{};
    } finally {
      _isFetching = false;
    }
    return _cachedUserData!;
  }

  void reset() {
    _cachedUserData = null;
  }
}
