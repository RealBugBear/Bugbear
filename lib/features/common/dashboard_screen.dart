// lib/features/common/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:bugbear_app/features/common/app_drawer.dart';

/// DashboardScreen
///
/// Startpunkt der App mit Navigation zu Training und Kalender.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Willkommen im Dashboard!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/training'),
              child: const Text('Zum Training'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/calendar'),
              child: const Text('Zum Kalender'),
            ),
          ],
        ),
      ),
    );
  }
}
