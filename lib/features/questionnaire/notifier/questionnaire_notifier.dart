import 'package:flutter/foundation.dart';
import '../models/question_item.dart';
import '../models/questionnaire_progress.dart';
import '../services/questionnaire_repository.dart';

class QuestionnaireNotifier extends ChangeNotifier {
  final QuestionnaireRepository _repo;
  QuestionnaireProgress _progress;
  List<QuestionItem> _questions = [];

  QuestionnaireNotifier(this._repo, this._progress);

  List<QuestionItem> get questions => _questions;
  int get index => _progress.index;
  String get language => _progress.language;
  Map<String, String> get answers => _progress.answers;

  QuestionItem? get currentQuestion =>
      index < _questions.length ? _questions[index] : null;

  Future<void> loadQuestions() async {
    _questions = await _repo.loadQuestions(_progress.language);
    if (_progress.index > _questions.length) {
      _progress.index = _questions.length;
    }
    notifyListeners();
  }

  Future<void> start(String language) async {
    _progress.language = language;
    _progress.index = 0;
    _progress.answers.clear();
    await _repo.saveProgress(_progress);
    await loadQuestions();
  }

  Future<void> answer(String value) async {
    final q = currentQuestion;
    if (q == null) return;
    _progress.answers[q.id] = value;
    _progress.index++;
    await _repo.saveProgress(_progress);
    notifyListeners();
  }

  void next() {
    if (_progress.index < _questions.length - 1) {
      _progress.index++;
      _repo.saveProgress(_progress);
      notifyListeners();
    }
  }

  void previous() {
    if (_progress.index > 0) {
      _progress.index--;
      _repo.saveProgress(_progress);
      notifyListeners();
    }
  }
}
