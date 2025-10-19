import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Bottom navigation bar for mobile devices
///
/// Provides primary navigation for the mobile app with 3 tabs:
/// - Home (spaces view)
/// - Search
/// - Settings
///
/// Uses Material 3 NavigationBar widget with proper accessibility support.
/// Displays only on mobile breakpoints (< 768px).
///
/// Example usage:
/// ```dart
/// Scaffold(
///   bottomNavigationBar: AppBottomNavigationBar(
///     currentIndex: _selectedIndex,
///     onDestinationSelected: (index) {
///       setState(() => _selectedIndex = index);
///     },
///   ),
/// )
/// ```
class AppBottomNavigationBar extends StatelessWidget {
  /// Creates a bottom navigation bar.
  ///
  /// The [currentIndex] parameter must not be null and must be between 0 and 2.
  /// The [onDestinationSelected] callback is called when the user taps a destination.
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  }) : assert(
          currentIndex >= 0 && currentIndex < 3,
          'currentIndex must be between 0 and 2',
        );

  /// The index of the currently selected destination.
  final int currentIndex;

  /// Called when the user taps a destination.
  ///
  /// The callback receives the index of the tapped destination.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: isDarkMode
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      indicatorColor: isDarkMode
          ? AppColors.selectedDark
          : AppColors.selectedLight,
      elevation: AppSpacing.elevation2,
      height: 64.0, // Provides adequate touch target size
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            semanticLabel: 'Home navigation',
          ),
          selectedIcon: Icon(
            Icons.home,
            semanticLabel: 'Home navigation (selected)',
          ),
          label: 'Home',
          tooltip: 'View your spaces',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.search_outlined,
            semanticLabel: 'Search navigation',
          ),
          selectedIcon: Icon(
            Icons.search,
            semanticLabel: 'Search navigation (selected)',
          ),
          label: 'Search',
          tooltip: 'Search items',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.settings_outlined,
            semanticLabel: 'Settings navigation',
          ),
          selectedIcon: Icon(
            Icons.settings,
            semanticLabel: 'Settings navigation (selected)',
          ),
          label: 'Settings',
          tooltip: 'App settings',
        ),
      ],
    );
  }
}
