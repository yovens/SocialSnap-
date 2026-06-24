import 'package:flutter/material.dart';
import '../../../models/post_model.dart';

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
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              Text(
                "Aucune publication",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];

        return GestureDetector(
          onTap: () => onPostTap(post),
          child: Hero(
            tag: post.postId,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.broken_image,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}