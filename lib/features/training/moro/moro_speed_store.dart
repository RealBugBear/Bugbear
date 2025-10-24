import 'package:hive/hive.dart';

class MoroSpeedStore {
  static const _boxName = 'moro_speed_offsets';
  static const _offsetsKey = 'offsets';

  static Future<Box<dynamic>> _openBox() => Hive.openBox<dynamic>(_boxName);

  static int _sanitizeOffset(num value) => value.clamp(0, 3).toInt();

  static Map<String, int> _readOffsets(Box<dynamic> box) {
    final raw = box.get(_offsetsKey);
    if (raw is Map) {
      final result = <String, int>{};
      raw.forEach((key, value) {
        if (value is num) {
          result[key.toString()] = _sanitizeOffset(value);
        }
      });
      return result;
    }
    return <String, int>{};
  }

  static Future<int> getOffsetForExercise(int exerciseIndex) async {
    final box = await _openBox();
    final offsets = _readOffsets(box);
    final value = offsets['$exerciseIndex'];
    return value ?? 0;
  }

  static Future<void> setOffsetForExercise(int exerciseIndex, int offsetSec) async {
    final box = await _openBox();
    final offsets = _readOffsets(box);
    offsets['$exerciseIndex'] = _sanitizeOffset(offsetSec);
    await box.put(_offsetsKey, offsets);
  }
}
