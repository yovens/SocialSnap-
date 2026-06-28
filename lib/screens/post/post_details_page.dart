import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final User? currentUser = FirebaseAuth.instance.currentUser;

  String? replyToCommentId;
  String? replyToUsername;

  bool liked = false;

  String get postId => widget.post.postId;


  // ───────────────── LIKE ─────────────────
  Future<void> toggleLike() async {
    if (currentUser == null) return;

    final uid = currentUser!.uid;

    await _service.toggleLike(postId: postId, uid: uid);

final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
if (currentUid.isNotEmpty) {
  final userSnap = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
  if (userSnap.exists && userSnap.data() != null) {
    final userData = userSnap.data()!;
    await _service.sendNotification(
      receiverUid: widget.post.uid,
      senderUid: currentUid,
      senderName: userData['displayName'] ?? 'Quelqu\'un',
      senderProfileImageUrl: userData['profileImageUrl'] ?? '',
      type: 'like',
      postId: widget.post.postId, // 👈 Nou itilize .postId
    );
  }
}

    setState(() => liked = !liked);
  }

  // ───────────────── COMMENT / REPLY ─────────────────
Future<void> addComment() async {
  if (_commentCtrl.text.trim().isEmpty || currentUser == null) return;

  final uid = currentUser!.uid;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  final userData = userDoc.data() ?? {};

  final username = userData['username'] ?? "user";
  final profileImageUrl = userData['profileImageUrl'] ?? "";

  // ✅ SÈL INSERT (NO DUPLICATE)
  await FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .add({
    "uid": uid,
    "username": username,
    "profileImageUrl": profileImageUrl,
    "text": _commentCtrl.text.trim(),
    "replyTo": replyToCommentId,
    "createdAt": FieldValue.serverTimestamp(),
  });

  // notification
 final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
if (currentUid.isNotEmpty) {
  final userSnap = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
  if (userSnap.exists && userSnap.data() != null) {
    final userData = userSnap.data()!;
    await _service.sendNotification(
      receiverUid: widget.post.uid,
      senderUid: currentUid,
      senderName: userData['displayName'] ?? 'Quelqu\'un',
      senderProfileImageUrl: userData['profileImageUrl'] ?? '',
      type: 'comment',
      postId: widget.post.postId, // 👈 Nou itilize .postId
    );
  }
}

  _commentCtrl.clear();

  setState(() {
    replyToCommentId = null;
    replyToUsername = null;
  });
}

  // ───────────────── UI ─────────────────
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF121212) : Colors.white,
            // ✅ AJOUTE APPBAR LA ISIT LA
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: dark ? Colors.white : Colors.black),
        actions: [
          // Bouton efase (Sèlman pou pwopriyetè pòs la)
          if (widget.post.uid == currentUser?.uid)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Supprimer ?"),
                    content: const Text("Voulez-vous supprimer ce post définitivement ?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Oui")),
                    ],
                  ),
                );

                if (confirm == true) {
                  // ✅ ITILIZE SÈVIS LA POU NETWAYE DONE YO
                  await _service.deletePost(postId); 
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [

          // ───────── IMAGE ─────────
          Expanded(
            child: GestureDetector(
              onDoubleTap: toggleLike,
              child: PhotoView(
                imageProvider: NetworkImage(widget.post.imageUrl),
                backgroundDecoration: BoxDecoration(
                  color: dark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),

          // ───────── INFO ─────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // USER TAP
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/profile",
                      arguments: widget.post.uid,
                    );
                  },
                  child: Text(
                    widget.post.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.post.caption,
                  style: TextStyle(
                    color: dark ? Colors.white70 : Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // ───────── COMMENTS ─────────
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {

                    final comments = snapshot.data?.docs ?? [];

                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final data = comments[index].data() as Map<String, dynamic>;
                          final commentId = comments[index].id;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // PROFILE PIC
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  data['profileImageUrl'] ?? "",
                                ),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    // USERNAME CLICKABLE
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          "/profile",
                                          arguments: data['uid'],
                                        );
                                      },
                                      child: Text(
                                        data['username'] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Text(data['text'] ?? ""),

                                    Row(
                                      children: [

                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              replyToCommentId = commentId;
                                              replyToUsername = data['username'];
                                              _commentCtrl.text = "@${data['username']} ";
                                            });
                                          },
                                          child: const Text("Reply"),
                                        ),

                                        if (data['uid'] == currentUser?.uid)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(postId)
                                                  .collection('comments')
                                                  .doc(commentId)
                                                  .delete();
                                            },
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // ───────── INPUT ─────────
                Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        style: TextStyle(
                          color: dark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: replyToUsername != null
                              ? "Reply to @$replyToUsername..."
                              : "Ajouter un commentaire...",
                          hintStyle: TextStyle(
                            color: dark ? Colors.grey : Colors.black54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: dark ? Colors.white : Colors.black,
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