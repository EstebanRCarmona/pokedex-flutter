import 'package:flutter/material.dart';

class AppTheme {
  static const _orange = Color(0xFFFF6D00);
  static const _onOrange = Colors.white;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _orange,
      onPrimary: _onOrange,
      secondary: Color(0xFFFFAB40),
      onSecondary: Colors.black,
      surface: Color(0xFFFFF8F0),
      onSurface: Color(0xFF1A1A1A),
      error: Color(0xFFB00020),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF3E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: _orange,
      foregroundColor: _onOrange,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.orange.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textTheme: _textTheme,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _orange,
      onPrimary: Colors.black,
      secondary: Color(0xFFFFAB40),
      onSecondary: Colors.black,
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFF5F5F5),
      error: Color(0xFFCF6679),
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      foregroundColor: Color.fromARGB(255, 240, 97, 2),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2A2A),
      elevation: 6,
      shadowColor: Colors.orange.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textTheme: _textTheme,
  );

  static const TextTheme _textTheme = TextTheme(
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    labelSmall: TextStyle(fontSize: 11, letterSpacing: 0.8),
  );
}
