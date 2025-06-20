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
