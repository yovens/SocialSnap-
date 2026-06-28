import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.35),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    children: [

                      /// TITLE
                    const Text(
  "BON RETOUR PARMI NOUS",
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1A2E),
  ),
),

                      const SizedBox(height: 25),

                      /// EMAIL
                      CustomTextField(
                        controller: _emailController,
                        label: "EMAIL",
                        hint: "Adresse e-mail",
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      CustomTextField(
                        controller: _passwordController,
                        label: "MOT DE PASSE",
                        hint: "********",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 25),

                      /// ================= LOGIN BUTTON =================
                      authProvider.isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFF22E1D0),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: const Color(0xFF22E1D0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  final authProvider =
                                      Provider.of<AppAuthProvider>(
                                    context,
                                    listen: false,
                                  );

                                  String? error = await authProvider.login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                                  /// 🚨 SAFE NAVIGATION FIX
                                  if (!mounted) return;

                                  if (error == null) {
                                    context.go('/home');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
                                },
                                child: const Text(
                                  "SE CONNECTER",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 12),

                      /// ================= REGISTER =================
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text(
                          "Pas encore de compte ? Créer un compte",
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