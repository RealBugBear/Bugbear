import 'package:flutter/foundation.dart';
import '../models/quiz_question.dart';
import '../models/reflex_category.dart';
import '../models/reflex_profile.dart';
import '../services/quiz_service.dart';
import '../services/reflex_profile_service.dart';

class QuizNotifier extends ChangeNotifier {
  final QuizService _service;
  final ReflexProfileService _profileService;

  List<QuizQuestion> _questions = [];
  List<ReflexCategory> _categories = [];
  final Map<String, bool> _answers = {};
  int _index = 0;

  QuizNotifier(this._service, this._profileService);

  List<QuizQuestion> get questions => _questions;
  List<ReflexCategory> get categories => _categories;
  int get index => _index;

  Future<void> load() async {
    _questions = await _service.loadQuestions();
    _categories = await _service.loadCategories();
    _index = 0;
    _answers.clear();
    notifyListeners();
  }

  bool? get currentAnswer => _answers[_questions[_index].id];

  void answer(bool value) {
    _answers[_questions[_index].id] = value;
    notifyListeners();
  }

  void next() {
    if (_index < _questions.length - 1) {
      _index++;
      notifyListeners();
    }
  }

  void previous() {
    if (_index > 0) {
      _index--;
      notifyListeners();
    }
  }

  bool get isLast => _index == _questions.length - 1;

  Map<String, double> _calculateScores() {
    final Map<String, int> totals = {};
    final Map<String, int> yes = {};
    for (var q in _questions) {
      for (var cat in q.categoryIds) {
        totals[cat] = (totals[cat] ?? 0) + 1;
        if (_answers[q.id] == true) {
          yes[cat] = (yes[cat] ?? 0) + 1;
        }
      }
    }
    final Map<String, double> result = {};
    for (var cat in totals.keys) {
      final y = yes[cat] ?? 0;
      result[cat] = totals[cat]! == 0 ? 0 : y / totals[cat]! * 100;
    }
    return result;
  }

  ReflexProfile buildProfile() {
    return ReflexProfile(
      scores: _calculateScores(),
      createdAt: DateTime.now(),
    );
  }

  Future<void> saveProfile() async {
    final profile = buildProfile();
    await _profileService.save(profile);
  }
}
