import 'package:flutter/material.dart';
import 'package:bugbear_app/features/training/screens/phase_selection_screen.dart';

/// Der Side-Menu-Drawer für das Training.
class TrainingDrawer extends StatelessWidget {
  const TrainingDrawer({super.key});

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
              leading: const Icon(Icons.playlist_play),
              title: const Text('Phase auswählen'),
              onTap: () {
                Navigator.pop(context); // Drawer schließen
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PhaseSelectionScreen()),
                );
              },
            ),
            // Hier kannst Du weitere Menü-Punkte hinzufügen:
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
          ],
        ),
      ),
    );
  }
}
