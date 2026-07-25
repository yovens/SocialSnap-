import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return "12:48 PM";
    
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

  // 💡 Mètod pou tcheke si yon tèks se yon lyen imaj (ImgBB oswa web)
  bool _isImageUrl(String text) {
    final lower = text.toLowerCase().trim();
    return lower.startsWith('http://') || 
           lower.startsWith('https://') || 
           lower.contains('ibb.co') || 
           lower.endsWith('.jpg') || 
           lower.endsWith('.png') || 
           lower.endsWith('.jpeg') || 
           lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 💡 Jwenn URL imaj la (fwa sa a nou gade mediaUrl AK message.message)
    final String? directMediaUrl = message.mediaUrl;
    final bool isMessageAnImage = _isImageUrl(message.message);
    
    final String? finalImageUrl = (directMediaUrl != null && directMediaUrl.isNotEmpty)
        ? directMediaUrl
        : (isMessageAnImage ? message.message : null);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF00E5FF).withOpacity(0.15)
              : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: Border.all(
            color: isMe 
                ? const Color(0xFF00E5FF).withOpacity(0.4)
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
            // 📷 AFICHE IMAJ LA (si nou jwenn yon URL)
            if (finalImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  finalImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red.withOpacity(0.1),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, color: Colors.red, size: 20),
                        SizedBox(width: 6),
                        Text(
                          "Erreur de chargement",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            
            // 💬 AFICHE TÈKS LA (sèlman si se pa yon imaj pi)
            if (message.message.isNotEmpty && !isMessageAnImage)
              Text(
                message.message,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              
            const SizedBox(height: 6),
            
            // 🕒 LÈ AK CHÈK CYAN
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatMessageTime(message.timestamp), 
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: message.isSeen ? const Color(0xFF00E5FF) : Colors.grey,
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