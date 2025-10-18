---
title: Flutter Platform Adaptations
description: Flutter-specific implementation guidance for Later app design system
version: 1.0.0
last-updated: 2025-10-18
status: approved
related-files:
  - ../style-guide.md
  - ./ios.md
  - ./android.md
  - ./web.md
---

# Flutter Platform Adaptations

## Overview

This guide provides Flutter-specific implementation patterns for the Later design system, enabling consistent cross-platform experiences while respecting platform conventions.

## Design System Approach

### Material Design 3 vs Custom

**Philosophy**: Custom design built on Material 3 foundation

**Approach**:
- Use Material 3 widgets as base (theming, gestures, accessibility)
- Override visual styling to match Later's design system
- Leverage Material's state management and interactions
- Platform-adaptive behavior where needed (iOS vs Android)

### Theme Configuration

**ThemeData Setup**:
```dart
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      primaryContainer: AppColors.lightPrimaryLight,
      secondary: AppColors.lightSecondary,
      secondaryContainer: AppColors.lightSecondaryLight,
      error: AppColors.lightError,
      surface: Colors.white,
      background: AppColors.neutral50,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.neutral900,
      onBackground: AppColors.neutral900,
    ),

    // Typography
    textTheme: AppTypography.textTheme,

    // Component Themes
    elevatedButtonTheme: _elevatedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cardTheme,
    appBarTheme: _appBarTheme,

    // Spacing & Sizing
    scaffoldBackgroundColor: AppColors.neutral50,
    dividerColor: AppColors.neutral200,

    // Accessibility
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.darkPrimaryLight,
      secondary: AppColors.darkSecondary,
      secondaryContainer: AppColors.darkSecondaryLight,
      error: AppColors.darkError,
      surface: AppColors.darkNeutral100,
      background: AppColors.darkNeutral50,
      onPrimary: AppColors.darkNeutral900,
      onSecondary: AppColors.darkNeutral900,
      onSurface: AppColors.darkNeutral900,
      onBackground: AppColors.darkNeutral900,
    ),

    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.darkNeutral50,
    dividerColor: AppColors.darkNeutral200,
  );
}
```

## Responsive Layout

### Breakpoint System

**Implementation**:
```dart
// lib/core/responsive/breakpoints.dart

enum DeviceType { mobile, tablet, desktop, wide }

class Breakpoints {
  static const double mobile = 320;
  static const double mobileMax = 767;
  static const double tablet = 768;
  static const double tabletMax = 1023;
  static const double desktop = 1024;
  static const double desktopMax = 1439;
  static const double wide = 1440;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= wide) return DeviceType.wide;
    if (width >= desktop) return DeviceType.desktop;
    if (width >= tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.wide;
  }
}
```

### Responsive Builder Widget

**Usage**:
```dart
// lib/widgets/responsive_builder.dart

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? wide;

  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Breakpoints.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.wide:
        return wide ?? desktop ?? tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

// Usage example:
ResponsiveBuilder(
  mobile: ItemListView(columns: 1),
  tablet: ItemListView(columns: 2),
  desktop: ItemListView(columns: 3),
)
```

### Adaptive Spacing

**Implementation**:
```dart
// lib/core/responsive/adaptive_spacing.dart

class AdaptiveSpacing {
  static double pageMargin(BuildContext context) {
    final deviceType = Breakpoints.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 32.0;
      case DeviceType.desktop:
      case DeviceType.wide:
        return 48.0;
    }
  }

  static double cardPadding(BuildContext context) {
    return Breakpoints.isMobile(context) ? 12.0 : 16.0;
  }

  static double gridGutter(BuildContext context) {
    final deviceType = Breakpoints.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 20.0;
      case DeviceType.desktop:
      case DeviceType.wide:
        return 24.0;
    }
  }
}
```

## Typography Implementation

### Text Styles

**Setup**:
```dart
// lib/core/theme/typography.dart

class AppTypography {
  static const String fontFamily = 'Inter';

  static TextTheme textTheme = TextTheme(
    // Headings
    displayLarge: h1,
    displayMedium: h2,
    displaySmall: h3,
    headlineMedium: h4,
    headlineSmall: h5,

    // Body
    bodyLarge: bodyLarge,
    bodyMedium: body,
    bodySmall: bodySmall,

    // Labels
    labelLarge: label,
    labelMedium: caption,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 32,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01 * 24,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01 * 20,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.03 * 12,
  );

  static const TextStyle code = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
  );
}

// Usage:
Text('Hello', style: AppTypography.h1)
// or
Text('Hello', style: Theme.of(context).textTheme.displayLarge)
```

### Responsive Typography

**Mobile Adjustments**:
```dart
// lib/core/theme/responsive_typography.dart

class ResponsiveTypography {
  static TextStyle h1(BuildContext context) {
    return Breakpoints.isMobile(context)
      ? AppTypography.h1.copyWith(fontSize: 28, height: 36 / 28)
      : AppTypography.h1;
  }

  static TextStyle h2(BuildContext context) {
    return Breakpoints.isMobile(context)
      ? AppTypography.h2.copyWith(fontSize: 22, height: 30 / 22)
      : AppTypography.h2;
  }

  // ... similar for other text styles
}
```

## Animation System

### Duration & Easing

**Constants**:
```dart
// lib/core/theme/animations.dart

class AppAnimations {
  // Durations
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 400);
  static const Duration extended = Duration(milliseconds: 600);

  // Easing Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeIn = Curves.easeIn;

  // Custom curves matching design specs
  static const Curve customEaseOut = Cubic(0.0, 0, 0.2, 1);
  static const Curve customEaseInOut = Cubic(0.4, 0, 0.6, 1);
  static const Curve customEaseIn = Cubic(0.4, 0, 1, 1);

  // Spring animation
  static SpringDescription spring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 20,
  );
}

// Usage:
AnimatedContainer(
  duration: AppAnimations.medium,
  curve: AppAnimations.easeOut,
  // ...
)
```

### Common Animation Patterns

**Fade In/Out**:
```dart
class FadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeInWidget({
    required this.child,
    this.duration = AppAnimations.short,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: AppAnimations.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
}
```

**Slide Up (Bottom Sheet)**:
```dart
class SlideUpRoute extends PageRouteBuilder {
  final Widget page;

  SlideUpRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: AppAnimations.easeOut,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      );
}
```

### Reduced Motion Support

**Implementation**:
```dart
// lib/core/accessibility/reduced_motion.dart

class ReducedMotion {
  static bool isEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  static Duration duration(
    BuildContext context,
    Duration normalDuration,
  ) {
    return isEnabled(context)
      ? const Duration(milliseconds: 1)
      : normalDuration;
  }

  static Widget adaptive(
    BuildContext context, {
    required Widget animated,
    required Widget reduced,
  }) {
    return isEnabled(context) ? reduced : animated;
  }
}

// Usage:
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: ReducedMotion.duration(context, AppAnimations.short),
  child: widget,
)
```

## Platform-Specific Behavior

### iOS vs Android Detection

**Helper**:
```dart
// lib/core/platform/platform_helper.dart

import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformHelper {
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (
    Platform.isWindows || Platform.isMacOS || Platform.isLinux
  );
  static bool get isMobile => isIOS || isAndroid;
}
```

### Platform-Adaptive Widgets

**Adaptive Bottom Sheet**:
```dart
// lib/widgets/adaptive_bottom_sheet.dart

class AdaptiveBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => child,
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        builder: (context) => child,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
      );
    }
  }
}
```

**Adaptive Navigation**:
```dart
// Use NavigationRail (desktop) vs BottomNavigationBar (mobile)

class AdaptiveNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isDesktop(context)) {
      return NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((dest) =>
          NavigationRailDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: Text(dest.label),
          ),
        ).toList(),
      );
    } else {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      );
    }
  }
}
```

## Widget Structure Recommendations

### Composition Over Inheritance

**Preferred Pattern**:
```dart
// Good: Composition
class ItemCard extends StatelessWidget {
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ItemHeader(item: item),
            ItemContent(item: item),
            ItemFooter(item: item),
          ],
        ),
      ),
    );
  }
}

// Avoid: Deep inheritance
class ItemCard extends BaseCard {
  // Too many inheritance levels
}
```

### State Management

**Provider Pattern** (Recommended):
```dart
// lib/providers/items_provider.dart

class ItemsProvider extends ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items => _items;

  Future<void> addItem(Item item) async {
    _items.add(item);
    notifyListeners();
    await _saveToLocal();
  }

  Future<void> _saveToLocal() async {
    // Offline-first: save locally first
  }
}

// Usage in widget:
Consumer<ItemsProvider>(
  builder: (context, itemsProvider, child) {
    return ListView.builder(
      itemCount: itemsProvider.items.length,
      itemBuilder: (context, index) {
        return ItemCard(item: itemsProvider.items[index]);
      },
    );
  },
)
```

## Performance Optimization

### List Virtualization

**Use ListView.builder**:
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)

// For grid layouts:
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: Breakpoints.isMobile(context) ? 1 : 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)
```

### Const Constructors

**Use const wherever possible**:
```dart
// Good
const SizedBox(height: 16)
const Divider()
const Icon(Icons.add)

// Even better: extract to constants
class Spacing {
  static const verticalSmall = SizedBox(height: 8);
  static const verticalMedium = SizedBox(height: 16);
  static const verticalLarge = SizedBox(height: 24);
}
```

### Image Caching

**Cached Network Images**:
```dart
// Use cached_network_image package
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: AppColors.neutral100,
    highlightColor: AppColors.neutral200,
    child: Container(
      width: 120,
      height: 80,
      color: Colors.white,
    ),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

## Offline-First Implementation

### Local Database

**Hive or Drift** (Recommended):
```dart
// lib/data/local/local_database.dart

import 'package:hive/hive.dart';

class LocalDatabase {
  static const String itemsBox = 'items';

  Future<void> saveItem(Item item) async {
    final box = await Hive.openBox<Item>(itemsBox);
    await box.put(item.id, item);
  }

  Future<List<Item>> getAllItems() async {
    final box = await Hive.openBox<Item>(itemsBox);
    return box.values.toList();
  }

  Future<void> deleteItem(String id) async {
    final box = await Hive.openBox<Item>(itemsBox);
    await box.delete(id);
  }
}
```

### Sync Queue

**Background Sync**:
```dart
// lib/services/sync_service.dart

class SyncService {
  final LocalDatabase _localDb;
  final ApiService _api;

  Future<void> syncItems() async {
    // Get unsynced items from local DB
    final unsyncedItems = await _localDb.getUnsyncedItems();

    for (final item in unsyncedItems) {
      try {
        await _api.syncItem(item);
        await _localDb.markAsSynced(item.id);
      } catch (e) {
        // Queue for retry
        await _localDb.addToSyncQueue(item.id);
      }
    }
  }
}
```

## Accessibility in Flutter

### Semantics

**Screen Reader Support**:
```dart
Semantics(
  label: 'Task: Buy groceries',
  hint: 'Double tap to open',
  button: true,
  child: ItemCard(item: item),
)

// For complex widgets:
MergeSemantics(
  child: Row(
    children: [
      Checkbox(value: item.isComplete),
      Text(item.title),
    ],
  ),
)
```

### Focus Management

**FocusNode**:
```dart
class QuickCaptureModal extends StatefulWidget {
  @override
  _QuickCaptureModalState createState() => _QuickCaptureModalState();
}

class _QuickCaptureModalState extends State<QuickCaptureModal> {
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus input when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _inputFocus,
      // ...
    );
  }
}
```

## Testing Recommendations

### Widget Tests

**Component Testing**:
```dart
testWidgets('ItemCard displays title', (WidgetTester tester) async {
  final item = Item(title: 'Test Task', type: ItemType.task);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ItemCard(item: item),
      ),
    ),
  );

  expect(find.text('Test Task'), findsOneWidget);
  expect(find.byType(Checkbox), findsOneWidget);
});
```

### Golden Tests

**Visual Regression**:
```dart
testWidgets('ItemCard golden test', (WidgetTester tester) async {
  await tester.pumpWidget(/* ... */);

  await expectLater(
    find.byType(ItemCard),
    matchesGoldenFile('goldens/item_card.png'),
  );
});
```

## Related Documentation

- [Style Guide](../style-guide.md) - Design system foundation
- [iOS Adaptations](./ios.md) - iOS-specific patterns
- [Android Adaptations](./android.md) - Android-specific patterns
- [Web Adaptations](./web.md) - Web-specific considerations

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved
