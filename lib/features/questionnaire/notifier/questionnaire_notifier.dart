import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/questionnaire_state.dart';
import '../services/questionnaire_repository.dart';

/// QuestionnaireNotifier
///
/// Manages a list of questions and the user's answers. Answers are
/// persisted via [QuestionnaireRepository]. Statistics per reflex can be
/// computed based on stored answers.
class QuestionnaireNotifier extends ChangeNotifier {
  final QuestionnaireRepository _repo;
  final List<Question> _questions;

  int _currentIndex = 0;
  final Map<String, Answer> _answers = {};

  QuestionnaireNotifier(this._repo, this._questions);

  /// Load saved progress if available.
  Future<void> resume() async {
    final saved = await _repo.load();
    if (saved != null) {
      _currentIndex = saved.index.clamp(0, _questions.length);
      _answers
        ..clear()
        ..addAll(saved.answers);
      notifyListeners();
    }
  }

  /// Currently displayed question.
  Question? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;

  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  bool get isCompleted => _currentIndex >= _questions.length;
  Map<String, Answer> get answers => Map.unmodifiable(_answers);

  void answerYes() => _handleAnswer(Answer.yes);
  void answerNo() => _handleAnswer(Answer.no);
  void skip() => _handleAnswer(Answer.skipped);

  void _handleAnswer(Answer value) {
    if (isCompleted) return;
    final id = _questions[_currentIndex].id;
    _answers[id] = value;
    _currentIndex++;
    notifyListeners();
    _repo.save(QuestionnaireState(index: _currentIndex, answers: _answers));
  }

  /// Compute ratio of "yes" answers per reflex key.
  Map<String, double> reflexStatistics() {
    final Map<String, int> yesCount = {};
    final Map<String, int> totalCount = {};

    for (final q in _questions) {
      final ans = _answers[q.id];
      if (ans == null || ans == Answer.skipped) continue;
      for (final key in q.reflexKeys) {
        totalCount[key] = (totalCount[key] ?? 0) + 1;
        if (ans == Answer.yes) {
          yesCount[key] = (yesCount[key] ?? 0) + 1;
        }
      }
    }

    final Map<String, double> result = {};
    for (final key in totalCount.keys) {
      final total = totalCount[key] ?? 1;
      final yes = yesCount[key] ?? 0;
      result[key] = yes / total;
    }
    return result;
  }
}
