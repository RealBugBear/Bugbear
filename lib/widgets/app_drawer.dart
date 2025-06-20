import 'package:flutter/material.dart';
import 'package:bugbear_app/features/training/screens/phase_selection_screen.dart';

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
              child: Text(
                'Men\u00fc',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Training'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/training');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Kalender'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/calendar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Einstellungen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Fragebogen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/questionnaire');
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_play),
              title: const Text('Phase ausw\u00e4hlen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PhaseSelectionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
