import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

class CommonStyles {
  // Loading Styles
  static Widget get loadingIndicator => const CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      );

  static Widget loadingIndicatorWithColor(Color color) =>
      CircularProgressIndicator(
        color: color,
        strokeWidth: 3,
      );

  static BoxDecoration get loadingOverlayDecoration => BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
      );

  // Dialog Styles
  static BoxDecoration get dialogDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static TextStyle get dialogTitle => AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get dialogContent => AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Snackbar Styles
  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      );

  static SnackBar successSnackBar(String message) => SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      );

  static SnackBar errorSnackBar(String message) => SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      );

  static SnackBar warningSnackBar(String message) => SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      );

  // Empty State Styles
  static Widget emptyState({
    required IconData icon,
    required String title,
    required String description,
    Widget? action,
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action,
          ],
        ],
      );

  // Divider Styles
  static Widget get divider => Container(
        height: 1,
        color: AppColors.divider,
      );

  static Widget get thickDivider => Container(
        height: 8,
        color: AppColors.background,
      );

  // Shadow Styles
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Border Radius
  static BorderRadius get smallBorderRadius => BorderRadius.circular(8);
  static BorderRadius get mediumBorderRadius => BorderRadius.circular(12);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(16);
  static BorderRadius get extraLargeBorderRadius => BorderRadius.circular(20);

  // Padding
  static const EdgeInsets tinyPadding = EdgeInsets.all(4);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  static const EdgeInsets mediumPadding = EdgeInsets.all(12);
  static const EdgeInsets largePadding = EdgeInsets.all(16);
  static const EdgeInsets extraLargePadding = EdgeInsets.all(20);
  static const EdgeInsets hugePadding = EdgeInsets.all(24);

  // Margin
  static const EdgeInsets tinyMargin = EdgeInsets.all(4);
  static const EdgeInsets smallMargin = EdgeInsets.all(8);
  static const EdgeInsets mediumMargin = EdgeInsets.all(12);
  static const EdgeInsets largeMargin = EdgeInsets.all(16);
  static const EdgeInsets extraLargeMargin = EdgeInsets.all(20);
  static const EdgeInsets hugeMargin = EdgeInsets.all(24);

  // Spacing
  static const double tinySpacing = 4.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 20.0;
  static const double hugeSpacing = 24.0;

  // Icon Sizes
  static const double tinyIconSize = 16.0;
  static const double smallIconSize = 20.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 40.0;
  static const double hugeIconSize = 48.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
}
