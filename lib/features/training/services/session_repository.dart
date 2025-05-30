// lib/features/training/services/session_repository.dart

import 'package:bugbear_app/features/training/models/session_state.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SessionRepository {
  static const String _boxName = 'session_state';
  static const String _key = 'current';

  Future<Box<SessionState>> _openBox() async =>
      Hive.box<SessionState>(_boxName);

  Future<SessionState?> load() async {
    final box = await _openBox();
    return box.get(_key);
  }

  Future<void> save(SessionState state) async {
    final box = await _openBox();
    await box.put(_key, state);
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_key);
  }
}
