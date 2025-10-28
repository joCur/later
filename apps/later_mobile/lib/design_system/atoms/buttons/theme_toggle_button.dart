import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../providers/theme_provider.dart';

/// Animated theme toggle button
///
/// Displays an animated icon button that toggles between light and dark themes.
/// Features:
/// - Animated icon rotation and fade on toggle
/// - Haptic feedback on press
/// - Accessibility tooltip
/// - Consumer pattern for reactive updates
///
/// The icon changes based on current theme:
/// - Light mode: Shows dark_mode icon (sun)
/// - Dark mode: Shows light_mode icon (moon)
///
/// Example usage:
/// ```dart
/// // In AppBar actions
/// AppBar(
///   actions: [
///     ThemeToggleButton(),
///   ],
/// )
///
/// // In Sidebar
/// ThemeToggleButton(),
/// ```
class ThemeToggleButton extends StatelessWidget {
  /// Creates a theme toggle button
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;

        return IconButton(
          icon: AnimatedSwitcher(
            duration: AppAnimations.quick,
            transitionBuilder: (child, animation) {
              // Combine rotation and fade for smooth transition
              return RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              // Unique key ensures AnimatedSwitcher detects the change
              key: ValueKey(isDark),
            ),
          ),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: () async {
            // Trigger haptic feedback for user satisfaction
            await AppAnimations.lightHaptic();
            // Toggle theme with animation
            await themeProvider.toggleTheme();
          },
        );
      },
    );
  }
}
