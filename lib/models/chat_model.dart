import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastSenderId;
  final Timestamp? lastMessageTime;
  final bool isGroup;
  final String groupName;
  final String groupPhoto;

  /// unreadCount[uid] = kantite mesaj itilizatè sa poko li
  final Map<String, dynamic> unreadCount;

  /// typingStatus[uid] = true/false
  final Map<String, dynamic> typingStatus;

  // 🟢 AJOUTE GETTER SA A POU RANJE ERÈ "chat.id" LAN
  String get id => chatId;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastMessageTime,
    required this.isGroup,
    required this.groupName,
    required this.groupPhoto,
    required this.unreadCount,
    required this.typingStatus,
  });

factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
  return ChatModel(
    chatId: id, // ✅ Asire w se 'id' sa a li pran pou chatId la, pa map['chatId']
    participants: List<String>.from(map['participants'] ?? []),
    lastMessage: map['lastMessage'] ?? '',
    lastSenderId: map['lastSenderId'] ?? '',
    lastMessageTime: map['lastMessageTime'],
    isGroup: map['isGroup'] ?? false,
    groupName: map['groupName'] ?? '',
    groupPhoto: map['groupPhoto'] ?? '',
    typingStatus: Map<String, bool>.from(map['typingStatus'] ?? {}),
    unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
  );
}
  Map<String, dynamic> toMap() {
    return {
      "participants": participants,
      "lastMessage": lastMessage,
      "lastSenderId": lastSenderId,
      "lastMessageTime": lastMessageTime,
      "isGroup": isGroup,
      "groupName": groupName,
      "groupPhoto": groupPhoto,
      "unreadCount": unreadCount,
      "typingStatus": typingStatus,
    };
  }
}