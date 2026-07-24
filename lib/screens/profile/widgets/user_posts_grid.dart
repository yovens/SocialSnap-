import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post_model.dart'; // ✅ Chemen modèl ou an

class UserPostsGrid extends StatelessWidget {
  final List<PostModel> posts;
  final Function(PostModel) onPostTap;

  const UserPostsGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "Aucune publication pour le moment.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Pou l pa tande tèt li si l nan yon CustomScrollView
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 imaj sou chak liy jan sa ye nan makèt la
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0, // Kare pafè
      ),
      itemBuilder: (context, index) {
        final post = posts[index];

        return GestureDetector(
          onTap: () => onPostTap(post),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // Kwen trè awondi
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.4), // ✅ Liy neyon cyan sou rebò a jan sa ye nan foto a
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.1), // Ekla cyan lejè anba kat la
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5), // Pito l pi piti pou ti rebò a parèt byen pwòp
              child: Stack(
                children: [
                  // 1️⃣ IMAJ POST LA (Li sèvi ak post.imageUrl kounye a)
                  Positioned.fill(
                    child: post.imageUrl.isNotEmpty
                        ? Image.network(
                            post.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),

                  // 2️⃣ GRADIENT SOU ANBA POU DESIGN LAN KA PLIS SÒTI
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3️⃣ TI IKÒN MOUN ANLÈ A DWAT (JAN SA YE NAN MAKÈT LA)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}