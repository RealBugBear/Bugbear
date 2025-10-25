import 'dart:convert';

import 'package:hive/hive.dart';

class MoroProgressData {
  final int highestUnlocked;
  final Set<int> completed;

  const MoroProgressData({
    required this.highestUnlocked,
    required this.completed,
  });
}

class MoroProgressStore {
  static const _boxName = 'moro_progress';
  static const _progressKey = 'progress';

  static Future<MoroProgressData> load({int totalExercises = 7}) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_progressKey) as String?;
    if (raw == null) {
      return MoroProgressData(highestUnlocked: 1, completed: <int>{});
    }
    try {
      final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
      final highest = map['highestUnlocked'] as int? ?? 1;
      final completed = ((map['completed'] as List?) ?? const [])
          .map((e) => e as int)
          .where((idx) => idx >= 1 && idx <= totalExercises)
          .toSet();
      final unlocked = highest.clamp(1, totalExercises);
      return MoroProgressData(highestUnlocked: unlocked, completed: completed);
    } catch (_) {
      return MoroProgressData(highestUnlocked: 1, completed: <int>{});
    }
  }

  static Future<void> reset() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_progressKey);
  }

  static Future<void> markCompleted(int exerciseIndex, int totalExercises) async {
    final box = await Hive.openBox(_boxName);
    final current = await load(totalExercises: totalExercises);
    final completed = {...current.completed, exerciseIndex};
    final nextUnlocked = (exerciseIndex + 1).clamp(1, totalExercises);
    final highest = current.highestUnlocked < nextUnlocked
        ? nextUnlocked
        : current.highestUnlocked;
    final payload = jsonEncode({
      'highestUnlocked': highest,
      'completed': completed.toList(),
    });
    await box.put(_progressKey, payload);
  }
}
