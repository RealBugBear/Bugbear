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
      final stepsRaw = (e['steps'] as List?) ?? const [];
      final steps = stepsRaw
          .map((step) => MoroExerciseStep(
                order: step['order'] as int? ?? 0,
                text: step['text'] as String? ?? '',
                durationSec: step['durationSec'] as int?,
              ))
          .toList();
      final cues = ((e['cues'] as List?) ?? const [])
          .map((c) => c.toString())
          .toList();
      final breathRaw = (e['breath'] as Map?)?.cast<String, dynamic>();
      final breath = MoroBreathPattern(
        pattern: breathRaw?['pattern'] as String? ?? 'emphasis-exhale',
        exhaleSec: breathRaw?['exhaleSec'] as int?,
        holdSec: breathRaw?['holdSec'] as int?,
        notes: breathRaw?['notes'] as String?,
      );
      final abortRules = ((e['abortRules'] as List?) ?? const [])
          .map((a) => a.toString())
          .toList();
      final tags = ((e['tags'] as List?) ?? const [])
          .map((t) => t.toString())
          .toList();
      final mediaRaw = (e['media'] as Map?)?.cast<String, dynamic>() ?? {};
      final media = MoroMedia(
        image: mediaRaw['image'] as String?,
        video: mediaRaw['video'] as String?,
      );
      final resumeKey = e['resumeKey'] as String? ?? 'moro_${e['index']}';
      final autoplayDefault = e['autoplayDefault'] as int? ?? 3;
      final fallbackImage = e['mediaFallbackImage'] as String? ?? media.image;
      final xpReward = e['xpReward'] as int? ?? (type == MoroExerciseType.simple ? 60 : 30);
      return MoroExercise(
        index: e['index'] as int,
        title: e['title'] as String,
        type: type,
        repeats: e['repeats'] as int,
        phasesPerRepeat: e['phasesPerRepeat'] as int,
        baseSeconds: e['baseSeconds'] as int,
        autoplayDefault: autoplayDefault,
        goal: e['goal'] as String? ?? '',
        startPosition: e['startPosition'] as String? ?? '',
        endPosition: e['endPosition'] as String?,
        steps: steps,
        cues: cues,
        breath: breath,
        abortRules: abortRules,
        notes: e['notes'] as String?,
        tags: tags,
        version: e['version'] as String? ?? '1.0.0',
        media: media,
        resumeKey: resumeKey,
        mediaFallbackImage: fallbackImage,
        xpReward: xpReward,
      );
    }).toList();
    items.sort((a, b) => a.index.compareTo(b.index));
    return items;
  }
}
