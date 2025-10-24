import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/widgets/control_button_row.dart';
import 'package:free_base/features/training/widgets/exercise_canvas.dart';
import 'package:free_base/features/training/widgets/progress_row.dart';
import 'package:free_base/features/training/widgets/session_completion_dialog.dart';
import 'package:free_base/features/training/widgets/session_status_banner.dart';
import 'package:free_base/features/training/widgets/training_header.dart';
import 'package:free_base/widgets/app_drawer.dart';
import 'package:free_base/widgets/connectivity_banner.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<SessionNotifier>().refreshScheduleStatus();
  }

  Future<void> _handleCompletion(
      SessionNotifier notifier, SessionState state) async {
    if (_dialogShown) return;
    _dialogShown = true;
    final exercises = notifier.exercises;
    final totalReps = exercises.fold<int>(0, (sum, ex) => sum + ex.repetitions);
    final duration = state.endAt != null
        ? state.endAt!.difference(state.startedAt)
        : const Duration();
    final action = await showSessionCompletionDialog(
      context,
      summary: SessionCompletionSummary(
        totalDuration: duration,
        totalExercises: exercises.length,
        totalRepetitions: totalReps,
        phaseLabel: 'Phase ${state.phaseId}',
      ),
    );
    if (!mounted) return;
    notifier.scheduleNextSession();
    switch (action) {
      case SessionCompletionAction.openCalendar:
        Navigator.of(context).pushNamed('/calendar');
        break;
      case SessionCompletionAction.giveFeedback:
        Navigator.of(context).pushNamed('/questionnaire');
        break;
      case SessionCompletionAction.planNext:
      case SessionCompletionAction.close:
      case null:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => route.isFirst,
        );
        break;
    }
    if (mounted) {
      setState(() {
        _dialogShown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionNotifier = context.watch<SessionNotifier>();
    final state = sessionNotifier.state;
    final exercises = sessionNotifier.exercises;
    final idx = state.exerciseIndex.clamp(0, exercises.length - 1);
    final current = exercises[idx];

    if (state.status == SessionStatus.completed && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleCompletion(sessionNotifier, state);
      });
    }

    if (state.status != SessionStatus.completed && _dialogShown) {
      _dialogShown = false;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SessionStatusBanner.fromSession(state),
          ),
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
