import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glow_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Chanje liy sa a:
final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E4), // background krèm tankou mockup la
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "SocialSnap",
                style: TextStyle(
                  color: Color(0xFF9A9A9E),
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "WELCOME BACK TO\nSOCIALSNAP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomTextField(
                      controller: _emailController,
                      label: "EMAIL/USERNAME",
                     hint: "Adresse e-mail ou pseudo",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: "MOT DE PASSE",
                     hint: "Mot de passe",
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 28),
                    authProvider.isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF22E1D0))
                        : GlowButton(
                            label: "SE CONNECTER",
                            onPressed: () async {
                              String? error = await authProvider.login(
                                  _emailController.text, _passwordController.text);

                              if (error == null) {
                                context.go('/home');
                              } else if (error.contains("vérifier")) {
                                // Lojik dialog verifikasyon an
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Vérification"),
                                    content: Text(error),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          bool ok = await authProvider.checkEmailVerification();
                                          if (ok) {
                                            if (!mounted) return;
                                            Navigator.pop(context);
                                            context.go('/home');
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Imèl toujou pa verifye.")));
                                          }
                                        },
                                        child: const Text("J'ai vérifié"),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                              }
                            },
                          ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(
                        "Pas encore de compte ? Créer un compte",
                        style: TextStyle(color: Color(0xFF8A8A8E), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}