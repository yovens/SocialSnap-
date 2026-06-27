import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
            String nom = "Chargement...";
            String photo = "";
            bool enLigne = false;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data =
                  snapshot.data!.data() as Map<String, dynamic>;

              nom = data['username'] ??
                  data['displayName'] ??
                  "Utilisateur";

              photo = data['profileImageUrl'] ?? "";
              enLigne = data['isOnline'] ?? false;
            }

            return Row(
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
                            ),
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
                    Text(
                      enLigne ? "en ligne" : "hors ligne",
                      style: TextStyle(
                        color: enLigne ? Colors.cyan : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
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
                ? const Center(
                    child: Text(
                      "Commencez la conversation...",
                      style: TextStyle(color: Colors.grey),
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
                        isMe:
                            msg.senderId == provider.myUid,
                      );
                    },
                  ),
          ),

          // ================= INPUT =================
          MessageInput(
            controller: controller,

            onSend: () {
              final text = controller.text.trim();

              if (text.isNotEmpty) {
                provider.sendMessage(
                  chatId: widget.chatId,
                  text: text,
                );

                controller.clear();
              }
            },

            onImagePick: () async {
              // 📷 futur: upload image Firebase Storage / ImgBB
            },
          ),
        ],
      ),
    );
  }
}