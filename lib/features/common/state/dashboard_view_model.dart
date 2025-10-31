import 'package:flutter/material.dart';
import 'package:free_base/features/calendar/notifier/calendar_notifier.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';
import 'package:free_base/services/reminder/reminder_service.dart';

class CalendarWeekSummary {
  final DateTime weekStart;
  final int plannedDays;
  final int completedDays;
  final bool hasGoldenDay;

  const CalendarWeekSummary({
    required this.weekStart,
    required this.plannedDays,
    required this.completedDays,
    required this.hasGoldenDay,
  });

  double get completionRate {
    if (plannedDays == 0) {
      return 0;
    }
    return completedDays / plannedDays;
  }

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));
}

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

  CalendarWeekSummary get currentWeekSummary => _calculateCurrentWeekSummary();

  TimeOfDay? get scheduledReminder => _reminderService.scheduledTime;

  bool get hasScheduledReminder => _reminderService.hasScheduledReminder;

  Future<void> scheduleReminder(TimeOfDay time) async {
    await _reminderService.scheduleDailyReminder(time);
  }

  Future<void> cancelReminder() async {
    await _reminderService.cancelDailyReminder();
  }

  CalendarWeekSummary _calculateCurrentWeekSummary() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - DateTime.monday));
    var plannedDays = 0;
    var completedDays = 0;
    var hasGoldenDay = false;

    for (var i = 0; i < 7; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      final events = _calendarNotifier.eventsForDay(day);
      if (events.isEmpty) {
        continue;
      }
      plannedDays += 1;
      if (events.any((e) => e.isCompleted)) {
        completedDays += 1;
      }
      if (!hasGoldenDay && events.any((e) => e.isGoldenDay)) {
        hasGoldenDay = true;
      }
    }

    return CalendarWeekSummary(
      weekStart: DateTime(start.year, start.month, start.day),
      plannedDays: plannedDays,
      completedDays: completedDays,
      hasGoldenDay: hasGoldenDay,
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
