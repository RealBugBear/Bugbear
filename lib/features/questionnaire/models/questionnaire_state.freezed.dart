// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'questionnaire_state.dart';

T _$identity<T>(T value) => value;

QuestionnaireState _$QuestionnaireStateFromJson(Map<String, dynamic> json) {
  return _QuestionnaireState.fromJson(json);
}

mixin _$QuestionnaireState {
  int get currentIndex => throw _privateConstructorUsedError;
  Map<String, AnswerType> get answers => throw _privateConstructorUsedError;
  QuestionnaireLanguage get language => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestionnaireStateCopyWith<QuestionnaireState> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $QuestionnaireStateCopyWith<$Res> {
  factory $QuestionnaireStateCopyWith(
          QuestionnaireState value, $Res Function(QuestionnaireState) then) =
      _$QuestionnaireStateCopyWithImpl<$Res>;
  $Res call({
    int currentIndex,
    Map<String, AnswerType> answers,
    QuestionnaireLanguage language,
  });
}

class _$QuestionnaireStateCopyWithImpl<$Res>
    implements $QuestionnaireStateCopyWith<$Res> {
  _$QuestionnaireStateCopyWithImpl(this._value, this._then);

  final QuestionnaireState _value;
  final $Res Function(QuestionnaireState) _then;

  @override
  $Res call({
    Object? currentIndex = freezed,
    Object? answers = freezed,
    Object? language = freezed,
  }) {
    return _then(_QuestionnaireState(
      currentIndex: currentIndex == freezed
          ? _value.currentIndex
          : currentIndex as int,
      answers: answers == freezed
          ? _value.answers
          : answers as Map<String, AnswerType>,
      language:
          language == freezed ? _value.language : language as QuestionnaireLanguage,
    ));
  }
}

@JsonSerializable()
class _QuestionnaireState implements QuestionnaireState {
  const _QuestionnaireState({
    this.currentIndex = 0,
    this.answers = const <String, AnswerType>{},
    this.language = QuestionnaireLanguage.en,
  });

  factory _QuestionnaireState.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireStateFromJson(json);

  @override
  @JsonKey()
  final int currentIndex;
  @override
  @JsonKey()
  final Map<String, AnswerType> answers;
  @override
  @JsonKey()
  final QuestionnaireLanguage language;

  @override
  String toString() {
    return 'QuestionnaireState(currentIndex: $currentIndex, answers: $answers, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _QuestionnaireState &&
            other.currentIndex == currentIndex &&
            const DeepCollectionEquality().equals(other.answers, answers) &&
            other.language == language);
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentIndex,
      const DeepCollectionEquality().hash(answers), language);

  @JsonKey(ignore: true)
  @override
  $QuestionnaireStateCopyWith<QuestionnaireState> get copyWith =>
      _$QuestionnaireStateCopyWithImpl<QuestionnaireState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuestionnaireStateToJson(this);
  }
}
