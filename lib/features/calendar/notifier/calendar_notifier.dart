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

  /// Lädt alle Events des Monats [month]
  Future<void> loadMonth(DateTime month) async {
    _focusedDay = month;
    final events = await _service.loadEventsForMonth(month);
    _eventsByDay.clear();
    for (var ev in events) {
      final key = DateTime(ev.date.year, ev.date.month, ev.date.day);
      _eventsByDay.putIfAbsent(key, () => []).add(ev);
    }
    notifyListeners();
  }

  /// Wählt den Tag [day], lädt bei Monatswechsel neu
  void selectDay(DateTime day) {
    _selectedDay = day;
    if (day.year != _focusedDay.year || day.month != _focusedDay.month) {
      loadMonth(day);
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
}
