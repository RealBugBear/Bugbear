import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'moro_models.dart';

class MoroRepository {
  Future<List<MoroExercise>> load() async {
    final raw = await rootBundle.loadString('assets/moro/moro_exercises.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final items = list.map((e) {
      final type = e['type'] == 'phased4x'
          ? MoroExerciseType.phased4x
          : MoroExerciseType.simple;
      return MoroExercise(
        index: e['index'] as int,
        title: e['title'] as String,
        type: type,
        repeats: e['repeats'] as int,
        phasesPerRepeat: e['phasesPerRepeat'] as int,
        baseSeconds: e['baseSeconds'] as int,
      );
    }).toList();
    items.sort((a, b) => a.index.compareTo(b.index));
    return items;
  }
}
