// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionStateImpl _$$SessionStateImplFromJson(Map<String, dynamic> json) =>
    _$SessionStateImpl(
      phaseId: json['phaseId'] as String,
      exerciseIndex: (json['exerciseIndex'] as num).toInt(),
      completedReps: (json['completedReps'] as num).toInt(),
      remainingSeconds: (json['remainingSeconds'] as num).toInt(),
      isPaused: json['isPaused'] as bool? ?? false,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endAt: json['endAt'] == null
          ? null
          : DateTime.parse(json['endAt'] as String),
      status: $enumDecodeNullable(_$SessionStatusEnumMap, json['status']) ??
          SessionStatus.inProgress,
    );

Map<String, dynamic> _$$SessionStateImplToJson(_$SessionStateImpl instance) =>
    <String, dynamic>{
      'phaseId': instance.phaseId,
      'exerciseIndex': instance.exerciseIndex,
      'completedReps': instance.completedReps,
      'remainingSeconds': instance.remainingSeconds,
      'isPaused': instance.isPaused,
      'startedAt': instance.startedAt.toIso8601String(),
      'endAt': instance.endAt?.toIso8601String(),
      'status': _$SessionStatusEnumMap[instance.status]!,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.inProgress: 'inProgress',
  SessionStatus.completed: 'completed',
};
