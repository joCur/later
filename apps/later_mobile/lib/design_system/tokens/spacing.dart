import 'package:flutter/material.dart';

/// Temporal Flow Design System - Spacing Tokens
/// Progressive spacing system based on 4px base unit
/// Creates proportional harmony and consistent visual rhythm
class AppSpacing {
  AppSpacing._();

  // ============================================================
  // BASE UNIT SYSTEM
  // ============================================================

  /// Base unit (4px) - All spacing is a multiple of this
  static const double base = 4.0;

  // ============================================================
  // SPACING SCALE
  // ============================================================

  /// XXS: 4px (1×) - Micro spacing, icon-text gaps
  static const double xxs = 4.0;

  /// XS: 8px (2×) - Internal padding, tight groupings
  static const double xs = 8.0;

  /// SM: 12px (3×) - Small spacing, comfortable groupings
  static const double sm = 12.0;

  /// MD: 16px (4×) - Standard spacing, default margins (DEFAULT)
  static const double md = 16.0;

  /// LG: 24px (6×) - Section spacing, card padding
  static const double lg = 24.0;

  /// XL: 32px (8×) - Large spacing, major separations
  static const double xl = 32.0;

  /// 2XL: 48px (12×) - Extra large spacing, screen padding
  static const double xxl = 48.0;

  /// 3XL: 64px (16×) - Huge spacing, hero sections
  static const double xxxl = 64.0;

  /// 4XL: 96px (24×) - Maximum spacing, full-bleed sections
  static const double xxxxl = 96.0;

  // ============================================================
  // SEMANTIC ALIASES
  // ============================================================

  /// Tiny spacing alias for xxs
  static const double tiny = xxs;

  /// Small spacing alias for xs
  static const double small = xs;

  /// Medium spacing alias for md
  static const double medium = md;

  /// Large spacing alias for lg
  static const double large = lg;

  /// Huge spacing alias for xxl
  static const double huge = xxl;

  // ============================================================
  // COMMON PADDING PRESETS
  // ============================================================

  /// Padding preset: all sides XXS (4px)
  static const EdgeInsets paddingXXS = EdgeInsets.all(xxs);

  /// Padding preset: all sides XS (8px)
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);

  /// Padding preset: all sides SM (12px)
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);

  /// Padding preset: all sides MD (16px) - DEFAULT
  static const EdgeInsets paddingMD = EdgeInsets.all(md);

  /// Padding preset: all sides LG (24px)
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  /// Padding preset: all sides XL (32px)
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  /// Padding preset: all sides XXL (48px)
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  /// Padding preset: all sides XXXL (64px)
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);

  // ============================================================
  // HORIZONTAL PADDING PRESETS
  // ============================================================

  /// Horizontal padding preset: XS (8px)
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);

  /// Horizontal padding preset: SM (12px)
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal padding preset: MD (16px)
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal padding preset: LG (24px)
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  /// Horizontal padding preset: XL (32px)
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  /// Horizontal padding preset: XXL (48px)
  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(horizontal: xxl);

  // ============================================================
  // VERTICAL PADDING PRESETS
  // ============================================================

  /// Vertical padding preset: XS (8px)
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);

  /// Vertical padding preset: SM (12px)
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);

  /// Vertical padding preset: MD (16px)
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);

  /// Vertical padding preset: LG (24px)
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  /// Vertical padding preset: XL (32px)
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  /// Vertical padding preset: XXL (48px)
  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: xxl);

  // ============================================================
  // COMPONENT-SPECIFIC SPACING
  // ============================================================

  // Card Spacing
  /// Card padding on mobile (20px - Mobile-first bold design)
  static const double cardPaddingMobile = 20.0;

  /// Card padding on tablet/desktop (24px)
  static const double cardPaddingDesktop = lg;

  /// Spacing between cards (16px - Mobile-first bold design)
  static const double cardSpacing = md;

  /// Border radius for cards (20px - Pill shape for mobile-first bold design)
  static const double cardRadius = 20.0;

  /// Card border width (2px - Subtle gradient border for mobile-first design)
  static const double cardBorderWidth = 2.0;

  // List Item Spacing
  /// Compact list item spacing (8px)
  static const double listItemSpacingCompact = xs;

  /// Default list item spacing (12px)
  static const double listItemSpacing = sm;

  /// Comfortable list item spacing (16px)
  static const double listItemSpacingComfortable = md;

  /// Internal list item padding (16px)
  static const double listItemPadding = md;

  // Button Spacing
  /// Small button vertical padding (8px) - 32-36px height
  static const double buttonPaddingVerticalSmall = xs;

  /// Medium button vertical padding (12px) - 40-44px height
  static const double buttonPaddingVerticalMedium = sm;

  /// Large button vertical padding (16px) - 48-52px height
  static const double buttonPaddingVerticalLarge = md;

  /// Small button horizontal padding (16px)
  static const double buttonPaddingHorizontalSmall = md;

  /// Medium button horizontal padding (24px) - DEFAULT
  static const double buttonPaddingHorizontalMedium = lg;

  /// Large button horizontal padding (32px)
  static const double buttonPaddingHorizontalLarge = xl;

  /// Spacing between buttons horizontally (12px)
  static const double buttonSpacingHorizontal = sm;

  /// Spacing between buttons vertically (8px)
  static const double buttonSpacingVertical = xs;

  /// Button border radius (10px for Temporal Flow)
  static const double buttonRadius = 10.0;

  // Input Field Spacing
  /// Input field vertical padding (12px)
  static const double inputPaddingVertical = sm;

  /// Input field horizontal padding (16px)
  static const double inputPaddingHorizontal = md;

  /// Label to input spacing (8px)
  static const double inputLabelSpacing = xs;

  /// Helper text spacing (4px)
  static const double inputHelperSpacing = xxs;

  /// Spacing between form fields (16px default, 24px comfortable)
  static const double formFieldSpacing = md;

  /// Spacing between form sections (32px)
  static const double formSectionSpacing = xl;

  /// Input border radius (10px for Temporal Flow)
  static const double inputRadius = 10.0;

  // FAB Spacing
  /// FAB margin from screen edges (16px for Temporal Flow)
  static const double fabMargin = md;

  /// FAB size (56×56px - Android standard circular for mobile-first design)
  static const double fabSize = 56.0;

  /// FAB border radius (28px - Perfect circle for mobile-first design)
  static const double fabRadius = 28.0;

  /// FAB touch target size (56px, same as visual)
  static const double fabTouchTarget = 56.0;

  // Modal/Dialog Spacing
  /// Modal internal padding (24px)
  static const double modalPadding = lg;

  /// Modal margin from screen edges (16px)
  static const double modalMargin = md;

  /// Modal border radius (16px)
  static const double modalRadius = md;

  /// Quick capture modal max width (560px)
  static const double modalMaxWidth = 560.0;

  // Screen Spacing
  /// Screen margin from edges (16px - Mobile-first bold design)
  static const double screenMargin = md;

  /// Screen padding on mobile (16px)
  static const double screenPaddingMobile = md;

  /// Screen padding on tablet (32px)
  static const double screenPaddingTablet = xl;

  /// Screen padding on desktop (48px)
  static const double screenPaddingDesktop = xxl;

  /// Section spacing on mobile (24px)
  static const double sectionSpacingMobile = lg;

  /// Section spacing on tablet/desktop (32px)
  static const double sectionSpacingDesktop = xl;

  /// Major section spacing (48px)
  static const double sectionSpacingMajor = xxl;

  // Icon Spacing
  /// Icon margin (8px)
  static const double iconMargin = xs;

  /// Icon padding (4px)
  static const double iconPadding = xxs;

  /// Icon-text gap (4px for tight, 8px for comfortable)
  static const double iconTextGap = xxs;

  /// Icon-text gap comfortable (8px)
  static const double iconTextGapComfortable = xs;

  // ============================================================
  // BORDER RADIUS SYSTEM
  // ============================================================

  /// Border radius XS: 4px - Subtle rounding
  static const double radiusXS = xxs;

  /// Border radius SM: 8px - Small rounding, inputs
  static const double radiusSM = xs;

  /// Border radius MD: 12px - Medium rounding, cards
  static const double radiusMD = sm;

  /// Border radius LG: 16px - Large rounding, modals, FAB
  static const double radiusLG = md;

  /// Border radius XL: 24px - Extra large rounding
  static const double radiusXL = lg;

  /// Border radius full: 999px - Fully rounded, pills
  static const double radiusFull = 999.0;

  // ============================================================
  // BORDER WIDTH SYSTEM
  // ============================================================

  /// Border width thin: 1px - Standard borders, dividers
  static const double borderWidthThin = 1.0;

  /// Border width medium: 2px - Emphasized borders, focus states
  static const double borderWidthMedium = 2.0;

  /// Border width thick: 3px - Strong borders
  static const double borderWidthThick = 3.0;

  /// Border width accent: 2px - Type-specific top border for items
  static const double borderWidthAccent = 2.0;

  // ============================================================
  // TOUCH TARGET SIZES (WCAG AA Compliance)
  // ============================================================

  /// Minimum touch target size (48×48px) - WCAG 2.5.5 Level AA
  static const double minTouchTarget = 48.0;

  /// Small touch target (48px) - Minimum for accessibility
  static const double touchTargetSmall = 48.0;

  /// Medium touch target (48px) - Standard comfortable size
  static const double touchTargetMedium = 48.0;

  /// Large touch target (56px) - Extra comfortable
  static const double touchTargetLarge = 56.0;

  // ============================================================
  // SHADOW & ELEVATION SYSTEM
  // ============================================================

  /// Elevation 1: 1px offset - Subtle elevation
  static const double elevation1 = 1.0;

  /// Elevation 2: 2px offset - Soft shadows
  static const double elevation2 = 2.0;

  /// Elevation 3: 3px offset - Default cards
  static const double elevation3 = 3.0;

  /// Elevation 4: 4px offset - Elevated cards
  static const double elevation4 = 4.0;

  /// Elevation 6: 6px offset - Floating elements
  static const double elevation6 = 6.0;

  /// Elevation 8: 8px offset - Modals, overlays
  static const double elevation8 = 8.0;

  /// Elevation 12: 12px offset - High elevation
  static const double elevation12 = 12.0;

  /// Elevation 16: 16px offset - Maximum elevation
  static const double elevation16 = 16.0;

  /// Blur radius for soft shadows (4-16px based on elevation)
  static const double shadowBlurRadius = 4.0;

  /// Blur radius for glass morphism effects (20px)
  static const double glassBlurRadius = 20.0;

  // ============================================================
  // RESPONSIVE SPACING HELPERS
  // ============================================================

  /// Get responsive screen padding based on screen width
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return paddingMD; // 16px
    if (width < 1024) return paddingXL; // 32px
    return paddingXXL; // 48px
  }

  /// Get responsive card padding based on screen width
  static EdgeInsets cardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return paddingMD; // 16px
    return paddingLG; // 24px
  }

  /// Get responsive section spacing based on screen width
  static double sectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return lg; // 24px
    if (width < 1024) return xl; // 32px
    return xxl; // 48px
  }

  /// Get responsive horizontal padding based on screen width
  static EdgeInsets responsiveHorizontal(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return horizontalMD;
    if (width < 1024) return horizontalXL;
    return horizontalXXL;
  }

  /// Get responsive vertical padding based on screen width
  static EdgeInsets responsiveVertical(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return verticalMD;
    if (width < 1024) return verticalXL;
    return verticalXXL;
  }
}

// ============================================================
// CONTENT WIDTH CONSTRAINTS
// ============================================================

/// Content width constraints for optimal reading and layout
class ContentWidth {
  ContentWidth._();

  /// Optimal width for long-form reading (680px)
  /// 50-75 characters per line
  static const double reading = 680.0;

  /// Comfortable width for forms (480px)
  /// Single-column forms
  static const double form = 480.0;

  /// Standard modal container width (560px)
  /// Dialogs, popups, quick capture
  static const double modal = 560.0;

  /// Full content area max width (1200px)
  /// Default max width for main content
  static const double content = 1200.0;

  /// Maximum application width (1440px)
  /// Wide screens, edge-to-edge on smaller
  static const double wide = 1440.0;
}

// ============================================================
// RESPONSIVE GRID SYSTEM
// ============================================================

/// Grid system for responsive layouts
class ResponsiveGrid {
  ResponsiveGrid._();

  /// Get number of columns based on screen width
  static int getColumns(double width) {
    if (width < 768) return 4; // Mobile
    if (width < 1024) return 8; // Tablet
    return 12; // Desktop
  }

  /// Get gutter size based on screen width
  static double getGutter(double width) {
    if (width < 768) return AppSpacing.md; // 16px
    if (width < 1440) return AppSpacing.lg; // 24px
    return AppSpacing.xl; // 32px
  }

  /// Get margin size based on screen width
  static double getMargin(double width) {
    if (width < 768) return AppSpacing.md; // 16px
    if (width < 1024) return AppSpacing.xl; // 32px
    if (width < 1440) return AppSpacing.xxl; // 48px
    return AppSpacing.xxxl; // 64px
  }

  /// Get max content width based on screen width
  static double getMaxWidth(double width) {
    if (width < 1024) return width - (getMargin(width) * 2);
    if (width < 1440) return ContentWidth.content; // 1200px
    return ContentWidth.wide; // 1440px
  }

  /// Get responsive padding for the entire screen
  static EdgeInsets getScreenPadding(double width) {
    return EdgeInsets.all(getMargin(width));
  }
}
