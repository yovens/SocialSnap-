import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ==========================================================
/// UPLOAD SERVICE (ImgBB VERSION)
/// - Upload images via ImgBB API
/// - Save media messages to Firestore
/// ==========================================================
class UploadService {
  UploadService._();

  static final UploadService instance = UploadService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUid => _auth.currentUser!.uid;

  /// ⚠️ Mete API KEY ImgBB ou la isit la
  final String _apiKey = "6af56b5d2a71117a5a3e330a2e3ac5bc";

  /// ==========================================================
  /// UPLOAD IMAGE TO IMGBB
  /// ==========================================================
  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse("https://api.imgbb.com/1/upload?key=$_apiKey");

    final request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        "image",
        imageFile.path,
      ),
    );

    final response = await request.send();
    final resBody = await http.Response.fromStream(response);

    final data = jsonDecode(resBody.body);

    if (data["success"] == true) {
      return data["data"]["url"];
    } else {
      throw Exception("ImgBB upload failed");
    }
  }

  /// ==========================================================
  /// SEND IMAGE MESSAGE
  /// ==========================================================
  Future<void> sendImageMessage({
    required String chatId,
    required String imageUrl,
  }) async {
    final msgRef = _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc();

    await msgRef.set({
      "id": msgRef.id,
      "senderId": currentUid,
      "message": "",
      "mediaUrl": imageUrl,
      "type": "image",
      "timestamp": FieldValue.serverTimestamp(),
      "isSeen": false,
      "isEdited": false,
      "isDeleted": false,
      "reactions": [],
    });

    // update chat last message
    await _firestore.collection("chats").doc(chatId).update({
      "lastMessage": "📷 Image",
      "lastSenderId": currentUid,
      "lastMessageTime": FieldValue.serverTimestamp(),
    });
  }
}