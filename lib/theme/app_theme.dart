import 'package:flutter/material.dart';

class AppTheme {
  // Koulè prensipal (Cyan Neon pou aksyon)
  static const Color accentColor = Color(0xFF00F0FF);
  
  // Tèm Klè (Light Mode)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F0), // Koulè krèm klè
    primaryColor: accentColor,
    useMaterial3: true,
  );

  // Tèm Sombre (Dark Mode)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Nwa pwofon
    primaryColor: accentColor,
    useMaterial3: true,
  );
}