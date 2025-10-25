import 'dart:convert';

import 'package:hive/hive.dart';

class MoroLogEntry {
  final DateTime timestamp;
  final int exerciseIndex;
  final int tension;
  final int pain;
  final String? notes;

  const MoroLogEntry({
    required this.timestamp,
    required this.exerciseIndex,
    required this.tension,
    required this.pain,
    this.notes,
  });
}

class MoroLogStore {
  static const _boxName = 'moro_logs';
  static const _entriesKey = 'entries';

  static Future<void> addEntry(MoroLogEntry entry) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_entriesKey) as String?;
    final list = <Map<String, dynamic>>[];
    if (raw != null) {
      try {
        final parsed = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        list.addAll(parsed);
      } catch (_) {
        list.clear();
      }
    }
    list.add({
      'timestamp': entry.timestamp.toIso8601String(),
      'exerciseIndex': entry.exerciseIndex,
      'tension': entry.tension,
      'pain': entry.pain,
      'notes': entry.notes,
    });
    await box.put(_entriesKey, jsonEncode(list));
  }

  static Future<List<MoroLogEntry>> loadEntries({int? exerciseIndex}) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_entriesKey) as String?;
    if (raw == null) return const [];
    try {
      final parsed = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final entries = parsed.map((e) {
        return MoroLogEntry(
          timestamp: DateTime.tryParse(e['timestamp'] as String? ?? '') ?? DateTime.now(),
          exerciseIndex: e['exerciseIndex'] as int? ?? 0,
          tension: e['tension'] as int? ?? 0,
          pain: e['pain'] as int? ?? 0,
          notes: e['notes'] as String?,
        );
      });
      if (exerciseIndex != null) {
        return entries
            .where((entry) => entry.exerciseIndex == exerciseIndex)
            .toList(growable: false);
      }
      return entries.toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}
