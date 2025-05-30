// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflex_phase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReflexPhaseImpl _$$ReflexPhaseImplFromJson(Map<String, dynamic> json) =>
    _$ReflexPhaseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      totalExercises: (json['totalExercises'] as num).toInt(),
      iconPath: json['iconPath'] as String,
    );

Map<String, dynamic> _$$ReflexPhaseImplToJson(_$ReflexPhaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'totalExercises': instance.totalExercises,
      'iconPath': instance.iconPath,
    };
