class QuizQuestion {
  final String id;
  final Map<String, String> text;
  final List<String> categoryIds;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.categoryIds,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      text: Map<String, String>.from(json['text'] as Map),
      categoryIds: List<String>.from(json['categoryIds'] as List),
    );
  }
}
