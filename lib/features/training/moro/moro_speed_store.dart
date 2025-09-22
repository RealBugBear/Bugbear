import 'package:hive/hive.dart';

class MoroSpeedStore {
  static const _boxName = 'moro_speed_offsets';
  static const _offsetsKey = 'offsets';

  static Future<int> getOffsetForExercise(int exerciseIndex) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_offsetsKey);
    if (raw is Map) {
      final entry = raw['$exerciseIndex'];
      if (entry is int) {
        return entry;
      }
      if (entry is num) {
        return entry.toInt();
      }
    }
    return 0;
  }

  static Future<void> setOffsetForExercise(int exerciseIndex, int offsetSec) async {
    final box = await Hive.openBox(_boxName);
    final dynamic raw = box.get(_offsetsKey);
    final Map<String, int> map = {};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is int) {
          map[key.toString()] = value;
        } else if (value is num) {
          map[key.toString()] = value.toInt();
        }
      });
    }
    final clamped = offsetSec < 0
        ? 0
        : offsetSec > 3
            ? 3
            : offsetSec;
    map['$exerciseIndex'] = clamped;
    await box.put(_offsetsKey, map);
  }
}
