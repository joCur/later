---
title: Navigation Component
description: Bottom navigation, app bar, and navigation patterns
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../style-guide.md
  - ../tokens/spacing.md
---

# Navigation Component

## Overview

later uses **bottom navigation** on mobile for primary navigation and an **adaptive navigation system** that transforms to a side rail on tablet and sidebar on desktop. Navigation feels fluid and context-aware.

---

## Bottom Navigation (Mobile)

### Visual Design

**Container**
```dart
Container(
  height: 72, // 56px bar + 16px safe area
  decoration: BoxDecoration(
    color: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : AppColors.neutral900,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, -2),
      ),
    ],
    border: Border(
      top: BorderSide(
        color: AppColors.neutral200,
        width: 1,
      ),
    ),
  ),
)
```

**Properties**:
- Height: 56px content + safe area padding
- Background: White (light), Neutral-900 (dark)
- Top border: 1px Neutral-200
- Shadow: Subtle upward shadow
- Safe Area: Respects bottom inset

### Navigation Items

**Primary Navigation Tabs**:
1. **Inbox** - All uncategorized items
2. **Spaces** - Organized workspaces
3. **Search** - Search and filter
4. **Profile** - Settings and profile

**Layout**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    NavItem(icon: Lucide.inbox, label: 'Inbox', isActive: true),
    NavItem(icon: Lucide.folder, label: 'Spaces', isActive: false),
    Spacer(), // Space for FAB
    NavItem(icon: Lucide.search, label: 'Search', isActive: false),
    NavItem(icon: Lucide.user, label: 'Profile', isActive: false),
  ],
)
```

### Navigation Item States

**Inactive State**
```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      icon,
      size: 24,
      color: AppColors.neutral400,
    ),
    SizedBox(height: 4),
    Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: AppColors.neutral400,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
)
```

**Active State**
```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        icon,
        size: 24,
        color: Colors.white,
      ),
    ),
    SizedBox(height: 4),
    Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: AppColors.primarySolid,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
)
```

**Visual Changes on Active**:
- Icon: Contained in gradient pill background
- Icon color: White
- Label: Primary color, semibold
- Smooth transition (200ms)

**Tap Interaction**
```dart
GestureDetector(
  onTap: () {
    HapticFeedback.lightImpact();
    onNavigate();
  },
  child: AnimatedContainer(
    duration: AppAnimations.fast,
    curve: AppAnimations.easeOutQuart,
    child: NavItemContent(),
  ),
)
```

**Animation on Selection**:
- Scale: 0.95 → 1.0 (100ms)
- Color transition: 200ms
- Haptic: Light impact

### FAB Integration

The quick capture FAB sits **above** the bottom navigation:

**Position**
```dart
Stack(
  children: [
    Positioned.fill(
      child: PageContent(),
    ),
    Positioned(
      bottom: 80, // 72px nav + 8px gap
      right: AppSpacing.md,
      child: QuickCaptureFAB(),
    ),
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BottomNav(),
    ),
  ],
)
```

---

## App Bar (Top)

### Standard App Bar

**Visual Design**
```dart
AppBar(
  toolbarHeight: 64,
  elevation: 0,
  backgroundColor: Colors.transparent,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white.withOpacity(0.9)
          : AppColors.neutral900.withOpacity(0.9),
      border: Border(
        bottom: BorderSide(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(),
    ),
  ),
  title: Text(
    pageTitle,
    style: Theme.of(context).textTheme.titleLarge,
  ),
  centerTitle: false, // Left-aligned
)
```

**Properties**:
- Height: 64px
- Background: Frosted glass effect
- Border: 1px bottom border
- Blur: 10px backdrop blur
- Title: Left-aligned, Title Large style

### App Bar Variants

**With Back Button**
```dart
AppBar(
  leading: IconButton(
    icon: Icon(Lucide.arrowLeft),
    onPressed: () {
      HapticFeedback.lightImpact();
      Navigator.pop(context);
    },
  ),
  title: Text(pageTitle),
)
```

**With Actions**
```dart
AppBar(
  title: Text(pageTitle),
  actions: [
    IconButton(
      icon: Icon(Lucide.moreVertical),
      onPressed: () => _showMenu(),
    ),
    SizedBox(width: AppSpacing.xs),
  ],
)
```

**Search Bar Variant**
```dart
AppBar(
  title: TextField(
    decoration: InputDecoration(
      hintText: 'Search...',
      prefixIcon: Icon(Lucide.search),
      border: InputBorder.none,
    ),
  ),
)
```

---

## Navigation Rail (Tablet)

For tablet portrait mode (768-1023px width):

**Visual Design**
```dart
NavigationRail(
  selectedIndex: currentIndex,
  onDestinationSelected: (index) {
    setState(() => currentIndex = index);
    HapticFeedback.lightImpact();
  },
  labelType: NavigationRailLabelType.all,
  backgroundColor: Theme.of(context).brightness == Brightness.light
      ? Colors.white
      : AppColors.neutral900,
  indicatorColor: AppColors.primaryLight,
  selectedIconTheme: IconThemeData(color: AppColors.primarySolid),
  destinations: [
    NavigationRailDestination(
      icon: Icon(Lucide.inbox),
      label: Text('Inbox'),
    ),
    NavigationRailDestination(
      icon: Icon(Lucide.folder),
      label: Text('Spaces'),
    ),
    NavigationRailDestination(
      icon: Icon(Lucide.search),
      label: Text('Search'),
    ),
    NavigationRailDestination(
      icon: Icon(Lucide.user),
      label: Text('Profile'),
    ),
  ],
)
```

**Properties**:
- Width: 72px
- Vertical layout
- Full labels
- Left side of screen
- FAB positioned bottom-right

---

## Sidebar Navigation (Desktop)

For desktop and tablet landscape (1024px+ width):

**Visual Design**
```dart
Container(
  width: 280,
  decoration: BoxDecoration(
    color: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : AppColors.neutral900,
    border: Border(
      right: BorderSide(
        color: AppColors.neutral200,
        width: 1,
      ),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(),
      _buildNavItems(),
      Spacer(),
      _buildQuickCapture(),
      _buildFooter(),
    ],
  ),
)
```

**Components**:

*Header*
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.lg),
  child: Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: Text(
            'L',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      SizedBox(width: AppSpacing.sm),
      Text(
        'later',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ],
  ),
)
```

*Navigation Items*
```dart
ListView(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
  children: [
    NavItem(icon: Lucide.inbox, label: 'Inbox', isActive: true),
    NavItem(icon: Lucide.folder, label: 'Spaces', isActive: false),
    Divider(),
    NavItem(icon: Lucide.search, label: 'Search', isActive: false),
    NavItem(icon: Lucide.archive, label: 'Archive', isActive: false),
  ],
)
```

*Sidebar Nav Item*
```dart
// Active state
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  ),
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppRadius.sm),
    boxShadow: [
      BoxShadow(
        color: AppColors.primarySolid.withOpacity(0.2),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    children: [
      Icon(icon, size: 20, color: Colors.white),
      SizedBox(width: AppSpacing.sm),
      Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)

// Inactive state
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  ),
  child: Row(
    children: [
      Icon(icon, size: 20, color: AppColors.neutral600),
      SizedBox(width: AppSpacing.sm),
      Text(
        label,
        style: TextStyle(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
)
```

*Quick Capture Button*
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: Container(
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      boxShadow: [
        BoxShadow(
          color: AppColors.primarySolid.withOpacity(0.3),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          _openQuickCapture();
        },
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Lucide.plus, color: Colors.white),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Quick Capture',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
)
```

*Footer*
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: Row(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundImage: userAvatar,
      ),
      SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        icon: Icon(Lucide.settings, size: 20),
        onPressed: () => _openSettings(),
      ),
    ],
  ),
)
```

---

## Tab Navigation (Within Screens)

For switching between views within a screen:

**Visual Design**
```dart
Container(
  height: 48,
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
  decoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: AppColors.neutral200,
        width: 1,
      ),
    ),
  ),
  child: Row(
    children: [
      TabItem(label: 'All', isActive: true),
      TabItem(label: 'Tasks', isActive: false),
      TabItem(label: 'Notes', isActive: false),
      TabItem(label: 'Lists', isActive: false),
    ],
  ),
)
```

**Tab Item**
```dart
// Active
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  ),
  decoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: AppColors.primarySolid,
        width: 2,
      ),
    ),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: AppColors.primarySolid,
      fontWeight: FontWeight.w600,
    ),
  ),
)

// Inactive
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  ),
  child: Text(
    label,
    style: TextStyle(
      color: AppColors.neutral600,
      fontWeight: FontWeight.w500,
    ),
  ),
)
```

---

## Breadcrumbs (Desktop)

For hierarchical navigation:

```dart
Row(
  children: [
    TextButton(
      onPressed: () => _navigateTo('Spaces'),
      child: Text('Spaces'),
    ),
    Icon(Lucide.chevronRight, size: 16, color: AppColors.neutral400),
    TextButton(
      onPressed: () => _navigateTo('Work'),
      child: Text('Work'),
    ),
    Icon(Lucide.chevronRight, size: 16, color: AppColors.neutral400),
    Text(
      'Project Alpha',
      style: TextStyle(color: AppColors.neutral900),
    ),
  ],
)
```

---

## Navigation Transitions

### Screen Transitions

**Forward Navigation**
```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutExpo,
      )),
      child: child,
    );
  },
  transitionDuration: Duration(milliseconds: 400),
)
```

**Back Navigation**
```dart
// Slide out to right
position: Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(1.0, 0.0),
).animate(animation)
```

### Tab Switches

**Crossfade Transition**
```dart
AnimatedSwitcher(
  duration: AppAnimations.fast,
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
  child: currentTab,
)
```

---

## Accessibility

### Screen Reader Support

```dart
Semantics(
  label: 'Navigation bar',
  child: BottomNavigationBar(...),
)

Semantics(
  label: 'Navigate to $label',
  selected: isActive,
  button: true,
  child: NavItem(...),
)
```

### Keyboard Navigation

- **Tab**: Move between nav items
- **Enter/Space**: Activate nav item
- **Arrow keys**: Navigate between items
- **1-9**: Quick jump to nav items (desktop)

### Focus States

```dart
Container(
  decoration: BoxDecoration(
    border: isFocused
        ? Border.all(color: AppColors.primarySolid, width: 2)
        : null,
    borderRadius: BorderRadius.circular(AppRadius.sm),
  ),
  child: NavItem(...),
)
```

---

## Responsive Behavior Summary

| Screen Size | Navigation Style | FAB Position | Additional |
|-------------|------------------|--------------|------------|
| Mobile (< 768px) | Bottom bar (4 items) | Above bottom bar | Floating |
| Tablet Portrait (768-1023px) | Navigation rail | Bottom-right | 72px wide rail |
| Tablet Landscape (1024px+) | Sidebar | Bottom-right | 280px sidebar |
| Desktop (1024px+) | Sidebar | In sidebar | Full features |

---

## Flutter Implementation

```dart
// lib/core/navigation/adaptive_navigation.dart

class AdaptiveNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;
  final Widget child;

  const AdaptiveNavigation({
    required this.currentIndex,
    required this.onNavigate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) {
      return _buildMobileNav(context);
    } else if (width < 1024) {
      return _buildTabletNav(context);
    } else {
      return _buildDesktopNav(context);
    }
  }

  Widget _buildMobileNav(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavigate,
        type: BottomNavigationBarType.fixed,
        items: _getNavItems(),
      ),
      floatingActionButton: QuickCaptureFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabletNav(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onNavigate,
            labelType: NavigationRailLabelType.all,
            destinations: _getRailDestinations(),
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: QuickCaptureFAB(),
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            child: NavigationSidebar(
              currentIndex: currentIndex,
              onNavigate: onNavigate,
            ),
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Lucide.inbox),
        label: 'Inbox',
      ),
      BottomNavigationBarItem(
        icon: Icon(Lucide.folder),
        label: 'Spaces',
      ),
      BottomNavigationBarItem(
        icon: Icon(Lucide.search),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(Lucide.user),
        label: 'Profile',
      ),
    ];
  }

  List<NavigationRailDestination> _getRailDestinations() {
    return _getNavItems().map((item) {
      return NavigationRailDestination(
        icon: item.icon,
        label: Text(item.label!),
      );
    }).toList();
  }
}
```

---

**Related Documentation**
- [Style Guide](../style-guide.md)
- [Quick Capture](./quick-capture.md)
- [Platform Adaptations](../platform-adaptations/)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
