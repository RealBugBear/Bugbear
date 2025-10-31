/// SessionNotifier
///
/// Verwaltet den SessionState, persistiert Fortschritt und stellt
/// Hilfsmethoden für Planung, Gamification und Moro-Resume-Punkte bereit.

import 'package:flutter/foundation.dart';
import 'package:free_base/features/training/models/session_state.dart';
import 'package:free_base/features/training/models/exercise_item.dart';
import 'package:free_base/features/training/services/session_repository.dart';
import 'package:free_base/features/training/services/sync_service.dart';
import 'package:free_base/features/training/services/exercise_repository.dart';

class SessionNotifier extends ChangeNotifier {
  final SessionRepository _repo;
  final SyncService _syncService;
  final ExerciseRepository _exerciseRepo;

  late List<ExerciseItem> _exercises;
  SessionState _state;
  SessionNotifier(
    this._repo,
    this._syncService,
    this._exerciseRepo,
    List<ExerciseItem> initialExercises,
    SessionState state,
  )   : _exercises = initialExercises,
        _state = state {
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

  /// Wechselt die Phase komplett neu.
  void changePhase(String newPhaseId) {
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
  }

  void markOnboardingComplete() {
    if (!state.onboardingComplete) {
      state = state.copyWith(onboardingComplete: true);
    }
  }

  void restartSession({DateTime? plannedFor}) {
    scheduleNextSession(plannedFor: plannedFor);
  }

  void scheduleNextSession({DateTime? plannedFor}) {
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

  bool spendXp(int amount) {
    if (amount <= 0) {
      return true;
    }
    if (state.xpTotal < amount) {
      return false;
    }
    state = state.copyWith(xpTotal: state.xpTotal - amount);
    return true;
  }

  void startMoroSession() {
    state = state.copyWith(
      status: SessionStatus.inProgress,
      startedAt: DateTime.now(),
      plannedFor: null,
      isPaused: false,
    );
  }

  Map<String, dynamic>? getResumePoint(String resumeKey) {
    final entry = state.moroResume[resumeKey];
    if (entry is Map<String, dynamic>) {
      return Map<String, dynamic>.from(entry);
    }
    return null;
  }

  void saveResumePoint(String resumeKey, Map<String, dynamic> snapshot) {
    final updated = Map<String, dynamic>.from(state.moroResume)
      ..[resumeKey] = snapshot;
    state = state.copyWith(moroResume: updated);
  }

  void clearResumePoint(String resumeKey) {
    if (!state.moroResume.containsKey(resumeKey)) {
      return;
    }
    final updated = Map<String, dynamic>.from(state.moroResume)
      ..remove(resumeKey);
    state = state.copyWith(moroResume: updated);
  }

  void applyXpReward({required int xp, DateTime? completionTime}) {
    if (xp <= 0) {
      return;
    }
    final completion = completionTime ?? DateTime.now();
    final normalized = _normalizeDate(completion);
    final lastCompleted = state.lastCompletedOn;
    final sameDay = lastCompleted != null && _isSameDay(lastCompleted, normalized);
    final newDaily = sameDay ? state.dailyXp + xp : xp;
    state = state.copyWith(
      xpTotal: state.xpTotal + xp,
      dailyXp: newDaily,
      lastCompletedOn: normalized,
    );
    updateStreakFreeze(referenceDate: normalized);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
