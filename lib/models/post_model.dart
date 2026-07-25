import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid;
  final String username; // <--- Nouvo chan
  final List<String> imageUrls; // 🟢 sipòte plizyè imaj (avan se te 1 sèl)
  final String caption;
  final List<String> hashtags; // 🟢 hashtags ekstrè nan lejand lan
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username, // <--- Obligatwa nan constructor
    required this.imageUrls,
    required this.caption,
    this.hashtags = const [],
    required this.createdAt,
  });

  /// 🟢 Retwokonpatibilite: kòd ki toujou itilize `post.imageUrl` (1 sèl imaj)
  /// ap kontinye mache — li retounen premye imaj la nan lis la.
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      uid: data['uid'] ?? '',
      username: data['username'] ?? 'Anonymous', // <--- Li chan an
      imageUrls: _extractImageUrls(data),
      caption: data['caption'] ?? '',
      hashtags: _extractHashtags(data),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username, // <--- Sove chan an nan Firestore
      'imageUrls': imageUrls,
      // 🟢 Nou kenbe 'imageUrl' (premye imaj la) pou ansyen vèsyon kòd/app
      // ki ta ka li dokiman sa a toujou konte sou yon sèl chan string.
      'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
      'caption': caption,
      'hashtags': hashtags,
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
      imageUrls: _extractImageUrls(map),
      caption: map['caption'] ?? '',
      hashtags: _extractHashtags(map),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// 🟢 Li 'imageUrls' (nouvo fòma, lis) si li egziste; sinon li retonbe sou
  /// ansyen chan 'imageUrl' (yon sèl string) pou pòs ki te kreye avan sa.
  static List<String> _extractImageUrls(Map<String, dynamic> map) {
    final rawList = map['imageUrls'];
    if (rawList is List) {
      return rawList.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    final single = map['imageUrl'];
    if (single is String && single.isNotEmpty) {
      return [single];
    }
    return [];
  }

  static List<String> _extractHashtags(Map<String, dynamic> map) {
    final raw = map['hashtags'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
