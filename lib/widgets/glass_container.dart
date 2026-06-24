
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        // sigma fèb paske background la se yon koulè plat - blur la pa fè gwo efè
        // men nou kenbe l pou lè gen kontni dèyè kat la pita
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92), // pi opak pase anvan = pi vizib
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
          child: child,
        ),
      ),
    );
  }
}