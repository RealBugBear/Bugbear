import 'package:flutter/material.dart';
import 'package:bugbear_app/models/quiz_question.dart';
import 'package:bugbear_app/models/reflex_category.dart';
import 'package:bugbear_app/services/local_question_service.dart';
import 'package:bugbear_app/services/local_category_service.dart';

/// Steuert Laden, Beantworten & Auswertung des Quiz.
class QuizModel extends ChangeNotifier {
  final LocalQuestionService _qs;
  final LocalCategoryService _cs;

  List<QuizQuestion> questions = [];
  List<ReflexCategory> categories = [];
  int currentIndex = 0;
  final Map<String, bool> answers = {};

  QuizModel({
    LocalQuestionService? qs,
    LocalCategoryService? cs,
  })  : _qs = qs ?? LocalQuestionService(),
        _cs = cs ?? LocalCategoryService();

  /// Lädt Fragen & Kategorien aus assets-JSON.
  Future<void> loadAll(String locale) async {
    questions = await _qs.loadQuestions(locale);
    categories = await _cs.loadCategories(locale);
    currentIndex = 0;
    answers.clear();
    for (var cat in categories) {
      cat.score = 0;
    }
    notifyListeners();
  }

  /// Speichert die Antwort und zählt "yes".
  void answerCurrent(bool yes) {
    final q = questions[currentIndex];
    answers[q.id] = yes;
    if (yes) {
      for (var catId in q.categoryIds) {
        final cat = categories.firstWhere((c) => c.id == catId);
        cat.score += 1;
      }
    }
    notifyListeners();
  }

  /// Weiter zur nächsten Frage oder auf Results.
  void next(BuildContext ctx) {
    if (currentIndex + 1 < questions.length) {
      currentIndex++;
      notifyListeners();
    } else {
      _calculateScores();
      Navigator.of(ctx).pushReplacementNamed('/results');
    }
  }

  /// Wandelt die rohen Punktzahlen in Prozent um.
  void _calculateScores() {
    for (var cat in categories) {
      final total = questions
          .where((q) => q.categoryIds.contains(cat.id))
          .length;
      cat.score = total == 0 ? 0 : (cat.score / total) * 100;
    }
    notifyListeners();
  }

  /// Öffentliche Schnittstelle für manuelles Recalculaten (z.B. im QuizScreen).
  void calculateScores() => _calculateScores();
}
