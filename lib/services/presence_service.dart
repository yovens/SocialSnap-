import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ==========================================================
/// PRESENCE SERVICE
/// Gère statut en ligne / hors ligne / last seen
/// ==========================================================
class PresenceService {
  PresenceService._();

  static final PresenceService instance = PresenceService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _users =>
      _firestore.collection("users");

  String get currentUid => _auth.currentUser!.uid;

  /// ==========================================================
  /// SET USER ONLINE
  /// ==========================================================
  Future<void> setOnline() async {
    await _users.doc(currentUid).set({
      "isOnline": true,
      "lastSeen": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ==========================================================
  /// SET USER OFFLINE
  /// ==========================================================
  Future<void> setOffline() async {
    await _users.doc(currentUid).update({
      "isOnline": false,
      "lastSeen": FieldValue.serverTimestamp(),
    });
  }

  /// ==========================================================
  /// UPDATE LAST SEEN ONLY
  /// ==========================================================
  Future<void> updateLastSeen() async {
    await _users.doc(currentUid).update({
      "lastSeen": FieldValue.serverTimestamp(),
    });
  }

  /// ==========================================================
  /// STREAM USER PRESENCE (real-time UI)
  /// ==========================================================
  Stream<DocumentSnapshot> userPresenceStream(String uid) {
    return _users.doc(uid).snapshots();
  }

  /// ==========================================================
  /// GET SINGLE USER PRESENCE ONCE
  /// ==========================================================
  Future<DocumentSnapshot> getUserPresence(String uid) {
    return _users.doc(uid).get();
  }

  /// ==========================================================
  /// AUTO HANDLERS (call in app lifecycle)
  /// ==========================================================

  /// App opened / resumed
  Future<void> onAppResume() async {
    await setOnline();
  }

  /// App paused / closed
  Future<void> onAppPause() async {
    await setOffline();
  }
}