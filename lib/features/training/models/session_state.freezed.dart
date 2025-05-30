// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SessionState _$SessionStateFromJson(Map<String, dynamic> json) {
  return _SessionState.fromJson(json);
}

/// @nodoc
mixin _$SessionState {
  String get phaseId => throw _privateConstructorUsedError;
  int get exerciseIndex => throw _privateConstructorUsedError;
  int get completedReps => throw _privateConstructorUsedError;
  int get remainingSeconds => throw _privateConstructorUsedError;
  bool get isPaused => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endAt => throw _privateConstructorUsedError;
  SessionStatus get status => throw _privateConstructorUsedError;

  /// Serializes this SessionState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionStateCopyWith<SessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionStateCopyWith<$Res> {
  factory $SessionStateCopyWith(
          SessionState value, $Res Function(SessionState) then) =
      _$SessionStateCopyWithImpl<$Res, SessionState>;
  @useResult
  $Res call(
      {String phaseId,
      int exerciseIndex,
      int completedReps,
      int remainingSeconds,
      bool isPaused,
      DateTime startedAt,
      DateTime? endAt,
      SessionStatus status});
}

/// @nodoc
class _$SessionStateCopyWithImpl<$Res, $Val extends SessionState>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phaseId = null,
    Object? exerciseIndex = null,
    Object? completedReps = null,
    Object? remainingSeconds = null,
    Object? isPaused = null,
    Object? startedAt = null,
    Object? endAt = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      phaseId: null == phaseId
          ? _value.phaseId
          : phaseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseIndex: null == exerciseIndex
          ? _value.exerciseIndex
          : exerciseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      completedReps: null == completedReps
          ? _value.completedReps
          : completedReps // ignore: cast_nullable_to_non_nullable
              as int,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: freezed == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionStateImplCopyWith<$Res>
    implements $SessionStateCopyWith<$Res> {
  factory _$$SessionStateImplCopyWith(
          _$SessionStateImpl value, $Res Function(_$SessionStateImpl) then) =
      __$$SessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String phaseId,
      int exerciseIndex,
      int completedReps,
      int remainingSeconds,
      bool isPaused,
      DateTime startedAt,
      DateTime? endAt,
      SessionStatus status});
}

/// @nodoc
class __$$SessionStateImplCopyWithImpl<$Res>
    extends _$SessionStateCopyWithImpl<$Res, _$SessionStateImpl>
    implements _$$SessionStateImplCopyWith<$Res> {
  __$$SessionStateImplCopyWithImpl(
      _$SessionStateImpl _value, $Res Function(_$SessionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phaseId = null,
    Object? exerciseIndex = null,
    Object? completedReps = null,
    Object? remainingSeconds = null,
    Object? isPaused = null,
    Object? startedAt = null,
    Object? endAt = freezed,
    Object? status = null,
  }) {
    return _then(_$SessionStateImpl(
      phaseId: null == phaseId
          ? _value.phaseId
          : phaseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseIndex: null == exerciseIndex
          ? _value.exerciseIndex
          : exerciseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      completedReps: null == completedReps
          ? _value.completedReps
          : completedReps // ignore: cast_nullable_to_non_nullable
              as int,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: freezed == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionStateImpl implements _SessionState {
  const _$SessionStateImpl(
      {required this.phaseId,
      required this.exerciseIndex,
      required this.completedReps,
      required this.remainingSeconds,
      this.isPaused = false,
      required this.startedAt,
      this.endAt,
      this.status = SessionStatus.inProgress});

  factory _$SessionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionStateImplFromJson(json);

  @override
  final String phaseId;
  @override
  final int exerciseIndex;
  @override
  final int completedReps;
  @override
  final int remainingSeconds;
  @override
  @JsonKey()
  final bool isPaused;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endAt;
  @override
  @JsonKey()
  final SessionStatus status;

  @override
  String toString() {
    return 'SessionState(phaseId: $phaseId, exerciseIndex: $exerciseIndex, completedReps: $completedReps, remainingSeconds: $remainingSeconds, isPaused: $isPaused, startedAt: $startedAt, endAt: $endAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStateImpl &&
            (identical(other.phaseId, phaseId) || other.phaseId == phaseId) &&
            (identical(other.exerciseIndex, exerciseIndex) ||
                other.exerciseIndex == exerciseIndex) &&
            (identical(other.completedReps, completedReps) ||
                other.completedReps == completedReps) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, phaseId, exerciseIndex,
      completedReps, remainingSeconds, isPaused, startedAt, endAt, status);

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStateImplCopyWith<_$SessionStateImpl> get copyWith =>
      __$$SessionStateImplCopyWithImpl<_$SessionStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionStateImplToJson(
      this,
    );
  }
}

abstract class _SessionState implements SessionState {
  const factory _SessionState(
      {required final String phaseId,
      required final int exerciseIndex,
      required final int completedReps,
      required final int remainingSeconds,
      final bool isPaused,
      required final DateTime startedAt,
      final DateTime? endAt,
      final SessionStatus status}) = _$SessionStateImpl;

  factory _SessionState.fromJson(Map<String, dynamic> json) =
      _$SessionStateImpl.fromJson;

  @override
  String get phaseId;
  @override
  int get exerciseIndex;
  @override
  int get completedReps;
  @override
  int get remainingSeconds;
  @override
  bool get isPaused;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endAt;
  @override
  SessionStatus get status;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionStateImplCopyWith<_$SessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
