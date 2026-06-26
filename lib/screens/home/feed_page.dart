import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/feed_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';

import '../../services/firestore_service.dart';
import '../../services/imgbb_service.dart';
import '../notifications/notifications_page.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  
  // Fonksyon pou Upload Story
  Future<void> addStory() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
   String? imageUrl = await ImgBBService().uploadImage(imageFile);
      
      if (imageUrl != null) {
        await FirestoreService().addStory(
          uid: FirebaseAuth.instance.currentUser!.uid,
          imageUrl: imageUrl,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Story ajouté avec succès!")),
          );
        }
      }
    }
  }


Widget _buildShortcutItem(
  IconData icon,
  String label,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.25),
                color.withOpacity(0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 26),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

 


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.camera_alt_outlined, color: isDark ? Colors.white : Colors.black),
                  const Spacer(),
                  Text("SocialSnap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const Spacer(),
                 Stack(
  children: [
    IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
      },
    ),
    // Pwen wouj la parèt sèlman si gen notifikasyon
    Positioned(
      right: 8,
      top: 8,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            );
          }
          return const SizedBox.shrink(); // Pa montre anyen si pa gen notifikasyon
        },
      ),
    ),
  ],
)
                ],
              ),
            ),

            // ZÒN STORIES
           // ZÒN QUICK ACTIONS (Ranplasman Stories)
Container(
  height: 100,
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: ListView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
   
children: [

  _buildShortcutItem(Icons.bookmark_border, "Saved", Colors.green, () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved en cours de développement...")),
    );
  }),

  const SizedBox(width: 15),

  _buildShortcutItem(Icons.live_tv, "Live", Colors.red, () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Live en cours de développement...")),
    );
  }),

  const SizedBox(width: 15),

  _buildShortcutItem(Icons.share, "Share", Colors.orange, () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Share en cours de développement...")),
    );
  }),

  const SizedBox(width: 15),

  _buildShortcutItem(Icons.auto_stories, "Stories", Colors.purple, () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Stories en cours de développement...")),
    );
  }),
],

  ),
),

            // ZÒN POSTS
            Expanded(
              child: Consumer<FeedProvider>(
                builder: (_, provider, __) {
                  return StreamBuilder<List<PostModel>>(
                    stream: provider.getPostsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final posts = snapshot.data!;
                      if (posts.isEmpty) return const Center(child: Text("Aucun post disponible"));
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) => PostCard(post: posts[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}