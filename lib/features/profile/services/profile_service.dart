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

  /// Streamt alle Profile eines Nutzers sortiert nach Erstellungsdatum.
  Stream<List<ReflexProfile>> watchProfiles(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((qs) =>
            qs.docs.map((d) => ReflexProfile.fromMap(d.data(), d.id)).toList());
  }

  /// Liefert den aktuellen Hauptprofil-ID-Stream für einen Nutzer.
  Stream<String?> watchMainProfileId(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['mainProfileId'] as String?);
  }

  /// Entfernt ein Profil endgültig.
  Future<void> deleteProfile(String userId, String profileId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .doc(profileId)
        .delete();
  }
}
