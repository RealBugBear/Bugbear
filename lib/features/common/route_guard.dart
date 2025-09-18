import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:free_base/features/onboarding/screens/login_screen.dart';

Route<dynamic> guard(
  RouteSettings settings,
  WidgetBuilder authed, {
  WidgetBuilder? unauthed,
}) {
  final isLoggedIn = FirebaseAuth.instance.currentUser != null;
  if (isLoggedIn) {
    return MaterialPageRoute(builder: authed, settings: settings);
  }
  return MaterialPageRoute(
    builder: unauthed ?? (_) => const LoginScreen(),
    settings: settings,
  );
}
