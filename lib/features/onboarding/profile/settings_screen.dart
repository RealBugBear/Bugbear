// File: lib/screens/profile/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:free_base/features/onboarding/services/auth_service.dart';
import 'package:free_base/services/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  Future<void> _signOut() async {
    final auth = context.read<AuthService>();
    await auth.signOut();
    if (!mounted) return;
    context.goNamed(AppRouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Abmelden'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
