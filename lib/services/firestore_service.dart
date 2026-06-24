import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    await _db.collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(myUid)
        .set({'createdAt': FieldValue.serverTimestamp()});

    await _db.collection('users')
        .doc(myUid)
        .collection('following')
        .doc(targetUid)
        .set({'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> unfollow({
    required String myUid,
    required String targetUid,
  }) async {
    await _db.collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(myUid)
        .delete();

    await _db.collection('users')
        .doc(myUid)
        .collection('following')
        .doc(targetUid)
        .delete();
  }

  // ───────────────── NOTIFICATIONS ─────────────────
  Future<void> sendNotification({
    required String receiverUid,
    required String senderUid,
    required String type,
    String? postId,
  }) async {
    await _db.collection('notifications').add({
      'receiverUid': receiverUid,
      'senderUid': senderUid,
      'type': type,
      'postId': postId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
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
}