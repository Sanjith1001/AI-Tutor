import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 ByteBrain Modern AI Color Palette
  static const Color primaryIndigo = Color(0xFF6C63FF); // Main indigo violet
  static const Color primaryIndigoLight = Color(0xFF8B7EFF);
  static const Color primaryIndigoDark = Color(0xFF5A52E5);

  static const Color secondaryTeal = Color(0xFF4FD1C5); // Calming teal
  static const Color secondaryTealLight = Color(0xFF6FE7DB);
  static const Color secondaryTealDark = Color(0xFF38B2AC);

  static const Color accentLavender = Color(0xFFB794F6); // Soft lavender
  static const Color accentLavenderLight = Color(0xFFD6BCFA);
  static const Color accentLavenderDark = Color(0xFF9F7AEA);

  // Background & Surface Colors
  static const Color backgroundPrimary =
      Color(0xFFF5F7FB); // Subtle light background
  static const Color backgroundSecondary = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceElevated =
      Color(0xFFFCFDFF); // Slightly elevated surface

  // Legacy / Compatibility aliases (used across older screens)
  // Map older project color names to the new modern palette
  static const Color backgroundGrey = backgroundPrimary; // legacy name
  static const Color cardWhite = backgroundSecondary; // legacy name
  static const Color primaryRed =
      Color(0xFFEF4444); // legacy accent for errors/actions
  static const Color dividerGrey = Color(0xFFE6E9EE); // subtle divider

  // Text Colors
  static const Color textPrimary =
      Color(0xFF1A202C); // Dark gray for readability
  static const Color textSecondary = Color(0xFF4A5568); // Medium gray
  static const Color textTertiary = Color(0xFF718096); // Light gray
  static const Color textOnPrimary =
      Color(0xFFFFFFFF); // White text on colored backgrounds

  // Semantic Colors
  static const Color successColor = Color(0xFF48BB78);
  static const Color warningColor = Color(0xFFED8936);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color infoColor = Color(0xFF4299E1);

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E0);
  static const Color dividerColor = Color(0xFFF1F5F9);

  // 🌟 AI-Enhanced Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, primaryIndigoLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [secondaryTeal, secondaryTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [accentLavender, accentLavenderLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [backgroundSecondary, backgroundPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [primaryIndigo, secondaryTeal, accentLavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // ✨ Shadows (Minimal & Clean)
  static List<BoxShadow> cardShadows = [
    BoxShadow(
      color: primaryIndigo.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadows = [
    BoxShadow(
      color: primaryIndigo.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadows = [
    BoxShadow(
      color: primaryIndigo.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // 🌟 Modern AI Theme Data with Google Fonts
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: backgroundPrimary,
      primaryColor: primaryIndigo,
      cardColor: backgroundSecondary,

      // App Bar with Clean AI Design
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundSecondary,
        elevation: 0,
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Modern Typography with Google Fonts
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: -0.1,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: textSecondary,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          color: textTertiary,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
      ),

      // Modern Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryIndigo,
        secondary: secondaryTeal,
        surface: backgroundSecondary,
        error: errorColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onError: textOnPrimary,
        tertiary: accentLavender,
        onTertiary: textOnPrimary,
      ),

      // Modern Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryIndigo,
          foregroundColor: textOnPrimary,
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return borderLight;
            }
            if (states.contains(WidgetState.pressed)) {
              return primaryIndigoDark;
            }
            return primaryIndigo;
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: primaryIndigo,
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Elevated Card Design
      cardTheme: CardThemeData(
        color: backgroundSecondary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Modern Input Design
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: borderLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primaryIndigo,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: errorColor,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.roboto(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.roboto(
          color: textTertiary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Modern Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundSecondary,
        selectedItemColor: primaryIndigo,
        unselectedItemColor: textTertiary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundSecondary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
      ),

      // Modern SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.roboto(
          color: textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryIndigo,
        linearTrackColor: borderLight,
        circularTrackColor: borderLight,
      ),

      // Modern Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        disabledColor: borderLight,
        selectedColor: primaryIndigo.withValues(alpha: 0.1),
        secondarySelectedColor: secondaryTeal.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: GoogleFonts.roboto(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.roboto(
          color: primaryIndigo,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.light,
      ),

      // Modern Tab Bar
      tabBarTheme: TabBarThemeData(
        indicator: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: primaryIndigo,
        unselectedLabelColor: textSecondary,
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),

      // Divider
      dividerColor: dividerColor,

      // Modern Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryIndigo;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        side: BorderSide(
          color: borderMedium,
          width: 2,
        ),
      ),

      // Modern Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryIndigo;
          }
          return Colors.transparent;
        }),
      ),

      // Modern Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return textOnPrimary;
          }
          return borderMedium;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryIndigo;
          }
          return Colors.grey.shade300;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  // 🎯 Utility Methods
  static BoxDecoration getGradientDecoration({
    LinearGradient? gradient,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      boxShadow: buttonShadows,
    );
  }

  static BoxDecoration getCardDecoration({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundSecondary,
      borderRadius: BorderRadius.circular(borderRadius ?? 20),
      boxShadow: cardShadows,
    );
  }

  static BoxDecoration getSubtleCardDecoration({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundSecondary,
      borderRadius: BorderRadius.circular(borderRadius ?? 20),
      border: Border.all(color: borderLight, width: 1),
    );
  }

  // 🎨 Modern Shimmer Colors for Loading States
  static Color shimmerBaseColor = borderLight;
  static Color shimmerHighlightColor = surfaceElevated;

  // 🌊 Modern Border Radius Values
  static const double radiusXS = 8.0;
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;

  // ✨ Spacing Constants
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
}
