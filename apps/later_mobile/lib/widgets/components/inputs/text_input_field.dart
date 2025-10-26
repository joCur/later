import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';

/// Single-line text input field component with Temporal Flow design system
///
/// Features:
/// - Glass background (3% opacity)
/// - Gradient border on focus (30% opacity)
/// - Glass effect overlay on focus (5% opacity)
/// - Focus shadow with gradient tint (8px blur, 20% opacity)
/// - Smooth focus/blur transitions (200ms)
/// - Border radius: 10px
/// - Padding: 12px horizontal, 12px vertical
/// - Error state with red gradient border
/// - Character counter with gradient warning colors
/// - Softer placeholder colors (60% opacity)
/// - States: default, focus, error, disabled
/// - Validation feedback support
/// - Auto-focus and keyboard actions support
/// - Accessibility: screen reader compatible
/// - Optional prefix/suffix icons
/// - Optional label (for cases like search fields, quick capture)
/// - External focus control via focusNode parameter
/// - Text capitalization support
class TextInputField extends StatefulWidget {
  const TextInputField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Field label (optional - omit for cases like search fields)
  final String? label;

  /// Placeholder text
  final String? hintText;

  /// Text controller
  final TextEditingController? controller;

  /// Initial value (if controller not provided)
  final String? initialValue;

  /// Called when text changes
  final ValueChanged<String>? onChanged;

  /// Called when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Validation function
  final FormFieldValidator<String>? validator;

  /// Error message to display
  final String? errorText;

  /// Whether field is enabled
  final bool enabled;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether to auto-focus on mount
  final bool autofocus;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action button
  final TextInputAction? textInputAction;

  /// Maximum text length
  final int? maxLength;

  /// Maximum number of lines (1 for single-line)
  final int maxLines;

  /// Icon to show at start of field
  final IconData? prefixIcon;

  /// Icon to show at end of field
  final IconData? suffixIcon;

  /// Callback when suffix icon is pressed
  final VoidCallback? onSuffixIconPressed;

  /// External focus node (optional - if not provided, internal one will be created)
  final FocusNode? focusNode;

  /// Text capitalization behavior
  final TextCapitalization textCapitalization;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();

    // Use provided focus node or create internal one
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_handleFocusChange);

    // Create internal controller if not provided
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }

    // Listen to text changes for character counter
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    // Only dispose focus node if we own it
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _controller.removeListener(_handleTextChange);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTextChange() {
    // Trigger rebuild for character counter
    if (widget.maxLength != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine if we should show error gradient
    final hasError = widget.errorText != null;

    // Determine gradient for border (30% opacity on focus as per plan)
    LinearGradient? borderGradient;
    if (hasError) {
      // Error gradient
      borderGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFFF87171), // red-400
                const Color(0xFFFBBF24), // yellow-400
              ]
            : [
                const Color(0xFFEF4444), // red-500
                const Color(0xFFFB923C), // orange-400
              ],
      );
    } else if (_isFocused) {
      // Focus gradient with 30% opacity
      final gradientColors = isDark
          ? [
              AppColors.primaryStartDark.withValues(alpha: 0.3),
              AppColors.primaryEndDark.withValues(alpha: 0.3),
            ]
          : [
              AppColors.primaryStart.withValues(alpha: 0.3),
              AppColors.primaryEnd.withValues(alpha: 0.3),
            ];
      borderGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      );
    }

    // Glass effect overlay on focus (5% opacity)
    Color? glassOverlay;
    if (_isFocused && !hasError) {
      glassOverlay = isDark
          ? AppColors.primaryStartDark.withValues(alpha: 0.05)
          : AppColors.primaryStart.withValues(alpha: 0.05);
    }

    // Glass background color (3% opacity)
    final backgroundColor = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.03)
        : AppColors.surfaceLight.withValues(alpha: 0.03);

    // Standard border color (when not focused)
    final standardBorderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    // Focus shadow
    List<BoxShadow>? boxShadow;
    if (_isFocused && !hasError) {
      final shadowColor = isDark
          ? AppColors.primaryEndDark.withValues(alpha: 0.2)
          : AppColors.primaryEnd.withValues(alpha: 0.2);
      boxShadow = [
        BoxShadow(
          color: shadowColor,
          blurRadius: 8.0,
          offset: const Offset(0, 2),
        ),
      ];
    }

    // Placeholder color (60% opacity)
    final hintColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
        : AppColors.textSecondaryLight.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (optional)
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxs),
            child: Text(
              widget.label!,
              style: AppTypography.labelMedium.copyWith(
                color: widget.enabled
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : (isDark
                        ? AppColors.textDisabledDark
                        : AppColors.textDisabledLight),
              ),
            ),
          ),

        // Input field with gradient border and smooth transitions
        AnimatedContainer(
          duration: AppAnimations.inputFocus, // 200ms transition
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            gradient: borderGradient,
            boxShadow: boxShadow,
          ),
          child: AnimatedContainer(
            duration: AppAnimations.inputFocus,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              border: borderGradient == null
                  ? Border.all(
                      color: standardBorderColor,
                    )
                  : null,
            ),
            // Add padding to create border effect when gradient is used
            padding: borderGradient != null
                ? const EdgeInsets.all(AppSpacing.borderWidthThin)
                : null,
            child: AnimatedContainer(
              duration: AppAnimations.inputFocus,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                // Blend glass overlay with background when focused
                color: glassOverlay != null
                    ? Color.alphaBlend(glassOverlay, backgroundColor)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(
                  AppSpacing.inputRadius - AppSpacing.borderWidthThin,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                obscureText: widget.obscureText,
                autofocus: widget.autofocus,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                textCapitalization: widget.textCapitalization,
                maxLines: widget.maxLines,
                style: AppTypography.input.copyWith(
                  color: widget.enabled
                      ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                      : (isDark
                          ? AppColors.textDisabledDark
                          : AppColors.textDisabledLight),
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTypography.input.copyWith(
                    color: hintColor,
                  ),
                  border: InputBorder.none,
                  // Updated padding: 12px horizontal, 12px vertical
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          size: 20,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          onPressed: widget.onSuffixIconPressed,
                        )
                      : null,
                ),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ),
          ),
        ),

        // Character counter or error message
        if (widget.errorText != null || widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xxxs,
              left: AppSpacing.xxs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Error message
                if (widget.errorText != null)
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),

                // Character counter
                if (widget.maxLength != null)
                  _buildCharacterCounter(isDark),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCharacterCounter(bool isDark) {
    final currentLength = _controller.text.length;
    final maxLength = widget.maxLength!;
    final percentage = currentLength / maxLength;
    final counterText = '$currentLength / $maxLength';

    // Warning gradient for >80%
    if (percentage > 0.8) {
      final errorGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFFF87171), // red-400
                const Color(0xFFFBBF24), // yellow-400
              ]
            : [
                const Color(0xFFEF4444), // red-500
                const Color(0xFFFB923C), // orange-400
              ],
      );

      return ShaderMask(
        shaderCallback: (bounds) => errorGradient.createShader(bounds),
        child: Text(
          counterText,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white, // Required for ShaderMask
            fontWeight: percentage > 0.9 ? FontWeight.bold : null,
          ),
        ),
      );
    }

    // Normal counter
    return Text(
      counterText,
      style: AppTypography.labelSmall.copyWith(
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }
}
