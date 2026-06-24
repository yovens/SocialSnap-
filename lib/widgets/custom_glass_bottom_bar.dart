import 'package:flutter/material.dart';

class CustomGlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomGlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 24,
        left: 20,
        right: 20,
      ),
      height: 64,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.30 : 0.10,
            ),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
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

          // ADD POST BUTTON
          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      isDark ? 0.30 : 0.12,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                size: 24,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ),

          _NavItem(
            icon:
                Icons.chat_bubble_outline_rounded,
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
          ),

          _NavItem(
            icon: Icons.person_outline_rounded,
            index: 4,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bool selected =
        index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Icon(
          icon,
          size: 26,
          color: selected
              ? (isDark
                  ? Colors.white
                  : const Color(0xFF1A1A2E))
              : (isDark
                  ? Colors.grey.shade600
                  : const Color(0xFFC0BAB0)),
        ),
      ),
    );
  }
}