import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/firestore_service.dart';

class FeedProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _useTestData = false;
  bool get useTestData => _useTestData;

  void setMode(bool isTest) {
    _useTestData = isTest;
    notifyListeners();
  }

  // 1. Metòd prensipal pou jwenn Posts
  Stream<List<PostModel>> getPosts() {
    if (_useTestData) {
      return Stream.value([
        PostModel(
          postId: "1",
          uid: "user_test_1",
          username: "Jocelyn",
          imageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
          caption: "Premye pòs tès - SocialSnap!",
          createdAt: DateTime.now(),
        ),
      ]);
    }
    
    // Konvèsyon QuerySnapshot -> List<PostModel>
    return _firestoreService.posts.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => 
        PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
    });
  }

  // 2. Alias pou evite erè nan paj yo
   Stream<List<PostModel>> getPostsStream() {
    return _firestoreService.posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 3. Metòd pou jwenn Comments
  Stream<List<CommentModel>> getComments(String postId) {
    return _firestoreService.getComments(postId).map((snapshot) {
      return snapshot.docs.map((doc) => 
        CommentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
    });
  }
}