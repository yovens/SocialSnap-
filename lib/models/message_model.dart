import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  gif,
}

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;

  final String message;

  final MessageType type;

  final String mediaUrl;

  final Timestamp? timestamp;

  final bool isSeen;

  final bool isDelivered;

  final bool isEdited;

  final bool isDeleted;

  final String replyToMessageId;

  final String replyMessage;

  final String replySender;

  final List<String> reactions;
MessageModel copyWith({
  String? message,
  bool? isSeen,
  bool? isDelivered,
  bool? isEdited,
  bool? isDeleted,
  List<String>? reactions,
}) {
  return MessageModel(
    messageId: messageId,
    senderId: senderId,
    receiverId: receiverId,
    message: message ?? this.message,
    type: type,
    mediaUrl: mediaUrl,
    timestamp: timestamp,
    isSeen: isSeen ?? this.isSeen,
    isDelivered: isDelivered ?? this.isDelivered,
    isEdited: isEdited ?? this.isEdited,
    isDeleted: isDeleted ?? this.isDeleted,
    replyToMessageId: replyToMessageId,
    replyMessage: replyMessage,
    replySender: replySender,
    reactions: reactions ?? this.reactions,
  );
}
  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.mediaUrl,
    required this.timestamp,
    required this.isSeen,
    required this.isDelivered,
    required this.isEdited,
    required this.isDeleted,
    required this.replyToMessageId,
    required this.replyMessage,
    required this.replySender,
    required this.reactions,
  });

  factory MessageModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return MessageModel(
      messageId: id,
      senderId: map["senderId"] ?? "",
      receiverId: map["receiverId"] ?? "",
      message: map["message"] ?? "",
      mediaUrl: map["mediaUrl"] ?? "",
      timestamp: map["timestamp"],
      isSeen: map["isSeen"] ?? false,
      isDelivered: map["isDelivered"] ?? false,
      isEdited: map["isEdited"] ?? false,
      isDeleted: map["isDeleted"] ?? false,
      replyToMessageId:
      map["replyToMessageId"] ?? "",
      replyMessage:
      map["replyMessage"] ?? "",
      replySender:
      map["replySender"] ?? "",
      reactions:
      List<String>.from(map["reactions"] ?? []),
      type: MessageType.values.firstWhere(
            (e) =>
        e.name ==
            (map["type"] ?? "text"),
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
      "isSeen": isSeen,
      "isDelivered": isDelivered,
      "isEdited": isEdited,
      "isDeleted": isDeleted,
      "replyToMessageId": replyToMessageId,
      "replyMessage": replyMessage,
      "replySender": replySender,
      "reactions": reactions,
      "type": type.name,
    };
  }
}