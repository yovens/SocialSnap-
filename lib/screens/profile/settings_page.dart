import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import 'language_page.dart';
import 'privacy_page.dart';
import 'help_page.dart';
import '../../l10n/app_localizations.dart';


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
        title: Text(AppLocalizations.of(context)!.settingsTitle),
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
                  user?.displayName ?? AppLocalizations.of(context)!.defaultUserName,
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
                          ? AppLocalizations.of(context)!.emailVerified
                          : AppLocalizations.of(context)!.emailNotVerified,
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
                  child: Text(AppLocalizations.of(context)!.resendVerificationEmail),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= APPARENCE =================
          _sectionTitle(AppLocalizations.of(context)!.appearanceSection),

          _glassCard(
            child: SwitchListTile(
              value: dark,
              activeColor: cyan,
              title: Text(AppLocalizations.of(context)!.darkMode),
              secondary: const Icon(Icons.dark_mode),
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),

          const SizedBox(height: 20),

          /// ================= SECURITE =================
          _sectionTitle(AppLocalizations.of(context)!.securitySection),

          _glassCard(
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: Text(AppLocalizations.of(context)!.changePassword),
                  onTap: _changePassword,
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.email, color: Colors.orange),
                  title: Text(AppLocalizations.of(context)!.verifyEmail),
                  onTap: _verifyEmail,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= NOTIFICATIONS =================
          _sectionTitle(AppLocalizations.of(context)!.notificationsSection),

          _glassCard(
            child: SwitchListTile(
              value: pushNotif,
              activeColor: cyan,
              title: Text(AppLocalizations.of(context)!.pushNotifications),
              secondary: const Icon(Icons.notifications),
              onChanged: (v) => setState(() => pushNotif = v),
            ),
          ),

          const SizedBox(height: 20),

          /// ================= AUTRE =================
          _sectionTitle(AppLocalizations.of(context)!.othersSection),

_glassCard(
  child: Column(
    children: [

      ListTile(
        leading: const Icon(Icons.language),
        title: Text(AppLocalizations.of(context)!.languageSetting),
        subtitle: Text(AppLocalizations.of(context)!.languageSubtitle),
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
        title: Text(AppLocalizations.of(context)!.privacySetting),
        subtitle: Text(AppLocalizations.of(context)!.privacySubtitle),
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
        title: Text(AppLocalizations.of(context)!.helpSetting),
        subtitle: Text(AppLocalizations.of(context)!.helpSubtitle),
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
  AppLocalizations.of(context)!.settingsFooterInfo,
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
),
          const SizedBox(height: 20),

          /// ================= DANGER =================
          _sectionTitle(AppLocalizations.of(context)!.dangerSection),

          _glassCard(
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(AppLocalizations.of(context)!.logout),
                  onTap: _logout,
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(AppLocalizations.of(context)!.deleteAccount),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.verificationEmailSent)),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }

/// ================= PASSWORD =================
Future<void> _changePassword() async {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.changePassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 1. Mo de pas aktyèl
          TextField(
            controller: currentPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.currentPassword,
              hintText: AppLocalizations.of(context)!.currentPasswordHint,
            ),
          ),
          const SizedBox(height: 15),

          /// 2. Nouvo mo de pas
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.newPassword,
              hintText: AppLocalizations.of(context)!.newPasswordHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final currentPwd = currentPasswordController.text.trim();
            final newPwd = newPasswordController.text.trim();

            if (currentPwd.isEmpty || newPwd.isEmpty) {
              _msg(AppLocalizations.of(context)!.fillAllFields);
              return;
            }

            if (newPwd.length < 6) {
              _msg(AppLocalizations.of(context)!.newPasswordTooShort);
              return;
            }

            try {
              final user = FirebaseAuth.instance.currentUser;

              if (user != null && user.email != null) {
                // 🔐 1. Kreye kredansyal ak mo de pas aktyèl la
                AuthCredential credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPwd,
                );

                // 🔐 2. Re-otantifye itilizatè a
                await user.reauthenticateWithCredential(credential);

                // 🔐 3. Chanje mo de pas la kounye a
                await user.updatePassword(newPwd);

                if (mounted) Navigator.pop(dialogContext);
                _msg(AppLocalizations.of(context)!.passwordChangedSuccess);
              }
            } on FirebaseAuthException catch (e) {
              if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                _msg(AppLocalizations.of(context)!.wrongCurrentPassword);
              } else {
                _showError(e);
              }
            } catch (e) {
              _showError(e);
            }
          },
          child: Text(AppLocalizations.of(context)!.validate),
        ),
      ],
    ),
  );
}

  /// ================= LOGOUT =================
Future<void> _logout() async {
  // 1. Afficher la boîte de dialogue de confirmation
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(AppLocalizations.of(context)!.logoutConfirmTitle),
        content: Text(AppLocalizations.of(context)!.logoutConfirmMessage),
        actions: [
          // Bouton d'annulation
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // Bouton de confirmation
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );

  // 2. Si l'utilisateur clique sur "Déconnexion" (confirm == true)
  if (confirm == true) {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
  /// ================= DELETE =================
  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccount),
        content: Text(AppLocalizations.of(context)!.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.delete),
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
      SnackBar(content: Text(AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
    );
  }
}