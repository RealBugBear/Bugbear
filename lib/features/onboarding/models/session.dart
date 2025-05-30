/// lib/models/session.dart
library;
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String userId;
  final DateTime date;
  final List<String>? completedExercises;

  SessionModel({
    required this.id,
    required this.userId,
    required this.date,
    this.completedExercises,
  });

  factory SessionModel.fromMap(Map<String, dynamic> data, String docId) {
    return SessionModel(
      id: docId,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      completedExercises:
        List<String>.from(data['completedExercises'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'date': Timestamp.fromDate(date),
    'completedExercises': completedExercises,
  };
}
