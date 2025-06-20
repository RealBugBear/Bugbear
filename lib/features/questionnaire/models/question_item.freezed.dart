// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'question_item.dart';

T _$identity<T>(T value) => value;

QuestionItem _$QuestionItemFromJson(Map<String, dynamic> json) {
  return _QuestionItem.fromJson(json);
}

mixin _$QuestionItem {
  String get id => throw _privateConstructorUsedError;
  List<String> get reflexKeys => throw _privateConstructorUsedError;
  List<String> get reflexNames => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get example => throw _privateConstructorUsedError;
  List<String> get sources => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestionItemCopyWith<QuestionItem> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $QuestionItemCopyWith<$Res> {
  factory $QuestionItemCopyWith(
          QuestionItem value, $Res Function(QuestionItem) then) =
      _$QuestionItemCopyWithImpl<$Res>;
  $Res call({
    String id,
    List<String> reflexKeys,
    List<String> reflexNames,
    String text,
    String example,
    List<String> sources,
  });
}

class _$QuestionItemCopyWithImpl<$Res> implements $QuestionItemCopyWith<$Res> {
  _$QuestionItemCopyWithImpl(this._value, this._then);

  final QuestionItem _value;
  final $Res Function(QuestionItem) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? reflexKeys = freezed,
    Object? reflexNames = freezed,
    Object? text = freezed,
    Object? example = freezed,
    Object? sources = freezed,
  }) {
    return _then(_QuestionItem(
      id: id == freezed ? _value.id : id as String,
      reflexKeys: reflexKeys == freezed
          ? _value.reflexKeys
          : reflexKeys as List<String>,
      reflexNames: reflexNames == freezed
          ? _value.reflexNames
          : reflexNames as List<String>,
      text: text == freezed ? _value.text : text as String,
      example: example == freezed ? _value.example : example as String,
      sources: sources == freezed ? _value.sources : sources as List<String>,
    ));
  }
}

@JsonSerializable()
class _QuestionItem implements QuestionItem {
  const _QuestionItem({
    required this.id,
    required this.reflexKeys,
    required this.reflexNames,
    required this.text,
    required this.example,
    required this.sources,
  });

  factory _QuestionItem.fromJson(Map<String, dynamic> json) =>
      _$QuestionItemFromJson(json);

  @override
  final String id;
  @override
  final List<String> reflexKeys;
  @override
  final List<String> reflexNames;
  @override
  final String text;
  @override
  final String example;
  @override
  final List<String> sources;

  @override
  String toString() {
    return 'QuestionItem(id: $id, reflexKeys: $reflexKeys, reflexNames: $reflexNames, text: $text, example: $example, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _QuestionItem &&
            other.id == id &&
            const DeepCollectionEquality().equals(other.reflexKeys, reflexKeys) &&
            const DeepCollectionEquality().equals(other.reflexNames, reflexNames) &&
            other.text == text &&
            other.example == example &&
            const DeepCollectionEquality().equals(other.sources, sources));
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        id,
        const DeepCollectionEquality().hash(reflexKeys),
        const DeepCollectionEquality().hash(reflexNames),
        text,
        example,
        const DeepCollectionEquality().hash(sources),
      );

  @JsonKey(ignore: true)
  @override
  $QuestionItemCopyWith<QuestionItem> get copyWith =>
      _$QuestionItemCopyWithImpl<QuestionItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuestionItemToJson(this);
  }
}
