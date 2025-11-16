import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

class AuthScreenStyles {
  // Background Styles
  static BoxDecoration get backgroundDecoration => const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  // Logo Styles
  static BoxDecoration get logoDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      );

  static TextStyle get logoText => AppTypography.headlineMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );

  // Form Card Styles
  static BoxDecoration get formCardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // Title Styles
  static TextStyle get formTitle => AppTypography.headlineSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get formSubtitle => AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      );

  // Input Field Styles
  static InputDecoration inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );

  static TextStyle get inputTextStyle => AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.buttonText,
        elevation: 0,
      );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primary),
        ),
        textStyle: AppTypography.buttonText,
        elevation: 0,
      );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  // Social Button Styles
  static ButtonStyle socialButtonStyle(Color color) => ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      );

  // Link Styles
  static TextStyle get linkText => AppTypography.bodyMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      );

  // Error Styles
  static TextStyle get errorText => AppTypography.bodySmall.copyWith(
        color: AppColors.error,
      );

  static BoxDecoration get errorDecoration => BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      );

  // Success Styles
  static TextStyle get successText => AppTypography.bodySmall.copyWith(
        color: AppColors.success,
      );

  static BoxDecoration get successDecoration => BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      );

  // Loading Styles
  static BoxDecoration get loadingOverlayDecoration => BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      );

  // Divider Styles
  static Widget get divider => Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.divider,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.divider,
            ),
          ),
        ],
      );

  // Spacing Constants
  static const double formPadding = 24.0;
  static const double fieldSpacing = 16.0;
  static const double sectionSpacing = 24.0;
  static const double buttonSpacing = 12.0;

  // Animation Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
}
