import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../profile/profile_page.dart'; 
import '../create/add_post_page.dart';
import '../../providers/feed_provider.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';

import '../../widgets/post_card.dart';
import '../../widgets/create_post_bar.dart';

import '../../services/firestore_service.dart';
import '../../services/imgbb_service.dart';

import '../notifications/notifications_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final Color cyan = const Color(0xFF00F0FF);

  Future<void> addStory() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      File imageFile = File(file.path);

      String? url = await ImgBBService().uploadImage(imageFile);

      if (url != null) {
        await FirestoreService().addStory(
          uid: FirebaseAuth.instance.currentUser!.uid,
          imageUrl: url,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Story ajoutée ✨")),
          );
        }
      }
    }
  }

  Widget _glassCard(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cyan.withOpacity(isDark ? 0.15 : 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: cyan.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 1,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildShortcutItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.35),
                  color.withOpacity(0.10),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 15,
                )
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
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [

            /// ================= APP BAR =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _glassCard(
                context,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [

                      Icon(Icons.camera_alt_outlined, color: textColor),

                      const Spacer(),

                      Text(
                        "SocialSnap",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const Spacer(),

                      Stack(
                        children: [

                          IconButton(
                            icon: Icon(Icons.notifications, color: textColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                ),
                              );
                            },
                          ),

                          Positioned(
                            right: 8,
                            top: 8,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('notifications')
                                  .where(
                                    'receiverUid',
                                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!.docs.isNotEmpty) {
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .get(),
  builder: (context, snapshot) {
    UserModel? fetchedUserModel;

    if (snapshot.hasData && snapshot.data!.data() != null) {
      fetchedUserModel = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
    }

    return CreatePostBar(
      userModel: fetchedUserModel,
      onProfileTap: () {
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePage(uid: currentUid),
          ),
        );
      },
      onBarTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddPostPage(), // Retire "const" si AddPostPage bay erè
          ),
        );
      },
    );
  },
),

const SizedBox(height: 10),



            /// ================= POSTS =================
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
                        return Center(
                          child: Text(
                            "Aucun post disponible",
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
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