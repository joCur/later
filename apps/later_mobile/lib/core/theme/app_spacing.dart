/// Spacing system for Later app
/// Based on 8px base unit system
class AppSpacing {
  AppSpacing._();

  // Base unit (8px)
  static const double baseUnit = 8.0;

  // Spacing scale (multiples of base unit)
  static const double xxxs = baseUnit * 0.5; // 4px
  static const double xxs = baseUnit; // 8px
  static const double xs = baseUnit * 1.5; // 12px
  static const double sm = baseUnit * 2; // 16px
  static const double md = baseUnit * 3; // 24px
  static const double lg = baseUnit * 4; // 32px
  static const double xl = baseUnit * 5; // 40px
  static const double xxl = baseUnit * 6; // 48px
  static const double xxxl = baseUnit * 8; // 64px

  // Named spacing for specific use cases

  // Padding
  static const double paddingXS = xxs; // 8px
  static const double paddingSM = sm; // 16px
  static const double paddingMD = md; // 24px
  static const double paddingLG = lg; // 32px

  // Margins
  static const double marginXS = xxs; // 8px
  static const double marginSM = sm; // 16px
  static const double marginMD = md; // 24px
  static const double marginLG = lg; // 32px

  // Gap (for flex layouts)
  static const double gapXS = xxs; // 8px
  static const double gapSM = xs; // 12px
  static const double gapMD = sm; // 16px
  static const double gapLG = md; // 24px

  // Component-specific spacing

  // Screen padding (horizontal/vertical screen edges)
  static const double screenPaddingMobile = sm; // 16px
  static const double screenPaddingTablet = md; // 24px
  static const double screenPaddingDesktop = lg; // 32px

  // Card padding
  static const double cardPadding = sm; // 16px
  static const double cardMargin = xxs; // 8px

  // List item spacing
  static const double listItemSpacing = xxs; // 8px
  static const double listItemPadding = sm; // 16px

  // Button padding
  static const double buttonPaddingVerticalSmall = xxs; // 8px (32px height)
  static const double buttonPaddingVerticalMedium = xs; // 12px (40px height)
  static const double buttonPaddingVerticalLarge = sm; // 16px (48px height)
  static const double buttonPaddingHorizontal = md; // 24px

  // Input field padding
  static const double inputPaddingVertical = xs; // 12px
  static const double inputPaddingHorizontal = sm; // 16px

  // Icon spacing
  static const double iconMargin = xxs; // 8px
  static const double iconPadding = xxxs; // 4px

  // FAB positioning
  static const double fabMargin = sm; // 16px

  // Modal/Dialog spacing
  static const double modalPadding = md; // 24px
  static const double modalMargin = sm; // 16px

  // Section spacing
  static const double sectionSpacing = md; // 24px
  static const double sectionPadding = sm; // 16px

  // Border radius (related to spacing system)
  static const double radiusXS = xxxs; // 4px
  static const double radiusSM = xxs; // 8px
  static const double radiusMD = xs; // 12px
  static const double radiusLG = sm; // 16px
  static const double radiusXL = md; // 24px
  static const double radiusFull = 999; // Fully rounded

  // Component-specific border radius
  static const double cardRadius = radiusMD; // 12px
  static const double buttonRadius = radiusSM; // 8px
  static const double inputRadius = radiusSM; // 8px
  static const double fabRadius = radiusLG; // 16px (for 56x56 FAB)
  static const double modalRadius = radiusLG; // 16px
  static const double chipRadius = radiusFull; // Fully rounded

  // Elevation/Shadow offsets (used with shadow definitions)
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;

  // Touch targets (minimum interactive area)
  // WCAG 2.5.5 requires 44x44dp minimum, Material Design recommends 48x48px
  static const double minTouchTarget = 48.0; // 48x48px minimum (Material Design)
  static const double touchTargetSmall = 48.0; // 48px (increased for accessibility)
  static const double touchTargetMedium = 48.0; // 48px (meets WCAG AA)
  static const double touchTargetLarge = 56.0; // 56px (comfortable size)
  static const double touchTargetFAB = 56.0; // 56px (visual size, 64px touch)
  static const double touchTargetFABArea = 64.0; // 64px (actual touch area)

  // Item border width
  static const double itemBorderWidth = 4.0; // 4px left border for item cards
  static const double borderWidthThin = 1.0; // 1px standard borders
  static const double borderWidthMedium = 2.0; // 2px emphasized borders
  static const double borderWidthThick = 3.0; // 3px strong borders
}
