import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Light Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightPrimaryForeground,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightSecondaryForeground,
      tertiary: AppColors.lightAccent,
      onTertiary: AppColors.lightAccentForeground,
      error: AppColors.lightDestructive,
      onError: AppColors.lightDestructiveForeground,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightCardForeground,
      outline: AppColors.lightBorder,
    ),
    appBarTheme: AppBarTheme(
      elevation: 1,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightForeground,
      centerTitle: false,
      titleTextStyle: _getTitleTextStyle(isDark: false),
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.lightBorder,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(
          color: AppColors.lightBorder,
          width: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.lightPrimary,
          width: 2,
        ),
      ),
      hintStyle: _getBodyTextStyle(isDark: false).copyWith(
        color: AppColors.lightMutedForeground,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: _getTitleTextStyle(isDark: false, size: AppFontSizes.display1),
      displayMedium: _getTitleTextStyle(isDark: false, size: AppFontSizes.display2),
      headlineLarge: _getTitleTextStyle(isDark: false, size: AppFontSizes.xxxl),
      headlineMedium: _getTitleTextStyle(isDark: false, size: AppFontSizes.xxl),
      headlineSmall: _getTitleTextStyle(isDark: false, size: AppFontSizes.xl),
      titleLarge: _getTitleTextStyle(isDark: false, size: AppFontSizes.lg),
      titleMedium: _getTitleTextStyle(isDark: false),
      titleSmall: _getTitleTextStyle(isDark: false, size: AppFontSizes.sm),
      bodyLarge: _getBodyTextStyle(isDark: false),
      bodyMedium: _getBodyTextStyle(isDark: false, size: AppFontSizes.sm),
      bodySmall: _getBodyTextStyle(isDark: false, size: AppFontSizes.xs),
      labelLarge: _getLabelTextStyle(isDark: false),
      labelMedium: _getLabelTextStyle(isDark: false, size: AppFontSizes.sm),
      labelSmall: _getLabelTextStyle(isDark: false, size: AppFontSizes.xs),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightPrimaryForeground,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(
          color: AppColors.lightBorder,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.lightPrimary;
        }
        return AppColors.lightSwitchBackground;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.lightPrimary.withOpacity(0.5);
        }
        return AppColors.lightSwitchBackground.withOpacity(0.5);
      }),
    ),
  );

  // Dark Theme Data
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkPrimaryForeground,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkSecondaryForeground,
      tertiary: AppColors.darkAccent,
      onTertiary: AppColors.darkAccentForeground,
      error: AppColors.darkDestructive,
      onError: AppColors.darkDestructiveForeground,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkCardForeground,
      outline: AppColors.darkBorder,
    ),
    appBarTheme: AppBarTheme(
      elevation: 1,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkForeground,
      centerTitle: false,
      titleTextStyle: _getTitleTextStyle(isDark: true),
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.darkBorder,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInput,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.darkBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.darkBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.darkPrimary,
          width: 2,
        ),
      ),
      hintStyle: _getBodyTextStyle(isDark: true).copyWith(
        color: AppColors.darkMutedForeground,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: _getTitleTextStyle(isDark: true, size: AppFontSizes.display1),
      displayMedium: _getTitleTextStyle(isDark: true, size: AppFontSizes.display2),
      headlineLarge: _getTitleTextStyle(isDark: true, size: AppFontSizes.xxxl),
      headlineMedium: _getTitleTextStyle(isDark: true, size: AppFontSizes.xxl),
      headlineSmall: _getTitleTextStyle(isDark: true, size: AppFontSizes.xl),
      titleLarge: _getTitleTextStyle(isDark: true, size: AppFontSizes.lg),
      titleMedium: _getTitleTextStyle(isDark: true),
      titleSmall: _getTitleTextStyle(isDark: true, size: AppFontSizes.sm),
      bodyLarge: _getBodyTextStyle(isDark: true),
      bodyMedium: _getBodyTextStyle(isDark: true, size: AppFontSizes.sm),
      bodySmall: _getBodyTextStyle(isDark: true, size: AppFontSizes.xs),
      labelLarge: _getLabelTextStyle(isDark: true),
      labelMedium: _getLabelTextStyle(isDark: true, size: AppFontSizes.sm),
      labelSmall: _getLabelTextStyle(isDark: true, size: AppFontSizes.xs),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkPrimaryForeground,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(
          color: AppColors.darkBorder,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary;
        }
        return AppColors.darkMuted;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary.withOpacity(0.5);
        }
        return AppColors.darkMuted.withOpacity(0.5);
      }),
    ),
  );

  static TextStyle _getTitleTextStyle({
    required bool isDark,
    double size = AppFontSizes.base,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: AppFontWeights.semiBold,
      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
      fontFamily: 'Inter',
      letterSpacing: 0.5,
    );
  }

  static TextStyle _getBodyTextStyle({
    required bool isDark,
    double size = AppFontSizes.base,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: AppFontWeights.normal,
      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
      fontFamily: 'Inter',
      letterSpacing: 0.2,
    );
  }

  static TextStyle _getLabelTextStyle({
    required bool isDark,
    double size = AppFontSizes.sm,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: AppFontWeights.medium,
      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
      fontFamily: 'Inter',
      letterSpacing: 0.3,
    );
  }
}
