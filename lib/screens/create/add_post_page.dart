import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/post_model.dart';
import '../../services/imgbb_service.dart';
import '../../l10n/app_localizations.dart';

/// 🟢 Kantite maksimòm imaj yon moun ka mete sou yon sèl pòs.
const int _kMaxImages = 10;

/// 🟢 Ekstrè tout hashtag (#mo) ki nan yon tèks, san doub.
List<String> _extractHashtags(String text) {
  final matches = RegExp(r'#([a-zA-Z0-9_À-ÿ]+)').allMatches(text);
  final seen = <String>{};
  final result = <String>[];
  for (final m in matches) {
    final tag = m.group(1);
    if (tag == null) continue;
    final normalized = tag.toLowerCase();
    if (seen.add(normalized)) {
      result.add(tag);
    }
  }
  return result;
}

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final List<File> _selectedImages = [];
  final TextEditingController _captionController = TextEditingController();

  bool _isLoading = false;

  /// 🟢 Pwogresyon global upload la (0.0 → 1.0), pou tout imaj yo konbine.
  double _uploadProgress = 0;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  // ───────────────── IMAGE PICKER ─────────────────

  Future<void> _pickSingleImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _addImages([File(pickedFile.path)]);
      }
    } catch (e) {
      _showSnack(AppLocalizations.of(context)!.imagePickError(e.toString()));
    }
  }

  /// 🟢 Seleksyon PLIZYÈ imaj sòti nan galri a an yon sèl fwa.
  Future<void> _pickMultipleImages() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage(
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        _addImages(pickedFiles.map((x) => File(x.path)).toList());
      }
    } catch (e) {
      _showSnack(AppLocalizations.of(context)!.imagePickError(e.toString()));
    }
  }

  void _addImages(List<File> newFiles) {
    setState(() {
      _selectedImages.addAll(newFiles);
      if (_selectedImages.length > _kMaxImages) {
        _selectedImages.removeRange(_kMaxImages, _selectedImages.length);
        _showSnack(AppLocalizations.of(context)!.maxImagesReached(_kMaxImages));
      }
    });
  }

  void _removeImageAt(int index) {
    setState(() => _selectedImages.removeAt(index));
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
    if (_selectedImages.isEmpty) {
      _showSnack(AppLocalizations.of(context)!.pleaseChooseImage);
      return;
    }

    if (_captionController.text.trim().isEmpty) {
      _showSnack(AppLocalizations.of(context)!.pleaseWriteDescription);
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception(AppLocalizations.of(context)!.userNotConnected);
      }

      // ───── Upload chak imaj sou ImgBB, ak pwogresyon total ─────
      final imgbbService = ImgBBService();
      final imageUrls = <String>[];
      final totalImages = _selectedImages.length;

      for (var i = 0; i < totalImages; i++) {
        final url = await imgbbService.uploadImageWithProgress(
          _selectedImages[i],
          onProgress: (fileProgress) {
            // Pwogresyon global = (imaj deja fini + pousantaj imaj kounye a) / total
            final overall = (i + fileProgress) / totalImages;
            if (mounted) {
              setState(() => _uploadProgress = overall);
            }
          },
        );

        if (url == null) {
          throw Exception(AppLocalizations.of(context)!.imageUploadFailed(i + 1, totalImages));
        }

        imageUrls.add(url);
      }

      // User data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data() ?? {};

      final username =
          userData['username'] ?? currentUser.displayName ?? AppLocalizations.of(context)!.defaultUserName;

      final caption = _captionController.text.trim();

      // Create post
      final post = PostModel(
        postId: '',
        uid: currentUser.uid,
        username: username,
        imageUrls: imageUrls,
        caption: caption,
        hashtags: _extractHashtags(caption),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('posts').add(post.toMap());

      if (mounted) {
        _showSnack(AppLocalizations.of(context)!.postPublishedSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack(AppLocalizations.of(context)!.errorWithDetail(e.toString()));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _uploadProgress = 0;
      });
    }
  }

  // ───────────────── BUILD ─────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ───────── APP BAR ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      size: 30,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        "SocialSnap",
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.createPostTitle,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ───────── IMAGES PREVIEW (carousel + remove) ─────────
                    _selectedImages.isEmpty
                        ? GestureDetector(
                            onTap: _pickMultipleImages,
                            child: Container(
                              height: 340,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 80,
                                    color: isDark ? Colors.grey : Colors.black26,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppLocalizations.of(context)!.choosePicturesPlaceholder,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 340,
                            child: PageView.builder(
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Image.file(
                                          _selectedImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () => _removeImageAt(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "${index + 1}/${_selectedImages.length}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                    const SizedBox(height: 25),

                    // ───────── CAPTION (+ hashtags) ─────────
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                      child: TextField(
                        controller: _captionController,
                        maxLines: 4,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.captionHint,
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey : Colors.black54,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                        ),
                      ),
                    ),

                    // ───────── HASHTAGS PREVIEW ─────────
                    if (_extractHashtags(_captionController.text).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8,
                          runSpacing: 4,
                          children: _extractHashtags(_captionController.text)
                              .map(
                                (tag) => Chip(
                                  label: Text("#$tag"),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: isDark
                                      ? const Color(0xFF252525)
                                      : const Color(0xFFEFEFEF),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 25),

                    // ───────── ACTION BUTTONS ─────────
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.photo_library,
                            title: AppLocalizations.of(context)!.galleryButton,
                            color: Colors.orange,
                            bgColor: isDark
                                ? const Color(0xFF252525)
                                : const Color(0xFFFFF0EA),
                            onTap: _pickMultipleImages,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.camera,
                            title: AppLocalizations.of(context)!.cameraButton,
                            color: Colors.blue,
                            bgColor: isDark ? const Color(0xFF252525) : Colors.white,
                            onTap: () => _pickSingleImage(ImageSource.camera),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ───────── UPLOAD PROGRESS BAR ─────────
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _uploadProgress > 0 ? _uploadProgress : null,
                                minHeight: 8,
                                backgroundColor:
                                    isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF22E1D0)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${(_uploadProgress * 100).clamp(0, 100).toStringAsFixed(0)} %",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ───────── SUBMIT ─────────
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitPost,
                        style: ElevatedButton.styleFrom(
                          elevation: 6,
                          backgroundColor: isDark
                              ? const Color(0xFF00C2FF)
                              : const Color(0xFF1A1A2E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.publishButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
