import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/question_item.dart';
import '../models/questionnaire_progress.dart';

class QuestionnaireRepository {
  static const String _boxName = 'questionnaire_state';
  static const String _key = 'progress';

  Future<List<QuestionItem>> loadQuestions(String languageCode) async {
    final asset = languageCode == 'de'
        ? 'assets/quiz_questions_de.json'
        : 'assets/quiz_questions_en.json';
    final str = await rootBundle.loadString(asset);
    final list = json.decode(str) as List<dynamic>;
    return list
        .map((e) => QuestionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Box> _box() async => Hive.box(_boxName);

  Future<QuestionnaireProgress?> loadProgress() async {
    final box = await _box();
    final data = box.get(_key);
    if (data is Map) {
      return QuestionnaireProgress.fromMap(data as Map);
    }
    return null;
  }

  Future<void> saveProgress(QuestionnaireProgress progress) async {
    final box = await _box();
    await box.put(_key, progress.toMap());
  }

  Future<void> clear() async {
    final box = await _box();
    await box.delete(_key);
  }
}
