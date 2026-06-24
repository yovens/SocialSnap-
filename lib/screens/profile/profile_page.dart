import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../profile/widgets/user_posts_grid.dart';
import '../post/post_details_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'package:flutter/material.dart';


import '../../services/firestore_service.dart';
import 'widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(

        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .snapshots(),

          builder: (context, userSnapshot) {

            if (!userSnapshot.hasData) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            final user = UserModel.fromMap(
              userSnapshot.data!.data()
                  as Map<String, dynamic>,
            );

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("uid",
                      isEqualTo: uid)
                  .snapshots(),

              builder: (context, postSnapshot) {

                if (!postSnapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final posts =
                    postSnapshot.data!.docs;

                return SingleChildScrollView(

                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      ProfileHeader(
                        user: user,
                        postsCount:
                            posts.length,

                        onEdit: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfilePage(
                                user: user,
                              ),
                            ),
                          );
                        },

                        onSettings: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SettingsPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                    UserPostsGrid(
  posts: posts
     .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
.toList(),

  onPostTap: (post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsPage(
          post: post,
        ),
      ),
    );
  },
),
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