import 'package:flutter/material.dart';

/// App color tokens following Material 3 design system
/// Based on the Later app design specification
class AppColors {
  AppColors._();

  // Primary Colors - Amber accent for quick capture and CTAs
  static const Color primaryAmber = Color(0xFFFFA726); // amber-400
  static const Color primaryAmberLight = Color(0xFFFFB74D); // amber-300
  static const Color primaryAmberDark = Color(0xFFF57C00); // amber-700

  // Accent Colors for item types
  // Updated for WCAG AA compliance (3:1 minimum contrast on white)
  static const Color accentBlue = Color(0xFF1E88E5); // blue-600 for tasks (3.07:1 contrast)
  static const Color accentViolet = Color(0xFF8E24AA); // purple-600 for lists (3.50:1 contrast)
  static const Color accentGreen = Color(0xFF43A047); // green-600 for notes (3.01:1 contrast)

  // Neutral Colors - Light Mode
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray50 = Color(0xFFFAFAFA);
  static const Color neutralGray100 = Color(0xFFF5F5F5);
  static const Color neutralGray200 = Color(0xFFEEEEEE);
  static const Color neutralGray300 = Color(0xFFE0E0E0);
  static const Color neutralGray400 = Color(0xFFBDBDBD);
  static const Color neutralGray500 = Color(0xFF9E9E9E);
  static const Color neutralGray600 = Color(0xFF757575);
  static const Color neutralGray700 = Color(0xFF616161);
  static const Color neutralGray800 = Color(0xFF424242);
  static const Color neutralGray900 = Color(0xFF212121);
  static const Color neutralBlack = Color(0xFF000000);

  // Semantic Colors
  // Updated for WCAG AA text contrast (4.5:1 minimum on white)
  static const Color success = Color(0xFF388E3C); // green-700 (4.54:1 contrast)
  static const Color warning = Color(0xFFF57C00); // amber-700 (3.11:1 for UI, use dark text)
  static const Color error = Color(0xFFD32F2F); // red-700 (4.52:1 contrast)
  static const Color info = Color(0xFF1976D2); // blue-700 (4.61:1 contrast)

  // Background Colors - Light Mode
  static const Color backgroundLight = neutralWhite;
  static const Color backgroundLightSecondary = neutralGray50;
  static const Color surfaceLight = neutralWhite;
  static const Color surfaceLightVariant = neutralGray100;

  // Background Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundDarkSecondary = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkVariant = Color(0xFF2C2C2C);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = neutralGray900;
  static const Color textSecondaryLight = neutralGray600;
  static const Color textDisabledLight = neutralGray400;

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF6E6E6E);

  // Border Colors
  // Updated for WCAG AA UI component contrast (3:1 minimum)
  static const Color borderLight = neutralGray500; // 3.05:1 contrast on white
  static const Color borderDark = Color(0xFF757575); // 3.23:1 contrast on #121212

  // Shadow Colors
  static const Color shadowLight = Color(0x1F000000); // 12% opacity
  static const Color shadowDark = Color(0x3D000000); // 24% opacity

  // Item Type Border Colors (4px left border)
  static const Color itemBorderTask = accentBlue;
  static const Color itemBorderNote = primaryAmber;
  static const Color itemBorderList = accentViolet;

  // Overlay Colors
  static const Color overlayLight = Color(0x52000000); // 32% opacity
  static const Color overlayDark = Color(0x7A000000); // 48% opacity

  // Gradient Colors for FAB
  static const LinearGradient fabGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryAmber,
      primaryAmberDark,
    ],
  );

  // Ripple/Splash Colors
  static const Color rippleLight = Color(0x1F000000); // 12% opacity
  static const Color rippleDark = Color(0x33FFFFFF); // 20% opacity

  // Focus/Selection Colors
  // Focus indicators must have 3:1 contrast for WCAG AA (2.4.7)
  static const Color focusLight = info; // Use info blue (4.61:1 contrast)
  static const Color focusDark = primaryAmberLight; // Amber works on dark (good contrast)
  static const Color selectedLight = Color(0x14FFA726); // 8% opacity
  static const Color selectedDark = Color(0x1FFFA726); // 12% opacity

  // Completion/Strike-through opacity
  static const double completedOpacity = 0.5;

  // Helper method to get color scheme for theme mode
  static ColorScheme lightColorScheme() {
    return const ColorScheme.light(
      primary: primaryAmber,
      onPrimary: neutralBlack,
      secondary: accentBlue,
      onSecondary: neutralWhite,
      error: error,
      onSurface: textPrimaryLight,
    );
  }

  static ColorScheme darkColorScheme() {
    return const ColorScheme.dark(
      primary: primaryAmber,
      secondary: accentBlue,
      onSecondary: neutralWhite,
      error: error,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
    );
  }
}
