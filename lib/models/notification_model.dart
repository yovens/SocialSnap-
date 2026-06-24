import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String receiverUid; // Te manke
  final String senderUid;   // Te manke
  final String type;
  final String? postId;     // Te manke (li ka null, se poutèt sa li se String?)
  final bool isRead;
  final DateTime createdAt; // Nou itilize DateTime olye de Timestamp pou plis fleksibilite

  NotificationModel({
    required this.id,
    required this.receiverUid,
    required this.senderUid,
    required this.type,
    this.postId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      receiverUid: map['receiverUid'] ?? '',
      senderUid: map['senderUid'] ?? '',
      type: map['type'] ?? '',
      postId: map['postId'], // Ka rete null
      isRead: map['isRead'] ?? false,
      // Konvèti Timestamp an DateTime
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}