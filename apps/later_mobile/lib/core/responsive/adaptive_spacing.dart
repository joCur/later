import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'breakpoints.dart';

/// Adaptive spacing utilities that adjust based on screen size
/// Follows the design system's responsive spacing guidelines
class AdaptiveSpacing {
  AdaptiveSpacing._();

  /// Get screen padding based on breakpoint
  /// Mobile: 16px, Tablet: 24px, Desktop: 32px
  static double getScreenPadding(BuildContext context) {
    return Breakpoints.valueWhen<double>(
      context: context,
      mobile: AppSpacing.screenPaddingMobile,
      tablet: AppSpacing.screenPaddingTablet,
      desktop: AppSpacing.screenPaddingDesktop,
    );
  }

  /// Get horizontal screen padding as EdgeInsets
  static EdgeInsets getScreenPaddingInsets(BuildContext context) {
    final padding = getScreenPadding(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get all-around screen padding as EdgeInsets
  static EdgeInsets getScreenPaddingAll(BuildContext context) {
    final padding = getScreenPadding(context);
    return EdgeInsets.all(padding);
  }

  /// Get responsive gap for flex layouts (Row, Column)
  /// Mobile: 12px, Tablet: 16px, Desktop: 24px
  static double getGap(BuildContext context) {
    return Breakpoints.valueWhen<double>(
      context: context,
      mobile: AppSpacing.gapSM,
      tablet: AppSpacing.gapMD,
      desktop: AppSpacing.gapLG,
    );
  }

  /// Get responsive section spacing
  /// Mobile: 16px, Tablet/Desktop: 24px
  static double getSectionSpacing(BuildContext context) {
    return Breakpoints.valueWhen<double>(
      context: context,
      mobile: AppSpacing.sm,
      tablet: AppSpacing.md,
      desktop: AppSpacing.md,
    );
  }

  /// Get responsive card margin
  /// Consistent across all breakpoints for grid layouts
  static double getCardMargin(BuildContext context) {
    return AppSpacing.cardMargin; // 8px on all screen sizes
  }

  /// Get responsive modal/dialog padding
  /// Mobile: 16px, Tablet/Desktop: 24px
  static EdgeInsets getModalPadding(BuildContext context) {
    final padding = Breakpoints.valueWhen<double>(
      context: context,
      mobile: AppSpacing.sm,
      tablet: AppSpacing.md,
      desktop: AppSpacing.md,
    );
    return EdgeInsets.all(padding);
  }

  /// Get responsive list item spacing
  /// Consistent across all breakpoints
  static double getListItemSpacing(BuildContext context) {
    return AppSpacing.listItemSpacing; // 8px
  }

  /// Get content max width constraint
  /// Prevents overly wide content on large screens
  static BoxConstraints getContentConstraints(BuildContext context) {
    final maxWidth = Breakpoints.getMaxContentWidth(context);
    return BoxConstraints(maxWidth: maxWidth);
  }

  /// Wrap a widget with responsive content constraints
  static Widget constrainContent({
    required BuildContext context,
    required Widget child,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: getContentConstraints(context),
        child: child,
      ),
    );
  }

  /// Get responsive padding for bottom navigation bar
  /// Accounts for safe area on mobile devices
  static EdgeInsets getBottomNavPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      bottom: mediaQuery.padding.bottom,
    );
  }

  /// Get responsive app bar height
  /// Standard on all platforms, but accounts for safe area
  static double getAppBarHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return kToolbarHeight + mediaQuery.padding.top;
  }

  /// Get responsive sidebar width
  /// Returns null on mobile (no sidebar), fixed width on larger screens
  static double? getSidebarWidth(BuildContext context) {
    if (Breakpoints.isMobile(context)) return null;
    return 240.0; // 240px expanded sidebar
  }

  /// Get collapsed sidebar width
  /// Used when sidebar is in collapsed state on desktop
  static double getCollapsedSidebarWidth(BuildContext context) {
    return 72.0; // 72px collapsed sidebar
  }

  /// Responsive value for number of items to show per row in a grid
  static int getGridCrossAxisCount(BuildContext context) {
    return Breakpoints.getGridColumns(context);
  }

  /// Responsive spacing for grid layouts
  static double getGridSpacing(BuildContext context) {
    return Breakpoints.valueWhen<double>(
      context: context,
      mobile: AppSpacing.xxs, // 8px
      tablet: AppSpacing.sm, // 16px
      desktop: AppSpacing.md, // 24px
    );
  }
}

/// Extension on BuildContext for convenient adaptive spacing access
extension AdaptiveSpacingExtension on BuildContext {
  double get screenPadding => AdaptiveSpacing.getScreenPadding(this);
  EdgeInsets get screenPaddingInsets => AdaptiveSpacing.getScreenPaddingInsets(this);
  EdgeInsets get screenPaddingAll => AdaptiveSpacing.getScreenPaddingAll(this);
  double get gap => AdaptiveSpacing.getGap(this);
  double get sectionSpacing => AdaptiveSpacing.getSectionSpacing(this);
  EdgeInsets get modalPadding => AdaptiveSpacing.getModalPadding(this);
  double get listItemSpacing => AdaptiveSpacing.getListItemSpacing(this);
  BoxConstraints get contentConstraints => AdaptiveSpacing.getContentConstraints(this);
  EdgeInsets get bottomNavPadding => AdaptiveSpacing.getBottomNavPadding(this);
  double get appBarHeight => AdaptiveSpacing.getAppBarHeight(this);
  double? get sidebarWidth => AdaptiveSpacing.getSidebarWidth(this);
  int get gridCrossAxisCount => AdaptiveSpacing.getGridCrossAxisCount(this);
  double get gridSpacing => AdaptiveSpacing.getGridSpacing(this);

  /// Wrap child with responsive content constraints
  Widget constrainContent(Widget child) {
    return AdaptiveSpacing.constrainContent(context: this, child: child);
  }
}
