import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class MediaGalleryPage extends StatelessWidget {
  final String chatId;

  const MediaGalleryPage({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sharedMediaTitle),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Nou koute tout mesaj ki nan chat la
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorWithDetail(snapshot.error.toString())),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noSharedMedia),
            );
          }

          // 1. Filtre sèlman dokiman ki gen 'type' = 'image'
          final mediaDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type']?.toString();
            // Li enpòtan pou tcheke si valè a se pa null
            return type != null && type == 'image';
          }).toList();

          if (mediaDocs.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noSharedMedia),
            );
          }

          // 2. Afiche foto yo nan yon GridView
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 foto pa liy
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: mediaDocs.length,
            itemBuilder: (context, index) {
              final doc = mediaDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              // Nou rale URL la nan chan 'message' la ekzateman
              final imageUrl = data['message'] ?? '';

              return GestureDetector(
                onTap: () {
                  // Louvri paj pou gade foto yo an gwo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenMediaViewer(
                        chatId: chatId,
                        mediaDocs: mediaDocs,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    // Si imaj la pa ka chaje
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                    // Afiche loader pandan imaj la ap chaje
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ==========================================================
/// PAJ POU WE FOTO AN GWO, DEFILE, AK SIPRIME
/// ==========================================================
class FullscreenMediaViewer extends StatefulWidget {
  final String chatId;
  final List<QueryDocumentSnapshot> mediaDocs;
  final int initialIndex;

  const FullscreenMediaViewer({
    super.key,
    required this.chatId,
    required this.mediaDocs,
    required this.initialIndex,
  });

  @override
  State<FullscreenMediaViewer> createState() => _FullscreenMediaViewerState();
}

class _FullscreenMediaViewerState extends State<FullscreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _deleteMedia(String messageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePhotoTitle),
        content: Text(AppLocalizations.of(context)!.deletePhotoConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .doc(messageId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.photoDeleted)),
          );
          Navigator.pop(context); // Tounen nan galri a
        }
      } catch (e) {
        print("Erè pandan suppression: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${_currentIndex + 1} / ${widget.mediaDocs.length}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              final currentDoc = widget.mediaDocs[_currentIndex];
              _deleteMedia(currentDoc.id);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaDocs.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final data = widget.mediaDocs[index].data() as Map<String, dynamic>;
          // Nou re-rale URL la nan chan 'message' la
          final imageUrl = data['message'] ?? '';

          return InteractiveViewer(
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.white, size: 50);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}