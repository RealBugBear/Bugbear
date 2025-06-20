class Question {
  final String id;
  final List<String> reflexKeys;
  final List<String> reflexNames;
  final String question;
  final String example;
  final List<String> sources;

  Question({
    required this.id,
    required this.reflexKeys,
    required this.reflexNames,
    required this.question,
    this.example = '',
    this.sources = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      reflexKeys: List<String>.from(json['reflex_keys'] as List<dynamic>),
      reflexNames: List<String>.from(json['reflex_names'] as List<dynamic>),
      question: json['question'] as String,
      example: json['example'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reflex_keys': reflexKeys,
        'reflex_names': reflexNames,
        'question': question,
        'example': example,
        'sources': sources,
      };
}
