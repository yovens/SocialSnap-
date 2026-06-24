import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post_model.dart';
import '../screens/profile/profile_page.dart';
import '../services/firestore_service.dart';
import '../screens/post/post_details_page.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirestoreService _service = FirestoreService();

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // ───────── LIKE TOGGLE ─────────
  void _toggleLike() async {
    await _service.toggleLike(
      postId: widget.post.postId,
      uid: uid,
    );

    await _service.sendNotification(
      receiverUid: widget.post.uid,
      senderUid: uid,
      type: "like",
      postId: widget.post.postId,
    );
  }

  // ───────── OPEN POST DETAILS ─────────
  void _openPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsPage(post: widget.post),
      ),
    );
  }

  // ───────── OPEN PROFILE ─────────
  void _openProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(uid: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
       color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ───────── USER HEADER (REAL TIME) ─────────
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.post.uid)
                .snapshots(),
            builder: (context, snapshot) {

              String username = widget.post.username;
              String? profileImage;

              if (snapshot.hasData && snapshot.data!.exists) {
                final data =
                    snapshot.data!.data() as Map<String, dynamic>;

                username = data['username'] ?? username;
                profileImage = data['profileImageUrl'];
              }

              return ListTile(
                leading: GestureDetector(
                  onTap: () => _openProfile(widget.post.uid),
                  child: CircleAvatar(
                    backgroundImage: profileImage != null
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),

                title: GestureDetector(
                  onTap: () => _openProfile(widget.post.uid),
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                subtitle: const Text("Just now"),

                trailing: const Icon(Icons.more_horiz),
              );
            },
          ),

          // ───────── IMAGE ─────────
          GestureDetector(
            onTap: _openPost,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.post.imageUrl,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ───────── CAPTION ─────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post.caption,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 10),

          // ───────── ACTIONS ─────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [

                // ❤️ LIKE COUNT + BUTTON
                StreamBuilder<bool>(
                  stream: _service.isLiked(widget.post.postId, uid),
                  builder: (context, snapshot) {
                    final liked = snapshot.data ?? false;

                    return IconButton(
                      icon: Icon(
                        liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: liked ? Colors.red : Colors.black,
                      ),
                      onPressed: _toggleLike,
                    );
                  },
                ),

                StreamBuilder<int>(
                  stream: _service.likesCount(widget.post.postId),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Text("$count");
                  },
                ),

                const SizedBox(width: 10),

                // 💬 COMMENTS OPEN
                StreamBuilder<QuerySnapshot>(
                  stream: _service.getComments(widget.post.postId),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;

                    return TextButton.icon(
                      onPressed: _openPost,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text("$count"),
                    );
                  },
                ),

                const Spacer(),

                const Icon(Icons.bookmark_border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}