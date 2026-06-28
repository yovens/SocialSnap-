import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // ✅ Asire w chemen modèl ou an kòrèk

class CreatePostBar extends StatelessWidget {
  final UserModel? userModel; // ✅ Nou pase tout modèl la kounye a
  final VoidCallback onProfileTap;
  final VoidCallback onBarTap;

  const CreatePostBar({
    super.key,
    required this.userModel,
    required this.onProfileTap,
    required this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Rale premye mo nan displayName lan (pa egzanp: "Elis")
    final nameToDisplay = userModel?.displayName != null && userModel!.displayName.isNotEmpty
        ? userModel!.displayName.split(' ')[0]
        : "Utilisateur";

    // Rale URL foto profil la
    final imageUrl = userModel?.profileImageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // 1️⃣ FOTO PROFIL (AVÈK BÈL SÈK CYAN AN)
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E5FF),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.person, color: Colors.white, size: 22),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF00E5FF).withOpacity(0.1),
                              child: Center(
                                child: Text(
                                  nameToDisplay[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF00E5FF), 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 2️⃣ BAR PALE A: "Quoi de neuf, Elis ?"
                Expanded(
                  child: GestureDetector(
                    onTap: onBarTap,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Quoi de neuf, $nameToDisplay ?", // ✅ L ap afiche non an dinamikman kounye a
                            style: TextStyle(
                              color: isDarkMode ? Colors.white60 : Colors.black54, 
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.add_photo_alternate_rounded, 
                            color: const Color(0xFF00E5FF).withOpacity(0.8), 
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}