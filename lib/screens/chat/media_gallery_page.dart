import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MediaGalleryPage extends StatelessWidget {
  final String chatId;

  const MediaGalleryPage({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Médias partagés"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('imageUrl', isNotEqualTo: '')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aucun média partagé pour le moment."),
            );
          }

          final mediaDocs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: mediaDocs.length,
            itemBuilder: (context, index) {
              final data = mediaDocs[index].data() as Map<String, dynamic>;
              final imageUrl = data['imageUrl'] ?? '';

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}