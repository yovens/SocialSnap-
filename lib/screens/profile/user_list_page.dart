import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import 'profile_page.dart';

class UserListPage extends StatelessWidget {
  final String title; // "Abonnés" oswa "Abonnements"
  final List<String> userIds; // Lis UIDs moun yo

  const UserListPage({
    super.key,
    required this.title,
    required this.userIds,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: userIds.isEmpty
          ? Center(
              child: Text(
                "Aucun $title pour le moment.",
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: userIds.length,
              itemBuilder: (context, index) {
                final targetUid = userIds[index];

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(targetUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const SizedBox.shrink();
                    }

                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final user = UserModel.fromMap(userData);

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: user.profileImageUrl.isNotEmpty
                            ? NetworkImage(user.profileImageUrl)
                            : null,
                        child: user.profileImageUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        user.username.isNotEmpty
                            ? user.username
                            : "Utilisateur",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.displayName),
                      onTap: () {
                        // Ouvè profil moun lan lè w klike sou li
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilePage(uid: user.uid),
                          ),
                        );
                      },
                      trailing: currentUid == targetUid
                          ? null // Pa afiche bouton swiv si se kont pa w la
                          : _FollowButton(
                              currentUid: currentUid,
                              targetUid: targetUid,
                            ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// 🟢 Bouton Suivre / Abonné dinamik
class _FollowButton extends StatelessWidget {
  final String currentUid;
  final String targetUid;

  const _FollowButton({
    required this.currentUid,
    required this.targetUid,
  });

  Future<void> _toggleFollow(bool isFollowing) async {
    final batch = FirebaseFirestore.instance.batch();

    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUid);
    final targetUserRef =
        FirebaseFirestore.instance.collection('users').doc(targetUid);

    // Sub-collections refs
    final myFollowingDoc = currentUserRef.collection('following').doc(targetUid);
    final targetFollowerDoc = targetUserRef.collection('followers').doc(currentUid);

    if (isFollowing) {
      // Unfollow
      batch.delete(myFollowingDoc);
      batch.delete(targetFollowerDoc);
      batch.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});
      batch.update(targetUserRef, {'followersCount': FieldValue.increment(-1)});
    } else {
      // Follow
      batch.set(myFollowingDoc, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(targetFollowerDoc, {'timestamp': FieldValue.serverTimestamp()});
      batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
      batch.update(targetUserRef, {'followersCount': FieldValue.increment(1)});
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid)
          .snapshots(),
      builder: (context, snapshot) {
        final isFollowing = snapshot.hasData && snapshot.data!.exists;

        return SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: () => _toggleFollow(isFollowing),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isFollowing ? Colors.grey[300] : const Color(0xFF00E5FF),
              foregroundColor: isFollowing ? Colors.black : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              isFollowing ? "Abonné" : "Suivre",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}