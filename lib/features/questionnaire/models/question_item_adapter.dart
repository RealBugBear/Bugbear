import 'package:hive/hive.dart';
import 'package:bugbear_app/features/questionnaire/models/question_item.dart';
import 'question_item.dart';


class QuestionItemAdapter extends TypeAdapter<QuestionItem> {
  @override
  final int typeId = 3;

  @override
  QuestionItem read(BinaryReader reader) {
    final id = reader.readString();
    final reflexKeys = (reader.readList() as List).cast<String>();
    final reflexNames = (reader.readList() as List).cast<String>();
    final text = reader.readString();
    final example = reader.readString();
    final sources = (reader.readList() as List).cast<String>();
    return QuestionItem(
      id: id,
      reflexKeys: reflexKeys,
      reflexNames: reflexNames,
      text: text,
      example: example,
      sources: sources,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionItem obj) {
    writer
      ..writeString(obj.id)
      ..writeList(obj.reflexKeys)
      ..writeList(obj.reflexNames)
      ..writeString(obj.text)
      ..writeString(obj.example)
      ..writeList(obj.sources);
  }
}
