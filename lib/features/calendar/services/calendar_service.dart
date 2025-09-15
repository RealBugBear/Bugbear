// lib/features/calendar/services/calendar_service.dart

import 'package:hive/hive.dart';
import 'package:free_base/features/calendar/models/calendar_event.dart';

/// CalendarService
///
/// Verwaltet CalendarEvent-Objekte in der Hive-Box 'calendar_events'.
/// Bietet Methoden zum Laden, Hinzufügen, Entfernen und Speichern einzelner Tage.
class CalendarService {
  static const String _boxName = 'calendar_events';

  Box<CalendarEvent> get _calendarBox => Hive.box<CalendarEvent>(_boxName);

  /// Lädt alle Events eines Monats [month], sortiert nach Datum.
  Future<List<CalendarEvent>> loadEventsForMonth(DateTime month) async {
    final list = _calendarBox.values
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Fügt oder überschreibt einen Event.
  Future<void> addEvent(CalendarEvent event) async {
    await _calendarBox.put(event.id, event);
  }

  /// Entfernt einen Event anhand seiner [id].
  Future<void> removeEvent(String id) async {
    await _calendarBox.delete(id);
  }

  /// Speichert Änderungen an einem einzelnen Tag [event].
  Future<void> saveTrainingDay(CalendarEvent event) async {
    await _calendarBox.put(event.id, event);
  }

  /// Returns the next golden day on or after today, or `null` if none exist.
  Future<DateTime?> loadUpcomingGoldenDay() async {
    final goldenEvents = _calendarBox.values
        .where((e) => e.isGoldenDay)
        .toList();
    if (goldenEvents.isEmpty) return null;
    goldenEvents.sort((a, b) => a.date.compareTo(b.date));
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    for (final ev in goldenEvents) {
      if (!ev.date.isBefore(dayStart)) return ev.date;
    }
    return goldenEvents.last.date;
  }
}
