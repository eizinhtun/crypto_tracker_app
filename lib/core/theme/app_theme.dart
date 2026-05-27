import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        surface: AppColors.lightSurface,
        error: AppColors.negative,
        onSurface: AppColors.lightTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        foregroundColor: AppColors.lightTextPrimary,
        centerTitle: true,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineSmall: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        labelMedium: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
        labelSmall: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.darkSurface,
        error: AppColors.negative,
        onSurface: AppColors.darkTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        foregroundColor: AppColors.darkTextPrimary,
        centerTitle: true,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineSmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        labelMedium: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
        labelSmall: TextStyle(
          color: AppColors.darkTextMuted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}