import 'package:flutter/material.dart';
import 'colors/app_colors.dart';
import 'typography/app_typography.dart';
import 'styles/common_styles.dart';

class AppTheme {
  static TextTheme get _lightTextTheme {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.textPrimary),
      displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
      titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
      labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
    );
  }

  static TextTheme get _darkTextTheme {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkTextPrimary),
      displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.darkTextPrimary),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.darkTextPrimary),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.darkTextPrimary),
      titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.darkTextPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextSecondary),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
      labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.darkTextSecondary),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.darkTextSecondary),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _lightTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: CommonStyles.snackBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        error: AppColors.error,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _darkTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: CommonStyles.snackBarTheme,
    );
  }
}
