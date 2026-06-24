import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final int postsCount;
  final VoidCallback onEdit;
  final VoidCallback onSettings;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.postsCount,
    required this.onEdit,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [

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
                    color: const Color(0xFF00F0FF)
                        .withOpacity(0.5),
                    blurRadius: 35,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

            CircleAvatar(
              radius: 55,
              backgroundImage:
                  NetworkImage(user.profileImageUrl),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Text(
          user.displayName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color:
                dark ? Colors.white : Colors.black,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          "@${user.username}",
          style: TextStyle(
            color:
                dark ? Colors.white60 : Colors.black54,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          user.bio,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: dark
                ? const Color(0xFF1A1A1A)
                : Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [

              _StatItem(
                title: "Posts",
                value: postsCount.toString(),
              ),

              _StatItem(
                title: "Followers",
                value:
                    user.followersCount.toString(),
              ),

              _StatItem(
                title: "Following",
                value:
                    user.followingCount.toString(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle),
            label:
                const Text("Ajouter une Story"),
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: [

            Expanded(
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text(
                    "Modifier Profil"),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(14),
                color: dark
                    ? Colors.white10
                    : Colors.grey.shade200,
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.settings),
                onPressed: onSettings,
              ),
            ),
          ],
        ),
      ],
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
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        Text(title),
      ],
    );
  }
}