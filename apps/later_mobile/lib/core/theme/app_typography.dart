import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Temporal Flow Design System - Typography Tokens
/// Uses Inter for interface and JetBrains Mono for monospace/code
/// Based on 1.25 modular scale with optimized line heights
class AppTypography {
  AppTypography._();

  // ============================================================
  // FONT WEIGHTS
  // ============================================================

  /// Light weight (300) - Use sparingly, large text only
  static const FontWeight light = FontWeight.w300;

  /// Regular weight (400) - Default for body text
  static const FontWeight regular = FontWeight.w400;

  /// Medium weight (500) - Emphasized text and labels
  static const FontWeight medium = FontWeight.w500;

  /// Semibold weight (600) - Subheadings and important UI
  static const FontWeight semiBold = FontWeight.w600;

  /// Bold weight (700) - Headings and strong emphasis
  static const FontWeight bold = FontWeight.w700;

  /// Extrabold weight (800) - Hero text and display
  static const FontWeight extraBold = FontWeight.w800;

  // ============================================================
  // DISPLAY STYLES - Hero and large text
  // ============================================================

  /// Display Large: 48px, Extrabold - Hero headlines, splash screens
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        height: 1.17, // 56px line height
        fontWeight: extraBold,
        letterSpacing: -0.96, // -0.02em
      );

  /// Display: 40px, Bold - Major section headers, onboarding
  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 40,
        height: 1.20, // 48px line height
        fontWeight: bold,
        letterSpacing: -0.8, // -0.02em
      );

  /// Display Small: 36px, Bold - Reserved for future use
  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 36,
        height: 1.22, // 44px line height
        fontWeight: bold,
        letterSpacing: -0.72, // -0.02em
      );

  // ============================================================
  // HEADLINE STYLES - Page and section headers
  // ============================================================

  /// H1: 32px, Bold - Page titles, screen headers
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 32,
        height: 1.25, // 40px line height
        fontWeight: bold,
        letterSpacing: -0.32, // -0.01em
      );

  /// H2: 28px, Semibold - Section headers, modal titles
  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 28,
        height: 1.29, // 36px line height
        fontWeight: semiBold,
        letterSpacing: -0.28, // -0.01em
      );

  /// H3: 24px, Semibold - Subsection headers, card titles
  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 24,
        height: 1.33, // 32px line height
        fontWeight: semiBold,
        letterSpacing: 0,
      );

  // ============================================================
  // TITLE STYLES - Subheadings and prominent labels
  // ============================================================

  /// H4: 20px, Semibold - List headers, group titles
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        height: 1.40, // 28px line height
        fontWeight: semiBold,
        letterSpacing: 0,
      );

  /// H5: 18px, Medium - Small headers, emphasized labels
  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 18,
        height: 1.44, // 26px line height
        fontWeight: medium,
        letterSpacing: 0,
      );

  /// Title Small: 16px, Medium - Compact titles
  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 16,
        height: 1.50, // 24px line height
        fontWeight: medium,
        letterSpacing: 0,
      );

  // ============================================================
  // BODY STYLES - Main content text
  // ============================================================

  /// Body XL: 18px, Regular - Lead paragraphs, featured text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        height: 1.56, // 28px line height
        fontWeight: regular,
        letterSpacing: 0,
      );

  /// Body (Default): 16px, Regular - Standard UI text, descriptions
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        height: 1.50, // 24px line height
        fontWeight: regular,
        letterSpacing: 0,
      );

  /// Body Small: 14px, Regular - Secondary information, metadata
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        height: 1.43, // 20px line height
        fontWeight: regular,
        letterSpacing: 0,
      );

  // ============================================================
  // LABEL STYLES - Buttons, chips, form labels
  // ============================================================

  /// Label Large: 14px, Semibold - Form labels, section labels
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        height: 1.43, // 20px line height
        fontWeight: semiBold,
        letterSpacing: 0.42, // 0.03em for uppercase
      );

  /// Caption/Label Medium: 12px, Medium - Timestamps, counts, badges
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        height: 1.50, // 18px line height
        fontWeight: medium,
        letterSpacing: 0.12, // 0.01em
      );

  /// Overline/Label Small: 11px, Semibold - Tiny labels, status indicators
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        height: 1.45, // 16px line height
        fontWeight: semiBold,
        letterSpacing: 0.88, // 0.08em for uppercase
      );

  // ============================================================
  // MONOSPACE STYLES - Code, tags, technical labels
  // ============================================================

  /// Code: 14px, Regular - Tags, IDs, technical labels
  static TextStyle get code => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        height: 1.57, // 22px line height
        fontWeight: regular,
        letterSpacing: 0,
      );

  /// Code Small: 12px, Regular - Small technical labels
  static TextStyle get codeSmall => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        height: 1.50, // 18px line height
        fontWeight: regular,
        letterSpacing: 0,
      );

  // ============================================================
  // CUSTOM STYLES FOR LATER APP
  // ============================================================

  /// H1-H4 aliases for consistency with design docs
  static TextStyle get h1 => headlineLarge; // 32px
  static TextStyle get h2 => headlineMedium; // 28px
  static TextStyle get h3 => headlineSmall; // 24px
  static TextStyle get h4 => titleLarge; // 20px
  static TextStyle get h5 => titleMedium; // 18px

  /// Item card title: 16px, Medium
  static TextStyle get itemTitle => GoogleFonts.inter(
        fontSize: 16,
        height: 1.50,
        fontWeight: medium,
        letterSpacing: 0,
      );

  /// Item card content preview: 14px, Regular
  static TextStyle get itemContent => bodySmall;

  /// Metadata text: 12px, Medium - Timestamps, counts
  static TextStyle get metadata => labelMedium;

  /// Button text: 14px, Semibold
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        height: 1.43, // 20px line height
        fontWeight: semiBold,
        letterSpacing: 0,
      );

  /// Input field text: 16px, Regular
  static TextStyle get input => bodyMedium;

  /// Input field label: 14px, Semibold
  static TextStyle get inputLabel => labelLarge;

  /// Caption text: 12px, Medium
  static TextStyle get caption => labelMedium;

  /// Overline text: 11px, Semibold - UPPERCASE labels
  static TextStyle get overline => labelSmall;

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Add emphasis to text (increase font weight)
  static TextStyle emphasis(TextStyle base) {
    return base.copyWith(fontWeight: semiBold);
  }

  /// Apply color to text style
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  /// Convert to uppercase with appropriate letter spacing
  static TextStyle uppercase(TextStyle base) {
    // Add 0.03em to existing letter spacing for uppercase
    final currentSpacing = base.letterSpacing ?? 0;
    final fontSize = base.fontSize ?? 16;
    return base.copyWith(
      letterSpacing: currentSpacing + (fontSize * 0.03),
    );
  }

  /// Make text semibold (for emphasis)
  static TextStyle semibold(TextStyle base) {
    return base.copyWith(fontWeight: semiBold);
  }

  /// Make text bold
  static TextStyle makeBold(TextStyle base) {
    return base.copyWith(fontWeight: bold);
  }

  // ============================================================
  // RESPONSIVE SCALING HELPER
  // ============================================================

  /// Scale text size based on screen width
  /// Mobile: 95%, Tablet: 105%, Desktop: 100%, Wide: 110%
  static double getScaleFactor(double screenWidth) {
    if (screenWidth < 768) {
      return 0.95; // Mobile: slightly smaller
    } else if (screenWidth >= 1440) {
      return 1.10; // Wide: larger for viewing distance
    } else if (screenWidth >= 768 && screenWidth < 1024) {
      return 1.05; // Tablet: slightly larger
    }
    return 1.0; // Desktop: default
  }

  /// Apply responsive scaling to a text style
  static TextStyle responsive(TextStyle style, double screenWidth) {
    final scaleFactor = getScaleFactor(screenWidth);
    final fontSize = style.fontSize ?? 16;
    return style.copyWith(fontSize: fontSize * scaleFactor);
  }

  // ============================================================
  // TEXT THEME GENERATION
  // ============================================================

  /// Generate Material TextTheme with Temporal Flow typography
  static TextTheme textTheme({Color? color}) {
    return TextTheme(
      // Display styles
      displayLarge: displayLarge.copyWith(color: color),
      displayMedium: displayMedium.copyWith(color: color),
      displaySmall: displaySmall.copyWith(color: color),

      // Headline styles
      headlineLarge: headlineLarge.copyWith(color: color),
      headlineMedium: headlineMedium.copyWith(color: color),
      headlineSmall: headlineSmall.copyWith(color: color),

      // Title styles
      titleLarge: titleLarge.copyWith(color: color),
      titleMedium: titleMedium.copyWith(color: color),
      titleSmall: titleSmall.copyWith(color: color),

      // Body styles
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      bodySmall: bodySmall.copyWith(color: color),

      // Label styles
      labelLarge: labelLarge.copyWith(color: color),
      labelMedium: labelMedium.copyWith(color: color),
      labelSmall: labelSmall.copyWith(color: color),
    );
  }

  /// Generate themed TextTheme with specific colors for light/dark mode
  static TextTheme themedTextTheme({
    required Color primaryText,
    required Color headingText,
    required Color secondaryText,
  }) {
    return TextTheme(
      // Display styles - use heading color
      displayLarge: displayLarge.copyWith(color: headingText),
      displayMedium: displayMedium.copyWith(color: headingText),
      displaySmall: displaySmall.copyWith(color: headingText),

      // Headline styles - use heading color
      headlineLarge: headlineLarge.copyWith(color: headingText),
      headlineMedium: headlineMedium.copyWith(color: headingText),
      headlineSmall: headlineSmall.copyWith(color: headingText),

      // Title styles - use heading color
      titleLarge: titleLarge.copyWith(color: headingText),
      titleMedium: titleMedium.copyWith(color: headingText),
      titleSmall: titleSmall.copyWith(color: primaryText),

      // Body styles - use primary text color
      bodyLarge: bodyLarge.copyWith(color: primaryText),
      bodyMedium: bodyMedium.copyWith(color: primaryText),
      bodySmall: bodySmall.copyWith(color: primaryText),

      // Label styles - use secondary text color
      labelLarge: labelLarge.copyWith(color: secondaryText),
      labelMedium: labelMedium.copyWith(color: secondaryText),
      labelSmall: labelSmall.copyWith(color: secondaryText),
    );
  }

  // ============================================================
  // BACKWARD COMPATIBILITY ALIASES
  // ============================================================

  /// Font family constant for backward compatibility
  /// Returns 'Inter' as the primary font family
  static const String fontFamily = 'Inter';
}
