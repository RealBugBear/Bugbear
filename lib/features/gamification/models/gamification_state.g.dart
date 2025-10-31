// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GamificationStateAdapter extends TypeAdapter<GamificationState> {
  @override
  final int typeId = 4;

  @override
  GamificationState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GamificationState(
      level: fields[0] as int? ?? 1,
      nextThreshold: fields[1] as int? ?? 100,
      freezeTokens: fields[2] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, GamificationState obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.level)
      ..writeByte(1)
      ..write(obj.nextThreshold)
      ..writeByte(2)
      ..write(obj.freezeTokens);
  }
}
