import 'package:flutter/material.dart';

class ChatInfoPage extends StatelessWidget {
  const ChatInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Info Chat")),
      body: Column(
        children: const [
          CircleAvatar(radius: 40),
          SizedBox(height: 10),
          Text("User Name"),
          SizedBox(height: 20),
          ListTile(title: Text("Media")),
          ListTile(title: Text("Blocked Users")),
          ListTile(title: Text("Delete Chat")),
        ],
      ),
    );
  }
}