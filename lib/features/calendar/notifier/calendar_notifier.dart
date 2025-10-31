// lib/features/calendar/notifier/calendar_notifier.dart

import 'package:flutter/foundation.dart';
import '../models/calendar_event.dart';
import '../services/calendar_service.dart';

/// CalendarNotifier
///
/// Verwaltet UI-State für den Kalender:
/// - current focused month (focusedDay)
/// - selected day (selectedDay)
/// - Events grouped by day (_eventsByDay)
/// Stellt Methoden zum Laden, Auswählen und Bearbeiten von Events bereit.
class CalendarNotifier extends ChangeNotifier {
  final CalendarService _service;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final Map<DateTime, List<CalendarEvent>> _eventsByDay = {};

  CalendarNotifier(this._service);

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;

  /// Alle Events für einen beliebigen Tag
  List<CalendarEvent> eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsByDay[key] ?? [];
  }

  /// Events des aktuell selektierten Tages
  List<CalendarEvent> get eventsForSelectedDay => eventsForDay(_selectedDay);

  /// Returns the next golden day based on loaded events or `null` if none.
  DateTime? get upcomingGoldenDay {
    final goldenEvents = _eventsByDay.values
        .expand((e) => e)
        .where((ev) => ev.isGoldenDay)
        .toList();
    if (goldenEvents.isEmpty) return null;
    goldenEvents.sort((a, b) => a.date.compareTo(b.date));
    final now = DateTime.now();
    for (final ev in goldenEvents) {
      if (!ev.date.isBefore(DateTime(now.year, now.month, now.day))) {
        return ev.date;
      }
    }
    return goldenEvents.last.date;
  }

  /// Lädt alle Events des Monats [month] und behält bereits
  /// geladene Monate im Speicher, damit Marker beim Scrollen
  /// nicht verloren gehen.
  Future<void> loadMonth(
    DateTime month, {
    DateTime? ensureWeekForDay,
  }) async {
    _focusedDay = month;

    final monthsToLoad = <DateTime>{
      DateTime(month.year, month.month),
    };

    final weekAnchor = ensureWeekForDay ?? _selectedDay;
    final weekStart = weekAnchor.subtract(Duration(days: weekAnchor.weekday - DateTime.monday));
    final weekEnd = weekStart.add(const Duration(days: 6));

    void addMonth(DateTime date) {
      monthsToLoad.add(DateTime(date.year, date.month));
    }

    addMonth(weekStart);
    addMonth(weekEnd);

    DateTime cursor = DateTime(weekStart.year, weekStart.month);
    final lastMonth = DateTime(weekEnd.year, weekEnd.month);
    while (cursor.year < lastMonth.year ||
        (cursor.year == lastMonth.year && cursor.month < lastMonth.month)) {
      cursor = _nextMonth(cursor);
      monthsToLoad.add(cursor);
    }

    for (final monthKey in monthsToLoad) {
      final events = await _service.loadEventsForMonth(monthKey);

      final keysToRemove = _eventsByDay.keys
          .where((d) => d.year == monthKey.year && d.month == monthKey.month)
          .toList();
      for (final key in keysToRemove) {
        _eventsByDay.remove(key);
      }

      for (var ev in events) {
        final key = DateTime(ev.date.year, ev.date.month, ev.date.day);
        _eventsByDay.putIfAbsent(key, () => []).add(ev);
      }
    }
    notifyListeners();
  }

  /// Wählt den Tag [day], lädt bei Monatswechsel neu
  void selectDay(DateTime day) {
    _selectedDay = day;
    if (day.year != _focusedDay.year || day.month != _focusedDay.month) {
      loadMonth(day, ensureWeekForDay: day);
    } else {
      notifyListeners();
    }
  }

  /// Fügt einen Event hinzu und aktualisiert UI
  Future<void> addEvent(CalendarEvent event) async {
    await _service.addEvent(event);
    final key = DateTime(event.date.year, event.date.month, event.date.day);
    _eventsByDay.putIfAbsent(key, () => []).add(event);
    notifyListeners();
  }

  /// Entfernt einen Event mit [id] und aktualisiert UI
  Future<void> removeEvent(String id) async {
    for (var key in _eventsByDay.keys) {
      final list = _eventsByDay[key]!;
      final idx = list.indexWhere((ev) => ev.id == id);
      if (idx != -1) {
        await _service.removeEvent(id);
        list.removeAt(idx);
        notifyListeners();
        break;
      }
    }
  }

  /// Toggles the completed status of [event] and persists the change.
  Future<void> toggleCompleted(CalendarEvent event) async {
    final updated = event.copyWith(isCompleted: !event.isCompleted);
    await _service.saveTrainingDay(updated);
    final key = DateTime(updated.date.year, updated.date.month, updated.date.day);
    final list = _eventsByDay[key];
    if (list != null) {
      final idx = list.indexWhere((e) => e.id == event.id);
      if (idx != -1) {
        list[idx] = updated;
      }
    }
    notifyListeners();
  }


  /// Returns true if any event for [day] is marked completed.
  bool dayIsCompleted(DateTime day) {
    return eventsForDay(day).any((e) => e.isCompleted);
  }

  /// Toggles completion for the first event on [day] or creates one if none exist.
  Future<void> toggleDayCompleted(DateTime day) async {
    final key = DateTime(day.year, day.month, day.day);
    final list = _eventsByDay[key] ?? [];
    if (list.isEmpty) {
      final newEvent = CalendarEvent(
        id: 'manual_${day.toIso8601String()}',
        date: key,
        title: 'Training',
        isCompleted: true,
      );
      await _service.addEvent(newEvent);
      _eventsByDay.putIfAbsent(key, () => []).add(newEvent);
      notifyListeners();
      return;
    }

    await toggleCompleted(list.first);
  }

  /// Returns true when a day has been completed but no reflection has been saved yet.
  bool requiresReflection(DateTime day) {
    final events = eventsForDay(day);
    if (events.isEmpty) {
      return false;
    }
    final today = DateTime.now();
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);
    if (!normalizedDay.isBefore(normalizedToday)) {
      return false;
    }
    final hasCompletion = events.any((e) => e.isCompleted);
    final hasReflection = events.any((e) => e.notes.trim().isNotEmpty);
    return hasCompletion && !hasReflection;
  }

  DateTime _nextMonth(DateTime date) {
    if (date.month == 12) {
      return DateTime(date.year + 1, 1);
    }
    return DateTime(date.year, date.month + 1);
  }

}
