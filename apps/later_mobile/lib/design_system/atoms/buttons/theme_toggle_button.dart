import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../features/theme/presentation/controllers/theme_controller.dart';

/// Animated theme toggle button
///
/// Displays an animated icon button that toggles between light and dark themes.
/// Features:
/// - Animated icon rotation and fade on toggle
/// - Haptic feedback on press
/// - Accessibility tooltip
/// - Riverpod ConsumerWidget for reactive updates
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
class ThemeToggleButton extends ConsumerWidget {
  /// Creates a theme toggle button
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode;

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
        await themeController.toggleTheme();
      },
    );
  }
}
