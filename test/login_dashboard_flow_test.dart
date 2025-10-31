import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/onboarding/screens/login_screen.dart';
import 'package:free_base/features/onboarding/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

class FakeUserCredential extends Fake implements UserCredential {}

class _FakeSelectRoleScreen extends StatefulWidget {
  const _FakeSelectRoleScreen();

  @override
  State<_FakeSelectRoleScreen> createState() => _FakeSelectRoleScreenState();
}

class _FakeSelectRoleScreenState extends State<_FakeSelectRoleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Role Selection Placeholder')),
    );
  }
}

class _FakeDashboardScreen extends StatelessWidget {
  const _FakeDashboardScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard Placeholder')),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login success navigates through role selection to dashboard',
      (tester) async {
    final mockAuth = MockAuthService();
    when(mockAuth.signInWithEmail(any<String>(), any<String>()))
        .thenAnswer((_) async => FakeUserCredential());

    await tester.pumpWidget(
      Provider<AuthService>.value(
        value: mockAuth,
        child: MaterialApp(
          initialRoute: '/login',
          routes: {
            '/login': (_) => const LoginScreen(),
            '/select-role': (_) => const _FakeSelectRoleScreen(),
            '/dashboard': (_) => const _FakeDashboardScreen(),
          },
        ),
      ),
    );

    await tester.enterText(
      find.byKey(LoginScreenState.emailFieldKey),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(LoginScreenState.passwordFieldKey),
      'password123',
    );
    await tester.tap(find.byKey(LoginScreenState.submitButtonKey));

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Placeholder'), findsOneWidget);
    verify(mockAuth.signInWithEmail('test@example.com', 'password123'))
        .called(1);
  });
}
