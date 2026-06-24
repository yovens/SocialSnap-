import 'dart:io';
import 'dart:convert'; // Mete l isit la
import 'package:http/http.dart' as http; // Mete l isit la
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController;

  File? _imageFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.user.displayName,
    );

    _bioController =
        TextEditingController(
      text: widget.user.bio,
    );

    _usernameController =
        TextEditingController(
      text: widget.user.username,
    );
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }



Future<void> _saveProfile() async {
  try {
    setState(() { _loading = true; });

    String imageUrl = widget.user.profileImageUrl;

    if (_imageFile != null) {
      // 1. Prepare demann pou ImgBB
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=6af56b5d2a71117a5a3e330a2e3ac5bc'),
      );
      
      // 2. Ajoute imaj la
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      // 3. Voye demann lan
      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = json.decode(responseData);
        // ImgBB retounen URL imaj la nan 'data' -> 'url'
        imageUrl = result['data']['url'];
      } else {
        throw "Erè pandan chajman imaj nan ImgBB";
      }
    }

    // 4. Mete ajou Firestore
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.uid)
        .update({
      "displayName": _nameController.text.trim(),
      "username": _usernameController.text.trim(),
      "bio": _bioController.text.trim(),
      "profileImageUrl": imageUrl,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil mis à jour")));
      Navigator.pop(context);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erè : $e")));
  } finally {
    setState(() { _loading = false; });
  }
}

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modifier Profil",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment:
                    Alignment.bottomRight,
                children: [

                  Container(
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                                0xFF00F0FF,
                              ).withOpacity(
                                0.6,
                              ),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _imageFile != null
                              ? FileImage(
                                  _imageFile!,
                                )
                              : NetworkImage(
                                      widget.user
                                          .profileImageUrl,
                                    )
                                  as ImageProvider,
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .all(8),
                    decoration:
                        const BoxDecoration(
                      color: Color(
                        0xFF00F0FF,
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color:
                          Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            TextField(
              controller:
                  _nameController,
              decoration:
                  InputDecoration(
                labelText:
                    "Nom complet",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _usernameController,
              decoration:
                  InputDecoration(
                labelText:
                    "Nom utilisateur",
                prefixText: "@",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _bioController,
              maxLines: 4,
              decoration:
                  InputDecoration(
                labelText: "Bio",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    _loading
                        ? null
                        : _saveProfile,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF00F0FF,
                  ),
                  foregroundColor:
                      Colors.black,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Enregistrer",
                            style:
                                TextStyle(
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}