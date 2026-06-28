import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import 'language_page.dart';
import 'privacy_page.dart';
import 'help_page.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotif = true;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dark = themeProvider.isDarkMode;

    final cyan = const Color(0xFF00F0FF);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B0F14) : const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Paramètres"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          /// ================= PROFILE =================
          _glassCard(
            child: Column(
              children: [

                CircleAvatar(
                  radius: 40,
                  backgroundColor: cyan.withOpacity(0.2),
                  child: Text(
                    (user?.email ?? "U")[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 30,
                      color: cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  user?.displayName ?? "Utilisateur",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  user?.email ?? "",
                  style: TextStyle(color: Colors.grey.shade500),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(
                      user?.emailVerified == true
                          ? Icons.verified
                          : Icons.error_outline,
                      color: user?.emailVerified == true ? Colors.green : Colors.orange,
                      size: 18,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      user?.emailVerified == true
                          ? "Email vérifié"
                          : "Email non vérifié",
                      style: TextStyle(
                        color: user?.emailVerified == true ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _verifyEmail,
                  child: const Text("Renvoyer email de vérification"),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= APPARENCE =================
          _sectionTitle("Apparence"),

          _glassCard(
            child: SwitchListTile(
              value: dark,
              activeColor: cyan,
              title: const Text("Mode sombre"),
              secondary: const Icon(Icons.dark_mode),
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),

          const SizedBox(height: 20),

          /// ================= SECURITE =================
          _sectionTitle("Sécurité"),

          _glassCard(
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: const Text("Changer mot de passe"),
                  onTap: _changePassword,
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.email, color: Colors.orange),
                  title: const Text("Vérifier email"),
                  onTap: _verifyEmail,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= NOTIFICATIONS =================
          _sectionTitle("Notifications"),

          _glassCard(
            child: SwitchListTile(
              value: pushNotif,
              activeColor: cyan,
              title: const Text("Push Notifications"),
              secondary: const Icon(Icons.notifications),
              onChanged: (v) => setState(() => pushNotif = v),
            ),
          ),

          const SizedBox(height: 20),

          /// ================= AUTRE =================
          _sectionTitle("Autres"),

_glassCard(
  child: Column(
    children: [

      ListTile(
        leading: const Icon(Icons.language),
        title: const Text("Langue"),
        subtitle: const Text("Changer la langue de l’application"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const LanguagePage()),
  );
},
      ),

      const Divider(),

      ListTile(
        leading: const Icon(Icons.privacy_tip),
        title: const Text("Confidentialité"),
        subtitle: const Text("Gérer vos données et permissions"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
       onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PrivacyPage()),
  );
},
      ),

      const Divider(),

      ListTile(
        leading: const Icon(Icons.help),
        title: const Text("Aide"),
        subtitle: const Text("FAQ et support utilisateur"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const HelpPage()),
  );
},
      ),
    ],
  ),
),

const SizedBox(height: 8),

// optional info text (très clean UX)
Text(
  "Gérez vos préférences et informations de l’application",
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
),
          const SizedBox(height: 20),

          /// ================= DANGER =================
          _sectionTitle("Danger"),

          _glassCard(
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Déconnexion"),
                  onTap: _logout,
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Supprimer compte"),
                  onTap: _deleteAccount,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// ================= GLASS CARD =================
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ================= EMAIL VERIFY =================
  Future<void> _verifyEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email de vérification envoyé")),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }

  /// ================= PASSWORD =================
  Future<void> _changePassword() async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nouveau mot de passe"),
        content: TextField(
          controller: controller,
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser
                    ?.updatePassword(controller.text);

                if (mounted) Navigator.pop(context);

                _msg("Mot de passe modifié");
              } catch (e) {
                _showError(e);
              }
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  /// ================= LOGOUT =================
Future<void> _logout() async {
  await FirebaseAuth.instance.signOut();

  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }
}

  /// ================= DELETE =================
  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer compte"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                _showError(e);
              }
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  /// ================= HELPERS =================
  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur: $e")),
    );
  }
}