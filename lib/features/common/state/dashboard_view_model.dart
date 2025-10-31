import 'dart:async';

import 'package:flutter/material.dart';
import 'package:free_base/features/common/utils/day_completion_util.dart';
import 'package:free_base/features/progress/models/week_progress.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/reminder/reminder_service.dart';
import 'package:free_base/services/telemetry/telemetry_service.dart';
import 'package:free_base/features/progress/state/progress_store.dart';

class DashboardViewModel extends ChangeNotifier {
  static const int _xpPerLevel = 100;

  DashboardViewModel(
    SessionNotifier sessionNotifier,
    ProgressStore progressStore,
    ReminderService reminderService, {
    bool autoplayEnabled = true,
    bool audioEnabled = true,
    TelemetryService? telemetryService,
  })  : _sessionNotifier = sessionNotifier,
        _progressStore = progressStore,
        _reminderService = reminderService,
        _autoplayEnabled = autoplayEnabled,
        _audioEnabled = audioEnabled,
        _telemetry = telemetryService {
    _sessionNotifier.addListener(_sessionListener);
    _progressStore.addListener(_progressListener);
    _reminderService.addListener(_reminderListener);
  }

  late SessionNotifier _sessionNotifier;
  late ProgressStore _progressStore;
  late ReminderService _reminderService;
  TelemetryService? _telemetry;
  bool _autoplayEnabled = true;
  bool _audioEnabled = true;

  void updateSources(
    SessionNotifier sessionNotifier,
    ProgressStore progressStore,
    ReminderService reminderService,
    TelemetryService telemetryService,
  ) {
    if (!identical(_sessionNotifier, sessionNotifier)) {
      _sessionNotifier.removeListener(_sessionListener);
      _sessionNotifier = sessionNotifier;
      _sessionNotifier.addListener(_sessionListener);
    }
    if (!identical(_progressStore, progressStore)) {
      _progressStore.removeListener(_progressListener);
      _progressStore = progressStore;
      _progressStore.addListener(_progressListener);
    }
    if (!identical(_reminderService, reminderService)) {
      _reminderService.removeListener(_reminderListener);
      _reminderService = reminderService;
      _reminderService.addListener(_reminderListener);
    }
    if (!identical(_telemetry, telemetryService)) {
      _telemetry = telemetryService;
    }
    notifyListeners();
  }

  int get xpTotal => _sessionNotifier.state.xpTotal;
  int get dailyXp => _sessionNotifier.state.dailyXp;
  int get streakCount => _sessionNotifier.state.streakCount;
  DateTime? get streakFrozenUntil => _sessionNotifier.state.streakFrozenUntil;

  bool get freezeAvailable {
    final until = streakFrozenUntil;
    if (until == null) {
      return false;
    }
    final today = DateTime.now();
    final normalized = DateTime(until.year, until.month, until.day);
    return !today.isAfter(normalized);
  }

  int get currentLevel => (xpTotal ~/ _xpPerLevel) + 1;

  int get xpIntoLevel => xpTotal % _xpPerLevel;

  int get xpToNextLevel => _xpPerLevel - xpIntoLevel;

  double get levelProgress => xpIntoLevel / _xpPerLevel;

  CoreWeekProgress get currentWeekProgress => _calculateCurrentWeekProgress();

  WeekProgressStats get currentWeekStats => currentWeekProgress.stats;

  double get progressRatio => currentWeekProgress.progressRatio;

  int? get todayIndex => currentWeekProgress.todayIndex;

  TimeOfDay? get scheduledReminder => _reminderService.scheduledTime;

  bool get hasScheduledReminder => _reminderService.hasScheduledReminder;

  bool get autoplayEnabled => _autoplayEnabled;

  bool get audioEnabled => _audioEnabled;

  void setAutoplayEnabled(bool value) {
    if (_autoplayEnabled == value) {
      return;
    }
    _autoplayEnabled = value;
    notifyListeners();
  }

  void setAudioEnabled(bool value) {
    if (_audioEnabled == value) {
      return;
    }
    _audioEnabled = value;
    notifyListeners();
  }

  Future<void> scheduleReminder(TimeOfDay time) async {
    await _reminderService.scheduleDailyReminder(time);
  }

  Future<void> cancelReminder() async {
    await _reminderService.cancelDailyReminder();
  }

  Future<DayCompletionResult> markTodayComplete({
    DateTime? completionTime,
    int? xpReward,
  }) async {
    final completion = (completionTime ?? DateTime.now()).toLocal();
    final result = await markDayCompletion(
      sessionNotifier: _sessionNotifier,
      progressStore: _progressStore,
      completionTime: completion,
      xpReward: xpReward,
    );

    final telemetry = _telemetry;
    if (telemetry != null) {
      final stats = currentWeekProgress.stats;
      unawaited(
        telemetry.logEvent(
          'dashboard_mark_today_complete',
          properties: {
            'completion_date': result.date.toIso8601String(),
            'already_completed': result.wasAlreadyCompleted,
            'requires_reflection': result.requiresReflection,
            'pending_reflections': stats.pendingReflections,
            'daily_xp': _sessionNotifier.state.dailyXp,
            'streak_count': _sessionNotifier.state.streakCount,
          },
        ),
      );
    }

    return result;
  }

  CoreWeekProgress _calculateCurrentWeekProgress() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - DateTime.monday));
    final days = <DayProgressNode>[];
    final today = DateTime(now.year, now.month, now.day);

    for (var i = 0; i < 7; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      final isCompleted = _progressStore.isDayCompleted(day);
      days.add(
        DayProgressNode(
          date: day,
          isPlanned: !day.isAfter(today),
          isCompleted: isCompleted,
          isGoldenDay: false,
          hasReflection: false,
        ),
      );
    }

    return CoreWeekProgress(
      windowStart: DateTime(start.year, start.month, start.day),
      windowEnd: DateTime(start.year, start.month, start.day + 6),
      days: days,
    );
  }

  void _sessionListener() {
    notifyListeners();
  }

  void _progressListener() {
    notifyListeners();
  }

  void _reminderListener() {
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionNotifier.removeListener(_sessionListener);
    _progressStore.removeListener(_progressListener);
    _reminderService.removeListener(_reminderListener);
    super.dispose();
  }
}
