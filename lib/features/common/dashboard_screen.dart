// lib/features/common/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:bugbear_app/features/training/training_screen.dart';
import 'package:bugbear_app/features/calendar/screens/calendar_screen.dart';

/// DashboardScreen
///
/// Startpunkt der App mit Navigation zu Training und Kalender.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                MaterialPageRoute(builder: (_) => const TrainingScreen()),
              ),
              child: const Text('Zum Training'),
            ),
            const SizedBox(height: 12),
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
