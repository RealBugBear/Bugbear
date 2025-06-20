enum Answer { yes, no, skipped }

class QuestionnaireState {
  final int index;
  final Map<String, Answer> answers;

  QuestionnaireState({
    required this.index,
    required Map<String, Answer> answers,
  }) : answers = Map<String, Answer>.from(answers);

  factory QuestionnaireState.fromJson(Map<String, dynamic> json) {
    final map = (json['answers'] as Map).cast<String, int>();
    final ans = map.map((k, v) => MapEntry(k, Answer.values[v]));
    return QuestionnaireState(index: json['index'] as int, answers: ans);
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'answers': answers.map((k, v) => MapEntry(k, v.index)),
      };
}
