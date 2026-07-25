import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

  // ───────────────── COMMENT TILE (rasin oswa repons) ─────────────────
  Widget _buildCommentTile({
    required String commentId,
    required Map<String, dynamic> data,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
                      child: const Text("Répondre"),
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
      ),
    );
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

          // ───────── IMAGE(S) ─────────
          Expanded(
            child: GestureDetector(
              onDoubleTap: toggleLike,
              child: widget.post.imageUrls.length <= 1
                  ? PhotoView(
                      imageProvider: NetworkImage(widget.post.imageUrl),
                      backgroundDecoration: BoxDecoration(
                        color: dark ? Colors.black : Colors.white,
                      ),
                    )
                  : PhotoViewGallery.builder(
                      itemCount: widget.post.imageUrls.length,
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(widget.post.imageUrls[index]),
                        );
                      },
                      backgroundDecoration: BoxDecoration(
                        color: dark ? Colors.black : Colors.white,
                      ),
                      pageController: PageController(),
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

                if (widget.post.hashtags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.post.hashtags.map((t) => "#$t").join(" "),
                      style: TextStyle(
                        color: dark ? const Color(0xFF22E1D0) : const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // ───────── COMMENTS (fil de réponses) ─────────
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final allDocs = snapshot.data?.docs ?? [];

                    // 🟢 Separe kòmantè "rasin" yo (pa gen replyTo) ak repons yo,
                    // epi gwoupe chak repons anba kòmantè paran li (fil diskisyon).
                    final rootComments = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['replyTo'] == null;
                    }).toList();

                    Map<String, List<QueryDocumentSnapshot>> repliesByParent = {};
                    for (final doc in allDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final parentId = data['replyTo'] as String?;
                      if (parentId != null) {
                        repliesByParent.putIfAbsent(parentId, () => []).add(doc);
                      }
                    }

                    // Pi resan yo anwo pami kòmantè rasin yo.
                    final orderedRoots = rootComments.reversed.toList();

                    return SizedBox(
                      height: 220,
                      child: ListView.builder(
                        itemCount: orderedRoots.length,
                        itemBuilder: (context, index) {
                          final rootDoc = orderedRoots[index];
                          final rootData = rootDoc.data() as Map<String, dynamic>;
                          final replies = repliesByParent[rootDoc.id] ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCommentTile(
                                commentId: rootDoc.id,
                                data: rootData,
                              ),
                              // 🟢 Repons yo, mete yon ti dekalaj pou montre yo
                              // fè pati fil diskisyon kòmantè paran an.
                              for (final replyDoc in replies)
                                Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: _buildCommentTile(
                                    commentId: replyDoc.id,
                                    data: replyDoc.data() as Map<String, dynamic>,
                                  ),
                                ),
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