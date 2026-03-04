import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0A1F44);
  static const Color accent = Color(0xFF1E88E5);
  static const Color background = Color(0xFFF4F6FA);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}