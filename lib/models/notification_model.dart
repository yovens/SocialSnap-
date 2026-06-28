import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String receiverUid;
  final String senderUid;
  final String senderName;            // 🟢 AJOUTE: Pou pran non moun ki like/comment lan
  final String senderProfileImageUrl; // 🟢 AJOUTE: Pou foto profil li
  final String type;
  final String? postId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.receiverUid,
    required this.senderUid,
    required this.senderName,            // 🟢 Mande l nan constructor
    required this.senderProfileImageUrl, // 🟢 Mande l nan constructor
    required this.type,
    this.postId,
    required this.isRead,
    required this.createdAt,
  });

  // 1️⃣ Konvèti done Firestore yo pou yo tounen Objè nan aplikasyon an
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      receiverUid: map['receiverUid'] ?? '',
      senderUid: map['senderUid'] ?? '',
      senderName: map['senderName'] ?? "Quelqu'un", // 🟢 Li non an nan Firestore
      senderProfileImageUrl: map['senderProfileImageUrl'] ?? '', // 🟢 Li foto a
      type: map['type'] ?? '',
      postId: map['postId'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 2️⃣ 🟢 AJOUTE METÒD SA A: Pou lè w ap sove notifikasyon an nan Firestore
  Map<String, dynamic> toMap() {
    return {
      'receiverUid': receiverUid,
      'senderUid': senderUid,
      'senderName': senderName,                             // Sove non an
      'senderProfileImageUrl': senderProfileImageUrl,       // Sove foto a
      'type': type,
      'postId': postId,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(), // 🔥 Sa a ap asire Firestore pran BON LÈ sèvè a nèt!
    };
  }
}