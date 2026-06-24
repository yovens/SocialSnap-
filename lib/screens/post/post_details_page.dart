import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';

import '../../models/post_model.dart';
import '../../services/firestore_service.dart';

class PostDetailsPage extends StatefulWidget {
  final PostModel post;

  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _commentCtrl = TextEditingController();

  String get postId => widget.post.postId;

  final String uid = "current_user_id";
  final String username = "current_user";

  bool _liked = false;

  // ───────────────── LIKE ─────────────────
  Future<void> toggleLike() async {
    await _service.toggleLike(postId: postId, uid: uid);

    await _service.sendNotification(
      receiverUid: widget.post.uid,
      senderUid: uid,
      type: "like",
      postId: postId,
    );

    setState(() => _liked = !_liked);
  }

  // ───────────────── COMMENT ─────────────────
  Future<void> addComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;

    await _service.addComment(
      postId: postId,
      uid: uid,
      username: username,
      text: _commentCtrl.text.trim(),
    );

    await _service.sendNotification(
      receiverUid: widget.post.uid,
      senderUid: uid,
      type: "comment",
      postId: postId,
    );

    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : Colors.white,

      body: Column(
        children: [

          // ───────── IMAGE ZOOM + DOUBLE TAP ─────────
          Expanded(
            child: GestureDetector(
              onDoubleTap: toggleLike,
              child: PhotoView(
                imageProvider:
                    NetworkImage(widget.post.imageUrl),
                backgroundDecoration: BoxDecoration(
                  color: isDark
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ),

          // ───────── BOTTOM PANEL ─────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // ❤️ LIKES REAL TIME
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('likes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final likes =
                        snapshot.data?.docs.length ?? 0;

                    return Text(
                      "$likes likes",
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 6),

                // USERNAME
                Text(
                  widget.post.username,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // CAPTION
                Text(
                  widget.post.caption,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // ───────── COMMENTS LIST ─────────
                StreamBuilder<QuerySnapshot>(
                  stream: _service.getComments(postId),
                  builder: (context, snapshot) {
                    final comments =
                        snapshot.data?.docs ?? [];

                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final data = comments[index]
                              .data() as Map<String, dynamic>;

                          final commentId =
                              comments[index].id;

                          return ListTile(
                            dense: true,
                            title: Text(
                              data['username'] ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              data['text'] ?? "",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            trailing: data['uid'] == uid
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _service.deleteComment(
                                        postId: postId,
                                        commentId: commentId,
                                      );
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ───────── COMMENT INPUT ─────────
                Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              "Ajouter un commentaire...",
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey
                                : Colors.black54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: addComment,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}