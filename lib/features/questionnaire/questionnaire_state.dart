import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Einzelne Frage des Fragebogens.
class Question {
  final String id;
  final List<String> reflexKeys;
  final List<String> reflexNames;
  final String question;
  final String example;

  Question({
    required this.id,
    required this.reflexKeys,
    required this.reflexNames,
    required this.question,
    required this.example,
  });

  /// Erstellt eine Instanz je nach Sprach-Schlüsseln.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      reflexKeys: List<String>.from(json['reflex_keys'] ?? <String>[]),
      reflexNames: List<String>.from(json['reflex_names'] ?? <String>[]),
      question: json['frage'] as String? ?? json['question'] as String? ?? '',
      example: json['beispiel'] as String? ?? json['example'] as String? ?? '',
    );
  }
}

/// Mögliche Antworten auf eine Frage.
enum QuestionAnswer { yes, skip, no }

/// ChangeNotifier verwaltet Fragen, Antworten und Persistenz.
class QuestionnaireState extends ChangeNotifier {
  final Box _box;
  List<Question> _questions = [];
  int _index = 0;
  Map<String, QuestionAnswer> _answers = {};
  bool _helpVisible = false;
  bool _isGerman = true;
  bool _initialized = false;

  QuestionnaireState(this._box);

  bool get isInitialized => _initialized;
  bool get helpVisible => _helpVisible;
  int get currentIndex => _index;
  List<Question> get questions => _questions;
  Question? get currentQuestion =>
      (_index >= 0 && _index < _questions.length) ? _questions[_index] : null;

  /// Initialisiert State aus persistierten Daten.
  Future<void> init() async {
    _index = _box.get('index', defaultValue: 0) as int;
    final rawAnswers = Map<String, int>.from(_box.get('answers') ?? {});
    _answers = rawAnswers.map(
      (k, v) => MapEntry(k, QuestionAnswer.values[v]),
    );
    final lang = _box.get('lang', defaultValue: 'de') as String;
    await _loadQuestions(lang);
    _initialized = true;
    notifyListeners();
  }

  /// Sprache festlegen und Fragen laden.
  Future<void> setLanguage(String lang) async {
    await _loadQuestions(lang);
    await _box.put('lang', lang);
    notifyListeners();
  }

  Future<void> _loadQuestions(String lang) async {
    _isGerman = lang.startsWith('de');
    final path =
        _isGerman ? 'assets/quiz_questions_de.json' : 'assets/quiz_questions_en.json';
    final jsonStr = await rootBundle.loadString(path);
    final data = jsonDecode(jsonStr) as List<dynamic>;
    _questions = data
        .whereType<Map<String, dynamic>>()
        .where((m) => m['id'] != null)
        .map(Question.fromJson)
        .toList();
    if (_index >= _questions.length) _index = _questions.length - 1;
  }

  void toggleHelp() {
    _helpVisible = !_helpVisible;
    notifyListeners();
  }

  void _hideHelp() {
    if (_helpVisible) {
      _helpVisible = false;
    }
  }

  void previous() {
    if (_index > 0) {
      _index--;
      _hideHelp();
      _save();
      notifyListeners();
    }
  }

  void next() {
    if (_index < _questions.length - 1) {
      _index++;
      _hideHelp();
      _save();
      notifyListeners();
    }
  }

  void answerCurrent(QuestionAnswer answer) {
    final q = currentQuestion;
    if (q == null) return;
    _answers[q.id] = answer;
    _index++;
    _hideHelp();
    _save();
    notifyListeners();
  }

  bool get isCompleted => _index >= _questions.length;

  Future<void> _save() async {
    final map = _answers.map((k, v) => MapEntry(k, v.index));
    await _box.put('index', _index);
    await _box.put('answers', map);
    await _box.put('lang', _isGerman ? 'de' : 'en');
  }

  /// Berechnet für jedes Reflex-Label Anzahl Ja-Antworten und Gesamtfragen.
  Map<String, List<int>> calculateReflexSummary() {
    final result = <String, List<int>>{}; // [ja, gesamt]
    for (final q in _questions) {
      final ans = _answers[q.id];
      for (final name in q.reflexNames) {
        final entry = result.putIfAbsent(name, () => [0, 0]);
        if (ans != QuestionAnswer.skip) {
          entry[1] += 1;
          if (ans == QuestionAnswer.yes) entry[0] += 1;
        }
      }
    }
    return result;
  }

  /// Speichert Ergebnis in Firestore und leert den lokalen Fortschritt.
  Future<void> saveResult() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final summary = calculateReflexSummary().map((k, v) =>
        MapEntry(k, {'yes': v[0], 'total': v[1]}));
    final answers = _answers.map((k, v) => MapEntry(k, v.name));
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tracking')
        .add({
      'timestamp': Timestamp.now(),
      'answers': answers,
      'summary': summary,
    });
    await _box.clear();
  }
}
