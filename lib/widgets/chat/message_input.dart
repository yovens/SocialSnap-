import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImagePick;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 24.0, top: 8.0),
      child: Row(
        children: [
          // 1️⃣ BOTON POU CHWASI FOTO (AK EKLA CYAN FLUO)
          GestureDetector(
            onTap: onImagePick,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF), // Cyan ultra vreyan
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2️⃣ CHAMP SIZI TÈKS LA (INPUT KI KROUNDED SOU COMANSE PALE...)
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Écrire un message...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 3️⃣ BOTON VOYE (IKÒN PAPYE MESSAGERY SOU KOTE)
          GestureDetector(
            onTap: onSend,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.send_rounded,
               color: isDarkMode ? const Color(0xFF00E5FF) : Colors.black.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}