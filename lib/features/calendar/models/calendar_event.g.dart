// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEventImpl _$$CalendarEventImplFromJson(Map<String, dynamic> json) =>
    _$CalendarEventImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      isGoldenDay: json['isGoldenDay'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$$CalendarEventImplToJson(_$CalendarEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'isCompleted': instance.isCompleted,
      'isGoldenDay': instance.isGoldenDay,
      'notes': instance.notes,
    };
