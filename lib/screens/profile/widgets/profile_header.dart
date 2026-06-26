import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel user;
  final int postsCount;

  final bool isMyProfile;

  final VoidCallback? onEdit;
  final VoidCallback? onSettings;

  

  const ProfileHeader({
  super.key,
  required this.user,
  required this.postsCount,
  required this.isMyProfile,
  this.onEdit,
  this.onSettings,
});

  @override
  State<ProfileHeader> createState() =>
      _ProfileHeaderState();
}

class _ProfileHeaderState
    extends State<ProfileHeader> {

  final FirestoreService _service =
      FirestoreService();

  bool isFollowing = false;

  String get currentUid =>
      FirebaseAuth.instance.currentUser?.uid ??
      "";

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {

    if (widget.isMyProfile) return;

    final doc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('followers')
        .doc(currentUid)
        .get();

    if (mounted) {
      setState(() {
        isFollowing = doc.exists;
      });
    }
  }

  Future<void> _toggleFollow() async {

    if (isFollowing) {

      await _service.unfollow(
        myUid: currentUid,
        targetUid: widget.user.uid,
      );

      setState(() {
        isFollowing = false;
      });

    } else {

      await _service.follow(
        myUid: currentUid,
        targetUid: widget.user.uid,
      );

      await _service.sendNotification(
        receiverUid: widget.user.uid,
        senderUid: currentUid,
        type: "follow",
      );

      setState(() {
        isFollowing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final dark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Column(
      children: [

        // PHOTO PROFIL
        Stack(
          alignment: Alignment.center,
          children: [

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF00F0FF,
                    ).withOpacity(0.5),
                    blurRadius: 35,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

            CircleAvatar(
              radius: 55,
              backgroundImage:
                  NetworkImage(
                widget.user.profileImageUrl,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Text(
          widget.user.displayName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: dark
                ? Colors.white
                : Colors.black,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          "@${widget.user.username}",
          style: TextStyle(
            color: dark
                ? Colors.white60
                : Colors.black54,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          widget.user.bio,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // STATS
       Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: dark ? const Color(0xFF1A1A1A) : Colors.white,
    borderRadius: BorderRadius.circular(22),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [

      _StatStream(
        title: "Posts",
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.user.uid)
            .snapshots(),
      ),

      _StatStream(
        title: "Followers",
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .collection('followers')
            .snapshots(),
      ),

      _StatStream(
        title: "Following",
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .collection('following')
            .snapshots(),
      ),
    ],
  ),
),

        const SizedBox(height: 20),


     

        // STORY (Sèlman sou pwofil pa w)
       
            


        // BOUTONS
        widget.isMyProfile

            ? Row(
                children: [

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          widget.onEdit,
                      icon: const Icon(
                        Icons.edit,
                      ),
                      label: const Text(
                        "Modifier Profil",
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                      color: dark
                          ? Colors.white10
                          : Colors
                              .grey
                              .shade200,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                      ),
                      onPressed:
                          widget.onSettings,
                    ),
                  ),
                ],
              )

            : Row(
                children: [

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _toggleFollow,
                      icon: Icon(
                        isFollowing
                            ? Icons.check
                            : Icons.person_add,
                      ),
                      label: Text(
                        isFollowing
                            ? "Suivi"
                            : "Suivre",
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: () {

                        // ouvrir chat
                      },
                      icon: const Icon(
                        Icons.chat,
                      ),
                      label: const Text(
                        "Message",
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
class _StatStream extends StatelessWidget {
  final String title;
  final Stream<QuerySnapshot> stream;

  const _StatStream({
    required this.title,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return Column(
          children: [
            Text(
              "$count",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(title),
          ],
        );
      },
    );
  }
}
class _StatItem extends StatelessWidget {

  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 22,
          ),
        ),

        Text(title),
      ],
    );
  }
}