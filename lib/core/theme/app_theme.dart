// Example Theme Extension or Class
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF001F3F); // Navy from Logo
  static const Color accentColor = Color(0xFFFF8C00);  // Orange from Logo

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}