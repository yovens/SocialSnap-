import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context);

    final dark =
        themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paramètres",
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [

          const SizedBox(height: 10),

          _sectionTitle(
            "Apparence",
          ),

          Card(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: SwitchListTile(
              value: dark,
              activeColor:
                  const Color(
                0xFF00F0FF,
              ),
              title: const Text(
                "Mode sombre",
              ),
              secondary: const Icon(
                Icons.dark_mode,
              ),
              onChanged: (value) {
                themeProvider
                    .toggleTheme(
                  value,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle(
            "Compte",
          ),

          Card(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              children: [

                ListTile(
                  leading:
                      const Icon(
                    Icons.lock_reset,
                  ),
                  title: const Text(
                    "Changer le mot de passe",
                  ),
                  onTap:
                      _changePassword,
                ),

                const Divider(
                  height: 0,
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons.email,
                  ),
                  title: const Text(
                    "Vérifier mon email",
                  ),
                  onTap:
                      _verifyEmail,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle(
            "Notifications",
          ),

          Card(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: const ListTile(
              leading: Icon(
                Icons.notifications,
              ),
              title: Text(
                "Notifications activées",
              ),
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle(
            "Danger",
          ),

          Card(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              children: [

                ListTile(
                  leading:
                      const Icon(
                    Icons.delete,
                    color:
                        Colors.red,
                  ),
                  title: const Text(
                    "Supprimer mon compte",
                    style: TextStyle(
                      color:
                          Colors.red,
                    ),
                  ),
                  onTap:
                      _deleteAccount,
                ),

                const Divider(
                  height: 0,
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons.logout,
                    color:
                        Colors.red,
                  ),
                  title: const Text(
                    "Déconnexion",
                    style: TextStyle(
                      color:
                          Colors.red,
                    ),
                  ),
                  onTap: () async {
                    await FirebaseAuth
                        .instance
                        .signOut();

                    if (mounted) {
                      Navigator.pop(
                        context,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Future<void>
      _verifyEmail() async {
    try {
      await FirebaseAuth
          .instance.currentUser!
          .sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              "Email de vérification envoyé.",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text("$e"),
        ),
      );
    }
  }

  Future<void>
      _changePassword() async {
    final controller =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
        title: const Text(
          "Nouveau mot de passe",
        ),
        content: TextField(
          controller:
              controller,
          obscureText: true,
        ),
        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
            ),
            child: const Text(
              "Annuler",
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth
                    .instance
                    .currentUser!
                    .updatePassword(
                  controller.text,
                );

                if (mounted) {
                  Navigator.pop(
                    context,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Mot de passe modifié.",
                      ),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content:
                        Text("$e"),
                  ),
                );
              }
            },
            child: const Text(
              "Valider",
            ),
          ),
        ],
      ),
    );
  }

  Future<void>
      _deleteAccount() async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
        title: const Text(
          "Supprimer le compte",
        ),
        content: const Text(
          "Cette action est irréversible.",
        ),
        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
            ),
            child: const Text(
              "Annuler",
            ),
          ),

          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,
            ),
            onPressed: () async {
              try {
                await FirebaseAuth
                    .instance
                    .currentUser!
                    .delete();

                if (mounted) {
                  Navigator.pop(
                    context,
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content:
                        Text("$e"),
                  ),
                );
              }
            },
            child: const Text(
              "Supprimer",
            ),
          ),
        ],
      ),
    );
  }
}