import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// SessionService (isolierte Variante) nur zum Anlegen & Abrufen von Sessions.
class SessionService {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  Future<void> createSession(DateTime date) async {
    final uid = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .add({
      'userId': uid,
      'date':   Timestamp.fromDate(date),
    });
  }

  Future<List<Map<String, dynamic>>> fetchUserSessions() async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .get();
    return snapshot.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();
  }
}
