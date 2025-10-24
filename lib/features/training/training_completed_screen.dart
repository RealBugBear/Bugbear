import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/app_routes.dart';

class TrainingCompletedScreen extends StatelessWidget {
  const TrainingCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionNotifier = context.watch<SessionNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Training abgeschlossen')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.emoji_events, size: 72, color: Colors.orangeAccent),
            const SizedBox(height: 24),
            Text(
              'Starke Leistung!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Du hast deine Session erfolgreich beendet. Nutze den Schwung für den nächsten Schritt oder kehre zum Dashboard zurück.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRouteNames.dashboard),
                child: const Text('Zurück zum Dashboard'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  sessionNotifier.restartSession();
                  context.goNamed(AppRouteNames.training);
                },
                child: const Text('Nächste Session planen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
