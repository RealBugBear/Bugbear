import 'package:freezed_annotation/freezed_annotation.dart';
part 'session_state.freezed.dart';
part 'session_state.g.dart';

enum SessionStatus { inProgress, completed }

@freezed
class SessionState with _$SessionState {
  const factory SessionState({
    required String phaseId,
    required int exerciseIndex,
    required int completedReps,
    required int remainingSeconds,
    @Default(false) bool isPaused,
    required DateTime startedAt,
    DateTime? endAt,
    @Default(SessionStatus.inProgress) SessionStatus status,
  }) = _SessionState;

  factory SessionState.fromJson(Map<String, dynamic> json) =>
      _$SessionStateFromJson(json);
}
