import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confidentialité"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Text(
            "Politique de confidentialité",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          Text(
            "• Nous respectons vos données personnelles.\n"
            "• Aucune information n'est vendue.\n"
            "• Vos données sont protégées avec Firebase.\n"
            "• Vous pouvez supprimer votre compte à tout moment.",
          ),
        ],
      ),
    );
  }
}