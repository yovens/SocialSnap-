import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/post_model.dart';
import '../../services/imgbb_service.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  File? _selectedImage;
  final TextEditingController _captionController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  // ───────────────── IMAGE PICKER ─────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnack("Erreur image : $e");
    }
  }

  // ───────────────── SNACKBAR ─────────────────

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  // ───────────────── SUBMIT POST ─────────────────

  Future<void> _submitPost() async {
    if (_selectedImage == null) {
      _showSnack("Veuillez choisir une image.");
      return;
    }

    if (_captionController.text.trim().isEmpty) {
      _showSnack("Veuillez écrire une description.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("Utilisateur non connecté.");
      }

      // Upload image ImgBB
      final imageUrl =
          await ImgBBService().uploadImage(
        _selectedImage!,
      );

      if (imageUrl == null) {
        throw Exception("Upload image échoué.");
      }

      // User data
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      final userData =
          userDoc.data() ?? {};

      final username =
          userData['username'] ??
              currentUser.displayName ??
              "Utilisateur";

      // Create post
      final post = PostModel(
        postId: '',
        uid: currentUser.uid,
        username: username,
        imageUrl: imageUrl,
        caption:
            _captionController.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .add(post.toMap());

      if (mounted) {
        _showSnack(
          "Post publié avec succès 🎉",
        );

        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack("Erreur : $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ───────────────── BUILD ─────────────────

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ───────── APP BAR ─────────

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      size: 30,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const Spacer(),

                  Column(
                    children: [
                      Text(
                        "SocialSnap",
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey
                              : Colors.black54,
                          fontSize: 12,
                        ),
                      ),

                      Text(
                        "Créer un post",
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const SizedBox(width: 30),
                ],
              ),
            ),

            // ───────── CONTENT ─────────

            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ───────── IMAGE PREVIEW ─────────

                    GestureDetector(
                      onTap: () =>
                          _pickImage(
                        ImageSource.gallery,
                      ),
                      child: Container(
                        height: 340,
                        width: double.infinity,
                        decoration:
                            BoxDecoration(
                          color: isDark
                              ? const Color(
                                  0xFF1E1E1E)
                              : const Color(
                                  0xFFF4F4F4),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            25,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                0.15,
                              ),
                              blurRadius: 15,
                              offset:
                                  const Offset(
                                0,
                                8,
                              ),
                            ),
                          ],
                        ),
                        child:
                            _selectedImage ==
                                    null
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .image_outlined,
                                        size: 80,
                                        color:
                                            isDark
                                                ? Colors
                                                    .grey
                                                : Colors
                                                    .black26,
                                      ),

                                      const SizedBox(
                                          height:
                                              10),

                                      Text(
                                        "Choisir une image",
                                        style:
                                            TextStyle(
                                          color:
                                              isDark
                                                  ? Colors
                                                      .grey
                                                  : Colors
                                                      .black54,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      25,
                                    ),
                                    child:
                                        Image.file(
                                      _selectedImage!,
                                      fit: BoxFit
                                          .cover,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(
                        height: 25),

                    // ───────── CAPTION ─────────

                    Container(
                      decoration:
                          BoxDecoration(
                        color: isDark
                            ? const Color(
                                0xFF1E1E1E)
                            : Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey
                                  .shade800
                              : Colors.grey
                                  .shade300,
                        ),
                      ),
                      child: TextField(
                        controller:
                            _captionController,
                        maxLines: 4,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration:
                            InputDecoration(
                          hintText:
                              "Écrivez une description...",
                          hintStyle:
                              TextStyle(
                            color: isDark
                                ? Colors.grey
                                : Colors
                                    .black54,
                          ),
                          border:
                              InputBorder.none,
                          contentPadding:
                              const EdgeInsets
                                  .all(18),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 25),

                    // ───────── ACTION BUTTONS ─────────

                    Row(
                      children: [
                        Expanded(
                          child:
                              _ActionButton(
                            icon: Icons
                                .photo_library,
                            title:
                                "Galerie",
                            color:
                                Colors.orange,
                            bgColor: isDark
                                ? const Color(
                                    0xFF252525)
                                : const Color(
                                    0xFFFFF0EA),
                            onTap: () =>
                                _pickImage(
                              ImageSource
                                  .gallery,
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 10),

                        Expanded(
                          child:
                              _ActionButton(
                            icon:
                                Icons.camera,
                            title:
                                "Caméra",
                            color:
                                Colors.blue,
                            bgColor: isDark
                                ? const Color(
                                    0xFF252525)
                                : Colors
                                    .white,
                            onTap: () =>
                                _pickImage(
                              ImageSource
                                  .camera,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 30),

                    // ───────── SUBMIT ─────────

                    SizedBox(
                      width:
                          double.infinity,
                      height: 58,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _submitPost,
                        style:
                            ElevatedButton
                                .styleFrom(
                          elevation: 6,
                          backgroundColor:
                              isDark
                                  ? const Color(
                                      0xFF00C2FF)
                                  : const Color(
                                      0xFF1A1A2E),
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              30,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors
                                    .white,
                              )
                            : const Text(
                                "PUBLIER",
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  letterSpacing:
                                      1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── ACTION BUTTON ─────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}