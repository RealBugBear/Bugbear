import "package:cloud_firestore/cloud_firestore.dart";

class ReflexProfile {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final bool isMainProfile;
  final Map<String, dynamic> reflexScores;
  final Map<String, String> answers;
  final String? avatarItemId;
  final int xpSpent;
  final String questionnaireVersion;

  ReflexProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.isMainProfile,
    required this.reflexScores,
    required this.answers,
    this.avatarItemId,
    this.xpSpent = 0,
    this.questionnaireVersion = 'v1',
  });

  factory ReflexProfile.fromMap(Map<String, dynamic> data, String docId) {
    return ReflexProfile(
      id: docId,
      userId: data['userId'] as String,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isMainProfile: data['isMainProfile'] as bool? ?? false,
      reflexScores: Map<String, dynamic>.from(data['reflexScores'] ?? {}),
      answers: Map<String, String>.from(data['answers'] ?? {}),
      avatarItemId: data['avatarItemId'] as String?,
      xpSpent: (data['xpSpent'] as num?)?.round() ?? 0,
      questionnaireVersion:
          data['questionnaireVersion'] as String? ?? 'v1',
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'createdAt': Timestamp.fromDate(createdAt),
        'isMainProfile': isMainProfile,
        'reflexScores': reflexScores,
        'answers': answers,
        'avatarItemId': avatarItemId,
        'xpSpent': xpSpent,
        'questionnaireVersion': questionnaireVersion,
      };
}
