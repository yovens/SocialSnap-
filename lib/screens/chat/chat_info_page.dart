import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import 'media_gallery_page.dart';
import '../../l10n/app_localizations.dart';

class ChatInfoPage extends StatefulWidget {
  final UserModel user;
  final String chatId;

  const ChatInfoPage({
    super.key,
    required this.user,
    required this.chatId,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool isBlocked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfBlocked();
  }

  // Vérifier si l'utilisateur est déjà bloqué
  Future<void> _checkIfBlocked() async {
    if (currentUid.isEmpty) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('blocked')
        .doc(widget.user.uid)
        .get();

    if (mounted) {
      setState(() {
        isBlocked = doc.exists;
      });
    }
  }

  // Gérer le blocage / déblocage
  Future<void> _toggleBlockUser() async {
    setState(() => isLoading = true);
    final blockedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('blocked')
        .doc(widget.user.uid);

    if (isBlocked) {
      await blockedRef.delete();
      setState(() {
        isBlocked = false;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.userUnblocked)),
        );
      }
    } else {
      await blockedRef.set({
        'blockedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        isBlocked = true;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.userBlocked)),
        );
      }
    }
  }

  // Supprimer la conversation
  Future<void> _deleteChat() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteChatTitle),
        content: Text(AppLocalizations.of(context)!.deleteChatMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);

      // 1. Supprimer tous les messages de la sous-collection
      final messages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // 2. Supprimer le document principal du chat
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .delete();

      if (mounted) {
        // Retourner jusqu'à la page d'accueil ou la liste des chats
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.contactInfoTitle),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Photo de profil
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user.profileImageUrl.isNotEmpty
                        ? NetworkImage(widget.user.profileImageUrl)
                        : null,
                    child: widget.user.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Nom d'utilisateur
                  Text(
                    widget.user.displayName.isNotEmpty
                        ? widget.user.displayName
                        : widget.user.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.user.username.isNotEmpty)
                    Text(
                      "@${widget.user.username}",
                      style: const TextStyle(color: Colors.grey),
                    ),

                  const SizedBox(height: 30),
                  const Divider(),

                  // Option Médias
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(AppLocalizations.of(context)!.mediaAndFiles),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MediaGalleryPage(
                            chatId: widget.chatId,
                          ),
                        ),
                      );
                    },
                  ),

                  // Option Bloquer / Débloquer
                  ListTile(
                    leading: Icon(
                      Icons.block,
                      color: isBlocked ? Colors.grey : Colors.orange,
                    ),
                    title: Text(
                      isBlocked
                          ? AppLocalizations.of(context)!.unblockUser
                          : AppLocalizations.of(context)!.blockUser,
                    ),
                    onTap: _toggleBlockUser,
                  ),

                  // Option Supprimer
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      AppLocalizations.of(context)!.deleteChatTitle,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: _deleteChat,
                  ),
                ],
              ),
            ),
    );
  }
}