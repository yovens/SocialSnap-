import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';

import '../post/post_details_page.dart';
import '../profile/widgets/user_posts_grid.dart';

import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isMyProfile = currentUid == uid;

    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF121212) : Colors.white,

      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .snapshots(),

          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData =
                userSnapshot.data!.data() as Map<String, dynamic>;

            final user = UserModel.fromMap(userData);

            // POSTS STREAM
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("uid", isEqualTo: uid)
                  .snapshots(),

              builder: (context, postSnapshot) {
                if (!postSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = postSnapshot.data!.docs;

                final postModels = posts.map((doc) {
                  return PostModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      // ================= PROFILE HEADER =================
                    ProfileHeader(
  user: user,
  postsCount: postModels.length,
  isMyProfile: isMyProfile,
  onEdit: isMyProfile ? () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(user: user),
      ),
    );
  } : null,
  onSettings: isMyProfile ? () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsPage(),
      ),
    );
  } : null,
),

                      const SizedBox(height: 25),

                      // ================= POSTS =================
                      UserPostsGrid(
                        posts: postModels,
                        onPostTap: (post) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailsPage(post: post),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}