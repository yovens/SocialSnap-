import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
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

  // 🟢 Nou pa gen kòd doub ankò isit la — nou pase pa FirestoreService.follow/
  // unfollow, ki SÈL kote sub-koleksyon yo AK konte yo (followersCount/
  // followingCount) mete ajou an menm tan (batch atomik). Konsa konte yo
  // rete kòrèk kèlkeswa ki ekran ou itilize pou swiv/dezabòne.
  Future<void> _toggleFollow(bool isFollowing) async {
    final service = FirestoreService();

    if (isFollowing) {
      await service.unfollow(myUid: currentUid, targetUid: targetUid);
    } else {
      await service.follow(myUid: currentUid, targetUid: targetUid);
    }
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