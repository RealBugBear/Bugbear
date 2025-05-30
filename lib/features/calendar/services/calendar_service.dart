// lib/features/calendar/services/calendar_service.dart

import 'package:hive/hive.dart';
import 'package:bugbear_app/features/calendar/models/calendar_event.dart';

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
}
