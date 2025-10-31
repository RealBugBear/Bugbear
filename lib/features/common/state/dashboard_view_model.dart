import 'package:flutter/material.dart';
import 'package:free_base/features/calendar/notifier/calendar_notifier.dart';
import 'package:free_base/features/progress/models/week_progress.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/reminder/reminder_service.dart';

class DashboardViewModel extends ChangeNotifier {
  static const int _xpPerLevel = 100;

  DashboardViewModel(
    SessionNotifier sessionNotifier,
    CalendarNotifier calendarNotifier,
    ReminderService reminderService,
  )   : _sessionNotifier = sessionNotifier,
        _calendarNotifier = calendarNotifier,
        _reminderService = reminderService {
    _sessionNotifier.addListener(_sessionListener);
    _calendarNotifier.addListener(_calendarListener);
    _reminderService.addListener(_reminderListener);
  }

  late SessionNotifier _sessionNotifier;
  late CalendarNotifier _calendarNotifier;
  late ReminderService _reminderService;

  void updateSources(
    SessionNotifier sessionNotifier,
    CalendarNotifier calendarNotifier,
    ReminderService reminderService,
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

  Future<void> scheduleReminder(TimeOfDay time) async {
    await _reminderService.scheduleDailyReminder(time);
  }

  Future<void> cancelReminder() async {
    await _reminderService.cancelDailyReminder();
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
