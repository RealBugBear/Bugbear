import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';
import '../models/reflex_category.dart';

class QuizService {
  final String languageCode;
  QuizService(this.languageCode);

  Future<List<QuizQuestion>> loadQuestions() async {
    final file = languageCode.startsWith('de')
        ? 'assets/quiz_questions_de.json'
        : 'assets/quiz_questions_en.json';
    final str = await rootBundle.loadString(file);
    final list = json.decode(str) as List<dynamic>;
    return list
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReflexCategory>> loadCategories() async {
    final file = languageCode.startsWith('de')
        ? 'assets/reflex_categories_de.json'
        : 'assets/reflex_categories_en.json';
    final str = await rootBundle.loadString(file);
    final list = json.decode(str) as List<dynamic>;
    return list
        .map((e) => ReflexCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
