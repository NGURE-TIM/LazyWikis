import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Dark Theme (Primary)
  static const Color mainBackground = Color(0xFF1A1A1A);
  static const Color panelBackground = Color(0xFF2D2D2D);
  static const Color codeBackground = Color(0xFF1E1E1E);

  static const Color primaryText = Color(0xFFE0E0E0);
  static const Color secondaryText = Color(0xFFA0A0A0);

  static const Color accent = Color(0xFF0D6EFD);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFDC3545);

  static const Color border = Color(0xFF404040);

  // Light Theme (Alternative)
  static const Color mainBackgroundLight = Color(0xFFFFFFFF);
  static const Color panelBackgroundLight = Color(0xFFF5F5F5);
  static const Color codeBackgroundLight = Color(0xFFF8F9FA);
  static const Color primaryTextLight = Color(0xFF212529);
  static const Color secondaryTextLight = Color(0xFF6C757D);
  static const Color borderLight = Color(0xFFDEE2E6);
}

/// App typography
class AppTypography {
  static const String uiFontFamily = 'Roboto';
  static const String codeFontFamily = 'monospace';

  static const double appTitle = 20.0;
  static const double pageHeading = 24.0;
  static const double sectionHeading = 18.0;
  static const double bodyText = 14.0;
  static const double codeText = 13.0;
  static const double smallText = 12.0;
}

/// App theme configuration
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.mainBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.success,
        surface: AppColors.panelBackground,
        error: AppColors.danger,
      ),
      cardColor: AppColors.panelBackground,
      dividerColor: AppColors.border,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppTypography.pageHeading,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        displayMedium: TextStyle(
          fontSize: AppTypography.appTitle,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        titleLarge: TextStyle(
          fontSize: AppTypography.sectionHeading,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTypography.bodyText,
          color: AppColors.primaryText,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypography.bodyText,
          color: AppColors.secondaryText,
        ),
        bodySmall: TextStyle(
          fontSize: AppTypography.smallText,
          color: AppColors.secondaryText,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        color: AppColors.panelBackground,
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        backgroundColor: AppColors.panelBackground,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.codeBackground,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.mainBackgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.success,
        surface: AppColors.panelBackgroundLight,
        error: AppColors.danger,
      ),
      cardColor: AppColors.panelBackgroundLight,
      dividerColor: AppColors.borderLight,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppTypography.pageHeading,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextLight,
        ),
        displayMedium: TextStyle(
          fontSize: AppTypography.appTitle,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextLight,
        ),
        titleLarge: TextStyle(
          fontSize: AppTypography.sectionHeading,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextLight,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTypography.bodyText,
          color: AppColors.primaryTextLight,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypography.bodyText,
          color: AppColors.secondaryTextLight,
        ),
        bodySmall: TextStyle(
          fontSize: AppTypography.smallText,
          color: AppColors.secondaryTextLight,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        color: AppColors.panelBackgroundLight,
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        backgroundColor: AppColors.panelBackgroundLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.codeBackgroundLight,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }
}
