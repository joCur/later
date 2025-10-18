import 'package:flutter/widgets.dart';

/// Responsive breakpoints for Later app
/// Following mobile-first design approach
class Breakpoints {
  Breakpoints._();

  // Breakpoint values (in logical pixels)
  static const double mobile = 0; // 0px and up (default)
  static const double tablet = 768; // 768px and up
  static const double desktop = 1024; // 1024px and up
  static const double desktopLarge = 1440; // 1440px and up (optional, for large screens)

  /// Check if the current screen width is mobile size
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < tablet;
  }

  /// Check if the current screen width is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Check if the current screen width is desktop size
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktop;
  }

  /// Check if the current screen width is large desktop size
  static bool isDesktopLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopLarge;
  }

  /// Check if the current screen width is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet;
  }

  /// Check if the current screen width is desktop or larger
  static bool isDesktopOrLarger(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktop;
  }

  /// Get the current breakpoint as an enum
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopLarge) return ScreenSize.desktopLarge;
    if (width >= desktop) return ScreenSize.desktop;
    if (width >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  /// Returns a value based on the current screen size
  /// Usage: Breakpoints.valueWhen<double>(context, mobile: 16, tablet: 24, desktop: 32)
  static T valueWhen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? desktopLarge,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.desktopLarge:
        return desktopLarge ?? desktop ?? tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  /// Returns a widget based on the current screen size
  /// Usage: Breakpoints.builder(context, mobile: MobileWidget(), desktop: DesktopWidget())
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? desktopLarge,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.desktopLarge:
        return desktopLarge ?? desktop ?? tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  /// Get number of columns for grid layouts based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktopLarge(context)) return 4;
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Get max width for content (prevents overly wide content on large screens)
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktopLarge(context)) return 1200;
    if (isDesktop(context)) return 1024;
    if (isTablet(context)) return 768;
    return double.infinity;
  }
}

/// Enum representing screen size categories
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  desktopLarge,
}

/// Extension on BuildContext for convenient breakpoint access
extension BreakpointExtension on BuildContext {
  bool get isMobile => Breakpoints.isMobile(this);
  bool get isTablet => Breakpoints.isTablet(this);
  bool get isDesktop => Breakpoints.isDesktop(this);
  bool get isDesktopLarge => Breakpoints.isDesktopLarge(this);
  bool get isTabletOrLarger => Breakpoints.isTabletOrLarger(this);
  bool get isDesktopOrLarger => Breakpoints.isDesktopOrLarger(this);
  ScreenSize get screenSize => Breakpoints.getScreenSize(this);

  /// Shorthand for valueWhen
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? desktopLarge,
  }) {
    return Breakpoints.valueWhen<T>(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      desktopLarge: desktopLarge,
    );
  }
}
