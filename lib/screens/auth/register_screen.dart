import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glow_button.dart';
import '../../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isChecking = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;

    // Efface les anciens SnackBars pour afficher le nouveau immédiatement
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F1E4),
              Color(0xFFEDE7D9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ================= APP NAME =================
                const Text(
                  "SocialSnap",
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 18),

                /// ================= GLASS CARD =================
                GlassContainer(
                  child: Column(
                    children: [
                      /// 🟢 LOGO APPLIKASYON AN (IMAJ)
      Image.asset(
        'assets/logo.png', // 👈 Mete chemen imaj logo ou an la
        height: 80, // Axte logo a
        width: 80,
      ),

      const SizedBox(height: 15),
                      Text(
                        AppLocalizations.of(context)!.createAccountTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.joinCommunity,
                        style: TextStyle(
                          color: Color(0xFF8A8A8E),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// PSEUDONYME
                      CustomTextField(
                        controller: _usernameController,
                        label: AppLocalizations.of(context)!.usernameLabel,
                        hint: AppLocalizations.of(context)!.usernameHint,
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 15),

                      /// ADRESSE E-MAIL
                      CustomTextField(
                        controller: _emailController,
                        label: AppLocalizations.of(context)!.emailAddressLabel,
                        hint: AppLocalizations.of(context)!.emailHint,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 15),

                      /// MOT DE PASSE
                      CustomTextField(
                        controller: _passwordController,
                        label: AppLocalizations.of(context)!.passwordLabel,
                        hint: AppLocalizations.of(context)!.passwordHintCreate,
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 15),

                      /// CONFIRMER LE MOT DE PASSE
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: AppLocalizations.of(context)!.confirmPasswordLabel,
                        hint: AppLocalizations.of(context)!.confirmPasswordHint,
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 25),

                      /// ================= REGISTER BUTTON =================
                      (authProvider.isLoading || _isChecking)
                          ? const CircularProgressIndicator(
                              color: Color(0xFF22E1D0),
                            )
                          : GlowButton(
                              label: AppLocalizations.of(context)!.registerButton,
                              onPressed: () async {
                                final username = _usernameController.text.trim();
                                final email = _emailController.text.trim();
                                final password = _passwordController.text;
                                final confirmPassword =
                                    _confirmPasswordController.text;

                                // 1️⃣ Verifikasyon Chan yo
                                if (username.isEmpty ||
                                    email.isEmpty ||
                                    password.isEmpty) {
                                  _showSnackBar(
                                      AppLocalizations.of(context)!.fillAllFields);
                                  return;
                                }

                                if (password != confirmPassword) {
                                  _showSnackBar(
                                      AppLocalizations.of(context)!.passwordsDontMatch);
                                  return;
                                }

                                if (!mounted) return;
                                setState(() => _isChecking = true);

                                try {
                                  // 2️⃣ Tcheke Si Pseudo Egziste Deja nan Firestore
                                  final usernameQuery = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .where('username', isEqualTo: username)
                                      .limit(1)
                                      .get();

                                  if (usernameQuery.docs.isNotEmpty) {
                                    if (!mounted) return;
                                    setState(() => _isChecking = false);
                                    _showSnackBar(
                                        AppLocalizations.of(context)!.usernameTaken);
                                    return;
                                  }

                                  // 3️⃣ Enskripsyon ak Firebase Auth
                                  String? error = await authProvider.register(
                                      email, password);

                                  // 🔴 SI EMAIL LA GENYEN L DEJA OUSWA ERÈ FIREBASE
                                  if (error != null) {
                                    if (!mounted) return;
                                    setState(() => _isChecking = false);
                                    _showSnackBar(error);
                                    return;
                                  }

                                  // 4️⃣ Kreyasyon Dokiman Profil nan Firestore
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  if (currentUser == null) {
                                    if (!mounted) return;
                                    setState(() => _isChecking = false);
                                    _showSnackBar(
                                        AppLocalizations.of(context)!.userFetchError);
                                    return;
                                  }

                                  final uid = currentUser.uid;

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .set({
                                    'uid': uid,
                                    'displayName': username,
                                    'username': username,
                                    'email': email,
                                    'profileImageUrl':
                                        'https://static.vecteezy.com/system/resources/previews/009/292/244/original/default-avatar-icon-of-social-media-user-vector.jpg',
                                    'bio': 'Bienvenue sur mon profil !',
                                    'followersCount': 0,
                                    'followingCount': 0,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  // 5️⃣ Dekonekte l pou l ka al valide email li anvan l conecte
                                  await FirebaseAuth.instance.signOut();

                                  if (!mounted) return;
                                  setState(() => _isChecking = false);

                                  // 🟢 MESAJ SIKSÈ
                                  _showSnackBar(
                                    AppLocalizations.of(context)!.accountCreatedVerify,
                                    isError: false,
                                  );

                                  // ⏳ Poz pou moun lan gen tan wè mesaj la
                                  await Future.delayed(
                                      const Duration(seconds: 2));

                                  // 6️⃣ Redireksyon sou Login Page
                                  if (mounted) {
                                    context.go('/login');
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  setState(() => _isChecking = false);
                                  _showSnackBar(AppLocalizations.of(context)!.genericErrorWithDetail(e.toString()));
                                }
                              },
                            ),

                      const SizedBox(height: 14),

                      /// ================= TEXT BUTTON =================
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          AppLocalizations.of(context)!.alreadyHaveAccount,
                          style: TextStyle(
                            color: Color(0xFF8A8A8E),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}