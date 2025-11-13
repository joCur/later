import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import '../../core/theme/temporal_flow_theme.dart';

// Design Constants
const double _kNavBarHeight = 64.0;
const double _kIndicatorHeight = 40.0;
const double _kIndicatorWidth = 64.0;
const double _kIndicatorRadius = 20.0;
const double _kIconSize = 24.0;
const double _kLabelFontSize = 11.0;
const double _kItemVerticalPadding = 4.0;
const double _kLabelTopSpacing = 4.0;

/// Bottom navigation bar for mobile devices with glass morphism design
///
/// Provides primary navigation for the mobile app with 3 tabs:
/// - Home (spaces view)
/// - Search
/// - Settings
///
/// Features:
/// - Glassmorphic background with 20px blur and 90% opacity
/// - Gradient active indicator with pill shape (48px height)
/// - Outlined icons with 2px stroke weight
/// - Smooth indicator animation (250ms spring curve)
/// - Safe area support for notched devices
/// - 64px total height maintained
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
class AppBottomNavigationBar extends StatefulWidget {
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
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.springCurve,
    );
    _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(AppBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Trigger selection haptic feedback on navigation change
      AppAnimations.selectionHaptic();
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
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppColors.glassBlurRadius,
            sigmaY: AppColors.glassBlurRadius,
          ),
          child: Container(
            height: _kNavBarHeight,
            decoration: BoxDecoration(
              color: temporalTheme.glassBackground,
              border: Border(top: BorderSide(color: temporalTheme.glassBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: l10n.navigationBottomHome,
                  tooltip: l10n.navigationBottomHomeTooltip,
                  semanticLabel: l10n.navigationBottomHomeSemanticLabel,
                  isDarkMode: isDarkMode,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  label: l10n.navigationBottomSearch,
                  tooltip: l10n.navigationBottomSearchTooltip,
                  semanticLabel: l10n.navigationBottomSearchSemanticLabel,
                  isDarkMode: isDarkMode,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: l10n.navigationBottomSettings,
                  tooltip: l10n.navigationBottomSettingsTooltip,
                  semanticLabel: l10n.navigationBottomSettingsSemanticLabel,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String tooltip,
    required String semanticLabel,
    required bool isDarkMode,
  }) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final isSelected = widget.currentIndex == index;
    final theme = Theme.of(context);

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
            child: SizedBox(
              height: _kNavBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _kItemVerticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with animated indicator background
                    SizedBox(
                      height: _kIndicatorHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated gradient indicator
                          if (isSelected)
                            AnimatedBuilder(
                              animation: _indicatorAnimation,
                              builder: (context, child) {
                                // Clamp opacity value to 0-1 range (spring curves can overshoot)
                                final opacity = _indicatorAnimation.value.clamp(
                                  0.0,
                                  1.0,
                                );
                                final scale = _indicatorAnimation.value.clamp(
                                  0.0,
                                  1.0,
                                );

                                return Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Container(
                                      height: _kIndicatorHeight,
                                      width: _kIndicatorWidth,
                                      decoration: BoxDecoration(
                                        gradient: temporalTheme.primaryGradient,
                                        borderRadius: BorderRadius.circular(
                                          _kIndicatorRadius,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Icon
                          Icon(
                            isSelected ? selectedIcon : icon,
                            size: _kIconSize,
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode
                                      ? AppColors.neutral400
                                      : AppColors.neutral600),
                            semanticLabel: isSelected
                                ? '$semanticLabel (selected)'
                                : semanticLabel,
                          ),
                        ],
                      ),
                    ),
                    // Label
                    const SizedBox(height: _kLabelTopSpacing),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: _kLabelFontSize,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? temporalTheme.primaryGradient.colors.first
                            : (isDarkMode
                                  ? AppColors.neutral500
                                  : AppColors.neutral600),
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
