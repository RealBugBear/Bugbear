import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:free_base/constants/app_strings.dart';
import 'package:free_base/services/feature_flags.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final featureFlags = context.watch<FeatureFlags>();

    final items = <Widget>[
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/dashboard');
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
        leading: const Icon(Icons.person),
        title: const Text('Reflexprofile'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/reflexe-profil');
        },
      ),
      if (featureFlags.forumEnabled)
        ListTile(
          leading: const Icon(Icons.forum),
          title: const Text('Forum (Beta)'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/forum');
          },
        ),
      if (featureFlags.achievementsEnabled)
        ListTile(
          leading: const Icon(Icons.emoji_events),
          title: const Text('Erfolge'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/achievements');
          },
        ),
    ];

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menü',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}
