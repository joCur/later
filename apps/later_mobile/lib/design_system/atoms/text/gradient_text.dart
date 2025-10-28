import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// A text widget that applies a gradient shader to its content.
///
/// The [GradientText] widget uses a [ShaderMask] to apply gradient colors
/// to text, creating visually distinctive headings and labels that align
/// with the Temporal Flow design system.
///
/// By default, uses the theme-adaptive primary gradient. Custom gradients
/// can be provided via the [gradient] parameter.
///
/// Example usage:
/// ```dart
/// GradientText('Hello World')
/// GradientText('Styled', style: AppTypography.displayLarge)
/// GradientText('Custom', gradient: myGradient)
/// GradientText.primary('Primary Gradient')
/// GradientText.subtle('Metadata')
/// ```
///
/// Accessibility notes:
/// - Gradient text maintains semantic meaning for screen readers
/// - All gradients meet WCAG AA contrast requirements (3:1 for large text)
/// - Adapts to light/dark mode automatically
/// - Supports text scaling up to 2.0x
class GradientText extends StatelessWidget {
  /// Creates a gradient text with the primary gradient (indigo → purple).
  ///
  /// This is the default brand gradient, ideal for:
  /// - App name "later"
  /// - Primary headings
  /// - Hero text
  /// - Call-to-action labels
  ///
  /// Adapts to light/dark mode automatically.
  factory GradientText.primary(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GradientText(
      text,
      key: key,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a gradient text with the secondary gradient (amber → pink).
  ///
  /// Ideal for:
  /// - Secondary headings
  /// - Accent labels
  /// - Special metadata
  /// - Promotional content
  ///
  /// Adapts to light/dark mode automatically.
  factory GradientText.secondary(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GradientText(
      text,
      key: key,
      gradient: AppColors.secondaryGradient,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a gradient text with the task gradient (red → orange).
  ///
  /// Ideal for:
  /// - Task count labels
  /// - Task-specific headings
  /// - Urgent action indicators
  factory GradientText.task(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GradientText(
      text,
      key: key,
      gradient: AppColors.taskGradient,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a gradient text with the note gradient (blue → cyan).
  ///
  /// Ideal for:
  /// - Note count labels
  /// - Note-specific headings
  /// - Knowledge indicators
  factory GradientText.note(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GradientText(
      text,
      key: key,
      gradient: AppColors.noteGradient,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a gradient text with the list gradient (violet).
  ///
  /// Ideal for:
  /// - List count labels
  /// - List-specific headings
  /// - Organization indicators
  factory GradientText.list(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return GradientText(
      text,
      key: key,
      gradient: AppColors.listGradient,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a gradient text with reduced opacity for subtle emphasis.
  ///
  /// Ideal for:
  /// - Metadata (timestamps, counts)
  /// - Secondary information
  /// - Subtle accents
  /// - Footer text
  ///
  /// Applies 50% opacity to the gradient colors to ensure readability
  /// while maintaining visual interest.
  factory GradientText.subtle(
    String text, {
    Key? key,
    Gradient? gradient,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    // Create a subtle version by reducing opacity of gradient colors
    final baseGradient = gradient ?? AppColors.primaryGradient;

    Gradient subtleGradient;
    if (baseGradient is LinearGradient) {
      subtleGradient = LinearGradient(
        begin: baseGradient.begin,
        end: baseGradient.end,
        colors: baseGradient.colors
            .map((color) => color.withValues(alpha: color.a * 0.5))
            .toList(),
        stops: baseGradient.stops,
        tileMode: baseGradient.tileMode,
      );
    } else if (baseGradient is RadialGradient) {
      final radialGradient = baseGradient;
      subtleGradient = RadialGradient(
        center: radialGradient.center,
        radius: radialGradient.radius,
        colors: radialGradient.colors
            .map((color) => color.withValues(alpha: color.a * 0.5))
            .toList(),
        stops: radialGradient.stops,
        tileMode: radialGradient.tileMode,
      );
    } else {
      // Fallback for other gradient types
      subtleGradient = baseGradient;
    }

    return GradientText(
      text,
      key: key,
      gradient: subtleGradient,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a gradient text widget.
  ///
  /// The [text] parameter is required and specifies the text content.
  ///
  /// If [gradient] is null, the theme-adaptive primary gradient is used.
  const GradientText(
    this.text, {
    super.key,
    this.gradient,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// The text to display with gradient.
  final String text;

  /// The gradient to apply to the text.
  ///
  /// If null, uses [AppColors.primaryGradientAdaptive] which adapts
  /// to the current theme brightness (light/dark mode).
  final Gradient? gradient;

  /// The text style to apply.
  ///
  /// The gradient shader is applied on top of this style.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// An optional maximum number of lines for the text to span.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    // Get theme-adaptive gradient
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final effectiveGradient = gradient ?? temporalTheme.primaryGradient;

    return ShaderMask(
      shaderCallback: (bounds) => effectiveGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
