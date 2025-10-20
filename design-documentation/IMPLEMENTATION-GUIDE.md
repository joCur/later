---
title: later - Implementation Guide
description: Comprehensive guide for implementing the later design system in Flutter
last-updated: 2025-10-19
version: 1.0.0
status: approved
---

# later - Implementation Guide

## Overview

This guide provides everything developers need to implement the later design system in Flutter. It covers setup, architecture, component implementation, and best practices.

---

## Quick Start

### 1. Install Required Packages

Add these dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Design System Foundation
  google_fonts: ^6.1.0              # Inter and JetBrains Mono
  flutter_svg: ^2.0.9               # Vector icons

  # UI & Animation
  flutter_animate: ^4.5.0           # Declarative animations
  shimmer: ^3.0.0                   # Loading states
  animations: ^2.0.11               # Material motion
  flutter_staggered_animations: ^1.1.1  # List animations

  # Gestures & Interactions
  flutter_slidable: ^3.0.1          # Swipe actions
  feedback: ^3.0.0                  # Haptic feedback

  # State Management
  riverpod: ^2.4.10                 # State management
  flutter_riverpod: ^2.4.10

  # Navigation
  go_router: ^13.0.0                # Declarative routing

  # Storage
  shared_preferences: ^2.2.2        # Local preferences
  hive: ^2.2.3                      # Local database
  hive_flutter: ^1.1.0

dev_dependencies:
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
```

### 2. Project Structure

Organize your project following this structure:

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart              # Main theme configuration
│   │   ├── app_colors.dart             # Color system
│   │   ├── app_typography.dart         # Typography system
│   │   ├── app_spacing.dart            # Spacing tokens
│   │   ├── app_radius.dart             # Border radius tokens
│   │   ├── app_shadows.dart            # Shadow system
│   │   └── app_animations.dart         # Animation tokens
│   ├── widgets/
│   │   ├── item_card.dart              # Item card component
│   │   ├── glass_container.dart        # Glass morphism container
│   │   ├── gradient_button.dart        # Gradient button
│   │   └── pressable_button.dart       # Interactive button
│   ├── navigation/
│   │   ├── adaptive_navigation.dart    # Responsive navigation
│   │   └── routes.dart                 # App routing
│   └── utils/
│       ├── responsive.dart             # Responsive utilities
│       └── accessibility.dart          # Accessibility helpers
├── features/
│   ├── quick_capture/
│   │   ├── quick_capture_fab.dart      # FAB button
│   │   ├── quick_capture_modal.dart    # Modal overlay
│   │   └── quick_capture_provider.dart # State management
│   ├── inbox/
│   ├── spaces/
│   ├── search/
│   └── profile/
└── main.dart
```

---

## Theme Setup

### 1. Create Theme Files

**`lib/core/theme/app_colors.dart`**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // PRIMARY COLORS
  static const primaryStart = Color(0xFF6366F1);
  static const primaryEnd = Color(0xFF8B5CF6);
  static const primarySolid = Color(0xFF7C3AED);
  static const primaryHover = Color(0xFF6D28D9);
  static const primaryLight = Color(0xFFEDE9FE);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  // SECONDARY COLORS
  static const secondaryStart = Color(0xFFF59E0B);
  static const secondaryEnd = Color(0xFFEC4899);
  static const secondarySolid = Color(0xFFF97316);

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStart, secondaryEnd],
  );

  // TYPE-SPECIFIC COLORS
  static const taskColor = Color(0xFFF87171);
  static const taskLight = Color(0xFFFEE2E2);
  static const noteColor = Color(0xFF60A5FA);
  static const noteLight = Color(0xFFDBEAFE);
  static const listColor = Color(0xFFA78BFA);
  static const listLight = Color(0xFFEDE9FE);

  // SEMANTIC COLORS
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF6EE7B7);
  static const successBg = Color(0xFFD1FAE5);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFCD34D);
  static const warningBg = Color(0xFFFEF3C7);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFCA5A5);
  static const errorBg = Color(0xFFFEE2E2);

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFF93C5FD);
  static const infoBg = Color(0xFFDBEAFE);

  // NEUTRALS
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);
  static const neutral950 = Color(0xFF020617);

  // THEME-AWARE HELPERS
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral50
        : neutral950;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : neutral900;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral600
        : neutral400;
  }

  static Color textEmphasis(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral700
        : neutral300;
  }
}
```

**`lib/core/theme/app_typography.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 48,
      height: 1.17,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.96,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 40,
      height: 1.20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.32,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      height: 1.29,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.28,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      height: 1.33,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      height: 1.40,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 18,
      height: 1.44,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 17,
      height: 1.53,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 16,
      height: 1.50,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.42,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      height: 1.50,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.12,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      height: 1.45,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.88,
    ),
  );

  static TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    height: 1.57,
    fontWeight: FontWeight.w400,
  );

  static TextStyle codeSmall = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    height: 1.50,
    fontWeight: FontWeight.w400,
  );
}
```

**`lib/core/theme/app_spacing.dart`**

```dart
import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double base = 4.0;

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  static const double xxxxl = 96.0;

  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return paddingMD;
    if (width < 1024) return paddingXL;
    return const EdgeInsets.all(xxl);
  }
}

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
}
```

**`lib/core/theme/app_animations.dart`**

```dart
import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration instant = Duration.zero;
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);

  static const Curve easeOutExpo = Cubic(0.16, 1, 0.3, 1);
  static const Curve easeInOutQuint = Cubic(0.83, 0, 0.17, 1);
  static const Curve easeOutQuart = Cubic(0.25, 1, 0.5, 1);

  static bool get reduceMotion {
    return WidgetsBinding.instance.window.accessibilityFeatures.disableAnimations;
  }

  static Duration getDuration(Duration normal) {
    return reduceMotion ? Duration.zero : normal;
  }
}

class AppShadows {
  AppShadows._();

  static const level1 = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      offset: Offset(0, 0),
    ),
  ];

  static const level2 = [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const level3 = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];

  static const level4 = [
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 25,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 10,
      offset: Offset(0, 10),
    ),
  ];
}
```

**`lib/core/theme/app_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.light(
      primary: AppColors.primarySolid,
      secondary: AppColors.secondarySolid,
      surface: Colors.white,
      background: AppColors.neutral50,
      error: AppColors.error,
    ),

    textTheme: AppTypography.textTheme,

    scaffoldBackgroundColor: AppColors.neutral50,

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.9),
      foregroundColor: AppColors.neutral900,
      titleTextStyle: AppTypography.textTheme.titleLarge,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primarySolid,
      unselectedItemColor: AppColors.neutral400,
      type: BottomNavigationBarType.fixed,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.primarySolid, width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primarySolid,
      secondary: AppColors.secondarySolid,
      surface: AppColors.neutral900,
      background: AppColors.neutral950,
      error: AppColors.error,
    ),

    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.neutral400,
      displayColor: AppColors.neutral300,
    ),

    scaffoldBackgroundColor: AppColors.neutral950,

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.neutral900.withOpacity(0.9),
      foregroundColor: AppColors.neutral100,
      titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
        color: AppColors.neutral300,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.neutral900,
      selectedItemColor: AppColors.primarySolid,
      unselectedItemColor: AppColors.neutral400,
      type: BottomNavigationBarType.fixed,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.neutral700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.neutral700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.primarySolid, width: 2),
      ),
    ),
  );
}
```

### 2. Apply Theme in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    ProviderScope(
      child: LaterApp(),
    ),
  );
}

class LaterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'later',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respects system preference
      home: HomePage(),
    );
  }
}
```

---

## Component Implementation

### Item Card Component

**`lib/core/widgets/item_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';

enum ItemType { task, note, list }

class ItemCard extends StatelessWidget {
  final ItemType type;
  final String title;
  final String? content;
  final List<String>? tags;
  final DateTime lastModified;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const ItemCard({
    Key? key,
    required this.type,
    required this.title,
    this.content,
    this.tags,
    required this.lastModified,
    this.isCompleted = false,
    required this.onTap,
    this.onComplete,
    this.onDelete,
  }) : super(key: key);

  Color get typeColor {
    switch (type) {
      case ItemType.task:
        return AppColors.taskColor;
      case ItemType.note:
        return AppColors.noteColor;
      case ItemType.list:
        return AppColors.listColor;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case ItemType.task:
        return Icons.check_circle_outline;
      case ItemType.note:
        return Icons.description_outlined;
      case ItemType.list:
        return Icons.list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      startActionPane: type == ItemType.task
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    HapticFeedback.lightImpact();
                    onComplete?.call();
                  },
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  icon: Icons.check,
                  label: 'Complete',
                ),
              ],
            )
          : null,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: _buildGradient(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border(
              top: BorderSide(color: typeColor, width: 4),
            ),
            boxShadow: AppShadows.level1,
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, size: 20, color: typeColor),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (content != null) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  content!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (tags != null && tags!.isNotEmpty)
                    Wrap(
                      spacing: AppSpacing.xxs,
                      children: tags!
                          .map((tag) => Chip(
                                label: Text(tag, style: TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  Spacer(),
                  Text(
                    _formatTimestamp(lastModified),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Gradient _buildGradient(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return LinearGradient(
        colors: [AppColors.neutral900, AppColors.neutral900],
      );
    }

    Color endColor;
    switch (type) {
      case ItemType.task:
        endColor = AppColors.taskLight.withOpacity(0.3);
      case ItemType.note:
        endColor = AppColors.noteLight.withOpacity(0.3);
      case ItemType.list:
        endColor = AppColors.listLight.withOpacity(0.3);
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, endColor],
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
```

---

## Best Practices

### Performance

1. **Use `const` constructors** wherever possible
2. **Implement `RepaintBoundary`** for complex animations
3. **Lazy load** images and heavy widgets
4. **Dispose** controllers and streams properly
5. **Cache** expensive computations

### Accessibility

1. **Provide semantic labels** for all interactive elements
2. **Ensure minimum touch targets** (48×48px)
3. **Test with screen readers** (VoiceOver/TalkBack)
4. **Support keyboard navigation**
5. **Respect reduced motion** preferences

### Code Organization

1. **Separate concerns**: UI, logic, and data
2. **Use providers** for state management
3. **Create reusable widgets** for common patterns
4. **Document complex logic**
5. **Follow Flutter style guide**

---

## Testing Strategy

### Unit Tests

```dart
test('Item card displays correct title', () {
  final card = ItemCard(
    type: ItemType.task,
    title: 'Buy groceries',
    lastModified: DateTime.now(),
    onTap: () {},
  );

  expect(find.text('Buy groceries'), findsOneWidget);
});
```

### Widget Tests

```dart
testWidgets('Item card responds to tap', (tester) async {
  var tapped = false;

  await tester.pumpWidget(MaterialApp(
    home: ItemCard(
      type: ItemType.task,
      title: 'Test',
      lastModified: DateTime.now(),
      onTap: () => tapped = true,
    ),
  ));

  await tester.tap(find.byType(ItemCard));
  expect(tapped, true);
});
```

### Integration Tests

```dart
testWidgets('Complete user flow', (tester) async {
  // Test full user journey
});
```

---

## Deployment Checklist

### Pre-Launch

- [ ] All animations respect reduced motion
- [ ] All text meets contrast requirements
- [ ] All touch targets meet minimum size
- [ ] App works offline (graceful degradation)
- [ ] Error handling is comprehensive
- [ ] Loading states are implemented
- [ ] Dark mode fully supported
- [ ] Responsive on all screen sizes
- [ ] Accessibility audit completed
- [ ] Performance profiling done

### Platform-Specific

**iOS**
- [ ] Dynamic Type supported
- [ ] VoiceOver tested
- [ ] Safe area handled
- [ ] Haptics implemented

**Android**
- [ ] TalkBack tested
- [ ] Material Design compliance
- [ ] Back button behavior correct
- [ ] Permission handling proper

---

## Resources

### Documentation
- [Design System](./design-system/style-guide.md)
- [Component Library](./design-system/components/)
- [Accessibility Guidelines](./accessibility/guidelines.md)

### Flutter Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

### Design Tools
- Figma (component library coming soon)
- Design tokens JSON export

---

**Need Help?**

Refer to specific component documentation for detailed implementation examples:
- [Item Cards](./design-system/components/item-cards.md)
- [Quick Capture](./design-system/components/quick-capture.md)
- [Navigation](./design-system/components/navigation.md)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
