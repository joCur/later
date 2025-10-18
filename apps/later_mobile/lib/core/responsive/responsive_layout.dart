import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// A responsive layout builder that provides different widgets
/// based on the current screen size
class ResponsiveLayout extends StatelessWidget {
  /// Widget to show on mobile screens (< 768px)
  final Widget mobile;

  /// Widget to show on tablet screens (768px - 1023px)
  /// Falls back to mobile if not provided
  final Widget? tablet;

  /// Widget to show on desktop screens (>= 1024px)
  /// Falls back to tablet or mobile if not provided
  final Widget? desktop;

  /// Widget to show on large desktop screens (>= 1440px)
  /// Falls back to desktop, tablet, or mobile if not provided
  final Widget? desktopLarge;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.desktopLarge,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= Breakpoints.desktopLarge && desktopLarge != null) {
          return desktopLarge!;
        } else if (width >= Breakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (width >= Breakpoints.tablet && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A responsive builder that provides the screen size
/// Useful when you need to customize parts of a widget based on screen size
class ResponsiveBuilder extends StatelessWidget {
  /// Builder function that receives the current screen size
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Breakpoints.getScreenSize(context);
        return builder(context, screenSize);
      },
    );
  }
}

/// A widget that provides different values based on screen size
/// Useful for conditional styling
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? desktopLarge;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.desktopLarge,
  });

  T getValue(BuildContext context) {
    return Breakpoints.valueWhen<T>(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      desktopLarge: desktopLarge,
    );
  }
}

/// A widget that conditionally shows or hides content based on screen size
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
  });

  /// Show only on mobile
  const ResponsiveVisibility.mobileOnly({
    super.key,
    required this.child,
  })  : visibleOnMobile = true,
        visibleOnTablet = false,
        visibleOnDesktop = false;

  /// Show only on tablet
  const ResponsiveVisibility.tabletOnly({
    super.key,
    required this.child,
  })  : visibleOnMobile = false,
        visibleOnTablet = true,
        visibleOnDesktop = false;

  /// Show only on desktop
  const ResponsiveVisibility.desktopOnly({
    super.key,
    required this.child,
  })  : visibleOnMobile = false,
        visibleOnTablet = false,
        visibleOnDesktop = true;

  /// Show on tablet and larger
  const ResponsiveVisibility.tabletAndLarger({
    super.key,
    required this.child,
  })  : visibleOnMobile = false,
        visibleOnTablet = true,
        visibleOnDesktop = true;

  /// Show on desktop and larger
  const ResponsiveVisibility.desktopAndLarger({
    super.key,
    required this.child,
  })  : visibleOnMobile = false,
        visibleOnTablet = false,
        visibleOnDesktop = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = Breakpoints.getScreenSize(context);

    bool isVisible = false;
    switch (screenSize) {
      case ScreenSize.mobile:
        isVisible = visibleOnMobile;
        break;
      case ScreenSize.tablet:
        isVisible = visibleOnTablet;
        break;
      case ScreenSize.desktop:
      case ScreenSize.desktopLarge:
        isVisible = visibleOnDesktop;
        break;
    }

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return child;
  }
}

/// A responsive grid that automatically adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Breakpoints.valueWhen<int>(
      context: context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - (spacing * (columns + 1))) / columns,
          child: child,
        );
      }).toList(),
    );
  }
}
