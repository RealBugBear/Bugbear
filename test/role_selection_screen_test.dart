import 'package:bugbear_app/features/onboarding/screens/role_selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('redirects to login when no user is signed in', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => const RoleSelectionScreen(),
          '/login': (_) => const Placeholder(key: Key('login-page')),
          '/dashboard': (_) => const Placeholder(),
        },
      ),
    );

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-page')), findsOneWidget);
  });
}
