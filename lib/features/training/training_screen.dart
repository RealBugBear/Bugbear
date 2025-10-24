import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/features/training/widgets/control_button_row.dart';
import 'package:free_base/features/training/widgets/exercise_canvas.dart';
import 'package:free_base/features/training/widgets/progress_row.dart';
import 'package:free_base/features/training/widgets/session_completion_dialog.dart';
import 'package:free_base/features/training/widgets/session_status_banner.dart';
import 'package:free_base/features/training/widgets/training_header.dart';
import 'package:free_base/services/app_routes.dart';
import 'package:free_base/services/training_intent.dart';
import 'package:free_base/widgets/connectivity_banner.dart';

class TrainingScreen extends StatefulWidget {
  final TrainingIntent? intent;

  const TrainingScreen({super.key, this.intent});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  bool _dialogShown = false;
  bool _intentHandled = false;

  @override
  void didUpdateWidget(covariant TrainingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.intent != oldWidget.intent) {
      _intentHandled = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = context.read<SessionNotifier>();
    notifier.refreshScheduleStatus();
    if (_intentHandled) return;
    final intent = widget.intent;
    if (intent != null) {
      _intentHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (intent.type) {
          case TrainingIntentType.start:
          case TrainingIntentType.resume:
            notifier.start();
            break;
        }
      });
    }
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
        context.goNamed(AppRouteNames.calendar);
        break;
      case SessionCompletionAction.giveFeedback:
        context.pushNamed(AppRouteNames.questionnaireIntro);
        break;
      case SessionCompletionAction.planNext:
      case SessionCompletionAction.close:
      case null:
        context.goNamed(AppRouteNames.dashboard);
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
