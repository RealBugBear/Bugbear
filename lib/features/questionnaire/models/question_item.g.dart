// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_item.dart';

_QuestionItem _$QuestionItemFromJson(Map<String, dynamic> json) => _QuestionItem(
      id: json['id'] as String,
      reflexKeys:
          (json['reflexKeys'] as List<dynamic>).map((e) => e as String).toList(),
      reflexNames:
          (json['reflexNames'] as List<dynamic>).map((e) => e as String).toList(),
      text: json['text'] as String,
      example: json['example'] as String,
      sources:
          (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$QuestionItemToJson(_QuestionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reflexKeys': instance.reflexKeys,
      'reflexNames': instance.reflexNames,
      'text': instance.text,
      'example': instance.example,
      'sources': instance.sources,
    };
