/// SessionNotifier
///
/// Notifier für Trainings-Sessions mit:
/// - Timer-Logik (8 s aktiv / 4 s Pause)
/// - Wiederholungen & Übungswechsel
/// - Kalender-Event am Ende (via CalendarService.addEvent)
/// - dynamischer Phasenwechsel

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bugbear_app/features/training/models/session_state.dart';
import 'package:bugbear_app/features/training/models/exercise_item.dart';
import 'package:bugbear_app/features/training/services/session_repository.dart';
import 'package:bugbear_app/features/training/services/sync_service.dart';
import 'package:bugbear_app/features/calendar/services/calendar_service.dart';
import 'package:bugbear_app/features/calendar/models/calendar_event.dart';
import 'package:bugbear_app/features/training/services/exercise_repository.dart';

class SessionNotifier extends ChangeNotifier {
  final SessionRepository _repo;
  final SyncService _syncService;
  final CalendarService _calendarService;
  final ExerciseRepository _exerciseRepo;

  late List<ExerciseItem> _exercises;
  Timer? _timer;
  bool _inRest = false;

  SessionState _state;
  SessionNotifier(
    this._repo,
    this._syncService,
    this._calendarService,
    this._exerciseRepo,
    List<ExerciseItem> initialExercises,
    this._state,
  ) : _exercises = initialExercises;

  SessionState get state => _state;
  List<ExerciseItem> get exercises => _exercises;

  set state(SessionState newState) {
    _state = newState;
    notifyListeners();
    _repo.save(newState);
    _syncService.enqueue(newState);
  }

  /// Startet oder resumiert den Timer (falls pausiert).
  void start() {
    if (_timer != null) return;
    if (state.status == SessionStatus.completed) {
      state = state.copyWith(status: SessionStatus.inProgress);
    }
    state = state.copyWith(isPaused: false);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  /// Pausiert den Timer.
  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isPaused: true);
  }

  /// Wechselt die Phase komplett neu.
  void changePhase(String newPhaseId) {
    _timer?.cancel();
    _timer = null;
    _inRest = false;
    _exercises = _exerciseRepo.getExercisesForPhase(newPhaseId);
    final first = _exercises.first;
    state = SessionState(
      phaseId: newPhaseId,
      exerciseIndex: 0,
      completedReps: 0,
      remainingSeconds: first.activeSeconds,
      isPaused: true,
      startedAt: DateTime.now(),
    );
  }

  void _tick(Timer timer) {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
        isPaused: false,
      );
    } else {
      _timer?.cancel();
      _timer = null;
      if (!_inRest) {
        final repCount = state.completedReps + 1;
        state = state.copyWith(
          completedReps: repCount,
          remainingSeconds: _exercises[state.exerciseIndex].restSeconds,
        );
        _inRest = true;
        start();
      } else {
        _inRest = false;
        final cur = _exercises[state.exerciseIndex];
        if (state.completedReps < cur.repetitions) {
          state = state.copyWith(remainingSeconds: cur.activeSeconds);
          start();
        } else {
          _advanceExerciseOrComplete();
        }
      }
    }
  }

  void _advanceExerciseOrComplete() {
    final idx = state.exerciseIndex;
    if (idx < _exercises.length - 1) {
      final next = _exercises[idx + 1];
      state = state.copyWith(
        exerciseIndex: idx + 1,
        completedReps: 0,
        remainingSeconds: next.activeSeconds,
      );
      _inRest = false;
      start();
    } else {
      // Session komplett fertig
      state = state.copyWith(
        status: SessionStatus.completed,
        endAt: DateTime.now(),
      );
      // Kalender-Event erstellen statt undefined addSessionEvent
      final event = CalendarEvent.fromSession(state);
      _calendarService.addEvent(event);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
