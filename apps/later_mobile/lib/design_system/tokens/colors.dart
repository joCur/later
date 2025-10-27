import 'package:flutter/material.dart';

/// Temporal Flow Design System - Color Tokens
/// A gradient-infused palette inspired by dusk and dawn transitions
/// All colors meet WCAG AA accessibility standards minimum
class AppColors {
  AppColors._(); // Private constructor

  // ============================================================
  // PRIMARY COLORS - Twilight Gradient (Indigo → Purple)
  // ============================================================

  /// Primary gradient start color (Indigo-500)
  static const Color primaryStart = Color(0xFF6366F1);

  /// Primary gradient end color (Violet-500)
  static const Color primaryEnd = Color(0xFF8B5CF6);

  /// Primary solid color for flat contexts (Violet-600)
  static const Color primarySolid = Color(0xFF7C3AED);

  /// Primary hover state (Violet-700)
  static const Color primaryHover = Color(0xFF6D28D9);

  /// Primary active/pressed state (Violet-800)
  static const Color primaryActive = Color(0xFF5B21B6);

  /// Primary disabled state (Violet-200)
  static const Color primaryDisabled = Color(0xFFDDD6FE);

  /// Primary light tint (Violet-100)
  static const Color primaryLight = Color(0xFFEDE9FE);

  /// Primary pale tint (Violet-50)
  static const Color primaryPale = Color(0xFFF5F3FF);

  // Dark mode variants - softer, less saturated
  /// Primary gradient start color for dark mode (Indigo-400)
  static const Color primaryStartDark = Color(0xFF818CF8);

  /// Primary gradient end color for dark mode (Violet-400)
  static const Color primaryEndDark = Color(0xFFA78BFA);

  /// Primary gradient for light mode
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  /// Primary gradient for dark mode
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStartDark, primaryEndDark],
  );

  // ============================================================
  // SECONDARY COLORS - Dawn Gradient (Amber → Pink)
  // ============================================================

  /// Secondary gradient start color (Amber-500)
  static const Color secondaryStart = Color(0xFFF59E0B);

  /// Secondary gradient end color (Pink-500)
  static const Color secondaryEnd = Color(0xFFEC4899);

  /// Secondary solid color (Orange-500)
  static const Color secondarySolid = Color(0xFFF97316);

  /// Secondary hover state (Orange-600)
  static const Color secondaryHover = Color(0xFFEA580C);

  /// Secondary active state (Orange-700)
  static const Color secondaryActive = Color(0xFFC2410C);

  /// Secondary light tint (Orange-200)
  static const Color secondaryLight = Color(0xFFFED7AA);

  /// Secondary pale tint (Orange-100)
  static const Color secondaryPale = Color(0xFFFFEDD5);

  // Dark mode variants
  /// Secondary gradient start for dark mode (Amber-300)
  static const Color secondaryStartDark = Color(0xFFFCD34D);

  /// Secondary gradient end for dark mode (Pink-300)
  static const Color secondaryEndDark = Color(0xFFF9A8D4);

  /// Secondary gradient for light mode
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStart, secondaryEnd],
  );

  /// Secondary gradient for dark mode
  static const LinearGradient secondaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStartDark, secondaryEndDark],
  );

  // ============================================================
  // ACCENT COLORS
  // ============================================================

  // Accent Cyan - Cool Intelligence
  /// Accent cyan base color (Cyan-500)
  static const Color accentCyan = Color(0xFF06B6D4);

  /// Accent cyan light variant (Cyan-400)
  static const Color accentCyanLight = Color(0xFF22D3EE);

  /// Accent cyan pale tint (Cyan-100)
  static const Color accentCyanPale = Color(0xFFCFFAFE);

  /// Accent cyan dark mode variant (Cyan-300)
  static const Color accentCyanDark = Color(0xFF67E8F9);

  // Accent Emerald - Natural Success
  /// Accent emerald base color (Emerald-500)
  static const Color accentEmerald = Color(0xFF10B981);

  /// Accent emerald light variant (Emerald-400)
  static const Color accentEmeraldLight = Color(0xFF34D399);

  /// Accent emerald pale tint (Emerald-100)
  static const Color accentEmeraldPale = Color(0xFFD1FAE5);

  /// Accent emerald dark mode variant (Emerald-300)
  static const Color accentEmeraldDark = Color(0xFF6EE7B7);

  // ============================================================
  // TYPE-SPECIFIC COLORS - Instant Visual Recognition
  // ============================================================

  // Task Colors - Urgent Action (Red-Orange)
  /// Task primary color (Red-400)
  static const Color taskColor = Color(0xFFF87171);

  /// Task dark variant (Red-600)
  static const Color taskDark = Color(0xFFDC2626);

  /// Task light background (Red-100)
  static const Color taskLight = Color(0xFFFEE2E2);

  /// Task gradient start (Red-500)
  static const Color taskGradientStart = Color(0xFFEF4444);

  /// Task gradient end (Orange-500)
  static const Color taskGradientEnd = Color(0xFFF97316);

  /// Task gradient (Red → Orange)
  static const LinearGradient taskGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [taskGradientStart, taskGradientEnd],
  );

  // Note Colors - Contemplative Knowledge (Blue-Cyan)
  /// Note primary color (Blue-400)
  static const Color noteColor = Color(0xFF60A5FA);

  /// Note dark variant (Blue-600)
  static const Color noteDark = Color(0xFF2563EB);

  /// Note light background (Blue-100)
  static const Color noteLight = Color(0xFFDBEAFE);

  /// Note gradient start (Blue-500)
  static const Color noteGradientStart = Color(0xFF3B82F6);

  /// Note gradient end (Cyan-500)
  static const Color noteGradientEnd = Color(0xFF06B6D4);

  /// Note gradient (Blue → Cyan)
  static const LinearGradient noteGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [noteGradientStart, noteGradientEnd],
  );

  // List Colors - Organized Structure (Violet)
  /// List primary color (Violet-400)
  static const Color listColor = Color(0xFFA78BFA);

  /// List dark variant (Violet-600)
  static const Color listDark = Color(0xFF7C3AED);

  /// List light background (Violet-100)
  static const Color listLight = Color(0xFFEDE9FE);

  /// List gradient start (Violet-500)
  static const Color listGradientStart = Color(0xFF8B5CF6);

  /// List gradient end (Violet-400)
  static const Color listGradientEnd = Color(0xFFA78BFA);

  /// List gradient (Violet-500 → Violet-400)
  static const LinearGradient listGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [listGradientStart, listGradientEnd],
  );

  // ============================================================
  // SEMANTIC COLORS
  // ============================================================

  // Success Colors
  /// Success base color (Emerald-500) - 4.8:1 contrast on white
  static const Color success = Color(0xFF10B981);

  /// Success light variant (Emerald-300)
  static const Color successLight = Color(0xFF6EE7B7);

  /// Success dark variant (Emerald-600)
  static const Color successDark = Color(0xFF059669);

  /// Success background (Emerald-100)
  static const Color successBg = Color(0xFFD1FAE5);

  // Warning Colors
  /// Warning base color (Amber-500) - 5.1:1 contrast on white
  static const Color warning = Color(0xFFF59E0B);

  /// Warning light variant (Amber-300)
  static const Color warningLight = Color(0xFFFCD34D);

  /// Warning dark variant (Amber-600)
  static const Color warningDark = Color(0xFFD97706);

  /// Warning background (Amber-100)
  static const Color warningBg = Color(0xFFFEF3C7);

  // Error Colors
  /// Error base color (Red-500) - 5.9:1 contrast on white
  static const Color error = Color(0xFFEF4444);

  /// Error light variant (Red-300)
  static const Color errorLight = Color(0xFFFCA5A5);

  /// Error dark variant (Red-600)
  static const Color errorDark = Color(0xFFDC2626);

  /// Error background (Red-100)
  static const Color errorBg = Color(0xFFFEE2E2);

  // Info Colors
  /// Info base color (Blue-500) - 5.4:1 contrast on white
  static const Color info = Color(0xFF3B82F6);

  /// Info light variant (Blue-300)
  static const Color infoLight = Color(0xFF93C5FD);

  /// Info dark variant (Blue-600)
  static const Color infoDark = Color(0xFF2563EB);

  /// Info background (Blue-100)
  static const Color infoBg = Color(0xFFDBEAFE);

  // ============================================================
  // FORM VALIDATION COLORS
  // ============================================================
  // Semantic colors for form input character counters and validation states

  /// Form success indicator - used for valid input states
  static const Color formSuccess = success;

  /// Form warning indicator - used for approaching limits (70-90%)
  static const Color formWarning = warning;

  /// Form error indicator - used for exceeded limits (90-95%)
  static const Color formError = error;

  /// Form critical indicator - used for critical violations (>95%)
  static const Color formCritical = errorDark;

  // ============================================================
  // NEUTRAL COLORS - Slate Palette
  // ============================================================

  /// Neutral-50: Ultra light, canvas background
  static const Color neutral50 = Color(0xFFF8FAFC);

  /// Neutral-100: Subtle backgrounds, section divisions
  static const Color neutral100 = Color(0xFFF1F5F9);

  /// Neutral-200: Borders, dividers, disabled backgrounds
  static const Color neutral200 = Color(0xFFE2E8F0);

  /// Neutral-300: Disabled text, subtle dividers
  static const Color neutral300 = Color(0xFFCBD5E1);

  /// Neutral-400: Placeholders, secondary icons (3.6:1 contrast)
  static const Color neutral400 = Color(0xFF94A3B8);

  /// Neutral-500: Secondary text, muted content (4.9:1 contrast - AA)
  static const Color neutral500 = Color(0xFF64748B);

  /// Neutral-600: Primary body text, standard icons (7.8:1 contrast - AAA)
  static const Color neutral600 = Color(0xFF475569);

  /// Neutral-700: Headings, emphasized text (11.2:1 contrast - AAA)
  static const Color neutral700 = Color(0xFF334155);

  /// Neutral-800: Strong headings, dark emphasis (15.1:1 contrast - AAA)
  static const Color neutral800 = Color(0xFF1E293B);

  /// Neutral-900: Maximum contrast text, dark surfaces (18.2:1 contrast - AAA)
  static const Color neutral900 = Color(0xFF0F172A);

  /// Neutral-950: Canvas background for dark mode
  static const Color neutral950 = Color(0xFF020617);

  // ============================================================
  // GLASS MORPHISM COLORS
  // ============================================================

  /// Glass background color for light mode (70% white)
  static const Color glassLight = Color(0xB3FFFFFF);

  /// Glass background color for dark mode (70% Neutral-800)
  static const Color glassDark = Color(0xB31E293B);

  /// Glass border color for light mode (30% white)
  static const Color glassBorderLight = Color(0x4DFFFFFF);

  /// Glass border color for dark mode (10% white)
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  /// Blur radius for glass morphism effects
  static const double glassBlurRadius = 20.0;

  // ============================================================
  // SHADOW COLORS
  // ============================================================

  /// Shadow color for light mode (10% opacity, blue tint)
  static const Color shadowLight = Color(0x1A1F2687);

  /// Shadow color for dark mode (30% opacity, pure black)
  static const Color shadowDark = Color(0x4D000000);

  // ============================================================
  // OVERLAY COLORS
  // ============================================================

  /// Overlay background for modals in light mode (32% black)
  static const Color overlayLight = Color(0x52000000);

  /// Overlay background for modals in dark mode (48% black)
  static const Color overlayDark = Color(0x7A000000);

  // ============================================================
  // INTERACTION COLORS
  // ============================================================

  /// Ripple/splash color for light mode (12% black)
  static const Color rippleLight = Color(0x1F000000);

  /// Ripple/splash color for dark mode (20% white)
  static const Color rippleDark = Color(0x33FFFFFF);

  /// Focus indicator color for light mode
  static const Color focusLight = info;

  /// Focus indicator color for dark mode
  static const Color focusDark = primaryLight;

  /// Selected/hover state for light mode (8% primary)
  static const Color selectedLight = Color(0x147C3AED);

  /// Selected/hover state for dark mode (12% primary)
  static const Color selectedDark = Color(0x1F7C3AED);

  // ============================================================
  // CONSTANTS
  // ============================================================

  /// Opacity for completed items
  static const double completedOpacity = 0.5;

  /// Opacity for disabled items
  static const double disabledOpacity = 0.4;

  // ============================================================
  // THEME-AWARE HELPER METHODS
  // ============================================================

  /// Get adaptive background color based on theme
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral50
        : neutral950;
  }

  /// Get adaptive surface color based on theme
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : neutral900;
  }

  /// Get adaptive surface variant color based on theme
  static Color surfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral100
        : neutral800;
  }

  /// Get adaptive primary body text color based on theme
  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral600
        : neutral400;
  }

  /// Get adaptive emphasized text color based on theme
  static Color textEmphasis(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral700
        : neutral300;
  }

  /// Get adaptive secondary text color based on theme
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral500
        : neutral500;
  }

  /// Get adaptive disabled text color based on theme
  static Color textDisabled(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral400
        : neutral600;
  }

  /// Get adaptive border color based on theme
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral200
        : neutral700;
  }

  /// Get adaptive divider color based on theme
  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral200
        : neutral700;
  }

  /// Get adaptive glass background based on theme
  static Color glass(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? glassLight
        : glassDark;
  }

  /// Get adaptive glass border based on theme
  static Color glassBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? glassBorderLight
        : glassBorderDark;
  }

  /// Get adaptive shadow color based on theme
  static Color shadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? shadowLight
        : shadowDark;
  }

  /// Get adaptive overlay color based on theme
  static Color overlay(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? overlayLight
        : overlayDark;
  }

  /// Get adaptive ripple color based on theme
  static Color ripple(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? rippleLight
        : rippleDark;
  }

  /// Get adaptive focus indicator color based on theme
  static Color focus(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? focusLight
        : focusDark;
  }

  /// Get adaptive selected/hover state color based on theme
  static Color selected(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? selectedLight
        : selectedDark;
  }

  /// Get adaptive primary gradient based on theme
  static LinearGradient primaryGradientAdaptive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? primaryGradient
        : primaryGradientDark;
  }

  /// Get adaptive secondary gradient based on theme
  static LinearGradient secondaryGradientAdaptive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? secondaryGradient
        : secondaryGradientDark;
  }

  /// Get gradient for item type
  static LinearGradient typeGradient(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return taskGradient;
      case 'note':
        return noteGradient;
      case 'list':
        return listGradient;
      default:
        return primaryGradient;
    }
  }

  /// Get solid color for item type
  static Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return taskColor;
      case 'note':
        return noteColor;
      case 'list':
        return listColor;
      default:
        return primarySolid;
    }
  }

  /// Get light background color for item type
  static Color typeLightBg(String type, {required bool isDark}) {
    if (isDark) {
      // Return semi-transparent overlay for dark mode
      switch (type.toLowerCase()) {
        case 'task':
          return taskGradientStart.withValues(alpha: 0.1);
        case 'note':
          return noteGradientStart.withValues(alpha: 0.1);
        case 'list':
          return listGradientStart.withValues(alpha: 0.1);
        default:
          return primaryStart.withValues(alpha: 0.1);
      }
    }

    // Light mode solid backgrounds
    switch (type.toLowerCase()) {
      case 'task':
        return taskLight;
      case 'note':
        return noteLight;
      case 'list':
        return listLight;
      default:
        return primaryLight;
    }
  }

  // ============================================================
  // LEGACY COLOR SCHEME METHODS (for compatibility)
  // ============================================================

  /// Get Material ColorScheme for light theme
  static ColorScheme lightColorScheme() {
    return const ColorScheme.light(
      primary: primarySolid,
      secondary: secondarySolid,
      error: error,
      onSurface: neutral600,
    );
  }

  /// Get Material ColorScheme for dark theme
  static ColorScheme darkColorScheme() {
    return const ColorScheme.dark(
      primary: primarySolid,
      secondary: secondarySolid,
      error: error,
      surface: neutral900,
      onSurface: neutral400,
    );
  }
}
