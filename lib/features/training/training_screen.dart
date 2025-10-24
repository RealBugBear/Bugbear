import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/widgets/training_header.dart';
import 'package:free_base/widgets/app_drawer.dart';
import 'package:free_base/features/training/widgets/progress_row.dart';
import 'package:free_base/features/training/widgets/exercise_canvas.dart';
import 'package:free_base/features/training/widgets/control_button_row.dart';
import 'package:free_base/widgets/connectivity_banner.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionNotifier = context.watch<SessionNotifier>();
    final state = sessionNotifier.state;
    final exercises = sessionNotifier.exercises;
    final idx = state.exerciseIndex.clamp(0, exercises.length - 1);
    final current = exercises[idx];

    if (state.status == SessionStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (ModalRoute.of(context)?.settings.name == '/training/completed') {
          return;
        }
        Navigator.of(context).pushReplacementNamed('/training/completed');
      });
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: TrainingHeader(
        phaseName: 'Phase ${state.phaseId}',
        phaseId: state.phaseId,
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
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
