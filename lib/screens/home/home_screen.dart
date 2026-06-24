import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_glass_bottom_bar.dart';
import 'feed_page.dart';
import '../create/add_post_page.dart';
import '../profile/profile_page.dart';
import '../../providers/theme_provider.dart';

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

    final List<Widget> pages = [
      const FeedPage(),
      const Center(child: Text("Search")),
      const SizedBox(),
      const Center(child: Text("Chat")),
      ProfilePage(uid: currentUid),
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

      bottomNavigationBar: CustomGlassBottomBar(
        currentIndex: _selectedIndex,
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
      ),
    );
  }
}