
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


import 'package:hive/hive.dart';
import '../models/questionnaire_state.dart';

class QuestionnaireRepository {
  static const String _boxName = 'questionnaire_state';
  static const String _key = 'state';

  Future<Box<Map>> _openBox() async => Hive.box<Map>(_boxName);

  Future<QuestionnaireState?> load() async {
    final box = await _openBox();
    final json = box.get(_key);
    if (json == null) return null;
    return QuestionnaireState.fromJson(Map<String, dynamic>.from(json));

import 'package:hive_flutter/hive_flutter.dart';


import 'package:bugbear_app/features/questionnaire/models/questionnaire_state.dart';

import '../models/questionnaire_state.dart';


class QuestionnaireRepository {
  static const String _boxName = 'questionnaire_state';
  static const String _key = 'current';

  Future<Box<QuestionnaireState>> _openBox() async =>
      Hive.box<QuestionnaireState>(_boxName);

  Future<QuestionnaireState?> load() async {
    final box = await _openBox();
    return box.get(_key);
  }

  Future<void> save(QuestionnaireState state) async {
    final box = await _openBox();

    await box.put(_key, state.toJson());

    await box.put(_key, state);

  }

  Future<void> clear() async {
    final box = await _openBox();

    await box.delete(_key);
  }
}
