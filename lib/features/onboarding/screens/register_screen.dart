// File: lib/screens/onboarding/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:free_base/features/onboarding/services/auth_service.dart';
import 'package:free_base/services/error_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error     = null;
    });
    try {
      final auth = context.read<AuthService>();
      await auth.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        // falls du später Nickname unterstützen willst, hier einfügen:
        // nickname: _nicknameController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
    } catch (e) {
      if (!mounted) return;
      final locale = Localizations.maybeLocaleOf(context);
      final isGerman = locale != null && locale.languageCode.toLowerCase() == 'de';
      final message = ErrorHandler.messageFor(
        e,
        isGerman: isGerman,
        fallback: isGerman
            ? 'Fehler beim Registrieren. Bitte später erneut versuchen.'
            : 'Registration failed. Please try again later.',
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
      appBar: AppBar(title: const Text('Registrieren')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
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
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Registrieren'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Bereits registriert? Anmelden'),
            ),
          ],
        ),
      ),
    );
  }
}
