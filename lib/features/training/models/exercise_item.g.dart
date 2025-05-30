// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseItemImpl _$$ExerciseItemImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
      activeSeconds: (json['activeSeconds'] as num?)?.toInt() ?? 8,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 4,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 6,
      audioPath: json['audioPath'] as String?,
    );

Map<String, dynamic> _$$ExerciseItemImplToJson(_$ExerciseItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imagePath': instance.imagePath,
      'activeSeconds': instance.activeSeconds,
      'restSeconds': instance.restSeconds,
      'repetitions': instance.repetitions,
      'audioPath': instance.audioPath,
    };
