import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId; // Sa a se non varyab la
  final String postId;
  final String uid;
  final String username; // Mwen ajoute li paske ou itilize l nan fromMap
  final String text;
  final String? replyTo; // 🟢 id kòmantè paran an si se yon repons
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.uid,
    required this.username, // Obligatwa kounye a
    required this.text,
    this.replyTo,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      // Sèvi ak 'commentId' (non varyab la) olye de 'id'
      commentId: id, 
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      text: map['text'] ?? '',
      replyTo: map['replyTo'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'username': username,
      'text': text,
      'replyTo': replyTo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}