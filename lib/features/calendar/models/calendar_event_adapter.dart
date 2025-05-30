// lib/features/calendar/models/calendar_event_adapter.dart

import 'package:hive/hive.dart';
import 'calendar_event.dart';

/// Hive-Adapter für CalendarEvent.
/// Schreibt und liest alle Felder:
/// 0=id, 1=date, 2=title, 3=isCompleted, 4=isGoldenDay, 5=notes
class CalendarEventAdapter extends TypeAdapter<CalendarEvent> {
  @override
  final int typeId = 2;

  @override
  CalendarEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return CalendarEvent(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      title: fields[2] as String,
      isCompleted: fields[3] as bool,
      isGoldenDay: fields[4] as bool? ?? false,
      notes: fields[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, CalendarEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.isGoldenDay)
      ..writeByte(5)
      ..write(obj.notes);
  }
}
