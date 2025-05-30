import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bugbear_app/features/training/models/session_state.dart';
import 'package:bugbear_app/features/training/services/session_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SyncService {
  final SessionRepository _repo;
  final FirebaseFirestore _firestore;
  final String _userId; // zum Pfad in Firestore
  final List<SessionState> _queue = [];

  late final StreamSubscription<ConnectivityResult> _connSub;

  SyncService(this._repo, this._firestore, this._userId) {
    // Starte Monitoring
    _connSub = Connectivity()
      .onConnectivityChanged
      .listen(_onConnectivityChanged);
    // Lade evtl. noch nicht synchronisierte States
    _loadQueue();
  }

  Future<void> dispose() async {
    await _connSub.cancel();
  }

  Future<void> _loadQueue() async {
    final current = await _repo.load();
    if (current != null) {
      _queue.add(current);
    }
  }

  Future<void> enqueue(SessionState state) async {
    _queue.add(state);
    // Sofort versuchen, zu syncen, falls online
    final status = await Connectivity().checkConnectivity();
    if (status != ConnectivityResult.none) {
      await _flushQueue();
    }
  }

  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      await _flushQueue();
    }
  }

  Future<void> _flushQueue() async {
    while (_queue.isNotEmpty) {
      final state = _queue.first;
      try {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('sessions')
            .doc(state.startedAt.toIso8601String())
            .set(state.toJson());
        _queue.removeAt(0);
      } catch (e) {
        // Bei Fehler abbrechen und später erneut versuchen
        break;
      }
    }
  }
}
