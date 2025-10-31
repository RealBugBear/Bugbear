import 'package:hive/hive.dart';
import 'package:free_base/features/training/models/session_state.dart';

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

    DateTime? plannedFor;
    bool onboardingComplete = false;
    int xpTotal = 0;
    int dailyXp = 0;
    int streakCount = 0;
    DateTime? streakFrozenUntil;
    DateTime? lastCompletedOn;
    if (reader.availableBytes > 0) {
      final hasPlannedFor = reader.readBool();
      plannedFor = hasPlannedFor ? reader.read() as DateTime : null;
    }

    if (reader.availableBytes > 0) {
      onboardingComplete = reader.readBool();
    }

    if (reader.availableBytes > 0) {
      xpTotal = reader.readInt();
    }

    if (reader.availableBytes > 0) {
      dailyXp = reader.readInt();
    }

    if (reader.availableBytes > 0) {
      streakCount = reader.readInt();
    }

    if (reader.availableBytes > 0) {
      final hasFrozenUntil = reader.readBool();
      streakFrozenUntil = hasFrozenUntil ? reader.read() as DateTime : null;
    }

    if (reader.availableBytes > 0) {
      final hasLastCompleted = reader.readBool();
      lastCompletedOn = hasLastCompleted ? reader.read() as DateTime : null;
    }

    return SessionState(
      phaseId: phaseId,
      exerciseIndex: exerciseIndex,
      completedReps: completedReps,
      remainingSeconds: remainingSeconds,
      isPaused: isPaused,
      startedAt: startedAt,
      endAt: endAt,
      status: status,
      plannedFor: plannedFor,
      onboardingComplete: onboardingComplete,
      xpTotal: xpTotal,
      dailyXp: dailyXp,
      streakCount: streakCount,
      streakFrozenUntil: streakFrozenUntil,
      lastCompletedOn: lastCompletedOn,
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

    if (obj.plannedFor != null) {
      writer.writeBool(true);
      writer.write(obj.plannedFor!);
    } else {
      writer.writeBool(false);
    }

    writer.writeBool(obj.onboardingComplete);
    writer.writeInt(obj.xpTotal);
    writer.writeInt(obj.dailyXp);
    writer.writeInt(obj.streakCount);

    if (obj.streakFrozenUntil != null) {
      writer.writeBool(true);
      writer.write(obj.streakFrozenUntil!);
    } else {
      writer.writeBool(false);
    }

    if (obj.lastCompletedOn != null) {
      writer.writeBool(true);
      writer.write(obj.lastCompletedOn!);
    } else {
      writer.writeBool(false);
    }
  }
}
