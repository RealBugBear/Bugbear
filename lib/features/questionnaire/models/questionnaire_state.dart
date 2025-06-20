
enum Answer { yes, no, skipped }

class QuestionnaireState {
  final int index;
  final Map<String, Answer> answers;

  QuestionnaireState({
    required this.index,
    required Map<String, Answer> answers,
  }) : answers = Map<String, Answer>.from(answers);

  factory QuestionnaireState.fromJson(Map<String, dynamic> json) {
    final map = (json['answers'] as Map).cast<String, int>();
    final ans = map.map((k, v) => MapEntry(k, Answer.values[v]));
    return QuestionnaireState(index: json['index'] as int, answers: ans);
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'answers': answers.map((k, v) => MapEntry(k, v.index)),
      };

import 'package:freezed_annotation/freezed_annotation.dart';

part 'questionnaire_state.freezed.dart';
part 'questionnaire_state.g.dart';

enum QuestionnaireLanguage { de, en }

enum AnswerType { yes, partly, no }

@freezed
class QuestionnaireState with _$QuestionnaireState {
  const factory QuestionnaireState({
    @Default(0) int currentIndex,
    @Default(<String, AnswerType>{}) Map<String, AnswerType> answers,
    @Default(QuestionnaireLanguage.en) QuestionnaireLanguage language,
  }) = _QuestionnaireState;

  factory QuestionnaireState.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireStateFromJson(json);

}
