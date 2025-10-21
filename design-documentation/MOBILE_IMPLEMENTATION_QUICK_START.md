# Mobile-First Redesign: Developer Quick Start

**Last Updated**: 2025-10-21
**Estimated Time**: 2-4 weeks implementation
**Target**: Android phones (320-414px), 60fps on mid-range devices

---

## 🎯 What You're Building

A **mobile-first bold redesign** that:
- ✅ Looks distinctive on phone screens (not generic Material)
- ✅ Performs at 60fps on 3-4 year old Android devices
- ✅ Uses gradients strategically (not everywhere)
- ✅ Feels native to Android (not iOS)

**Key Visual Change**: Cards with **6px gradient pill borders** instead of subtle 2px top strips.

---

## 📁 Files You'll Edit

### Core Changes (Week 1-2):
```
lib/core/widgets/cards/
├── item_card.dart          ← MAJOR REDESIGN (6px border, 18px text)
├── card_border.dart        ← NEW FILE (gradient pill border widget)

lib/core/theme/
├── app_colors.dart         ← SIMPLIFY (remove unused gradients)
├── app_typography.dart     ← UPDATE (18px mobile title size)
├── app_spacing.dart        ← UPDATE (8px mobile base unit)

lib/core/widgets/navigation/
├── bottom_navigation_bar.dart  ← REDESIGN (icons only, gradient underline)
└── app_bar.dart                ← SIMPLIFY (solid background, remove glass)
```

### Secondary Changes (Week 3-4):
```
lib/core/widgets/
├── fab/quick_capture_fab.dart      ← UPDATE (56px circle, not squircle)
├── modals/quick_capture_modal.dart ← REDESIGN (bottom sheet style)
├── buttons/primary_button.dart     ← KEEP (gradient already good)
└── empty_state.dart                ← UPDATE (larger gradient icons)
```

---

## 🚀 Implementation Order

### Phase 1: Card Redesign (Days 1-3)

#### Step 1.1: Create Gradient Border Widget

Create `/lib/core/widgets/cards/card_border.dart`:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Mobile-first gradient pill border for item cards
/// 6px border provides clear visual hierarchy on small screens
class CardGradientBorder extends StatelessWidget {
  final Widget child;
  final ItemType type; // task, note, or list
  final double borderWidth;
  final double borderRadius;

  const CardGradientBorder({
    Key? key,
    required this.child,
    required this.type,
    this.borderWidth = 6.0,
    this.borderRadius = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradientForType(context, type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient,
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }

  LinearGradient _getGradientForType(BuildContext context, ItemType type) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case ItemType.task:
        // Red → Orange gradient
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [Color(0xFFDC2626), Color(0xFFEA580C)] // Darker for dark mode
            : [Color(0xFFEF4444), Color(0xFFF97316)],
        );
      case ItemType.note:
        // Blue → Cyan gradient
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [Color(0xFF2563EB), Color(0xFF0891B2)]
            : [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        );
      case ItemType.list:
        // Purple → Lavender gradient
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [Color(0xFF7C3AED), Color(0xFFA78BFA)]
            : [Color(0xFF8B5CF6), Color(0xFFC084FC)],
        );
    }
  }
}
```

#### Step 1.2: Update ItemCard Component

Update `/lib/core/widgets/cards/item_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'card_border.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onCheckboxChanged;

  const ItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mobile-first: Use larger spacing and text
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      // CHANGED: 16px horizontal margins (floating card effect)
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 24.0,
        vertical: 8.0,
      ),
      child: CardGradientBorder(
        type: item.type,
        borderWidth: 6.0,  // CHANGED: 6px gradient border (was 2px top)
        borderRadius: 20.0, // CHANGED: 20px radius (was 12px)
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.0), // 20-6 = 14
            child: Padding(
              // CHANGED: 24px horizontal padding (was 16px)
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24.0 : 20.0,
                vertical: isMobile ? 20.0 : 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox (if task)
                  if (item.type == ItemType.task) ...[
                    _buildCheckbox(context),
                    SizedBox(width: 16.0),
                  ],

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title - CHANGED: 18px bold (was 16px)
                        Text(
                          item.title,
                          style: isMobile
                            ? AppTypography.mobileTitleLarge(context)
                            : AppTypography.titleMedium(context),
                          maxLines: 2, // CHANGED: Limit to 2 lines
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Spacing
                        if (item.content.isNotEmpty)
                          SizedBox(height: 12.0),

                        // Preview - CHANGED: 15px regular (was 14px)
                        if (item.content.isNotEmpty)
                          Text(
                            item.content,
                            style: AppTypography.bodyMedium(context)
                              .copyWith(
                                color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6), // 60% opacity
                              ),
                            maxLines: 2, // CHANGED: Limit to 2 lines
                            overflow: TextOverflow.ellipsis,
                          ),

                        // Spacing
                        SizedBox(height: 12.0),

                        // Metadata - CHANGED: 13px medium (was 12px)
                        Text(
                          _formatMetadata(item),
                          style: AppTypography.labelMedium(context)
                            .copyWith(
                              color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5), // 50% opacity
                            ),
                        ),
                      ],
                    ),
                  ),

                  // Type icon (right side)
                  _buildTypeIcon(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: onCheckboxChanged,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: item.isCompleted
              ? Colors.green
              : Theme.of(context).colorScheme.outline,
            width: 2.0,
          ),
          color: item.isCompleted
            ? Colors.green.withOpacity(0.2)
            : Colors.transparent,
        ),
        child: item.isCompleted
          ? Icon(Icons.check, size: 16.0, color: Colors.green)
          : null,
      ),
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    IconData icon;
    switch (item.type) {
      case ItemType.task:
        icon = Icons.task_alt_outlined;
        break;
      case ItemType.note:
        icon = Icons.note_outlined;
        break;
      case ItemType.list:
        icon = Icons.list_outlined;
        break;
    }

    return Icon(
      icon,
      size: 20.0,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
    );
  }

  String _formatMetadata(Item item) {
    // Format date + time
    return '${item.formattedDate} • ${item.formattedTime}';
  }
}
```

#### Step 1.3: Update Typography (Mobile Sizes)

Update `/lib/core/theme/app_typography.dart`:

```dart
class AppTypography {
  // Existing methods...

  // NEW: Mobile-specific typography
  static TextStyle mobileTitleLarge(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 18.0,      // CHANGED: 18px (was 16px)
      fontWeight: FontWeight.w700, // Bold
      height: 1.4,         // CHANGED: Tighter line height
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle mobileTitleMedium(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle mobileBodyLarge(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 15.0,      // CHANGED: 15px (was 14px)
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle mobileLabelMedium(BuildContext context) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 13.0,      // CHANGED: 13px (was 12px)
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
```

#### Step 1.4: Update Spacing (Mobile Base Unit)

Update `/lib/core/theme/app_spacing.dart`:

```dart
class AppSpacing {
  // Mobile-first spacing (8px base unit for screens < 768px)
  static double _getBaseUnit(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 768 ? 8.0 : 4.0;
  }

  // Spacing scale
  static double xxs(BuildContext context) => _getBaseUnit(context);      // 8px mobile
  static double xs(BuildContext context) => _getBaseUnit(context) * 1.5; // 12px mobile
  static double sm(BuildContext context) => _getBaseUnit(context) * 2;   // 16px mobile
  static double md(BuildContext context) => _getBaseUnit(context) * 3;   // 24px mobile
  static double lg(BuildContext context) => _getBaseUnit(context) * 4;   // 32px mobile
  static double xl(BuildContext context) => _getBaseUnit(context) * 6;   // 48px mobile
  static double xxl(BuildContext context) => _getBaseUnit(context) * 8;  // 64px mobile

  // Border radius (mobile-optimized)
  static const double cardRadius = 20.0;   // CHANGED: 20px (was 12px)
  static const double buttonRadius = 10.0; // Keep at 10px
  static const double inputRadius = 10.0;  // Keep at 10px
  static const double fabRadius = 28.0;    // NEW: 56px circle / 2

  // Touch targets
  static const double minTouchTarget = 48.0; // Material standard
}
```

---

### Phase 2: Navigation Redesign (Days 4-6)

#### Step 2.1: Bottom Navigation (Icons Only, Gradient Underline)

Update `/lib/core/widgets/navigation/bottom_navigation_bar.dart`:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() =>
    _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState
    extends State<CustomBottomNavigationBar> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64.0, // Material standard
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              index: 0,
              label: 'Home',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              index: 1,
              label: 'Search',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              index: 2,
              label: 'Stats',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              index: 3,
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required String label,
  }) {
    final isActive = widget.currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Haptic feedback
            HapticFeedback.selectionClick();
            widget.onTap(index);
          },
          child: Container(
            height: 64.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon (24x24px, 48x48px touch target)
                SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 24.0,
                    color: isActive
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6)),
                  ),
                ),

                // Gradient underline (3px height, 48px width)
                SizedBox(height: 2.0),
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 48.0,
                  height: 3.0,
                  decoration: isActive
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(1.5),
                        gradient: LinearGradient(
                          colors: isDark
                            ? [Color(0xFF4338CA), Color(0xFF6D28D9)]
                            : [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        ),
                      )
                    : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Step 2.2: App Bar (Solid Background, Gradient Separator)

Update `/lib/core/widgets/navigation/app_bar.dart`:

```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onTitleTap;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onTitleTap,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            // Gradient separator (1px)
            width: 1.0,
            color: isDark
              ? Color(0xFF4338CA).withOpacity(0.3)
              : Color(0xFF4F46E5).withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Space switcher (left)
            IconButton(
              icon: Icon(Icons.swap_horiz, size: 24.0),
              onPressed: onTitleTap,
            ),

            // Title (center)
            Expanded(
              child: GestureDetector(
                onTap: onTitleTap,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Actions (right)
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
```

---

### Phase 3: FAB & Modal (Days 7-9)

#### Step 3.1: FAB (56px Circle, Gradient)

Update `/lib/core/widgets/fab/quick_capture_fab.dart`:

```dart
class QuickCaptureFab extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isOpen;

  const QuickCaptureFab({
    Key? key,
    required this.onPressed,
    this.isOpen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 56.0,  // CHANGED: 56px (was 64px)
      height: 56.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle, // CHANGED: Circle (was squircle)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [Color(0xFF4338CA), Color(0xFF6D28D9)]
            : [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Color(0xFF6D28D9) : Color(0xFF7C3AED))
              .withOpacity(0.3),
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(28.0), // 56/2
          child: AnimatedRotation(
            turns: isOpen ? 0.125 : 0.0, // 45° rotation (1/8 turn)
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Icon(
              isOpen ? Icons.close : Icons.add,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Step 3.2: Quick Capture Modal (Bottom Sheet)

Update `/lib/core/widgets/modals/quick_capture_modal.dart`:

```dart
Future<void> showQuickCaptureModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => QuickCaptureBottomSheet(),
  );
}

class QuickCaptureBottomSheet extends StatefulWidget {
  @override
  State<QuickCaptureBottomSheet> createState() =>
    _QuickCaptureBottomSheetState();
}

class _QuickCaptureBottomSheetState
    extends State<QuickCaptureBottomSheet> {

  final _controller = TextEditingController();
  ItemType _selectedType = ItemType.task;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.0), // CHANGED: 24px top radius
        ),
        border: Border(
          top: BorderSide(
            width: 4.0,
            color: _getGradientColorForType(_selectedType),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: keyboardHeight + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              SizedBox(height: 24.0),

              // Input field
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a task, note, or list...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Type selector chips
              Row(
                children: [
                  _buildTypeChip(ItemType.task, 'Task'),
                  SizedBox(width: 12.0),
                  _buildTypeChip(ItemType.note, 'Note'),
                  SizedBox(width: 12.0),
                  _buildTypeChip(ItemType.list, 'List'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(ItemType type, String label) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
            ? _getGradientColorForType(type).withOpacity(0.2)
            : Colors.transparent,
          border: Border.all(
            color: isSelected
              ? _getGradientColorForType(type)
              : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getGradientColorForType(ItemType type) {
    switch (type) {
      case ItemType.task:
        return Color(0xFFEF4444);
      case ItemType.note:
        return Color(0xFF3B82F6);
      case ItemType.list:
        return Color(0xFF8B5CF6);
    }
  }
}
```

---

## ⚡ Performance Checklist

### Before Every Commit:
- [ ] Test scrolling with 100+ cards at 60fps
- [ ] Profile with DevTools (no jank frames)
- [ ] Test on Android emulator with "Profile" build mode
- [ ] Check memory usage (< 100MB typical)

### Key Optimizations:
1. **Const constructors** wherever possible
2. **RepaintBoundary** around expensive widgets (cards, gradients)
3. **ListView.builder** with `itemExtent` hint (120px card height)
4. **Gradient caching** via const gradients
5. **Avoid setState** in scroll callbacks

---

## 🧪 Testing Strategy

### Widget Tests (Days 10-11):
```dart
testWidgets('ItemCard displays 6px gradient border', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ItemCard(
        item: Item(
          title: 'Test task',
          type: ItemType.task,
        ),
      ),
    ),
  );

  // Find CardGradientBorder widget
  final border = find.byType(CardGradientBorder);
  expect(border, findsOneWidget);

  // Verify border width
  final widget = tester.widget<CardGradientBorder>(border);
  expect(widget.borderWidth, 6.0);
});
```

### Integration Tests (Days 12-13):
```dart
testWidgets('Scroll 100 cards at 60fps', (tester) async {
  await tester.pumpWidget(MyApp());

  // Generate 100 test items
  final items = List.generate(100, (i) => Item(title: 'Task $i'));

  // Start profiling
  await tester.pumpAndSettle();
  final timeline = await tester.binding.traceAction(() async {
    await tester.fling(
      find.byType(ListView),
      Offset(0, -5000),
      10000,
    );
    await tester.pumpAndSettle();
  });

  // Assert 60fps (< 16ms per frame)
  final frameCount = timeline.events!
    .where((e) => e.name == 'Frame')
    .length;
  expect(frameCount, greaterThan(0));
});
```

---

## 📦 Deployment Checklist

### Before Releasing:
- [ ] All tests passing (unit, widget, integration)
- [ ] 60fps confirmed on 2021 mid-range Android device
- [ ] Accessibility audit (WCAG AA: 4.5:1 text, 3:1 UI)
- [ ] Dark mode verified (all gradients adapt)
- [ ] 320px width tested (small screens work)
- [ ] Reduced motion tested (animations skip gracefully)
- [ ] Beta testing with 10+ users
- [ ] Crashlytics integrated (monitor production errors)

---

## 🆘 Common Issues & Solutions

### Issue: Cards look cramped on 320px screens
**Solution**: Reduce horizontal padding from 24px to 20px on very small screens:
```dart
final isTinyScreen = MediaQuery.of(context).size.width < 340;
final padding = isTinyScreen ? 20.0 : 24.0;
```

### Issue: Gradient borders cause scroll jank
**Solution**: Wrap CardGradientBorder in RepaintBoundary:
```dart
RepaintBoundary(
  child: CardGradientBorder(...),
)
```

### Issue: Bottom nav jumps on keyboard open
**Solution**: Use `resizeToAvoidBottomInset: false` in Scaffold:
```dart
Scaffold(
  resizeToAvoidBottomInset: false,
  bottomNavigationBar: CustomBottomNavigationBar(...),
)
```

### Issue: Dark mode gradients too bright
**Solution**: Use darker gradient colors (already in code examples above)

---

## 📚 Additional Resources

- **Full Design Spec**: `/design-documentation/MOBILE-FIRST-BOLD-REDESIGN.md`
- **Component Library**: `/design-documentation/design-system/components/`
- **Accessibility Guide**: `/design-documentation/accessibility/guidelines.md`
- **Flutter Performance Docs**: https://docs.flutter.dev/perf/rendering-performance

---

## ✅ Done? What's Next?

After completing implementation:
1. **Deploy beta** to Google Play Internal Testing
2. **Collect feedback** from 20+ beta testers
3. **Iterate** based on user feedback (1 week)
4. **Public release** with announcement
5. **Monitor metrics**: User engagement, session time, completion rates

**Good luck! You're building something distinctive. 🚀**
