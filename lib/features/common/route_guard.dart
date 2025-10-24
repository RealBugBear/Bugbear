import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:free_base/features/onboarding/screens/login_screen.dart';

Route<dynamic> guard(
  RouteSettings settings,
  WidgetBuilder authed, {
  WidgetBuilder? unauthed,
}) {
  return MaterialPageRoute(
    builder: (context) => _GuardedRoute(
      targetBuilder: authed,
      unauthenticatedBuilder: unauthed,
      settings: settings,
    ),
    settings: settings,
  );
}

class _GuardedRoute extends StatefulWidget {
  final WidgetBuilder targetBuilder;
  final WidgetBuilder? unauthenticatedBuilder;
  final RouteSettings settings;

  const _GuardedRoute({
    required this.targetBuilder,
    required this.settings,
    this.unauthenticatedBuilder,
  });

  @override
  State<_GuardedRoute> createState() => _GuardedRouteState();
}

enum _GuardState { checking, authed, unauthed }

class _GuardedRouteState extends State<_GuardedRoute> {
  _GuardState _state = _GuardState.checking;

  @override
  void initState() {
    super.initState();
    _evaluateAccess();
  }

  Future<void> _evaluateAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _state = _GuardState.unauthed);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? const <String, dynamic>{};
      final role = (data['role'] as String?)?.trim();
      final firstSessionCompleted =
          (data['firstSessionCompleted'] as bool?) ?? false;

      if (!mounted) return;

      if (role == null || role.isEmpty) {
        _redirectTo('/select-role');
        return;
      }

      if (!_canBypassFirstSession(widget.settings.name) &&
          !firstSessionCompleted) {
        _redirectTo('/training');
        return;
      }

      setState(() => _state = _GuardState.authed);
    } catch (e) {
      if (!mounted) return;
      // Im Zweifel Nutzer durchlassen, damit Fehlerbildschirm greifen kann.
      setState(() => _state = _GuardState.authed);
    }
  }

  bool _canBypassFirstSession(String? routeName) {
    if (routeName == null) return false;
    if (routeName == '/training' || routeName == '/training/completed') {
      return true;
    }
    if (routeName.startsWith('/training/moro')) {
      return true;
    }
    return false;
  }

  void _redirectTo(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _GuardState.authed:
        return widget.targetBuilder(context);
      case _GuardState.unauthed:
        final builder =
            widget.unauthenticatedBuilder ?? (_) => const LoginScreen();
        return builder(context);
      case _GuardState.checking:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
