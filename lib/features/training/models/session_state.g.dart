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
      plannedFor: json['plannedFor'] == null
          ? null
          : DateTime.parse(json['plannedFor'] as String),
      status: $enumDecodeNullable(_$SessionStatusEnumMap, json['status']) ??
          SessionStatus.planned,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      xpTotal: (json['xpTotal'] as num?)?.toInt() ?? 0,
      dailyXp: (json['dailyXp'] as num?)?.toInt() ?? 0,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
      streakFrozenUntil: json['streakFrozenUntil'] == null
          ? null
          : DateTime.parse(json['streakFrozenUntil'] as String),
      lastCompletedOn: json['lastCompletedOn'] == null
          ? null
          : DateTime.parse(json['lastCompletedOn'] as String),
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
      'plannedFor': instance.plannedFor?.toIso8601String(),
      'status': _$SessionStatusEnumMap[instance.status]!,
      'onboardingComplete': instance.onboardingComplete,
      'xpTotal': instance.xpTotal,
      'dailyXp': instance.dailyXp,
      'streakCount': instance.streakCount,
      'streakFrozenUntil': instance.streakFrozenUntil?.toIso8601String(),
      'lastCompletedOn': instance.lastCompletedOn?.toIso8601String(),
    };

const _$SessionStatusEnumMap = {
  SessionStatus.inProgress: 'inProgress',
  SessionStatus.completed: 'completed',
  SessionStatus.planned: 'planned',
  SessionStatus.overdue: 'overdue',
};
