import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glow_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      body: Container(
        // Menm dégradé background ak LoginScreen
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
                      const Text(
                        "CRÉER UN COMPTE",
                        style: TextStyle(
                          fontSize: 20, // Harmonisé ak login lan
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Rejoignez la communauté SocialSnap",
                        style: TextStyle(
                          color: Color(0xFF8A8A8E), 
                          fontSize: 13,
                        ),
                      ),
                      
                      const SizedBox(height: 25),

                      /// PSEUDONYME
                      CustomTextField(
                        controller: _usernameController,
                        label: "PSEUDONYME",
                        hint: "Choisissez un pseudo",
                        icon: Icons.person_outline,
                      ),
                      
                      const SizedBox(height: 15),
                      
                      /// ADRESSE E-MAIL
                      CustomTextField(
                        controller: _emailController,
                        label: "ADRESSE E-MAIL",
                        hint: "Adresse e-mail",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 15),
                      
                      /// MOT DE PASSE
                      CustomTextField(
                        controller: _passwordController,
                        label: "MOT DE PASSE",
                        hint: "Créez un mot de passe sécurisé",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      
                      const SizedBox(height: 15),
                      
                      /// CONFIRMER LE MOT DE PASSE
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: "CONFIRMER LE MOT DE PASSE",
                        hint: "Confirmez le mot de passe",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 25),

                      /// ================= REGISTER BUTTON (Lojik orijinal ou) =================
                      authProvider.isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF22E1D0))
                          : GlowButton(
                              label: "S'INSCRIRE",
                              onPressed: () async {
                                // Lojik verifikasyon ak kreyasyon ou an nèt san chanjman
                                if (_passwordController.text != _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
                                  );
                                  return;
                                }

                                String? error = await authProvider.register(
                                    _emailController.text, _passwordController.text);
                                
                                if (error == null) {
                                  try {
                                    String uid = FirebaseAuth.instance.currentUser!.uid;
                                    await FirebaseFirestore.instance.collection('users').doc(uid).set({
                                      'uid': uid,
                                      'displayName': _usernameController.text,
                                      'username': _usernameController.text,
                                      'profileImageUrl': 'https://static.vecteezy.com/system/resources/previews/009/292/244/original/default-avatar-icon-of-social-media-user-vector.jpg',
                                      'bio': 'Byenveni sou profil mwen!',
                                      'followersCount': 0,
                                      'followingCount': 0,
                                    });
                                    context.go('/home');
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Erreur lors de la création du profil: $e")),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                }
                              },
                            ),

                      const SizedBox(height: 14),
                      
                      /// ================= TEXT BUTTON =================
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          "Déjà un compte ? Se connecter",
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