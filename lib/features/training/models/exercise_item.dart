import 'package:freezed_annotation/freezed_annotation.dart';
part 'exercise_item.freezed.dart';
part 'exercise_item.g.dart';

@freezed
class ExerciseItem with _$ExerciseItem {
  const factory ExerciseItem({
    required String id,
    required String name,
    required String imagePath,
    @Default(8) int activeSeconds,
    @Default(4) int restSeconds,
    @Default(6) int repetitions,
    String? audioPath,
  }) = _ExerciseItem;

  factory ExerciseItem.fromJson(Map<String, dynamic> json) =>
      _$ExerciseItemFromJson(json);
}
