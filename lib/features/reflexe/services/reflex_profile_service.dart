import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reflex_profile.dart';

/// Service for persisting reflex profiles in Firestore.
class ReflexProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Saves a profile for the current user.
  Future<void> saveProfile(Map<String, ReflexResult> results) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final data = {
      'createdAt': Timestamp.now(),
      'results': {
        for (var entry in results.entries) entry.key: entry.value.toMap(),
      },
    };
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('reflex_profiles')
        .add(data);
  }

  /// Loads all stored profiles for the current user ordered by date desc.
  Future<List<ReflexProfile>> loadProfiles() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('reflex_profiles')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => ReflexProfile.fromDoc(d))
        .toList();
  }
}
