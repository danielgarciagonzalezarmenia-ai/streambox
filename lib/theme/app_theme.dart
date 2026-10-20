import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF10141E);
  static const Color surfaceElevated = Color(0xFF1A1F2E);
  static const Color accent = Color(0xFFE50914); // Netflix / Apple Red
  static const Color accentGlow = Color(0xFFFF375F);
  static const Color secondary = Color(0xFF0A84FF); // iOS Blue
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color divider = Color(0xFF27272A);
  static const Color glassBorder = Color(0x26FFFFFF);

  static CupertinoThemeData get cupertinoDarkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: accent,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: Color(0xCC000000), // Frosted glass black
      scaffoldBackgroundColor: background,
      textTheme: CupertinoTextThemeData(
        primaryColor: textPrimary,
        textStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontFamily: '.SF Pro Text',
          letterSpacing: -0.3,
        ),
        navTitleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Display',
          letterSpacing: -0.4,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          fontFamily: '.SF Pro Display',
          letterSpacing: -0.8,
        ),
      ),
    );
  }

  static ThemeData get materialDarkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      canvasColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: secondary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xEE0A0D14),
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
