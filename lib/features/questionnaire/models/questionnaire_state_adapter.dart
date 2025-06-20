import 'package:hive/hive.dart';

import 'package:bugbear_app/features/questionnaire/models/questionnaire_state.dart';

class AnswerTypeAdapter extends TypeAdapter<AnswerType> {
  @override
  final int typeId = 4;

  @override
  AnswerType read(BinaryReader reader) {
    final index = reader.readInt();
    return AnswerType.values[index];
  }

  @override
  void write(BinaryWriter writer, AnswerType obj) {
    writer.writeInt(obj.index);
  }
}

class QuestionnaireLanguageAdapter extends TypeAdapter<QuestionnaireLanguage> {
  @override
  final int typeId = 5;

  @override
  QuestionnaireLanguage read(BinaryReader reader) {
    final index = reader.readInt();
    return QuestionnaireLanguage.values[index];
  }

  @override
  void write(BinaryWriter writer, QuestionnaireLanguage obj) {
    writer.writeInt(obj.index);
  }
}

class QuestionnaireStateAdapter extends TypeAdapter<QuestionnaireState> {
  @override
  final int typeId = 6;

  @override
  QuestionnaireState read(BinaryReader reader) {
    final currentIndex = reader.readInt();
    final answerCount = reader.readInt();
    final answers = <String, AnswerType>{};
    for (var i = 0; i < answerCount; i++) {
      final key = reader.readString();
      final value = AnswerType.values[reader.readInt()];
      answers[key] = value;
    }
    final language = QuestionnaireLanguage.values[reader.readInt()];
    return QuestionnaireState(
      currentIndex: currentIndex,
      answers: answers,
      language: language,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionnaireState obj) {
    writer
      ..writeInt(obj.currentIndex)
      ..writeInt(obj.answers.length);
    obj.answers.forEach((key, value) {
      writer
        ..writeString(key)
        ..writeInt(value.index);
    });
    writer.writeInt(obj.language.index);
  }
}
