import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../core/theme/temporal_flow_theme.dart';

// Design Constants (Phase 2 - Mobile-First Bold Redesign)
const double _kNavBarHeight = 60.0; // Reduced from 64px
const double _kIconSize = 24.0; // Standard icon size
const double _kUnderlineHeight = 3.0; // Gradient underline height
const double _kUnderlineWidth = 32.0; // Gradient underline width
const double _kTouchTargetSize = 48.0; // WCAG AA compliant

/// Icon-only bottom navigation bar for mobile-first bold redesign
///
/// Phase 2 Implementation: Navigation Redesign
/// - Icon-only layout (no text labels) for spacious modern look
/// - 3px gradient underline on active tab (not background fill)
/// - 48×48px touch targets for accessibility
/// - 60px total height (reduced from 64-68px)
/// - Active indicator: gradient underline with smooth animation
/// - Inactive icons: gray (neutral600 light, neutral400 dark)
/// - Active icons: white with gradient underline
///
/// Features:
/// - Three tabs: Home, Search, Settings
/// - Smooth underline animation (200ms, ease-out curve)
/// - Haptic feedback on tap
/// - Semantic labels for screen readers
/// - Tooltips on long-press
/// - Safe area support for notched devices
///
/// Example usage:
/// ```dart
/// Scaffold(
///   bottomNavigationBar: IconOnlyBottomNav(
///     currentIndex: _selectedIndex,
///     onDestinationSelected: (index) {
///       setState(() => _selectedIndex = index);
///     },
///   ),
/// )
/// ```
class IconOnlyBottomNav extends StatefulWidget {
  /// Creates an icon-only bottom navigation bar.
  ///
  /// The [currentIndex] parameter must not be null and must be between 0 and 2.
  /// The [onDestinationSelected] callback is called when the user taps a destination.
  const IconOnlyBottomNav({
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
  State<IconOnlyBottomNav> createState() => _IconOnlyBottomNavState();
}

class _IconOnlyBottomNavState extends State<IconOnlyBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _underlineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Fast animation
    );
    _underlineAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // Smooth ease-out curve
    );
    _animationController.value = 1.0; // Start at full opacity
  }

  @override
  void didUpdateWidget(IconOnlyBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Trigger haptic feedback on navigation change
      AppAnimations.selectionHaptic();
      // Animate underline: fade out → fade in
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        height: _kNavBarHeight,
        constraints: const BoxConstraints(minHeight: _kNavBarHeight),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? AppColors.neutral700.withValues(alpha: 0.1)
                  : AppColors.neutral200.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              tooltip: 'View your spaces',
              semanticLabel: 'Home navigation',
              isDarkMode: isDarkMode,
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.search_outlined,
              selectedIcon: Icons.search,
              tooltip: 'Search items',
              semanticLabel: 'Search navigation',
              isDarkMode: isDarkMode,
            ),
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              tooltip: 'App settings',
              semanticLabel: 'Settings navigation',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String tooltip,
    required String semanticLabel,
    required bool isDarkMode,
  }) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Only trigger haptic if actually changing tabs
              if (widget.currentIndex != index) {
                AppAnimations.selectionHaptic();
              }
              widget.onDestinationSelected(index);
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            splashColor: AppColors.ripple(context),
            highlightColor: Colors.transparent,
            child: Semantics(
              label: isSelected ? '$semanticLabel (selected)' : semanticLabel,
              selected: isSelected,
              button: true,
              child: SizedBox(
                width: _kTouchTargetSize,
                height: _kTouchTargetSize,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      isSelected ? selectedIcon : icon,
                      size: _kIconSize,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode
                                ? AppColors.neutral400
                                : AppColors.neutral600),
                    ),
                    // Spacing
                    const SizedBox(height: 4.0),
                    // Gradient underline (only for active tab)
                    _buildUnderline(context, isSelected),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnderline(BuildContext context, bool isSelected) {
    if (!isSelected) {
      // Inactive: no underline, just placeholder spacing
      return const SizedBox(height: _kUnderlineHeight, width: _kUnderlineWidth);
    }

    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // Active: animated gradient underline
    return AnimatedBuilder(
      animation: _underlineAnimation,
      builder: (context, child) {
        // Smooth fade in and width expand animation
        final opacity = _underlineAnimation.value.clamp(0.0, 1.0);
        final width = _kUnderlineWidth * _underlineAnimation.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _kUnderlineHeight,
          width: width,
          constraints: const BoxConstraints(
            maxHeight: _kUnderlineHeight,
            maxWidth: _kUnderlineWidth,
          ),
          decoration: BoxDecoration(
            gradient: temporalTheme.primaryGradient,
            borderRadius: BorderRadius.circular(1.5), // Rounded ends
          ),
          child: Opacity(
            opacity: opacity,
            child: Container(), // Empty container for opacity transition
          ),
        );
      },
    );
  }
}
