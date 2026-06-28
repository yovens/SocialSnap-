import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aide & Support"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Text(
            "FAQ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          Text(
            "❓ Comment changer mon mot de passe ?\n"
            "→ Aller dans Paramètres > Sécurité\n\n"
            "❓ Comment supprimer mon compte ?\n"
            "→ Aller dans Paramètres > Danger\n\n"
            "❓ Comment contacter support ?\n"
            "→ Email support@tonapp.com",
          ),
        ],
      ),
    );
  }
}