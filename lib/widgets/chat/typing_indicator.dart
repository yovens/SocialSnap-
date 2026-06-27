import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final String username;

  const TypingIndicator({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "$username est en train d'écrire...",
        style: const TextStyle(
          color: Colors.cyan,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}