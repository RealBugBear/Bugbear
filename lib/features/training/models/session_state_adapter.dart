import 'package:hive/hive.dart';
import 'package:bugbear_app/features/training/models/session_state.dart';

class SessionStatusAdapter extends TypeAdapter<SessionStatus> {
  @override
  final int typeId = 0;

  @override
  SessionStatus read(BinaryReader reader) {
    final index = reader.readInt();
    return SessionStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, SessionStatus obj) {
    writer.writeInt(obj.index);
  }
}

class SessionStateAdapter extends TypeAdapter<SessionState> {
  @override
  final int typeId = 1;

  @override
  SessionState read(BinaryReader reader) {
    final phaseId = reader.readString();
    final exerciseIndex = reader.readInt();
    final completedReps = reader.readInt();
    final remainingSeconds = reader.readInt();
    final isPaused = reader.readBool();
    final startedAt = reader.read() as DateTime;

    final hasEndAt = reader.readBool();
    final endAt = hasEndAt ? reader.read() as DateTime : null;

    final status = reader.read() as SessionStatus;

    return SessionState(
      phaseId: phaseId,
      exerciseIndex: exerciseIndex,
      completedReps: completedReps,
      remainingSeconds: remainingSeconds,
      isPaused: isPaused,
      startedAt: startedAt,
      endAt: endAt,
      status: status,
    );
  }

  @override
  void write(BinaryWriter writer, SessionState obj) {
    writer.writeString(obj.phaseId);
    writer.writeInt(obj.exerciseIndex);
    writer.writeInt(obj.completedReps);
    writer.writeInt(obj.remainingSeconds);
    writer.writeBool(obj.isPaused);
    writer.write(obj.startedAt);

    if (obj.endAt != null) {
      writer.writeBool(true);
      writer.write(obj.endAt!);
    } else {
      writer.writeBool(false);
    }

    writer.write(obj.status);
  }
}
