import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';

/// Option for SegmentedControl
///
/// Generic container for segmented control options with icon and label.
/// Type parameter [T] represents the value type (e.g., enum, string, int).
class SegmentedControlOption<T> {
  const SegmentedControlOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  /// The value this option represents
  final T value;

  /// Display label for the option
  final String label;

  /// Icon to display above the label
  final IconData icon;
}

/// Segmented Control - iOS-style selector for mutually exclusive options
///
/// Features:
/// - iOS-native segmented control design pattern
/// - Fixed height: 44px (iOS standard)
/// - Pill-shaped selected state with elevation
/// - Supports 2-6 options (optimal: 3-4)
/// - Icon + label layout (vertical stack)
/// - Theme-aware (light/dark mode)
/// - Haptic feedback on selection
/// - Smooth spring animation on selection
/// - Equal width segments (uses Expanded)
/// - 48px minimum touch target for accessibility
/// - Semantic labels for screen readers
///
/// Usage:
/// ```dart
/// SegmentedControl<ListStyle>(
///   options: [
///     SegmentedControlOption(
///       value: ListStyle.bullets,
///       label: 'Bullets',
///       icon: Icons.format_list_bulleted,
///     ),
///     // ... more options
///   ],
///   selectedValue: _selectedStyle,
///   onSelectionChanged: (value) {
///     setState(() => _selectedStyle = value);
///   },
/// )
/// ```
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelectionChanged,
    this.height = 44.0,
    this.borderRadius = 12.0,
    this.iconSize = 18.0,
    this.labelFontSize = 10.0,
  }) : assert(options.length >= 2 && options.length <= 6,
            'SegmentedControl requires 2-6 options');

  /// List of options to display
  final List<SegmentedControlOption<T>> options;

  /// Currently selected value
  final T selectedValue;

  /// Callback when selection changes
  final ValueChanged<T> onSelectionChanged;

  /// Height of the control (default: 44px)
  final double height;

  /// Border radius (default: 12px)
  final double borderRadius;

  /// Icon size (default: 18px)
  final double iconSize;

  /// Label font size (default: 10px)
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // Background container color
    final containerColor = isDark
        ? AppColors.neutral800.withValues(alpha: 0.3)
        : AppColors.neutral200.withValues(alpha: 0.5);

    // Selected pill color
    final selectedColor =
        isDark ? AppColors.neutral700 : Colors.white;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = selectedValue == option.value;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                AppAnimations.lightHaptic();
                onSelectionChanged(option.value);
              },
              child: Semantics(
                button: true,
                selected: isSelected,
                label: '${option.label}${isSelected ? ', selected' : ''}',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(borderRadius - 2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: temporalTheme.shadowColor,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        option.icon,
                        size: iconSize,
                        color: isSelected
                            ? AppColors.text(context)
                            : AppColors.textSecondary(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.text(context)
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
