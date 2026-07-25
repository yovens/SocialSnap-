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
  // 🟢 Retounen `true` si pòs la vin like (aksyon LIKE), `false` si se yon
  // UNLIKE. Sa pèmèt moun ki rele fonksyon an konnen si li dwe voye yon
  // notifikasyon oswa non (yo pa dwe voye notifikasyon lè yon moun retire like l).
  Future<bool> toggleLike({
    required String postId,
    required String uid,
  }) async {
    final likeRef =
        posts.doc(postId).collection('likes').doc(uid);

    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
      return false; // te vin UNLIKE
    } else {
      await likeRef.set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true; // te vin LIKE
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

  // 🟢 Modifye lejand (ak hashtag) yon pòs — sèl lejand ki editab, dapre CDC la.
  Future<void> updatePostCaption({
    required String postId,
    required String caption,
    List<String> hashtags = const [],
  }) async {
    await posts.doc(postId).update({
      'caption': caption,
      'hashtags': hashtags,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

// Nan lib/services/firestore_service.dart
Future<void> deletePost(String postId) async {
  final postRef = _db.collection('posts').doc(postId);

  // Efase kòmantè yo
  final comments = await postRef.collection('comments').get();
  for (var doc in comments.docs) {
    await doc.reference.delete();
  }

  // 🟢 Efase like yo tou (avan sa yo te rete "òfelen" nan Firestore)
  final likes = await postRef.collection('likes').get();
  for (var doc in likes.docs) {
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
  // 🟢 SÈL VÈSYON follow/unfollow nan tout app la. Anvan sa, yon dezyèm
  // vèsyon te dòmi nan user_list_page.dart e li te mete ajou konte yo
  // (followersCount/followingCount) pandan vèsyon isit la pa t fè sa —
  // rezilta a se te konte ki pa koresponn selon ki ekran ou te itilize.
  // Kounye a tout aksyon follow/unfollow pase pa isit, ak yon batch atomik
  // ki mete ajou sou-koleksyon yo AK konte yo an menm tan.
  Future<void> follow({
    required String myUid,
    required String targetUid,
  }) async {
    if (myUid == targetUid) return; // yon moun pa ka swiv tèt li

    final batch = _db.batch();

    final targetFollowerDoc =
        _db.collection('users').doc(targetUid).collection('followers').doc(myUid);
    final myFollowingDoc =
        _db.collection('users').doc(myUid).collection('following').doc(targetUid);

    batch.set(targetFollowerDoc, {'createdAt': FieldValue.serverTimestamp()});
    batch.set(myFollowingDoc, {'createdAt': FieldValue.serverTimestamp()});

    batch.update(_db.collection('users').doc(targetUid), {
      'followersCount': FieldValue.increment(1),
    });
    batch.update(_db.collection('users').doc(myUid), {
      'followingCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollow({
    required String myUid,
    required String targetUid,
  }) async {
    if (myUid == targetUid) return;

    final batch = _db.batch();

    final targetFollowerDoc =
        _db.collection('users').doc(targetUid).collection('followers').doc(myUid);
    final myFollowingDoc =
        _db.collection('users').doc(myUid).collection('following').doc(targetUid);

    batch.delete(targetFollowerDoc);
    batch.delete(myFollowingDoc);

    batch.update(_db.collection('users').doc(targetUid), {
      'followersCount': FieldValue.increment(-1),
    });
    batch.update(_db.collection('users').doc(myUid), {
      'followingCount': FieldValue.increment(-1),
    });

    await batch.commit();
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
    // 🟢 Pa janm voye yon notifikasyon bay tèt ou (oto-like, oto-koman, elatriye)
    if (receiverUid == senderUid) return;

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
