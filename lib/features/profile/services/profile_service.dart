import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reflex_profile.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveProfile(ReflexProfile profile) {
    return _db
        .collection('users')
        .doc(profile.userId)
        .collection('profiles')
        .doc(profile.id)
        .set(profile.toMap());
  }

  Future<void> setMainProfile(String userId, String? profileId) {
    final data =
        profileId == null ? {'mainProfileId': FieldValue.delete()} : {'mainProfileId': profileId};
    return _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }
}
