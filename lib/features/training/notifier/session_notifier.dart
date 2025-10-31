/// SessionNotifier
///
/// Notifier für Trainings-Sessions mit:
/// - Timer-Logik (8 s aktiv / 4 s Pause)
/// - Wiederholungen & Übungswechsel
/// - Kalender-Event am Ende (via CalendarService.addEvent)
/// - dynamischer Phasenwechsel

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/models/exercise_item.dart';
import 'package:free_base/features/training/services/session_repository.dart';
import 'package:free_base/features/training/services/sync_service.dart';
import 'package:free_base/features/calendar/services/calendar_service.dart';
import 'package:free_base/features/calendar/models/calendar_event.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';
import 'package:free_base/features/calendar/services/golden_day_service.dart';

class SessionNotifier extends ChangeNotifier {
  final SessionRepository _repo;
  final SyncService _syncService;
  final CalendarService _calendarService;
  final GoldenDayService _goldenDayService;
  final ExerciseRepository _exerciseRepo;

  /// Tracks the number of completed sessions per week starting from
  /// the beginning of the current phase.
  final Map<int, int> _weeklyCounts = {};

  /// Start date of the current phase.
  DateTime _phaseStart;

  late List<ExerciseItem> _exercises;
  Timer? _timer;
  bool _inRest = false;

  SessionState _state;
  SessionNotifier(
    this._repo,
    this._syncService,
    this._calendarService,
    this._goldenDayService,
    this._exerciseRepo,
    List<ExerciseItem> initialExercises,
    SessionState state,
  )   : _exercises = initialExercises,
        _state = state,
        _phaseStart = state.startedAt {
    refreshScheduleStatus();
  }

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
      state = state.copyWith(
        status: SessionStatus.inProgress,
        startedAt: DateTime.now(),
        plannedFor: null,
        endAt: null,
      );
    }
    if (state.status == SessionStatus.planned ||
        state.status == SessionStatus.overdue) {
      state = state.copyWith(
        status: SessionStatus.inProgress,
        startedAt: DateTime.now(),
        plannedFor: null,
        endAt: null,
      );
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
    _weeklyCounts.clear();
    _exercises = _exerciseRepo.getExercisesForPhase(newPhaseId);
    final first = _exercises.first;
    final plannedFor = DateTime.now().add(const Duration(days: 1));
    state = SessionState(
      phaseId: newPhaseId,
      exerciseIndex: 0,
      completedReps: 0,
      remainingSeconds: first.activeSeconds,
      isPaused: true,
      startedAt: plannedFor,
      plannedFor: plannedFor,
      status: SessionStatus.planned,
      onboardingComplete: state.onboardingComplete,
    );
    _phaseStart = DateTime.now();
  }

  void markOnboardingComplete() {
    if (!state.onboardingComplete) {
      state = state.copyWith(onboardingComplete: true);
    }
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
      final completionDate = DateTime.now();
      state = state.copyWith(
        status: SessionStatus.completed,
        endAt: completionDate,
        plannedFor: null,
      );
      // Kalender-Event erstellen statt undefined addSessionEvent
      final event = CalendarEvent.fromSession(state);
      _calendarService.addEvent(event);

      // update weekly counts
      final weekIndex =
          state.startedAt.difference(_phaseStart).inDays ~/ 7;
      _weeklyCounts.update(weekIndex, (v) => v + 1, ifAbsent: () => 1);

      // calculate and persist the next Golden Day
      final goldenDay =
          _goldenDayService.calculateGoldenDay(_phaseStart, _weeklyCounts);
      final gdEvent = CalendarEvent(
        id: 'golden_${goldenDay.toIso8601String()}',
        date: DateTime(goldenDay.year, goldenDay.month, goldenDay.day),
        title: 'Golden Day',
        isCompleted: false,
        isGoldenDay: true,
        notes: '',
      );
      _calendarService.addEvent(gdEvent);

      _markFirstSessionCompleted();
      applyCompletionRewards(completionDate: completionDate);
    }
  }

  void restartSession({DateTime? plannedFor}) {
    scheduleNextSession(plannedFor: plannedFor);
  }

  void scheduleNextSession({DateTime? plannedFor}) {
    _timer?.cancel();
    _timer = null;
    _inRest = false;
    if (_exercises.isEmpty) {
      return;
    }
    final first = _exercises.first;
    final target = plannedFor ?? DateTime.now().add(const Duration(days: 1));
    state = state.copyWith(
      exerciseIndex: 0,
      completedReps: 0,
      remainingSeconds: first.activeSeconds,
      isPaused: true,
      startedAt: target,
      plannedFor: target,
      endAt: null,
      status: SessionStatus.planned,
    );
    _phaseStart = DateTime.now();
  }

  void refreshScheduleStatus() {
    if (state.status == SessionStatus.planned && state.plannedFor != null) {
      if (DateTime.now().isAfter(state.plannedFor!)) {
        state = state.copyWith(status: SessionStatus.overdue);
      }
    }
    _resetDailyXpIfNeeded();
    updateStreakFreeze();
  }

  void _resetDailyXpIfNeeded() {
    final lastCompleted = state.lastCompletedOn;
    final normalizedToday = _normalizeDate(DateTime.now());
    if (lastCompleted == null) {
      if (state.dailyXp != 0) {
        state = state.copyWith(dailyXp: 0);
      }
      return;
    }

    if (!_isSameDay(lastCompleted, normalizedToday) && state.dailyXp != 0) {
      state = state.copyWith(dailyXp: 0);
    }
  }

  @visibleForTesting
  int computeXp() {
    if (_exercises.isEmpty) {
      return 0;
    }
    var xp = 0;
    for (var i = 0; i < _exercises.length; i++) {
      final isHighTier = i >= _exercises.length - 2;
      xp += isHighTier ? 60 : 30;
    }
    return xp;
  }

  @visibleForTesting
  void applyCompletionRewards({DateTime? completionDate}) {
    final completion = completionDate ?? DateTime.now();
    final normalizedCompletion = _normalizeDate(completion);
    final xpEarned = computeXp();
    final lastCompleted = state.lastCompletedOn;
    final wasSameDay =
        lastCompleted != null && _isSameDay(lastCompleted, normalizedCompletion);
    final wasConsecutive = lastCompleted != null &&
        normalizedCompletion.difference(lastCompleted).inDays == 1;
    final freezeUntil = state.streakFrozenUntil != null
        ? _normalizeDate(state.streakFrozenUntil!)
        : null;

    final newDailyXp = wasSameDay ? state.dailyXp + xpEarned : xpEarned;

    int newStreakCount;
    if (wasSameDay) {
      newStreakCount = state.streakCount;
    } else if (wasConsecutive) {
      newStreakCount = state.streakCount + 1;
    } else if (freezeUntil != null &&
        !normalizedCompletion.isAfter(freezeUntil)) {
      newStreakCount = state.streakCount;
    } else {
      newStreakCount = 1;
    }

    state = state.copyWith(
      xpTotal: state.xpTotal + xpEarned,
      dailyXp: newDailyXp,
      streakCount: newStreakCount,
      lastCompletedOn: normalizedCompletion,
    );

    updateStreakFreeze(referenceDate: normalizedCompletion);
  }

  void updateStreakFreeze({DateTime? referenceDate}) {
    final today = _normalizeDate(referenceDate ?? DateTime.now());
    final freezeUntil = state.streakFrozenUntil;
    if (freezeUntil != null) {
      final normalizedFreeze = _normalizeDate(freezeUntil);
      if (today.isAfter(normalizedFreeze)) {
        state = state.copyWith(streakFrozenUntil: null);
      }
    }

    if (state.streakCount >= 2 && state.streakFrozenUntil == null) {
      final baseDate =
          _normalizeDate(referenceDate ?? state.lastCompletedOn ?? DateTime.now());
      state = state.copyWith(
        streakFrozenUntil: baseDate.add(const Duration(days: 1)),
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _markFirstSessionCompleted() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      markOnboardingComplete();
      return;
    }
    markOnboardingComplete();
    // Fire-and-forget: der Guard liest das Flag beim nächsten Start.
    unawaited(
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'firstSessionCompleted': true}, SetOptions(merge: true)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
