// lib/features/calendar/models/calendar_event.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bugbear_app/features/training/models/session_state.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

/// CalendarEvent
///
/// Modell für einen einzelnen Eintrag im Trainingskalender.
/// Wird in Hive persistiert und im UI dargestellt.
///
/// Felder:
/// - id: Einzigartige Kennung, z. B. 'phaseId_ISOtime'
/// - date: Datum (Jahr/Monat/Tag)
/// - title: Bezeichnung, z. B. 'Phase 3'
/// - isCompleted: true = abgeschlossen
/// - isGoldenDay: true = Golden Day
/// - notes: Freitext-Notiz (max. 500 Zeichen)
@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required DateTime date,
    required String title,
    required bool isCompleted,
    @Default(false) bool isGoldenDay,
    @Default('') String notes,
  }) = _CalendarEvent;

  /// JSON-Serialisierung
  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  /// Erzeugt einen Kalender-Eintrag aus einer SessionState-Instanz.
  factory CalendarEvent.fromSession(SessionState session) {
    return CalendarEvent(
      id: '${session.phaseId}_${session.startedAt.toIso8601String()}',
      date: DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      ),
      title: 'Phase ${session.phaseId}',
      isCompleted: session.status == SessionStatus.completed,
      isGoldenDay: false,
      notes: '',
    );
  }
}
