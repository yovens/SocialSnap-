import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Enpòtan pou tcheke fòma "Timestamp" la
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  // ✅ KÒD LÈ A METE NAN PLAS LI KÒRÈKMAN KÒM YON METÒD KLAS LA
  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return "12:48 PM"; // Default si Firebase poko synchro
    
    DateTime dateTime = (timestamp is Timestamp) ? timestamp.toDate() : timestamp;
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = "AM";
    
    if (hour >= 12) {
      period = "PM";
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    
    String minuteStr = minute < 10 ? "0$minute" : "$minute";
    return "$hour:$minuteStr $period";
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          // 🎨 Koulè dinamik pou Dark Mode ak bèl ekla cyan si se mwen k voye l
          color: isMe
              ? const Color(0xFF00E5FF).withOpacity(0.15) // Ti koulè cyan transparan (Glassmorphism look)
              : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: Border.all(
            color: isMe 
                ? const Color(0xFF00E5FF).withOpacity(0.4) // Liy neon cyan sou mesaj mwen yo
                : (isDarkMode ? Colors.white10 : Colors.black12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📷 Afiche foto si mesaj la gen yon lyen imaj
            if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  message.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 6),
            ],
            
            // 💬 Tèks mesaj la
            if (message.message.isNotEmpty)
              Text(
                message.message,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              
            const SizedBox(height: 6),
            
            // 🕒 Lè a ak Ti double chèk (Done All)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  // ✅ Kounye a li pran bon lè dinamik la!
                  _formatMessageTime(message.timestamp), 
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: Color(0xFF00E5FF), // Ti chèk cyan an liy ak tèm nan
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}