import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String username;
  final String? imageUrl;
  final bool hasStory; // Pou montre si itilizatè a gen yon story aktif

  const StoryCircle({
    super.key,
    required this.username,
    this.imageUrl,
    this.hasStory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Si gen story, nou montre gradient, sinon yon koulè gri
            gradient: hasStory 
              ? const LinearGradient(colors: [Color(0xFFE8A87C), Color(0xFFE05C5C)]) 
              : null,
            color: hasStory ? null : Colors.grey[300],
          ),
          padding: const EdgeInsets.all(3), // Epesè bag la
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF5F1E4)),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          username.length > 8 ? "${username.substring(0, 7)}..." : username,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}