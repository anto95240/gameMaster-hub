import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Mode Colors
  static const Color _bgPrimaryLight = Color(0xFFF9FAFB);
  static const Color _bgSecondaryLight = Color(0xFFE5E7EB);
  static const Color _textPrimaryLight = Color(0xFF111827);
  static const Color _textSecondaryLight = Color(0xFF4B5563);
  static const Color _accentPrimaryLight = Color(0xFF0891B2);
  static const Color _accentSecondaryLight = Color(0xFFEAB308);
  static const Color _borderLight = Color(0xFFD1D5DB);

  // Dark Mode Colors
  static const Color _bgPrimaryDark = Color(0xFF0A0F1E);
  static const Color _bgSecondaryDark = Color(0xFF2C2C3A);
  static const Color _textPrimaryDark = Color(0xFFEAEAEA);
  static const Color _textSecondaryDark = Color(0xFF9CA3AF);
  static const Color _accentPrimaryDark = Color(0xFF00E5FF);
  static const Color _accentSecondaryDark = Color(0xFFFFD60A);
  static const Color _borderDark = Color(0xFF2F2F3A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _accentPrimaryLight,
        secondary: _accentSecondaryLight,
        surface: _bgPrimaryLight,
        background: _bgPrimaryLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryLight,
        onBackground: _textPrimaryLight,
      ),
      scaffoldBackgroundColor: _bgPrimaryLight,
      cardColor: _bgSecondaryLight,
      dividerColor: _borderLight,
      textTheme: _buildTextTheme(_textPrimaryLight, _textSecondaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgSecondaryLight,
        foregroundColor: _textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _textPrimaryLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentPrimaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: _bgSecondaryLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _borderLight),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _accentPrimaryDark,
        secondary: _accentSecondaryDark,
        surface: _bgPrimaryDark,
        background: _bgPrimaryDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryDark,
        onBackground: _textPrimaryDark,
      ),
      scaffoldBackgroundColor: _bgPrimaryDark,
      cardColor: _bgSecondaryDark,
      dividerColor: _borderDark,
      textTheme: _buildTextTheme(_textPrimaryDark, _textSecondaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgSecondaryDark,
        foregroundColor: _textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentPrimaryDark,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: _bgSecondaryDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _borderDark),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: primary,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }
}