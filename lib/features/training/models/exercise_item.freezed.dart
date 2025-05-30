// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseItem _$ExerciseItemFromJson(Map<String, dynamic> json) {
  return _ExerciseItem.fromJson(json);
}

/// @nodoc
mixin _$ExerciseItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  int get activeSeconds => throw _privateConstructorUsedError;
  int get restSeconds => throw _privateConstructorUsedError;
  int get repetitions => throw _privateConstructorUsedError;
  String? get audioPath => throw _privateConstructorUsedError;

  /// Serializes this ExerciseItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseItemCopyWith<ExerciseItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseItemCopyWith<$Res> {
  factory $ExerciseItemCopyWith(
          ExerciseItem value, $Res Function(ExerciseItem) then) =
      _$ExerciseItemCopyWithImpl<$Res, ExerciseItem>;
  @useResult
  $Res call(
      {String id,
      String name,
      String imagePath,
      int activeSeconds,
      int restSeconds,
      int repetitions,
      String? audioPath});
}

/// @nodoc
class _$ExerciseItemCopyWithImpl<$Res, $Val extends ExerciseItem>
    implements $ExerciseItemCopyWith<$Res> {
  _$ExerciseItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imagePath = null,
    Object? activeSeconds = null,
    Object? restSeconds = null,
    Object? repetitions = null,
    Object? audioPath = freezed,
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
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      activeSeconds: null == activeSeconds
          ? _value.activeSeconds
          : activeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      audioPath: freezed == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseItemImplCopyWith<$Res>
    implements $ExerciseItemCopyWith<$Res> {
  factory _$$ExerciseItemImplCopyWith(
          _$ExerciseItemImpl value, $Res Function(_$ExerciseItemImpl) then) =
      __$$ExerciseItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String imagePath,
      int activeSeconds,
      int restSeconds,
      int repetitions,
      String? audioPath});
}

/// @nodoc
class __$$ExerciseItemImplCopyWithImpl<$Res>
    extends _$ExerciseItemCopyWithImpl<$Res, _$ExerciseItemImpl>
    implements _$$ExerciseItemImplCopyWith<$Res> {
  __$$ExerciseItemImplCopyWithImpl(
      _$ExerciseItemImpl _value, $Res Function(_$ExerciseItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExerciseItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imagePath = null,
    Object? activeSeconds = null,
    Object? restSeconds = null,
    Object? repetitions = null,
    Object? audioPath = freezed,
  }) {
    return _then(_$ExerciseItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      activeSeconds: null == activeSeconds
          ? _value.activeSeconds
          : activeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      audioPath: freezed == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseItemImpl implements _ExerciseItem {
  const _$ExerciseItemImpl(
      {required this.id,
      required this.name,
      required this.imagePath,
      this.activeSeconds = 8,
      this.restSeconds = 4,
      this.repetitions = 6,
      this.audioPath});

  factory _$ExerciseItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String imagePath;
  @override
  @JsonKey()
  final int activeSeconds;
  @override
  @JsonKey()
  final int restSeconds;
  @override
  @JsonKey()
  final int repetitions;
  @override
  final String? audioPath;

  @override
  String toString() {
    return 'ExerciseItem(id: $id, name: $name, imagePath: $imagePath, activeSeconds: $activeSeconds, restSeconds: $restSeconds, repetitions: $repetitions, audioPath: $audioPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.activeSeconds, activeSeconds) ||
                other.activeSeconds == activeSeconds) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.audioPath, audioPath) ||
                other.audioPath == audioPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, imagePath,
      activeSeconds, restSeconds, repetitions, audioPath);

  /// Create a copy of ExerciseItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseItemImplCopyWith<_$ExerciseItemImpl> get copyWith =>
      __$$ExerciseItemImplCopyWithImpl<_$ExerciseItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseItemImplToJson(
      this,
    );
  }
}

abstract class _ExerciseItem implements ExerciseItem {
  const factory _ExerciseItem(
      {required final String id,
      required final String name,
      required final String imagePath,
      final int activeSeconds,
      final int restSeconds,
      final int repetitions,
      final String? audioPath}) = _$ExerciseItemImpl;

  factory _ExerciseItem.fromJson(Map<String, dynamic> json) =
      _$ExerciseItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get imagePath;
  @override
  int get activeSeconds;
  @override
  int get restSeconds;
  @override
  int get repetitions;
  @override
  String? get audioPath;

  /// Create a copy of ExerciseItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseItemImplCopyWith<_$ExerciseItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
