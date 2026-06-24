import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/feed_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import '../../widgets/story_circle.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : Colors.white,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [

            // APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                children: [

                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "SocialSnap",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const Spacer(),

                  Stack(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.06),
                                    blurRadius: 8,
                                    offset:
                                        const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),

                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration:
                              const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // STORIES
            SizedBox(
              height: 95,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.only(left: 10),
                itemCount: 8,
                itemBuilder: (_, index) {
                  return StoryCircle(
                    username: "user$index",
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // POSTS
            Expanded(
              child: Consumer<FeedProvider>(
                builder: (_, provider, __) {
                  return StreamBuilder<List<PostModel>>(
                    stream:
                        provider.getPostsStream(),
                    builder: (context, snapshot) {

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Erreur : ${snapshot.error}",
                          ),
                        );
                      }

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            "Aucun post disponible",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      }

                      final posts = snapshot.data!;

                      return ListView.builder(
                        padding:
                            const EdgeInsets.only(
                          bottom: 100,
                        ),
                        itemCount: posts.length,
                        itemBuilder:
                            (context, index) {
                          return PostCard(
                            post: posts[index],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}