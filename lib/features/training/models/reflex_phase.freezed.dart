// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reflex_phase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReflexPhase _$ReflexPhaseFromJson(Map<String, dynamic> json) {
  return _ReflexPhase.fromJson(json);
}

/// @nodoc
mixin _$ReflexPhase {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get totalExercises => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;

  /// Serializes this ReflexPhase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReflexPhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReflexPhaseCopyWith<ReflexPhase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReflexPhaseCopyWith<$Res> {
  factory $ReflexPhaseCopyWith(
          ReflexPhase value, $Res Function(ReflexPhase) then) =
      _$ReflexPhaseCopyWithImpl<$Res, ReflexPhase>;
  @useResult
  $Res call({String id, String name, int totalExercises, String iconPath});
}

/// @nodoc
class _$ReflexPhaseCopyWithImpl<$Res, $Val extends ReflexPhase>
    implements $ReflexPhaseCopyWith<$Res> {
  _$ReflexPhaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReflexPhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? totalExercises = null,
    Object? iconPath = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      totalExercises: null == totalExercises
          ? _value.totalExercises
          : totalExercises // ignore: cast_nullable_to_non_nullable
              as int,
      iconPath: null == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReflexPhaseImplCopyWith<$Res>
    implements $ReflexPhaseCopyWith<$Res> {
  factory _$$ReflexPhaseImplCopyWith(
          _$ReflexPhaseImpl value, $Res Function(_$ReflexPhaseImpl) then) =
      __$$ReflexPhaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int totalExercises, String iconPath});
}

/// @nodoc
class __$$ReflexPhaseImplCopyWithImpl<$Res>
    extends _$ReflexPhaseCopyWithImpl<$Res, _$ReflexPhaseImpl>
    implements _$$ReflexPhaseImplCopyWith<$Res> {
  __$$ReflexPhaseImplCopyWithImpl(
      _$ReflexPhaseImpl _value, $Res Function(_$ReflexPhaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReflexPhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? totalExercises = null,
    Object? iconPath = null,
  }) {
    return _then(_$ReflexPhaseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      totalExercises: null == totalExercises
          ? _value.totalExercises
          : totalExercises // ignore: cast_nullable_to_non_nullable
              as int,
      iconPath: null == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReflexPhaseImpl implements _ReflexPhase {
  const _$ReflexPhaseImpl(
      {required this.id,
      required this.name,
      required this.totalExercises,
      required this.iconPath});

  factory _$ReflexPhaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReflexPhaseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int totalExercises;
  @override
  final String iconPath;

  @override
  String toString() {
    return 'ReflexPhase(id: $id, name: $name, totalExercises: $totalExercises, iconPath: $iconPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReflexPhaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.totalExercises, totalExercises) ||
                other.totalExercises == totalExercises) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, totalExercises, iconPath);

  /// Create a copy of ReflexPhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReflexPhaseImplCopyWith<_$ReflexPhaseImpl> get copyWith =>
      __$$ReflexPhaseImplCopyWithImpl<_$ReflexPhaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReflexPhaseImplToJson(
      this,
    );
  }
}

abstract class _ReflexPhase implements ReflexPhase {
  const factory _ReflexPhase(
      {required final String id,
      required final String name,
      required final int totalExercises,
      required final String iconPath}) = _$ReflexPhaseImpl;

  factory _ReflexPhase.fromJson(Map<String, dynamic> json) =
      _$ReflexPhaseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get totalExercises;
  @override
  String get iconPath;

  /// Create a copy of ReflexPhase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReflexPhaseImplCopyWith<_$ReflexPhaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
