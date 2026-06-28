import 'dart:ui';
import 'package:flutter/material.dart';

class CustomGlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool hasUnreadMessages; // 🔴 Kondisyon pou ti pwen wouj la

  const CustomGlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnreadMessages = false, // Pa defo li se false
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
      height: 68, // Nou moute wotè a yon ti kras pou l respire pi byen
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Efè Glassmorphism reyèl
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E).withOpacity(0.65)
                  : Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.15), // Ti rebò cyan fluo
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),

                // ➕ BOUTON PLUS LA AK STYLE KARE ADOUSI (BEN-TO STYLE)
                GestureDetector(
                  onTap: () => onTap(2),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      // Fòm kare adousi (Squircle) tankou nan foto a
                      borderRadius: BorderRadius.circular(16), 
                      color: const Color(0xFF00E5FF), // Koulè Cyan Cyan nan
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.45),
                          blurRadius: 14, // Ekla a (Glow effect)
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: Colors.white, // Ikòn blan sou fon cyan
                    ),
                  ),
                ),

                // 💬 IKÒN CHAT LA AK KONDISYON TI PWEN WOUJ LA
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  showBadge: hasUnreadMessages, // Pase kondisyon an isit la
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  index: 4,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;
  final bool showBadge; // 🔴 Pou kontwole ti pwen wouj la

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.showBadge = false, // Pa defo pa gen pwen
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool selected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ikòn prensipal la
            Icon(
              icon,
              size: 26,
              color: selected
                  ? (isDark ? Colors.white : const Color(0xFF1A1A2E))
                  : (isDark ? Colors.grey.shade600 : const Color(0xFFC0BAB0)),
            ),
            
            // 🔴 TI PWEN WOUJ LA SI CONDITION AN TRUE
            if (showBadge)
              Positioned(
                top: 2,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}