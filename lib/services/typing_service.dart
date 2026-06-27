import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ==========================================================
/// TYPING SERVICE
/// Gère "En train d'écrire..." en temps réel
/// ==========================================================
class TypingService {
  TypingService._();

  static final TypingService instance = TypingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _chatCollection =>
      _firestore.collection("chats");

  String get currentUid => _auth.currentUser!.uid;

  /// ==========================================================
  /// START TYPING
  /// Appelé quand l'utilisateur commence à écrire
  /// ==========================================================
  Future<void> startTyping(String chatId) async {
    await _chatCollection.doc(chatId).set({
      "typingStatus": {
        currentUid: true,
      }
    }, SetOptions(merge: true));
  }

  /// ==========================================================
  /// STOP TYPING
  /// Appelé quand l'utilisateur arrête d'écrire
  /// ==========================================================
  Future<void> stopTyping(String chatId) async {
    await _chatCollection.doc(chatId).set({
      "typingStatus": {
        currentUid: false,
      }
    }, SetOptions(merge: true));
  }

  /// ==========================================================
  /// STREAM TYPING STATUS (REAL-TIME)
  /// Observe si quelqu’un est en train d’écrire
  /// ==========================================================
  Stream<DocumentSnapshot> typingStream(String chatId) {
    return _chatCollection.doc(chatId).snapshots();
  }

  /// ==========================================================
  /// CHECK IF OTHER USER IS TYPING
  /// Util pour UI (affichage "typing...")
  /// ==========================================================
  bool isOtherUserTyping(
    Map<String, dynamic> typingStatus,
  ) {
    final otherUsersTyping = typingStatus.entries.any(
      (entry) =>
          entry.key != currentUid && entry.value == true,
    );

    return otherUsersTyping;
  }
}