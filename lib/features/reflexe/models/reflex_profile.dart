// lib/features/reflexe/models/reflex_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Holds yes/answered counts for a single reflex.
class ReflexResult {
  final int yesCount;
  final int answeredCount;

  ReflexResult({required this.yesCount, required this.answeredCount});

  Map<String, dynamic> toMap() => {
        'yes': yesCount,
        'answered': answeredCount,
      };

  factory ReflexResult.fromMap(Map<String, dynamic> map) {
    return ReflexResult(
      yesCount: map['yes'] as int? ?? 0,
      answeredCount: map['answered'] as int? ?? 0,
    );
  }
}

/// A stored reflex profile consisting of multiple reflex results.
class ReflexProfile {
  final String id;
  final DateTime createdAt;
  final Map<String, ReflexResult> results;

  ReflexProfile({
    required this.id,
    required this.createdAt,
    required this.results,
  });

  factory ReflexProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final resultMap = Map<String, dynamic>.from(data['results'] as Map);
    final results = resultMap.map((key, value) =>
        MapEntry(key, ReflexResult.fromMap(Map<String, dynamic>.from(value))));
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    return ReflexProfile(id: doc.id, createdAt: createdAt, results: results);
  }
}
