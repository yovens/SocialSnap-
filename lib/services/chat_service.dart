import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  // Singleton Pattern pwòp
  ChatService._();
  static final ChatService instance = ChatService._();

  // Kreyasyon constructor vid pou "ChatService()" ka mache tou nan Provider a san pwoblèm
  factory ChatService() => instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _chatCollection => _firestore.collection("chats");

  //==========================================================
  // USER
  //==========================================================

  String get currentUid => _auth.currentUser!.uid;

  //==========================================================
  // CREATE OR GET CHAT (Pou bouton Profile la ak kòd Provider a)
  //==========================================================

  Future<String> getOrCreateChat(String myUid, String targetUserId) async {
    return await createPrivateChat(targetUserId);
  }

  Future<String> createPrivateChat(String otherUserId) async {
    final ids = [currentUid, otherUserId]..sort();
    final chatId = ids.join("_");
    final doc = _chatCollection.doc(chatId);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        "participants": ids,
        "lastMessage": "",
        "lastSenderId": "",
        "lastMessageTime": FieldValue.serverTimestamp(),
        "isGroup": false,
        "groupName": "",
        "groupPhoto": "",
        "typingStatus": {currentUid: false, otherUserId: false},
        "unreadCount": {
          currentUid: 0,
          otherUserId: 0,
        },
      });
    }

    return chatId;
  }

  //==========================================================
  // CREATE GROUP
  //==========================================================

  Future<String> createGroup({
    required String name,
    required String photo,
    required List<String> members,
  }) async {
    final doc = _chatCollection.doc();
    final ids = [...members];

    if (!ids.contains(currentUid)) {
      ids.add(currentUid);
    }

    final unread = <String, int>{};
    final typing = <String, bool>{};

    for (final uid in ids) {
      unread[uid] = 0;
      typing[uid] = false;
    }

    await doc.set({
      "participants": ids,
      "lastMessage": "",
      "lastSenderId": "",
      "lastMessageTime": FieldValue.serverTimestamp(),
      "isGroup": true,
      "groupName": name,
      "groupPhoto": photo,
      "typingStatus": typing,
      "unreadCount": unread,
    });

    return doc.id;
  }

  //==========================================================
  // SEND MESSAGE
  //==========================================================

  // Vèsyon sa a sipòte tou de fason Provider a ka rele l
  Future<void> sendMessage({
    required String chatId,
    MessageModel? message,
    String? senderId,
    String? targetId,
    String? text,
  }) async {
    final chatRef = _chatCollection.doc(chatId);
    final msgRef = chatRef.collection("messages").doc();
    
    // Jwenn targetId a si se tèks sèlman ki pase
    String finalTargetId = targetId ?? "";
    if (finalTargetId.isEmpty && chatId.contains('_')) {
      finalTargetId = chatId.split('_').firstWhere((id) => id != currentUid, orElse: () => '');
    }

    Map<String, dynamic> data;
    String txtMessage;

    if (message != null) {
      data = message.toMap();
      txtMessage = message.message;
      // Asire nou receiverId la la si modèl la genyen l
      if (data["receiverId"] == null) data["receiverId"] = finalTargetId;
    } else {
      data = {
        "senderId": senderId ?? currentUid,
        "receiverId": finalTargetId, // ✅ Pwòp pou lòt user a ka rekonèt li
        "message": text ?? "",
        "isSeen": false,
      };
      txtMessage = text ?? "";
    }

    data["timestamp"] = FieldValue.serverTimestamp();

    // Itilize yon Batch pou tout bagay monte ansanm anmenmtan
    final batch = _firestore.batch();
    
    // 1. Kreye mesaj la
    batch.set(msgRef, data);

    // 2. Aktyalize dokiman chat prensipal la
    final chat = await chatRef.get();
    Map<String, dynamic> unread = {};
    
    if (chat.exists) {
      final map = chat.data() as Map<String, dynamic>;
      unread = Map<String, dynamic>.from(map["unreadCount"] ?? {});
    }
    
    // Ogmante unreadCount pou lòt moun nan
    if (finalTargetId.isNotEmpty) {
      unread[finalTargetId] = (unread[finalTargetId] ?? 0) + 1;
    }

    batch.update(chatRef, {
      "lastMessage": txtMessage,
      "lastSenderId": currentUid,
      "lastMessageTime": FieldValue.serverTimestamp(),
      "unreadCount": unread,
      "isRead": false,
    });

    await batch.commit();
  }

  //==========================================================
  // GET CHATS (Stream konpatib ak Provider a)
  //==========================================================

 Stream<QuerySnapshot> getMyChats(String myUid) {
    return _chatCollection
        .where("participants", arrayContains: myUid)
        .snapshots();
  }


  // 🔥 SUPPRIMER UNE CONVERSATION
  Future<void> deleteChat(String chatId) async {
    try {
      // 1. Delete chat document
      await _firestore.collection('chats').doc(chatId).delete();

      // 2. Delete messages subcollection (si li egziste)
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception("Erreur suppression chat: $e");
    }
  }


  Stream<List<ChatModel>> getChats() {
    return _chatCollection
        .where("participants", arrayContains: currentUid)
        .orderBy("lastMessageTime", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  //==========================================================
  // GET MESSAGES
  //==========================================================

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _chatCollection
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true) // Nou mete l true pou kòd ChatPage la ka 'reverse: true'
        .snapshots();
  }

  //==========================================================
  // MARK AS READ / SEEN
  //==========================================================

  Future<void> markAsSeen(String chatId, String myUid) async {
    await markChatAsRead(chatId);
  }

  Future<void> markChatAsRead(String chatId) async {
    await _chatCollection.doc(chatId).update({
      "unreadCount.$currentUid": 0,
    });

    final messages = await _chatCollection
        .doc(chatId)
        .collection("messages")
        .where("receiverId", isEqualTo: currentUid)
        .where("isSeen", isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {"isSeen": true});
    }
    await batch.commit();
  }

  //==========================================================
  // TYPING STATUS
  //==========================================================

  Future<void> setTypingStatus(String chatId, String uid, bool isTyping) async {
    await _chatCollection.doc(chatId).update({
      'typingStatus.$uid': isTyping,
    });
  }

  //==========================================================
  // DELETE & EDIT & REACTION
  //==========================================================

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _chatCollection
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .update({
      "isDeleted": true,
      "message": "Message supprimé",
    });
  }

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newText,
  }) async {
    await _chatCollection
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .update({
      "message": newText,
      "isEdited": true,
    });
  }

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    await _chatCollection
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .update({
      "reactions": FieldValue.arrayUnion([emoji])
    });
  }
}