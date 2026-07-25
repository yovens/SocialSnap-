import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ChatModel> _chats = [];
  List<ChatModel> _rawChats = [];
  List<MessageModel> _messages = [];
  List<String> _blockedUserIds = [];

  StreamSubscription? _chatSub;
  StreamSubscription? _blockedSub;
  StreamSubscription? _messageSub;

  bool _isLoading = false;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  String get myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// ==========================================================
  /// LOAD CHATS (REAL TIME + BLOCKED FILTER)
  /// ==========================================================
  void loadChats() {
    if (myUid.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    _chatSub?.cancel();
    _blockedSub?.cancel();

    // 1. Koute lis moun ki bloke yo an tan reyèl
    _blockedSub = _firestore
        .collection('users')
        .doc(myUid)
        .collection('blocked')
        .snapshots()
        .listen((blockedSnap) {
      
      // ID chak dokiman ki nan 'blocked' se UID moun ki bloke a
      _blockedUserIds = blockedSnap.docs.map((doc) => doc.id).toList();

      // Re-filtre chat yo chak fwa lis bloke a chanje
      _applyChatFilter();
    });

    // 2. Koute tout chat yo an tan reyèl
    _chatSub = _chatService.getMyChats(myUid).listen((snapshot) {
      _rawChats = snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _applyChatFilter();
    }, onError: (error) {
      print("Erè loadChats: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  /// ==========================================================
  /// FILTRE CHAT YO (KACHE MOUN KI BLOKE YO)
  /// ==========================================================
  void _applyChatFilter() {
    final List<ChatModel> filtered = [];

    for (var chat in _rawChats) {
      final targetId = chat.participants.firstWhere(
        (id) => id != myUid,
        orElse: () => '',
      );

      // Si moun nan PA nan lis bloke nou an, nou afiche chat la
      if (targetId.isNotEmpty && !_blockedUserIds.contains(targetId)) {
        filtered.add(chat);
      }
    }

    _chats = filtered;
    _isLoading = false;
    notifyListeners();
  }

  /// ==========================================================
  /// DELETE CHAT
  /// ==========================================================
  Future<void> deleteChat(String chatId) async {
    try {
      await _chatService.deleteChat(chatId);
      _chats.removeWhere((chat) => chat.chatId == chatId);
      notifyListeners();
    } catch (e) {
      print("Erè nan ChatProvider.deleteChat: $e");
    }
  }

  /// ==========================================================
  /// LOAD MESSAGES FOR A CHAT (REAL TIME + BLOCKED FILTER)
  /// ==========================================================
  void loadMessages(String chatId) {
    if (myUid.isEmpty) return;

    _messageSub?.cancel();
    _messageSub = _chatService.getMessages(chatId).listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((msg) => !_blockedUserIds.contains(msg.senderId)) // Retire mesaj moun ki bloke
          .toList();

      notifyListeners();
    });
  }

  /// ==========================================================
  /// KREYE OSWA JWENN YON CHAT
  /// ==========================================================
  Future<String> getOrCreateChatRoom(String targetUserId) async {
    if (myUid.isEmpty) return '';
    return await _chatService.getOrCreateChat(myUid, targetUserId);
  }

  /// ==========================================================
  /// VOYE MESAJ (AK VERIFIKASYON BLOKAJ)
  /// ==========================================================
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String type = 'text',
  }) async {
    if (myUid.isEmpty || text.trim().isEmpty) return;

    String targetId = '';

    try {
      final currentChat = _chats.firstWhere((c) => c.chatId == chatId);
      targetId = currentChat.participants.firstWhere((p) => p != myUid, orElse: () => '');
    } catch (_) {
      String cleanId = chatId.replaceAll(myUid, '').replaceAll('_', '');
      if (cleanId.isNotEmpty) {
        targetId = cleanId;
      }
    }

    if (targetId.isEmpty) {
      print("Erè: Pa ka jwenn targetId pou chat sa a: $chatId");
      return;
    }

    // VERIFIKASYON BLOKAJ (Si youn nan nou bloke lòt)
    final iBlocked = await _firestore
        .collection('users')
        .doc(myUid)
        .collection('blocked')
        .doc(targetId)
        .get();

    final theyBlockedMe = await _firestore
        .collection('users')
        .doc(targetId)
        .collection('blocked')
        .doc(myUid)
        .get();

    if (iBlocked.exists || theyBlockedMe.exists) {
      print("Aksyon anile: Moun sa a bloke oswa li bloke w.");
      return;
    }

    await _chatService.sendMessage(
      chatId: chatId,
      senderId: myUid,
      targetId: targetId,
      text: text.trim(),
      type: type,
    );
  }

  /// ==========================================================
  /// MARK AS READ
  /// ==========================================================
  Future<void> markAsRead(String chatId) async {
    if (myUid.isEmpty) return;
    await _chatService.markAsSeen(chatId, myUid);
  }

  /// ==========================================================
  /// UPDATE STATUS TYPING
  /// ==========================================================
  Future<void> updateTyping(String chatId, bool isTyping) async {
    if (myUid.isEmpty) return;
    await _chatService.setTypingStatus(chatId, myUid, isTyping);
  }

  /// ==========================================================
  /// CLEAR MESSAGES
  /// ==========================================================
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _blockedSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }
}