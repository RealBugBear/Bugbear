// lib/features/common/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:free_base/features/calendar/screens/calendar_screen.dart';
import 'package:free_base/widgets/app_drawer.dart';

/// DashboardScreen
///
/// Startpunkt der App mit Navigation zum Kalender.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Willkommen im Dashboard!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              ),
              child: const Text('Zum Kalender'),
            ),
          ],
        ),
      ),
    );
  }
}
