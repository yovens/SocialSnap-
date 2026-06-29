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

  String get currentUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    // 🟢 2️⃣ RANPLASE "Center(child: Text('Search'))" PA "SearchPage()"
    final List<Widget> pages = [
      const FeedPage(),
      const SearchPage(), // 
      const SizedBox(), // Sa a rete vid paske bouton '+' la louvri yon lòt paj (AddPostPage)
      const ChatsPage(),
      ProfilePage(uid: currentUid),
    ];

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF5F1E4),
      extendBody: true, // Sa enpòtan pou efè Glassmorphism nan ka parèt dèyè bar la!

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

bottomNavigationBar: StreamBuilder<QuerySnapshot>(
  // 🛰️ Nou koute 'chats' epi nou gade si 'participants' la gen ID pa w ladan l
  stream: FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: currentUid) // 🟢 Korije: 'participants' olye de 'users'
      .snapshots(),
  builder: (context, snapshot) {
    bool hasUnread = false;

    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      for (var doc in snapshot.data!.docs) {
        final chatData = doc.data() as Map<String, dynamic>;
        
        // 🟢 Korije chan yo daprè Firebase ou: 'lastSenderId'
        final lastSender = chatData['lastSenderId'] ?? '';
        final isRead = chatData['isRead'] ?? true; // Si chan an poko egziste, li ba l true pa defo

        // Si se pa ou ki voye dènye mesaj la, epi li poko li (isRead == false)
        if (lastSender != currentUid && isRead == false) {
          hasUnread = true;
          break; 
        }
      }
    }

    // 🟢 Pase 'hasUnread' bay CustomGlassBottomBar la
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