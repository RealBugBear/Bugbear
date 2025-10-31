import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Stores per-day training completion flags for the local progress view.
class ProgressStore extends ChangeNotifier {
  ProgressStore(this._box);

  final Box<bool> _box;

  /// Returns `true` if the given [day] was marked as completed.
  bool isDayCompleted(DateTime day) {
    final key = _keyFor(day);
    return _box.get(key, defaultValue: false) ?? false;
  }

  /// Sets the completion status for the given [day].
  Future<void> setDayCompleted(DateTime day, bool completed) async {
    final normalized = _normalize(day);
    final key = _keyFor(normalized);
    final current = _box.get(key, defaultValue: false) ?? false;
    if (current == completed) {
      return;
    }
    if (completed) {
      await _box.put(key, true);
    } else {
      await _box.delete(key);
    }
    notifyListeners();
  }

  /// Toggles the completion flag for [day].
  Future<void> toggleDayCompleted(DateTime day) async {
    final normalized = _normalize(day);
    final key = _keyFor(normalized);
    final current = _box.get(key, defaultValue: false) ?? false;
    if (current) {
      await _box.delete(key);
    } else {
      await _box.put(key, true);
    }
    notifyListeners();
  }

  /// Placeholder for potential reflection tracking.
  bool requiresReflection(DateTime day) => false;

  DateTime _normalize(DateTime day) => DateTime(day.year, day.month, day.day);

  String _keyFor(DateTime day) {
    final normalized = _normalize(day);
    final month = normalized.month.toString().padLeft(2, '0');
    final dayPart = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$dayPart';
  }
}
