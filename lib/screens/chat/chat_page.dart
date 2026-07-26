import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import '../../models/user_model.dart'; // 💡 Assure-toi d'avoir le bon chemin vers UserModel
import 'chat_info_page.dart'; // 💡 Import de la page ChatInfoPage
import '../../l10n/app_localizations.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {


  Future<String?> uploadImageToImgBB(File imageFile) async {
  try {
    // ⚠️ Mete API Key ImgBB pa w la la
    const String apiKey = '6af56b5d2a71117a5a3e330a2e3ac5bc'; 

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      return json['data']['url'] as String?;
    } else {
      print("Erreur ImgBB: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Erreur upload image: $e");
    return null;
  }
}
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        final chatProvider = context.read<ChatProvider>();
        chatProvider.loadMessages(widget.chatId);
        chatProvider.markAsRead(widget.chatId);
      }
    });
  }

  // ================= UTILITAIRE =================
  String _getTargetUid(String chatId) {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final parts = chatId.split('_');

    return parts.firstWhere((id) => id != myUid, orElse: () => '');
  }

  // ================= FORMATAGE HEURE =================
  String _formatHeureSimple(dynamic timestamp) {
    if (timestamp == null) return "--:--";

    DateTime date = (timestamp is Timestamp)
        ? timestamp.toDate()
        : timestamp;

    int heure = date.hour;
    int minute = date.minute;
    String periode = "AM";

    if (heure >= 12) {
      periode = "PM";
      if (heure > 12) heure -= 12;
    }
    if (heure == 0) heure = 12;

    final minStr = minute < 10 ? "0$minute" : "$minute";

    return "$heure:$minStr $periode";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final targetUid = _getTargetUid(widget.chatId);

    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : const Color(0xFFF7F9FB),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),

        // ================= PROFIL UTILISATEUR =================
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(targetUid)
              .snapshots(),

          builder: (context, snapshot) {
            String nom = AppLocalizations.of(context)!.loadingLabel;
            String photo = "";
            bool enLigne = false;
            UserModel? targetUser;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;

              // Création de l'objet UserModel à partir des données Firestore
              targetUser = UserModel.fromMap(data);

              nom = data['username'] ??
                  data['displayName'] ??
                  AppLocalizations.of(context)!.defaultUserName;

              photo = data['profileImageUrl'] ?? "";
              enLigne = data['isOnline'] ?? false;
            }

            // 🟢 GestureDetector permet de cliquer sur la photo et le nom
            return GestureDetector(
              onTap: () {
                if (targetUser != null) {
                // ✅ KÒD KI KORUJE A:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChatInfoPage(
      user: targetUser!,
      chatId: widget.chatId, // 👈 Ajoute liy sa a bò kote user a
    ),
  ),
);
                }
              },
              child: Row(
                children: [
                  // ================= AVATAR =================
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: photo.isNotEmpty
                            ? NetworkImage(photo)
                            : const NetworkImage(
                                "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                              ) as ImageProvider,
                      ),

                      if (enLigne)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.cyan,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 10),

                  // ================= NOM + STATUT =================
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        // ================= HEURE DERNIER MESSAGE =================
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .snapshots(),

                builder: (context, snapshot) {
                  dynamic time;

                  if (snapshot.hasData &&
                      snapshot.data!.exists) {
                    final data =
                        snapshot.data!.data() as Map<String, dynamic>;

                    time = data['lastMessageTime'];
                  }

                  return Text(
                    _formatHeureSimple(time),
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white60
                          : Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // ================= MESSAGES =================
          Expanded(
            child: provider.messages.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.startConversationHint,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = provider.messages[index];

                      return MessageBubble(
                        message: msg,
                        isMe: msg.senderId == provider.myUid,
                      );
                    },
                  ),
          ),

          // ================= INPUT =================
       // ================= INPUT OWSWA MESAJ BLOCAGE =================
StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('blocked')
      .doc(targetUid) // targetUid se ID lòt moun nan
      .snapshots(),
  builder: (context, snapshot) {
    final isBlockedByMe = snapshot.hasData && snapshot.data!.exists;

    // 1. Si ou bloke moun sa a
    if (isBlockedByMe) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
        width: double.infinity,
        child: Text(
          AppLocalizations.of(context)!.blockedUserMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    }

    // 2. Si ou pa bloke l, afiche MessageInput nòmal la
    return MessageInput(
      controller: controller,
      onSend: () {
        final textToSend = controller.text.trim();
        if (textToSend.isNotEmpty) {
          provider.sendMessage(
            chatId: widget.chatId,
            text: textToSend,
          );
          controller.clear();
        }
      },
   onImagePick: () async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70, // Akseleye upload la
  );

  if (image != null && mounted) {
    // 1. Afiche yon ti loading nan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.sendingImage),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );

    // 2. Upload sou ImgBB
    final File file = File(image.path);
    final String? imageUrl = await uploadImageToImgBB(file);

    if (imageUrl != null && mounted) {
      // 3. Voye imaj la atravè Provider / Service
      final provider = context.read<ChatProvider>();
      await provider.sendMessage(
        chatId: widget.chatId,
        text: imageUrl,
        type: 'image', // 👈 Mete type la 'image'
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.imageSendError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
},
    );
  },
)
        ],
      ),
    );
  }
}