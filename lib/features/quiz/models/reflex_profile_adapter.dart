import 'package:hive/hive.dart';
import 'reflex_profile.dart';

class ReflexProfileAdapter extends TypeAdapter<ReflexProfile> {
  @override
  final int typeId = 3;

  @override
  ReflexProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final Map map = fields[0] as Map;
    final scores = map.map((k, v) => MapEntry(k as String, (v as num).toDouble()));
    final created = fields[1] as DateTime;
    return ReflexProfile(scores: scores, createdAt: created);
  }

  @override
  void write(BinaryWriter writer, ReflexProfile obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.scores)
      ..writeByte(1)
      ..write(obj.createdAt);
  }
}
