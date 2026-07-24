import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';

import '../post/post_details_page.dart';
import '../profile/widgets/user_posts_grid.dart';

import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'user_list_page.dart';
import 'widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  /// Fonksyon pou rekiperer lis UIDs yo nan Firestore anvan nou louvri UserListPage
  Future<List<String>> _getUserIds(String collectionName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(collectionName)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
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
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
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
                        onEdit: isMyProfile
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfilePage(user: user),
                                  ),
                                );
                              }
                            : null,
                        onSettings: isMyProfile
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsPage(),
                                  ),
                                );
                              }
                            : null,

                        /// 🟢 OUVÈ LIS ABONNÉS (Followers)
                        onFollowersTap: () async {
                          final userIds = await _getUserIds('followers');
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserListPage(
                                  title: "Abonnés",
                                  userIds: userIds,
                                ),
                              ),
                            );
                          }
                        },

                        /// 🟢 OUVÈ LIS ABONNEMENTS (Following)
                        onFollowingTap: () async {
                          final userIds = await _getUserIds('following');
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserListPage(
                                  title: "Abonnements",
                                  userIds: userIds,
                                ),
                              ),
                            );
                          }
                        },
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