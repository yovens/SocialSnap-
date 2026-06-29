import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../profile/profile_page.dart'; // 🟢 Enpòte paj profil la
import '../post/post_details_page.dart'; // 🟢 Enpòte paj detay post la
import '../../models/post_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'TOUT';
  
  List<DocumentSnapshot> _allPosts = [];
  List<DocumentSnapshot> _allUsers = [];
  List<DocumentSnapshot> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExploreData();
  }

  Future<void> _fetchExploreData() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      setState(() {
        _allPosts = postsSnapshot.docs;
        _allUsers = usersSnapshot.docs.where((doc) => doc.id != currentUid).toList();
        _filteredUsers = _allUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Erreur k ap rale done: $e");
    }
  }

  void _searchProfile(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _allUsers);
      return;
    }

    setState(() {
      final lowercaseQuery = query.toLowerCase();
      _filteredUsers = _allUsers.where((doc) {
        final displayName = (doc.data() as Map<String, dynamic>)['displayName']?.toString().toLowerCase() ?? '';
        final username = (doc.data() as Map<String, dynamic>)['username']?.toString().toLowerCase() ?? '';
        return displayName.contains(lowercaseQuery) || username.contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recherche",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchProfile,
                            decoration: InputDecoration(
                              hintText: "Rechercher un profil...",
                              hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 14),
                              prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54),
                              filled: true,
                              fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CHIPS FILTÈ
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: ['TOUT', 'PEOPLE', 'POSTS'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selectedFilter = filter),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF00E5FF).withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : (isDark ? Colors.white24 : Colors.black12)),
                            ),
                            child: Text(filter, style: TextStyle(color: isSelected ? const Color(0xFF00E5FF) : (isDark ? Colors.white70 : Colors.black54), fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // KONTNI
              _isLoading
                  ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))))
                  : _buildContentBasedOnFilter(isDark),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBasedOnFilter(bool isDark) {
    if (_selectedFilter == 'PEOPLE') {
      return _buildUsersGrid(isDark, _filteredUsers);
    } else if (_selectedFilter == 'POSTS') {
      return _buildPostsGrid(isDark, _allPosts);
    } else {
      return SliverList(
        delegate: SliverChildListDelegate([
          if (_filteredUsers.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Utilisateurs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  return _buildUserCircleItem(isDark, _filteredUsers[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Publications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
            itemCount: _allPosts.length,
            itemBuilder: (context, index) {
              return _buildPostCardItem(isDark, _allPosts[index]);
            },
          ),
        ]),
      );
    }
  }

  Widget _buildUsersGrid(bool isDark, List<DocumentSnapshot> usersList) {
    if (usersList.isEmpty) return const SliverFillRemaining(child: Center(child: Text("Aucun utilisateur trouvé")));
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildUserCardItem(isDark, usersList[index]),
        childCount: usersList.length,
      ),
    );
  }

  Widget _buildPostsGrid(bool isDark, List<DocumentSnapshot> postsList) {
    if (postsList.isEmpty) return const SliverFillRemaining(child: Center(child: Text("Aucune publication")));
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildPostCardItem(isDark, postsList[index]),
        childCount: postsList.length,
      ),
    );
  }

  // 🔥 1️⃣ TI KÒD POST KI METE AJOU (AK KLIK POU DETAY APW KONTWÒL LIKE)
Widget _buildPostCardItem(bool isDark, DocumentSnapshot postDoc) {
    final post = postDoc.data() as Map<String, dynamic>;
    final imageUrl = post['imageUrl'] ?? '';
    final description = post['description'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailsPage(
              post: PostModel.fromMap(
                postDoc.data() as Map<String, dynamic>,
                postDoc.id,
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.01),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
          ),
          child: Stack(
            children: [
              // Imaj piblikasyon an
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade900),
              
              // Gradyan pou tèks la ka lizib
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
              ),
              
              // Deskripsyon sèlman anba kat la
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // 🔥 2️⃣ TI KÒD KAT KARE USER (FILTÈ PEOPLE) KI KLIKABLE POU PROFILEPAGE
  Widget _buildUserCardItem(bool isDark, DocumentSnapshot userDoc) {
    final user = userDoc.data() as Map<String, dynamic>;
    final photoUrl = user['profileImageUrl'] ?? '';
    final name = user['displayName'] ?? 'Utilisateur';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(uid: userDoc.id)), // Louvri paj pwofil li ak ID li
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E5FF), width: 1.5)),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 3️⃣ TI KÒD USER WON (FILTÈ TOUT ANLÈ) KI KLIKABLE TOU
  Widget _buildUserCircleItem(bool isDark, DocumentSnapshot userDoc) {
    final user = userDoc.data() as Map<String, dynamic>;
    final photoUrl = user['profileImageUrl'] ?? '';
    final name = user['displayName'] ?? 'Utilisateur';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(uid: userDoc.id)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E5FF), width: 1.5)),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54)),
            ),
          ],
        ),
      ),
    );
  }
}