import 'dart:async';

import 'package:flutter/material.dart';
import 'package:free_base/features/calendar/notifier/calendar_notifier.dart';
import 'package:free_base/features/common/utils/day_completion_util.dart';
import 'package:free_base/features/progress/models/week_progress.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/reminder/reminder_service.dart';
import 'package:free_base/services/telemetry/telemetry_service.dart';

class DashboardViewModel extends ChangeNotifier {
  static const int _xpPerLevel = 100;

  DashboardViewModel(
    SessionNotifier sessionNotifier,
    CalendarNotifier calendarNotifier,
    ReminderService reminderService, {
    bool autoplayEnabled = true,
    bool audioEnabled = true,
    TelemetryService? telemetryService,
  })  : _sessionNotifier = sessionNotifier,
        _calendarNotifier = calendarNotifier,
        _reminderService = reminderService,
        _autoplayEnabled = autoplayEnabled,
        _audioEnabled = audioEnabled,
        _telemetry = telemetryService {
    _sessionNotifier.addListener(_sessionListener);
    _calendarNotifier.addListener(_calendarListener);
    _reminderService.addListener(_reminderListener);
  }

  late SessionNotifier _sessionNotifier;
  late CalendarNotifier _calendarNotifier;
  late ReminderService _reminderService;
  TelemetryService? _telemetry;
  bool _autoplayEnabled = true;
  bool _audioEnabled = true;

  void updateSources(
    SessionNotifier sessionNotifier,
    CalendarNotifier calendarNotifier,
    ReminderService reminderService,
    TelemetryService telemetryService,
  ) {
    if (!identical(_sessionNotifier, sessionNotifier)) {
      _sessionNotifier.removeListener(_sessionListener);
      _sessionNotifier = sessionNotifier;
      _sessionNotifier.addListener(_sessionListener);
    }
    if (!identical(_calendarNotifier, calendarNotifier)) {
      _calendarNotifier.removeListener(_calendarListener);
      _calendarNotifier = calendarNotifier;
      _calendarNotifier.addListener(_calendarListener);
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

  Future<bool> startNextWeek() async {
    final progress = currentWeekProgress;
    final nextWeekStart =
        progress.windowEnd.add(const Duration(days: 1));
    final normalized = DateTime(
      nextWeekStart.year,
      nextWeekStart.month,
      nextWeekStart.day,
    );
    await _calendarNotifier.loadMonth(
      normalized,
      ensureWeekForDay: normalized,
    );
    _calendarNotifier.selectDay(normalized);

    final telemetry = _telemetry;
    if (telemetry != null) {
      final stats = progress.stats;
      unawaited(
        telemetry.logEvent(
          'dashboard_start_next_week',
          properties: {
            'next_week_start': normalized.toIso8601String(),
            'planned_days': stats.plannedDays,
            'completed_days': stats.completedDays,
            'pending_reflections': stats.pendingReflections,
          },
        ),
      );
    }
    return true;
  }

  Future<bool> openReflection() async {
    final progress = currentWeekProgress;
    DayProgressNode? pending;
    for (final node in progress.days) {
      if (node.requiresReflection) {
        pending = node;
        break;
      }
    }

    final telemetry = _telemetry;
    if (telemetry != null) {
      final stats = progress.stats;
      unawaited(
        telemetry.logEvent(
          'dashboard_open_reflection',
          properties: {
            'has_pending': pending != null,
            'target_date': pending?.date.toIso8601String(),
            'pending_reflections': stats.pendingReflections,
          },
        ),
      );
    }
    if (pending == null) {
      return false;
    }
    await _calendarNotifier.loadMonth(
      pending.date,
      ensureWeekForDay: pending.date,
    );
    _calendarNotifier.selectDay(pending.date);
    return true;
  }

  Future<DayCompletionResult> markTodayComplete({
    DateTime? completionTime,
    int? xpReward,
  }) async {
    final completion = (completionTime ?? DateTime.now()).toLocal();
    final result = await markDayCompletion(
      sessionNotifier: _sessionNotifier,
      calendarNotifier: _calendarNotifier,
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

    for (var i = 0; i < 7; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      final events = _calendarNotifier.eventsForDay(day);
      days.add(
        DayProgressNode(
          date: day,
          isPlanned: events.isNotEmpty,
          isCompleted: events.any((e) => e.isCompleted),
          isGoldenDay: events.any((e) => e.isGoldenDay),
          hasReflection: events.any((e) => e.notes.trim().isNotEmpty),
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

  void _calendarListener() {
    notifyListeners();
  }

  void _reminderListener() {
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionNotifier.removeListener(_sessionListener);
    _calendarNotifier.removeListener(_calendarListener);
    _reminderService.removeListener(_reminderListener);
    super.dispose();
  }
}
