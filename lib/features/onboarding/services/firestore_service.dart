// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Generischer Firestore-Helper für Lese- und Schreib-Operationen.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> readCollection(
    String path,
  ) async {
    final snapshot = await _db.collection(path).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>?> readDocument(
    String path,
    String id,
  ) async {
    final doc = await _db.collection(path).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  Future<void> writeDocument(
    String path,
    String id,
    Map<String, dynamic> data,
  ) {
    return _db.collection(path).doc(id).set(data);
  }

  Future<void> updateDocument(
    String path,
    String id,
    Map<String, dynamic> data,
  ) {
    return _db.collection(path).doc(id).update(data);
  }

  Future<void> deleteDocument(
    String path,
    String id,
  ) {
    return _db.collection(path).doc(id).delete();
  }
}
