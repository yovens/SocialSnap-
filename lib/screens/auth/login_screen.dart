import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 📩 Bwàt dyalòg pou Demann Mot de Pas Bliye
/// 📩 Bwàt dyalòg pou Demann Mot de Pas Bliye
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    bool isLoadingReset = false;

    showDialog(
      context: context,
      builder: (context) {
        // 🔧 RANPLASE StatefulWidgetBuilder AK StatefulBuilder ISIT LA
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Réinitialiser le mot de passe",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                // 🟢 KORÈK
crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Entrez votre e-mail pour recevoir un lien de réinitialisation.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF6C6C6C)),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "ADRESSE E-MAIL",
                      hintText: "exemple@gmail.com",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22E1D0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoadingReset
                      ? null
                      : () async {
                          setDialogState(() => isLoadingReset = true);

                          final authProvider = Provider.of<AppAuthProvider>(
                            context,
                            listen: false,
                          );

                          String? error = await authProvider
                              .sendPasswordResetEmail(resetEmailController.text);

                          if (!mounted) return;
                          Navigator.pop(context); // Fèmen dyalòg la

                          if (error == null) {
                            _showSnackBar(
                              "E-mail de réinitialisation envoyé ! Vérifiez votre boîte mail.",
                              isError: false,
                            );
                          } else {
                            _showSnackBar(error);
                          }
                        },
                  child: isLoadingReset
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Envoyer",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
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
                      /// 🟢 LOGO APPLIKASYON AN (IMAJ)
      Image.asset(
        'assets/logo.png', // 👈 Mete chemen imaj logo ou an la
        height: 80, // Axte logo a
        width: 80,
      ),

      const SizedBox(height: 15),
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

                      /// 🔑 BOUTON MOT DE PASSE OUBLIÉ
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

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
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text.trim();

                                  if (email.isEmpty || password.isEmpty) {
                                    _showSnackBar("Veuillez remplir tous les champs.");
                                    return;
                                  }

                                  String? error = await authProvider.login(
                                    email,
                                    password,
                                  );

                                  if (!mounted) return;

                                  if (error != null) {
                                    _showSnackBar(error);
                                    return;
                                  }

                                  // 🔍 Tcheke si email la verifye
                                  final currentUser = FirebaseAuth.instance.currentUser;
                                  await currentUser?.reload();
                                  final updatedUser = FirebaseAuth.instance.currentUser;

                                  if (updatedUser != null && !updatedUser.emailVerified) {
                                    await FirebaseAuth.instance.signOut();
                                    if (!mounted) return;
                                    _showSnackBar(
                                      "Veuillez vérifier votre e-mail avant de vous connecter.",
                                    );
                                    return;
                                  }

                                  if (mounted) {
                                    context.go('/home');
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