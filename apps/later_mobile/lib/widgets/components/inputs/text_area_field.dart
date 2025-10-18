import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Multiline text input field component (text area)
///
/// Features:
/// - States: default, focus, error, disabled
/// - Border radius: 6px (radius-sm)
/// - Focus: primary border with 0 2px 4px shadow
/// - Configurable min/max lines
/// - Validation feedback support
/// - Accessibility: screen reader compatible
class TextAreaField extends StatefulWidget {
  const TextAreaField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 8,
  });

  /// Field label
  final String label;

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

  /// Whether to auto-focus on mount
  final bool autofocus;

  /// Maximum text length
  final int? maxLength;

  /// Minimum number of lines to display
  final int minLines;

  /// Maximum number of lines (null for unlimited)
  final int? maxLines;

  @override
  State<TextAreaField> createState() => _TextAreaFieldState();
}

class _TextAreaFieldState extends State<TextAreaField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine border color based on state
    Color borderColor;
    if (widget.errorText != null) {
      borderColor = AppColors.error;
    } else if (_isFocused) {
      borderColor = AppColors.primaryAmber;
    } else if (!widget.enabled) {
      borderColor = isDark ? AppColors.neutralGray700 : AppColors.neutralGray300;
    } else {
      borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    }

    // Background color
    final backgroundColor = widget.enabled
        ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
        : (isDark ? AppColors.surfaceDarkVariant : AppColors.surfaceLightVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxs),
          child: Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: widget.enabled
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                  : (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight),
            ),
          ),
        ),

        // Input field
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? AppSpacing.borderWidthMedium : AppSpacing.borderWidthThin,
            ),
            boxShadow: _isFocused && widget.errorText == null
                ? [
                    BoxShadow(
                      color: AppColors.primaryAmber.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLength: widget.maxLength,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: AppTypography.input.copyWith(
              color: widget.enabled
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                  : (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight),
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.input.copyWith(
                color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.inputPaddingHorizontal,
                vertical: AppSpacing.inputPaddingVertical,
              ),
              counterText: '', // Hide character counter
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),

        // Error message
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xxxs,
              left: AppSpacing.xxs,
            ),
            child: Text(
              widget.errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
