import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

class HomeScreenStyles {
  // Top Bar Styles
  static BoxDecoration get topBarDecoration => const BoxDecoration(
        color: Colors.transparent,
      );

  static BoxDecoration get brandBadgeDecoration => BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      );

  static TextStyle get brandBadgeText => AppTypography.labelLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );

  // Hero Section Styles
  static BoxDecoration get heroDecoration => const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      );

  static BoxDecoration get heroIconDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      );

  static TextStyle get heroTitle => AppTypography.heroTitle.copyWith(
        color: Colors.white,
      );

  static TextStyle get heroSubtitle => AppTypography.heroSubtitle.copyWith(
        color: Colors.white70,
      );

  static TextStyle get heroWelcomeText => AppTypography.bodyLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heroDescriptionText => AppTypography.bodySmall.copyWith(
        color: Colors.white70,
      );

  // Continue Learning Section Styles
  static BoxDecoration get continueCardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get courseIconDecoration => BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      );

  static TextStyle get courseTitle => AppTypography.cardTitle.copyWith(
        color: AppColors.textPrimary,
      );

  static TextStyle get courseCategory => AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary,
      );

  static TextStyle get progressLabel => AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
      );

  static TextStyle get progressValue => AppTypography.caption.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      );

  // Quick Actions Styles
  static TextStyle get sectionTitle => AppTypography.sectionTitle.copyWith(
        color: AppColors.textPrimary,
      );

  static BoxDecoration quickActionDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      );

  static BoxDecoration quickActionIconDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      );

  static TextStyle get quickActionTitle => AppTypography.labelLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get quickActionSubtitle => AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
      );

  // Recommended Section Styles
  static BoxDecoration recommendedCardDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get recommendedIconDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      );

  static TextStyle get recommendedTitle => AppTypography.labelLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get recommendedSubtitle => AppTypography.caption.copyWith(
        color: Colors.white70,
      );

  // Button Styles
  static ButtonStyle get resumeButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.buttonText,
      );

  static ButtonStyle exploreButtonStyle(Color color) =>
      ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        textStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  // Progress Bar Styles
  static BorderRadius get progressBorderRadius => BorderRadius.circular(10);

  // Spacing Constants
  static const double sectionSpacing = 20.0;
  static const double cardSpacing = 16.0;
  static const double elementSpacing = 12.0;
  static const double smallSpacing = 8.0;
  static const double tinySpacing = 4.0;

  // Padding Constants
  static const EdgeInsets screenPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets elementPadding = EdgeInsets.all(16);
  static const EdgeInsets smallPadding = EdgeInsets.all(12);
  static const EdgeInsets tinyPadding = EdgeInsets.all(8);
}
