import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/app_routes.dart';

class TrainingCompletedScreen extends StatefulWidget {
  const TrainingCompletedScreen({super.key});

  @override
  State<TrainingCompletedScreen> createState() => _TrainingCompletedScreenState();
}

class _TrainingCompletedScreenState extends State<TrainingCompletedScreen> {
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _showConfetti = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionNotifier = context.watch<SessionNotifier>();
    final state = sessionNotifier.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Training abgeschlossen')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _showConfetti ? 1 : 0,
                    duration: const Duration(milliseconds: 600),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(
                        12,
                        (index) => const Icon(
                          Icons.celebration,
                          color: Colors.orangeAccent,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.emoji_events, size: 72, color: Colors.orangeAccent),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Starke Leistung!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Du hast deine Session erfolgreich beendet. Heute gesammelte XP: ${state.dailyXp}. Gesamtstand: ${state.xpTotal}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Aktuelle Streak: ${state.streakCount} Tage.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing folgt – aktuell wird ein Platzhalter verwendet.'),
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Fortschritt teilen'),
              ),
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
