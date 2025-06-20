
class QuestionItem {
  final String id;
  final List<String> reflexKeys;
  final List<String> reflexNames;
  final String text;
  final String example;

  QuestionItem({
    required this.id,
    required this.reflexKeys,
    required this.reflexNames,
    required this.text,
    required this.example,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    return QuestionItem(
      id: json['id'] as String,
      reflexKeys: List<String>.from(json['reflex_keys'] as List),
      reflexNames: List<String>.from(json['reflex_names'] as List),
      text: (json['frage'] ?? json['question']) as String,
      example: (json['beispiel'] ?? json['example']) as String,
    );
  }
}
