import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Langue"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Choisissez votre langue",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          RadioListTile(
            value: "fr",
            groupValue: "fr",
            onChanged: (_) {},
            title: const Text("Français"),
          ),

          RadioListTile(
            value: "en",
            groupValue: "fr",
            onChanged: (_) {},
            title: const Text("English"),
          ),

          RadioListTile(
            value: "ht",
            groupValue: "fr",
            onChanged: (_) {},
            title: const Text("Kreyòl Ayisyen"),
          ),
        ],
      ),
    );
  }
}