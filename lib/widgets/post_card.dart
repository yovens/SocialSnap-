import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_snap/services/firestore_service.dart';
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
    final nowLiked = await _service.toggleLike(
      postId: widget.post.postId,
      uid: uid,
    );

    // 🟢 Nou voye notifikasyon SÈLMAN lè se yon LIKE (pa yon UNLIKE).
    // (Oto-notifikasyon sou pwòp pòs ou deja bloke nan sendNotification.)
    if (!nowLiked) return;

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUid.isNotEmpty) {
      final userSnap = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
      if (userSnap.exists && userSnap.data() != null) {
        final userData = userSnap.data()!;

        await _service.sendNotification(
          receiverUid: widget.post.uid, // oswa widget.post.authorUid daprè modèl ou
          senderUid: currentUid,
          senderName: userData['displayName'] ?? 'Quelqu\'un',
          senderProfileImageUrl: userData['profileImageUrl'] ?? '',
          type: 'like',
          postId: widget.post.postId, // 👈 Nou chanje .id pou l vin .postId pou evite erè a
        );
      }
    }
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

                subtitle: const Text(""),


              );
            },
          ),

          // ───────── IMAGE(S) ─────────
          GestureDetector(
            onTap: _openPost,
            child: widget.post.imageUrls.length <= 1
                ? _AspectRatioNetworkImage(
                    imageUrl: widget.post.imageUrl,
                    borderRadius: BorderRadius.circular(12),
                  )
                : Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _AspectRatioNetworkImage(
                        // Nou itilize dimansyon 1e imaj la pou tout carousel la
                        // (se konsa Instagram fè l tou)
                        imageUrl: widget.post.imageUrls.first,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PageView.builder(
                            itemCount: widget.post.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                widget.post.imageUrls[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${widget.post.imageUrls.length} 📷",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
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

          // ───────── HASHTAGS ─────────
          if (widget.post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Text(
                widget.post.hashtags.map((t) => "#$t").join(" "),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
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

// ═════════════════════════════════════════════════════════════
// Widget top-level (DEYÒ _PostCardState) ki afiche yon imaj rezo
// respektan dimansyon (aspect ratio) reyèl li, olye de yon
// height fiks ki koupe imaj la.
// ═════════════════════════════════════════════════════════════
class _AspectRatioNetworkImage extends StatefulWidget {
  final String imageUrl;
  final BorderRadiusGeometry? borderRadius;

  const _AspectRatioNetworkImage({
    required this.imageUrl,
    this.borderRadius,
  });

  @override
  State<_AspectRatioNetworkImage> createState() =>
      _AspectRatioNetworkImageState();
}

class _AspectRatioNetworkImageState extends State<_AspectRatioNetworkImage> {
  double? _ratio; // width / height

  @override
  void initState() {
    super.initState();
    _resolveImageSize();
  }

  @override
  void didUpdateWidget(covariant _AspectRatioNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si imageUrl chanje (ex: kat la reyize pou yon lòt post), nou
    // rekalkile ratio a.
    if (oldWidget.imageUrl != widget.imageUrl) {
      _ratio = null;
      _resolveImageSize();
    }
  }

  void _resolveImageSize() {
    final image = NetworkImage(widget.imageUrl);
    final stream = image.resolve(const ImageConfiguration());
    late ImageStreamListener listener;

    listener = ImageStreamListener((info, _) {
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (mounted) {
        setState(() => _ratio = w / h);
      }
      stream.removeListener(listener);
    }, onError: (error, stackTrace) {
      // Si rezolisyon an echwe, nou itilize yon ratio default 4:5
      if (mounted) {
        setState(() => _ratio = 4 / 5);
      }
      stream.removeListener(listener);
    });

    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (_ratio == null) {
      // Pandan n ap chaje dimansyon an, nou mete yon placeholder 4:5
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Container(
            color: Colors.grey.withOpacity(0.15),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      );
    }

    // Nou limite ratio a EGZAKTMAN tankou Instagram:
    // - 4:5 (0.8) se limit MAKSIMOM pou yon foto vètikal (pòtrè)
    // - 1.91:1 se limit MAKSIMOM pou yon foto orizontal (peyizaj)
    // Nenpòt foto ki pi vètikal pase 4:5 (ex: yon screenshot 9:16)
    // ap KOUPE (crop) pou antre nan 4:5 — se konsa IG fè l, li pa
    // janm kite kat la vin pi long pase sa.
    final clampedRatio = _ratio!.clamp(0.8, 1.91);

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: clampedRatio,
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}