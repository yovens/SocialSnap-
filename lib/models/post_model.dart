import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid;
  final String username; // <--- Nouvo chan
  final String imageUrl;
  final String caption;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username, // <--- Obligatwa nan constructor
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
  });

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      uid: data['uid'] ?? '',
      username: data['username'] ?? 'Anonymous', // <--- Li chan an
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username, // <--- Sove chan an nan Firestore
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  // Nan post_model.dart
factory PostModel.fromMap(Map<String, dynamic> map, String id) {
  return PostModel(
    postId: id,
    uid: map['uid'] ?? '',
    // Si 'username' pa egziste nan dokiman an, li ap mete "Utilisateur"
    username: map['username'] ?? "Utilisateur", 
    imageUrl: map['imageUrl'] ?? '',
    caption: map['caption'] ?? '',
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );
}
}