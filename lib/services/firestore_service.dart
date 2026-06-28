import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


// Fonksyon pou ajoute yon istwa (Story)
  Future<void> addStory({required String uid, required String imageUrl}) async {
    await _db.collection('stories').add({
      'uid': uid,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'expiryDate': DateTime.now().add(const Duration(hours: 24)),
    });
  }
  // ───────────────── POSTS ─────────────────
  CollectionReference get posts => _db.collection('posts');

  // LIKE POST (toggle)
  Future<void> toggleLike({
    required String postId,
    required String uid,
  }) async {
    final likeRef =
        posts.doc(postId).collection('likes').doc(uid);

    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
Stream<QuerySnapshot> getPosts() {
  return _db.collection('posts').orderBy('createdAt', descending: true).snapshots();
}
  Stream<int> likesCount(String postId) {
    return posts
        .doc(postId)
        .collection('likes')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<bool> isLiked(String postId, String uid) {
    return posts
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

// Nan lib/services/firestore_service.dart
Future<void> deletePost(String postId) async {
  final postRef = _db.collection('posts').doc(postId);
  
  // Efase kòmantè yo
  final comments = await postRef.collection('comments').get();
  for (var doc in comments.docs) { 
    await doc.reference.delete();
  }
  
  // Efase pòs la
  await postRef.delete();
}
  // ───────────────── COMMENTS ─────────────────
  Future<void> addComment({
    required String postId,
    required String uid,
    required String username,
    required String text,
  }) async {
    await posts.doc(postId).collection('comments').add({
      'uid': uid,
      'username': username,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await posts
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // ───────────────── FOLLOW SYSTEM ─────────────────
     Future<void> follow({
  required String myUid,
  required String targetUid,
}) async {

  await FirebaseFirestore.instance
      .collection('users')
      .doc(targetUid)
      .collection('followers')
      .doc(myUid)
      .set({'createdAt': FieldValue.serverTimestamp()});

  await FirebaseFirestore.instance
      .collection('users')
      .doc(myUid)
      .collection('following')
      .doc(targetUid)
      .set({'createdAt': FieldValue.serverTimestamp()});
}

 Future<void> unfollow({
  required String myUid,
  required String targetUid,
}) async {

  await FirebaseFirestore.instance
      .collection('users')
      .doc(targetUid)
      .collection('followers')
      .doc(myUid)
      .delete();

  await FirebaseFirestore.instance
      .collection('users')
      .doc(myUid)
      .collection('following')
      .doc(targetUid)
      .delete();
}

// ───────────────── NOTIFICATIONS ─────────────────
  Future<void> sendNotification({
    required String receiverUid,
    required String senderUid,
    required String senderName,            // 🟢 AJOUTE: Non moun ki fè aksyon an
    required String senderProfileImageUrl, // 🟢 AJOUTE: Foto pwofil moun lan
    required String type,
    String? postId,
  }) async {
    await _db.collection('notifications').add({
      'receiverUid': receiverUid,
      'senderUid': senderUid,
      'senderName': senderName,                     // 🟢 Sove l nan Firestore
      'senderProfileImageUrl': senderProfileImageUrl, // 🟢 Sove l nan Firestore
      'type': type,
      'postId': postId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(), // 🔥 Sa a ap toujou bay bon jan lè egzat sèvè a!
    });
  }

  Stream<QuerySnapshot> getNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('receiverUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateNotificationStatus(
    String uid,
    String notificationId,
    bool isRead,
  ) async {
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': isRead});
  }

  Future<void> _clearAllNotifications(List<QueryDocumentSnapshot> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

}