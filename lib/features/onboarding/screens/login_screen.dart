import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:free_base/features/onboarding/services/auth_service.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/error_handler.dart';
import 'package:free_base/widgets/connectivity_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  static const emailFieldKey = ValueKey('login_email_field');
  static const passwordFieldKey = ValueKey('login_password_field');
  static const submitButtonKey = ValueKey('login_submit_button');

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error     = null;
    });
    try {
      final auth = context.read<AuthService>();
      await auth.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      context.goNamed(AppRouteNames.roleSelection);
    } catch (e) {
      if (!mounted) return;
      final locale = Localizations.maybeLocaleOf(context);
      final isGerman = locale != null && locale.languageCode.toLowerCase() == 'de';
      final message = ErrorHandler.messageFor(
        e,
        isGerman: isGerman,
        fallback: isGerman
            ? 'Fehler bei der Anmeldung. Bitte später erneut versuchen.'
            : 'Login failed. Please try again later.',
      );
      setState(() {
        _error = message;
      });
      ErrorHandler.showErrorSnack(context, message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anmelden')),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    key: emailFieldKey,
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: passwordFieldKey,
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Passwort'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    key: submitButtonKey,
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Anmelden'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pushNamed(AppRouteNames.register),
                    child: const Text('Noch keinen Account? Registrieren'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
