// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_state.dart';

_QuestionnaireState $QuestionnaireStateFromJson(Map<String, dynamic> json) =>
    _QuestionnaireState(
      currentIndex: json["currentIndex"] as int? ?? 0,
      answers: (json["answers"] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, $enumDecode(_$AnswerTypeEnumMap, e)),
          ) ??
          const <String, AnswerType>{},
      language: $enumDecodeNullable(
              _$QuestionnaireLanguageEnumMap, json["language"]) ??
          QuestionnaireLanguage.en,
    );

Map<String, dynamic> $QuestionnaireStateToJson(
        _QuestionnaireState instance) =>
    <String, dynamic>{
      'currentIndex': instance.currentIndex,
      'answers': instance.answers
          .map((k, e) => MapEntry(k, _$AnswerTypeEnumMap[e]!)),
      'language': _$QuestionnaireLanguageEnumMap[instance.language]!,
    };

const _$AnswerTypeEnumMap = {
  AnswerType.yes: 'yes',
  AnswerType.partly: 'partly',
  AnswerType.no: 'no',
};

const _$QuestionnaireLanguageEnumMap = {
  QuestionnaireLanguage.de: 'de',
  QuestionnaireLanguage.en: 'en',
};
