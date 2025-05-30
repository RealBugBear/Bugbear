/// lib/models/user.dart
class UserModel {
  final String uid;
  final String? role;
  final String? email;
  final String? nickname; // optional

  UserModel({
    required this.uid,
    this.role,
    this.email,
    this.nickname,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      role: data['role'] as String?,
      email: data['email'] as String?,
      nickname: data['nickname'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'role': role,
    'email': email,
    'nickname': nickname,
  };
}
