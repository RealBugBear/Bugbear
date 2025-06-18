import 'package:flutter/material.dart';
import 'package:bugbear_app/features/training/screens/phase_selection_screen.dart';

/// A global navigation drawer used across the app.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text('Menü', style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Training'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/training');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Kalender'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/calendar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Einstellungen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_play),
              title: const Text('Phase auswählen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PhaseSelectionScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
