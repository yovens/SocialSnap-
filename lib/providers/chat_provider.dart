import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Enpòtan pou QuerySnapshot ka rekonèt

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  StreamSubscription? _chatSub;
  StreamSubscription? _messageSub;
  bool _isLoading = false;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  // Jwenn UID itilizatè a dinamikman depi nan Firebase Auth
  String get myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// ==========================================================
  /// LOAD CHATS (REAL TIME)
  /// ==========================================================

void loadChats() {
    if (myUid.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    _chatSub?.cancel();
    _chatSub = _chatService.getMyChats(myUid).listen((QuerySnapshot snapshot) {
      _chats = snapshot.docs.map((doc) {
        // ✅ doc.id pase kòm dezyèm paramèt pou ChatModel ka gen bon ID a!
        return ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Erè loadChats: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

Future<void> deleteChat(String chatId) async {
    try {
      // Rele sèvis la pou efase l nan Firebase
      await _chatService.deleteChat(chatId);
      
      // Retire l nan lis lokal la imedyatman pou UI a ka dous
      _chats.removeWhere((chat) => chat.chatId == chatId);
      notifyListeners();
    } catch (e) {
      print("Erè nan ChatProvider.deleteChat: $e");
    }
  }

  
  /// ==========================================================
  /// LOAD MESSAGES FOR A CHAT (REAL TIME)
  /// ==========================================================
  void loadMessages(String chatId) {
    _messageSub?.cancel();
    _messageSub = _chatService.getMessages(chatId).listen((QuerySnapshot snapshot) {
      _messages = snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      notifyListeners();
    });
  }

  /// ==========================================================
  /// KREYE OSWA JWENN YON CHAT (Pou Paj Profile la)
  /// ==========================================================
  Future<String> getOrCreateChatRoom(String targetUserId) async {
    if (myUid.isEmpty) return '';
    return await _chatService.getOrCreateChat(myUid, targetUserId);
  }

 /// ==========================================================
  /// VOYE MESAJ (KORÈK AK SEKIRIZE)
  /// ==========================================================
/// ==========================================================
  /// VOYE MESAJ (KORÈK AK DETEKSYON REYÈL)
  /// ==========================================================
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    if (myUid.isEmpty || text.trim().isEmpty) return;

    String targetId = '';

    // Metòd 1: Chache l nan lis chat yo si li la deja nan UI a
    try {
      final currentChat = _chats.firstWhere((c) => c.chatId == chatId);
      targetId = currentChat.participants.firstWhere((p) => p != myUid, orElse: () => '');
    } catch (_) {
      // Metòd 2: Si li poko nan lis la, nou retire myUid la nan chatId a nèt 
      // epi nou netwaye tirè ba yo pou n jwenn lòt UID a!
      String cleanId = chatId.replaceAll(myUid, '').replaceAll('_', '');
      if (cleanId.isNotEmpty) {
        targetId = cleanId;
      }
    }

    if (targetId.isEmpty) {
      print("Erè: Pa ka jwenn targetId pou chat sa a: $chatId");
      return;
    }

    // Voye mesaj la bay ChatService
    await _chatService.sendMessage(
      chatId: chatId,
      senderId: myUid,
      targetId: targetId,
      text: text.trim(),
    );
  }

  /// ==========================================================
  /// MARK AS READ (Reset unreadCount a 0 lè ou nan ChatPage)
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
  /// CLEAR MESSAGES (UI ONLY)
  /// ==========================================================
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }
}