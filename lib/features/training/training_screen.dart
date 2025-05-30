import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bugbear_app/features/training/notifier/session_notifier.dart';
import 'package:bugbear_app/features/training/widgets/training_header.dart';
import 'package:bugbear_app/features/training/widgets/training_drawer.dart';
import 'package:bugbear_app/features/training/widgets/progress_row.dart';
import 'package:bugbear_app/features/training/widgets/exercise_canvas.dart';
import 'package:bugbear_app/features/training/widgets/control_button_row.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionNotifier = context.watch<SessionNotifier>();
    final state = sessionNotifier.state;
    final exercises = sessionNotifier.exercises;
    final idx = state.exerciseIndex.clamp(0, exercises.length - 1);
    final current = exercises[idx];

    return Scaffold(
      drawer: const TrainingDrawer(), // neuer Drawer
      appBar: TrainingHeader(
        phaseName: 'Phase ${state.phaseId}',
        onHelpPressed: () {
          // TODO: Hilfe-Overlay öffnen
        },
      ),
      body: Column(
        children: [
          ProgressRow(
            currentExercise: idx + 1,
            totalExercises: exercises.length,
            completedReps: state.completedReps,
            totalReps: current.repetitions,
            remainingSeconds: state.remainingSeconds,
          ),
          Expanded(
            child: ExerciseCanvas(
              imagePath: current.imagePath,
            ),
          ),
          ControlButtonRow(
            onBack: () {
              if (state.exerciseIndex > 0) {
                sessionNotifier.state = state.copyWith(
                  exerciseIndex: state.exerciseIndex - 1,
                  completedReps: 0,
                  remainingSeconds: current.activeSeconds,
                );
              }
            },
            onPlayPause: () {
              if (state.isPaused) {
                sessionNotifier.start();
              } else {
                sessionNotifier.pause();
              }
            },
            onNext: () {
              if (state.exerciseIndex < exercises.length - 1) {
                sessionNotifier.state = state.copyWith(
                  exerciseIndex: state.exerciseIndex + 1,
                  completedReps: 0,
                  remainingSeconds: current.activeSeconds,
                );
              }
            },
            isPlaying: !state.isPaused,
          ),
        ],
      ),
    );
  }
}
