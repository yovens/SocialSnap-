import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_glass_bottom_bar.dart';
import 'feed_page.dart';
import '../create/add_post_page.dart';
import '../profile/profile_page.dart';
import '../../providers/theme_provider.dart';
import '../chat/chats_page.dart';
import '../search/search_page.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 🟢 1. On autorise le fait que l'utilisateur puisse être null temporairement (String?)
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final uid = currentUid;

    // 🟢 2. Si l'utilisateur n'est pas encore chargé ou non connecté, on affiche un chargement
    if (uid == null) {
      return Scaffold(
        backgroundColor: theme.isDarkMode
            ? const Color(0xFF0F0F0F)
            : const Color(0xFFF5F1E4),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages = [
      const FeedPage(),
      const SearchPage(),
      const SizedBox(),
      const ChatsPage(),
      ProfilePage(uid: uid), // 🟢 On passe le 'uid' sécurisé
    ];

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF5F1E4),
      extendBody: true,

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: uid) // 🟢 Utilisation du 'uid' sécurisé
            .snapshots(),
        builder: (context, snapshot) {
          bool hasUnread = false;

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (var doc in snapshot.data!.docs) {
              final chatData = doc.data() as Map<String, dynamic>;
              
              final lastSender = chatData['lastSenderId'] ?? '';
              final isRead = chatData['isRead'] ?? true;

              if (lastSender != uid && isRead == false) {
                hasUnread = true;
                break; 
              }
            }
          }

          return CustomGlassBottomBar(
            currentIndex: _selectedIndex,
            hasUnreadMessages: hasUnread, 
            onTap: (index) {
              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddPostPage(),
                  ),
                );
              } else {
                setState(() => _selectedIndex = index);
              }
            },
          );
        },
      ),
    );
  }
}