import 'package:hive/hive.dart';

/// Persists the consent acceptance state for the current device/user.
///
/// The values are stored in the encrypted `user_settings` Hive box so they
/// survive offline sessions and can be evaluated during routing guards.
class ConsentState {
  static const hiveTypeId = 3;

  final bool accepted;
  final DateTime? acceptedAt;
  final String locale;

  const ConsentState({
    required this.accepted,
    this.acceptedAt,
    required this.locale,
  });

  ConsentState copyWith({
    bool? accepted,
    DateTime? acceptedAt,
    String? locale,
  }) {
    return ConsentState(
      accepted: accepted ?? this.accepted,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      locale: locale ?? this.locale,
    );
  }
}

class ConsentStateAdapter extends TypeAdapter<ConsentState> {
  @override
  final int typeId = ConsentState.hiveTypeId;

  @override
  ConsentState read(BinaryReader reader) {
    final accepted = reader.readBool();
    final hasAcceptedAt = reader.readBool();
    final acceptedAt = hasAcceptedAt ? reader.read() as DateTime : null;
    final locale = reader.readString();
    return ConsentState(
      accepted: accepted,
      acceptedAt: acceptedAt,
      locale: locale,
    );
  }

  @override
  void write(BinaryWriter writer, ConsentState obj) {
    writer
      ..writeBool(obj.accepted)
      ..writeBool(obj.acceptedAt != null);
    if (obj.acceptedAt != null) {
      writer.write(obj.acceptedAt!);
    }
    writer.writeString(obj.locale);
  }
}
