import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/feed_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import '../../widgets/story_circle.dart';
import '../notifications/notifications_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Enpòtan pou FirebaseFirestore
import 'package:firebase_auth/firebase_auth.dart';


class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

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

                  Icon(
                    Icons.camera_alt_outlined,
                    color: isDark ? Colors.white : Colors.black,
                  ),

                  const Spacer(),

                  Text(
                    "SocialSnap",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

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

            // STORIES
            SizedBox(
              height: 95,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (_, index) {
                  return StoryCircle(username: "user$index");
                },
              ),
            ),

            const SizedBox(height: 8),

            // POSTS
            Expanded(
              child: Consumer<FeedProvider>(
                builder: (_, provider, __) {
                  return StreamBuilder<List<PostModel>>(
                    stream: provider.getPostsStream(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!;

                      if (posts.isEmpty) {
                        return const Center(child: Text("Aucun post disponible"));
                      }

                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: posts[index]);
                        },
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