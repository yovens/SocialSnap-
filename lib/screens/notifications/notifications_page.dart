import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<QueryDocumentSnapshot> _currentDocs = [];

  String get currentUid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _clearAllNotifications() async {
    if (_currentDocs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in _currentDocs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Toutes les notifications ont été supprimées.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () async {
              bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Tout supprimer ?"),
                      content: const Text("Voulez-vous supprimer toutes les notifications ?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non")),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Oui")),
                      ],
                    ),
                  ) ??
                  false;

              if (confirm) {
                await _clearAllNotifications();
              }
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverUid', isEqualTo: currentUid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          _currentDocs = snapshot.data!.docs;

          if (_currentDocs.isEmpty) {
            return const Center(child: Text("Aucune notification"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _currentDocs.length,
            itemBuilder: (context, index) {
              final data = _currentDocs[index].data() as Map<String, dynamic>;
              
              // Nou rale enfòmasyon moun ki fè aksyon an nan dokiman an
              final senderName = data['senderName'] ?? "Quelqu'un";
              final senderPhoto = data['senderProfileImageUrl'] ?? "";
              final type = data['type'] ?? "like";

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.15), // Ti ekla cyan fluo
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 1️⃣ FOTO PROFIL MOUN KI FÈ AKSYON AN
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF).withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: senderPhoto.isNotEmpty
                                      ? Image.network(senderPhoto, fit: BoxFit.cover)
                                      : Container(
                                          color: const Color(0xFF00E5FF).withOpacity(0.1),
                                          child: Center(
                                            child: Text(
                                              senderName[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFF00E5FF),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              // Ti ti kreyòl badj pou montre si se yon Like oswa kòmantè
                              CircleAvatar(
                                radius: 9,
                                backgroundColor: _getIconColor(type),
                                child: Icon(_getIcon(type), size: 10, color: Colors.white),
                              ),
                            ],
                          ),
                          
                          const SizedBox(width: 14),
                          
                          // 2️⃣ TÈKS PRESI KI GEN NON ITILIZATÈ A
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "$senderName ", // Non moun lan an fonse
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: _getNotificationText(type)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Il y a quelques instants",
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white60 : Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type == "like") return Icons.favorite_rounded;
    if (type == "comment") return Icons.chat_bubble_rounded;
    return Icons.person_add_alt_1_rounded;
  }

  Color _getIconColor(String type) {
    if (type == "like") return Colors.redAccent;
    if (type == "comment") return const Color(0xFF00E5FF); // Cyan pou match ak style la
    return Colors.purpleAccent;
  }

  String _getNotificationText(String type) {
    if (type == "like") return "a aimé votre publication.";
    if (type == "comment") return "a commenté votre publication.";
    return "a commencé à vous suivre.";
  }
}