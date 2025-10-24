import 'package:hive/hive.dart';

/// Stores per-exercise speed offsets (0..3) with clamping.
class MoroSpeedStore {
  static const _box = 'moro_speed_offsets'; // Map<String,int>

  static Future<int> getOffsetForExercise(int exerciseIndex) async {
    final b = await Hive.openBox(_box);
    final map = (b.get('offsets') as Map?)?.cast<String, int>() ?? <String, int>{};
    final v = map['$exerciseIndex'] ?? 0;
    return v.clamp(0, 3);
  }

  static Future<void> setOffsetForExercise(int exerciseIndex, int offsetSec) async {
    final b = await Hive.openBox(_box);
    final map = (b.get('offsets') as Map?)?.cast<String, int>() ?? <String, int>{};
    map['$exerciseIndex'] = offsetSec.clamp(0, 3);
    await b.put('offsets', map);
  }
}
