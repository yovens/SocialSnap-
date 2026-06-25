import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Varyab pou estoke dokiman yo pou bouton an ka wè yo
  List<QueryDocumentSnapshot> _currentDocs = [];

  String get currentUid => FirebaseAuth.instance.currentUser!.uid;

  // Fonksyon efasman an
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

          _currentDocs = snapshot.data!.docs; // Nou mete ajou lis la isit la

          if (_currentDocs.isEmpty) {
            return const Center(child: Text("Aucune notification"));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _currentDocs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = _currentDocs[index].data() as Map<String, dynamic>;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(_getIcon(data['type']), color: Colors.blue),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getText(data['type']), style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text("Il y a quelques instants", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) => type == "like" ? Icons.favorite : type == "comment" ? Icons.comment : Icons.person_add;
  String _getText(String type) => type == "like" ? "Quelqu’un a aimé votre publication" : type == "comment" ? "Quelqu’un a commenté votre publication" : "Un nouvel abonné";
}