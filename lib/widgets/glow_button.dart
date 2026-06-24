import 'package:flutter/material.dart';

/// Bouton an fòm "pill" ak yon glow cyan dèyè l, menm jan ak mockup la.
class GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GlowButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2DE6D6), Color(0xFF19C9E0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22E1D0).withOpacity(0.55),
              blurRadius: 22,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}