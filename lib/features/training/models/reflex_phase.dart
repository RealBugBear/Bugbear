import 'package:freezed_annotation/freezed_annotation.dart';
part 'reflex_phase.freezed.dart';
part 'reflex_phase.g.dart';

@freezed
class ReflexPhase with _$ReflexPhase {
  const factory ReflexPhase({
    required String id,
    required String name,
    required int totalExercises,
    required String iconPath,
  }) = _ReflexPhase;

  factory ReflexPhase.fromJson(Map<String, dynamic> json) =>
      _$ReflexPhaseFromJson(json);
}
