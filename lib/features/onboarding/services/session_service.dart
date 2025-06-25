import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// SessionService (isolierte Variante) nur zum Anlegen & Abrufen von Sessions.
class SessionService {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  Future<void> createSession(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Cannot create session when no user is signed in');
    }
    final uid = user.uid;
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
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Cannot fetch sessions when no user is signed in');
    }
    final uid = user.uid;
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
