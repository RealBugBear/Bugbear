import 'package:flutter/material.dart';

/// Zeigt den Fortschritt in drei Segmenten:
/// 1. Übungscounter (z.B. "3 / 8")
/// 2. Reps-Counter (z.B. "2 / 6")
/// 3. Timer (z.B. "00:08")
class ProgressRow extends StatelessWidget {
  final int currentExercise;
  final int totalExercises;
  final int completedReps;
  final int totalReps;
  final int remainingSeconds;

  const ProgressRow({
    super.key,
    required this.currentExercise,
    required this.totalExercises,
    required this.completedReps,
    required this.totalReps,
    required this.remainingSeconds,
  });

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    // TextStyle für alle drei Felder
    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Übungscounter
          Column(
            children: [
              Text('Übung', style: labelStyle),
              const SizedBox(height: 4),
              Text('$currentExercise / $totalExercises'),
            ],
          ),
          // Reps-Counter
          Column(
            children: [
              Text('Reps', style: labelStyle),
              const SizedBox(height: 4),
              Text('$completedReps / $totalReps'),
            ],
          ),
          // Timer-Anzeige
          Column(
            children: [
              Text('Timer', style: labelStyle),
              const SizedBox(height: 4),
              Text(_formatTime(remainingSeconds)),
            ],
          ),
        ],
      ),
    );
  }
}
