import 'package:flutter/material.dart';

class SessionCompletionSummary {
  final Duration totalDuration;
  final int totalExercises;
  final int totalRepetitions;
  final String? phaseLabel;

  const SessionCompletionSummary({
    required this.totalDuration,
    required this.totalExercises,
    required this.totalRepetitions,
    this.phaseLabel,
  });
}

enum SessionCompletionAction { close, planNext, openCalendar, giveFeedback }

Future<SessionCompletionAction?> showSessionCompletionDialog(
  BuildContext context, {
  required SessionCompletionSummary summary,
}) {
  final duration = summary.totalDuration;
  final durationLabel = duration == Duration.zero
      ? 'Weniger als eine Minute'
      : _formatDuration(duration);

  return showDialog<SessionCompletionAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Session abgeschlossen',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Starke Leistung! Du hast deine aktuelle Trainingseinheit erfolgreich beendet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (summary.phaseLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                summary.phaseLabel!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 16),
            _StatTile(
              icon: Icons.timer_outlined,
              label: 'Gesamtdauer',
              value: durationLabel,
            ),
            const SizedBox(height: 8),
            _StatTile(
              icon: Icons.fitness_center_outlined,
              label: 'Übungen abgeschlossen',
              value: '${summary.totalExercises}',
            ),
            const SizedBox(height: 8),
            _StatTile(
              icon: Icons.repeat,
              label: 'Wiederholungen',
              value: '${summary.totalRepetitions}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(SessionCompletionAction.giveFeedback),
            child: const Text('Feedback geben'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(SessionCompletionAction.openCalendar),
            child: const Text('Zum Kalender'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context)
                .pop(SessionCompletionAction.planNext),
            child: const Text('Nächste Session planen'),
          ),
        ],
      );
    },
  );
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  if (minutes <= 0) {
    return '${duration.inSeconds}s';
  }
  if (seconds == 0) {
    return '${minutes}min';
  }
  return '${minutes}min ${seconds}s';
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
