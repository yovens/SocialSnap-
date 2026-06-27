import 'package:cloud_firestore/cloud_firestore.dart';

class TypingModel {
  final String uid;

  final String chatId;

  final bool isTyping;

  final Timestamp? updatedAt;

  TypingModel({
    required this.uid,
    required this.chatId,
    required this.isTyping,
    required this.updatedAt,
  });

  factory TypingModel.fromMap(
      Map<String, dynamic> map) {
    return TypingModel(
      uid: map["uid"] ?? "",
      chatId: map["chatId"] ?? "",
      isTyping: map["isTyping"] ?? false,
      updatedAt: map["updatedAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "chatId": chatId,
      "isTyping": isTyping,
      "updatedAt": updatedAt,
    };
  }
}