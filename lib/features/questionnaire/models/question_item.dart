import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_item.freezed.dart';
part 'question_item.g.dart';

@freezed
class QuestionItem with _$QuestionItem {
  const factory QuestionItem({
    required String id,
    required List<String> reflexKeys,
    required List<String> reflexNames,
    required String text,
    required String example,
    required List<String> sources,
  }) = _QuestionItem;

  factory QuestionItem.fromJson(Map<String, dynamic> json) =>
      _$QuestionItemFromJson(json);
}
