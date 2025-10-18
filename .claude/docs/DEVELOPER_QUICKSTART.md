# Later App - Developer Quick Start Guide

**Version**: 1.0.0 | **Last Updated**: 2025-10-18

Welcome to the Later app development! This guide will help you understand the design system and start implementing features quickly.

## 30-Second Overview

Later is a **flexible organizer** combining tasks, notes, and lists with **offline-first** functionality. Built with **Flutter** for cross-platform deployment (iOS, Android, Web, Desktop).

**Design Philosophy**: "Works how you think" - flexibility without forcing rigid workflows.

---

## Essential Documentation

### Start Here (Priority Order)

1. **[DESIGN_SYSTEM_SUMMARY.md](./DESIGN_SYSTEM_SUMMARY.md)** - Visual overview with ASCII diagrams (15 min read)
2. **[design-documentation/design-system/style-guide.md](./design-documentation/design-system/style-guide.md)** - Complete design system (30 min read)
3. **[design-documentation/assets/design-tokens.json](./design-documentation/assets/design-tokens.json)** - Exportable tokens for implementation
4. **[design-documentation/design-system/platform-adaptations/flutter.md](./design-documentation/design-system/platform-adaptations/flutter.md)** - Flutter-specific guidance (20 min read)

### Feature-Specific Documentation

- **Quick Capture**: [design-documentation/features/quick-capture/](./design-documentation/features/quick-capture/)
- **Item Management**: [design-documentation/features/unified-item-management/](./design-documentation/features/unified-item-management/)
- **Offline Architecture**: [design-documentation/features/offline-first-architecture/](./design-documentation/features/offline-first-architecture/)

### Component Library

- **Item Cards**: [design-documentation/design-system/components/item-cards.md](./design-documentation/design-system/components/item-cards.md)
- **All Components**: [design-documentation/design-system/components/](./design-documentation/design-system/components/)

---

## Quick Reference

### Color Palette

```dart
// Primary Colors
static const Color lightPrimary = Color(0xFF6366F1);  // Indigo
static const Color darkPrimary = Color(0xFF818CF8);

// Item Type Colors
static const Color taskColor = Color(0xFF3B82F6);     // Blue
static const Color noteColor = Color(0xFFF59E0B);     // Amber
static const Color listColor = Color(0xFF8B5CF6);     // Violet

// Semantic Colors
static const Color success = Color(0xFF10B981);       // Green
static const Color error = Color(0xFFEF4444);         // Red
static const Color warning = Color(0xFFF59E0B);       // Amber
```

### Typography Scale

```dart
// Headings
h1: 32px/40px, Bold 700       // Page titles
h2: 24px/32px, Semibold 600   // Section headers
h3: 20px/28px, Semibold 600   // Subsections
h4: 18px/26px, Semibold 600   // Card titles

// Body
bodyLarge: 16px/24px, Regular 400
body: 14px/22px, Regular 400
bodySmall: 12px/18px, Regular 400
caption: 11px/16px, Regular 400
```

### Spacing Scale (8px base)

```dart
xs: 4px    // Micro spacing
sm: 8px    // Small spacing
md: 16px   // Default spacing
lg: 24px   // Section spacing
xl: 32px   // Large spacing
2xl: 48px  // Major separators
3xl: 64px  // Hero sections
```

### Breakpoints

```dart
mobile: 320px - 767px
tablet: 768px - 1023px
desktop: 1024px - 1439px
wide: 1440px+
```

---

## Flutter Project Setup

### 1. Install Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.0

  # Local Database (Offline-first)
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Networking
  dio: ^5.3.3

  # UI Components
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9

  # Utilities
  intl: ^0.18.1
  uuid: ^4.1.0
  path_provider: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

### 2. Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart           # ThemeData configuration
│   │   ├── app_colors.dart          # Color constants
│   │   ├── app_typography.dart      # Text styles
│   │   └── app_animations.dart      # Animation constants
│   ├── responsive/
│   │   ├── breakpoints.dart         # Responsive helpers
│   │   └── adaptive_spacing.dart    # Spacing helpers
│   └── constants/
│       └── app_constants.dart       # Global constants
├── data/
│   ├── models/
│   │   ├── item.dart                # Item model (Task/Note/List)
│   │   └── space.dart               # Space model
│   ├── local/
│   │   └── local_database.dart      # Hive database
│   └── repositories/
│       └── item_repository.dart     # Data layer
├── providers/
│   ├── items_provider.dart          # Item state management
│   └── spaces_provider.dart         # Space state management
├── widgets/
│   ├── components/
│   │   ├── item_card.dart           # Item card component
│   │   ├── buttons.dart             # Button components
│   │   └── input_fields.dart        # Input components
│   └── screens/
│       ├── home_screen.dart         # Main workspace
│       ├── item_detail_screen.dart  # Item detail view
│       └── quick_capture_modal.dart # Quick capture
└── main.dart                        # App entry point
```

### 3. Initialize Theme

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

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

    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.neutral50,
    dividerColor: AppColors.neutral200,
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

### 4. Initialize App

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'providers/items_provider.dart';
import 'providers/spaces_provider.dart';
import 'widgets/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline storage
  await Hive.initFlutter();

  runApp(const LaterApp());
}

class LaterApp extends StatelessWidget {
  const LaterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => SpacesProvider()),
      ],
      child: MaterialApp(
        title: 'Later',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
```

---

## Implementing Key Features

### 1. Item Card Component

Reference: [design-documentation/design-system/components/item-cards.md](./design-documentation/design-system/components/item-cards.md)

**Quick Implementation**:

```dart
class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;

  const ItemCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: _getItemTypeColor(),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _buildLeadingElement(),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.content != null) ...[
                      SizedBox(height: 4),
                      Text(
                        item.content!,
                        style: AppTypography.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getItemTypeColor() {
    switch (item.type) {
      case ItemType.task:
        return AppColors.taskColor;
      case ItemType.note:
        return AppColors.noteColor;
      case ItemType.list:
        return AppColors.listColor;
    }
  }

  Widget _buildLeadingElement() {
    if (item.type == ItemType.task) {
      return Checkbox(
        value: item.isCompleted,
        onChanged: (value) => item.toggleComplete(),
      );
    }
    return Icon(
      item.type == ItemType.note ? Icons.note : Icons.list,
      size: 20,
      color: _getItemTypeColor(),
    );
  }
}
```

### 2. Quick Capture Modal

Reference: [design-documentation/features/quick-capture/screen-states.md](./design-documentation/features/quick-capture/screen-states.md)

**Quick Implementation**:

```dart
class QuickCaptureModal extends StatefulWidget {
  @override
  _QuickCaptureModalState createState() => _QuickCaptureModalState();
}

class _QuickCaptureModalState extends State<QuickCaptureModal> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  ItemType _selectedType = ItemType.task;

  @override
  void initState() {
    super.initState();
    // Auto-focus input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle (mobile)
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quick Capture', style: AppTypography.h3),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Input field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Actions
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.mic),
                onPressed: () {/* Voice input */},
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () {/* Image upload */},
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _save,
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_controller.text.isNotEmpty) {
      final item = Item(
        title: _controller.text,
        type: _selectedType,
      );
      Provider.of<ItemsProvider>(context, listen: false).addItem(item);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// Usage:
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => QuickCaptureModal(),
);
```

### 3. Responsive Layout

```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return MobileLayout();
        } else if (constraints.maxWidth < 1024) {
          return TabletLayout();
        } else {
          return DesktopLayout();
        }
      },
    );
  }
}

// Helper method
bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 768;
}
```

---

## Common Patterns

### 1. Responsive Padding

```dart
double getResponsivePadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 768) return 16.0;      // Mobile
  if (width < 1024) return 24.0;     // Tablet
  return 32.0;                        // Desktop
}
```

### 2. Animations

```dart
// Use design system animation constants
AnimatedContainer(
  duration: AppAnimations.medium,  // 300ms
  curve: AppAnimations.easeOut,
  // ...
)

// Respect reduced motion
Duration getDuration(BuildContext context) {
  return MediaQuery.of(context).disableAnimations
    ? Duration(milliseconds: 1)
    : AppAnimations.medium;
}
```

### 3. Offline-First Data

```dart
class ItemsProvider extends ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  List<Item> _items = [];

  Future<void> addItem(Item item) async {
    // Save locally first (offline-first)
    await _db.saveItem(item);
    _items.add(item);
    notifyListeners();

    // Queue for sync (if online)
    _syncQueue.add(item);
  }
}
```

---

## Testing Checklist

### Before Committing

- [ ] **Visual**: Matches design specs (colors, spacing, typography)
- [ ] **Responsive**: Works on mobile, tablet, desktop
- [ ] **Accessibility**: WCAG AA compliance, keyboard navigation
- [ ] **Performance**: 60fps animations, virtualized lists
- [ ] **Offline**: Works without network
- [ ] **States**: All states implemented (hover, focus, disabled, etc.)
- [ ] **Tests**: Widget tests pass

### Testing Tools

```bash
# Run tests
flutter test

# Check performance
flutter run --profile

# Analyze code
flutter analyze

# Format code
flutter format .
```

---

## Performance Tips

1. **Use const constructors** wherever possible
2. **Virtualize lists**: `ListView.builder` not `ListView`
3. **Avoid unnecessary rebuilds**: Use `const`, proper keys
4. **Cache expensive operations**: Images, calculations
5. **Profile regularly**: Use DevTools

---

## Accessibility Checklist

- [ ] All interactive elements have semantic labels
- [ ] Minimum 44x44dp touch targets
- [ ] WCAG AA contrast ratios (4.5:1 text, 3:1 UI)
- [ ] Keyboard navigation works
- [ ] Screen reader tested (TalkBack/VoiceOver)
- [ ] Reduced motion supported

---

## Common Gotchas

1. **Don't hardcode colors** - Always use theme colors
2. **Don't skip breakpoints** - Test all screen sizes
3. **Don't forget offline** - All features work offline
4. **Don't ignore accessibility** - Required, not optional
5. **Don't overcomplicate** - Simple solutions first

---

## Getting Help

1. **Design Questions**: Check [design-documentation/](./design-documentation/)
2. **Component Specs**: See [components/](./design-documentation/design-system/components/)
3. **Flutter Patterns**: Review [flutter.md](./design-documentation/design-system/platform-adaptations/flutter.md)
4. **Feature Details**: Check [features/](./design-documentation/features/)

---

## Next Steps

1. **Read** [DESIGN_SYSTEM_SUMMARY.md](./DESIGN_SYSTEM_SUMMARY.md) for visual overview
2. **Review** [style-guide.md](./design-documentation/design-system/style-guide.md) for complete specs
3. **Explore** [design-tokens.json](./design-documentation/assets/design-tokens.json) for values
4. **Implement** your first component using this guide
5. **Test** thoroughly across platforms and breakpoints
6. **Iterate** based on design feedback

---

**Happy Coding!** Remember: "Works how you think" - keep it simple, flexible, and beautiful.

**Last Updated**: 2025-10-18 | **Version**: 1.0.0
