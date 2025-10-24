import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/constants/app_strings.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/feature_flags.dart';
import 'package:free_base/services/training_intent.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final featureFlags = context.watch<FeatureFlags>();
    final router = GoRouter.of(context);

    final primaryActions = <Widget>[
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        onTap: () {
          Navigator.pop(context);
          router.goNamed(AppRouteNames.dashboard);
        },
      ),
      ListTile(
        leading: const Icon(Icons.fitness_center),
        title: const Text('Training starten'),
        subtitle: const Text('Direkt zur aktuellen Einheit wechseln'),
        onTap: () {
          Navigator.pop(context);
          router.goNamed(
            AppRouteNames.training,
            extra: TrainingIntent.start(),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Kalender'),
        onTap: () {
          Navigator.pop(context);
          router.goNamed(AppRouteNames.calendar);
        },
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Profil & Auswertungen'),
        onTap: () {
          Navigator.pop(context);
          router.goNamed(AppRouteNames.profile);
        },
      ),
    ];

    final secondaryActions = <Widget>[
      ListTile(
        leading: const Icon(Icons.quiz),
        title: const Text('Fragebogen'),
        onTap: () {
          Navigator.pop(context);
          router.goNamed(AppRouteNames.questionnaireIntro);
        },
      ),
      ListTile(
        leading: const Icon(Icons.flag),
        title: const Text('Reflexprofile'),
        subtitle: const Text('Detailansichten & Entwicklungsverlauf'),
        onTap: () {
          Navigator.pop(context);
          router.goNamed(AppRouteNames.profile);
        },
      ),
      if (featureFlags.forumEnabled)
        ListTile(
          leading: const Icon(Icons.forum),
          title: const Text('Forum (Beta)'),
          onTap: () {
            Navigator.pop(context);
            router.goNamed(AppRouteNames.forum);
          },
        ),
      if (featureFlags.achievementsEnabled)
        ListTile(
          leading: const Icon(Icons.emoji_events),
          title: const Text('Erfolge'),
          onTap: () {
            Navigator.pop(context);
            router.goNamed(AppRouteNames.achievements);
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
            ...primaryActions,
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Einstellungen & weitere Features'),
              onTap: () {
                Navigator.pop(context);
                router.goNamed(AppRouteNames.settings);
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('Mehr entdecken'),
              children: secondaryActions,
            ),
          ],
        ),
      ),
    );
  }
}
