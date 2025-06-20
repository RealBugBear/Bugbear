class QuestionnaireProgress {
  String language;
  int index;
  Map<String, String> answers;

  QuestionnaireProgress({
    required this.language,
    required this.index,
    required this.answers,
  });

  Map<String, dynamic> toMap() => {
        'language': language,
        'index': index,
        'answers': answers,
      };

  factory QuestionnaireProgress.fromMap(Map<dynamic, dynamic> map) {
    return QuestionnaireProgress(
      language: (map['language'] as String?) ?? 'de',
      index: (map['index'] as int?) ?? 0,
      answers: Map<String, String>.from(map['answers'] as Map? ?? {}),
    );
  }
}
