class ReflexProfile {
  final Map<String, double> scores;
  final DateTime createdAt;

  ReflexProfile({required this.scores, required this.createdAt});

  factory ReflexProfile.fromJson(Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(json['scores'] as Map);
    final scores = raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    return ReflexProfile(
      scores: scores,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'scores': scores,
        'createdAt': createdAt.toIso8601String(),
      };
}
