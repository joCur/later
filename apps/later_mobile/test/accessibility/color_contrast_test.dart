import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Accessibility Test Suite: Color Contrast Verification
///
/// Tests that all color combinations meet WCAG AA compliance standards:
/// - Text: 4.5:1 contrast ratio (normal text)
/// - Large text: 3:1 contrast ratio (18pt+ or 14pt+ bold)
/// - UI Components: 3:1 contrast ratio (borders, icons, states)
///
/// Focus areas:
/// - Gradient text readability (especially challenging with gradients)
/// - Button text on gradient backgrounds
/// - Input field text and borders
/// - Navigation text and icons
/// - Card content and metadata
/// - Dark mode variants
///
/// Success Criteria:
/// - All text ≥ 4.5:1 contrast
/// - Large text ≥ 3:1 contrast
/// - UI components ≥ 3:1 contrast
void main() {
  group('Color Contrast - Text on Solid Backgrounds', () {
    test('Primary text on light background meets WCAG AA', () {
      // Arrange: Primary text color on light background
      const textColor = AppColors.neutral600; // neutral600
      const bgColor = AppColors.neutral50; // neutral50

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(textColor, bgColor);

      // Assert: Should be at least 4.5:1 for normal text
      expect(
        ratio >= 4.5,
        isTrue,
        reason:
            'Primary text on light background should have ≥4.5:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Primary text on dark background meets WCAG AA', () {
      // Arrange: Primary text color on dark background
      const textColor = AppColors.neutral400; // neutral400
      const bgColor = AppColors.neutral950; // neutral950

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(textColor, bgColor);

      // Assert: Should be at least 4.5:1 for normal text
      expect(
        ratio >= 4.5,
        isTrue,
        reason:
            'Primary text on dark background should have ≥4.5:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Secondary text on light background meets WCAG AA', () {
      // Arrange: Secondary text color on light background
      const textColor = AppColors.neutral500; // neutral500
      const bgColor = AppColors.neutral50; // neutral50

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(textColor, bgColor);

      // Assert: Should be at least 4.5:1 for normal text
      expect(
        ratio >= 4.5,
        isTrue,
        reason:
            'Secondary text on light background should have ≥4.5:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Secondary text on dark background meets WCAG AA', () {
      // Arrange: Secondary text color on dark background
      const textColor = AppColors.neutral500; // neutral500
      const bgColor = AppColors.neutral950; // neutral950

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(textColor, bgColor);

      // Assert: Should be at least 4.5:1 for normal text
      expect(
        ratio >= 4.5,
        isTrue,
        reason:
            'Secondary text on dark background should have ≥4.5:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Disabled text provides adequate visual distinction', () {
      // Arrange: Disabled text colors
      const disabledLight = AppColors.neutral400; // neutral400
      const disabledDark = AppColors.neutral600; // neutral600
      const bgLight = AppColors.neutral50;
      const bgDark = AppColors.neutral950;

      // Act: Calculate contrast ratios
      final ratioLight = _calculateContrastRatio(disabledLight, bgLight);
      final ratioDark = _calculateContrastRatio(disabledDark, bgDark);

      // Assert: Disabled text should still have some contrast (≥3:1 recommended)
      // but doesn't need to meet full 4.5:1 as it's not actionable
      expect(
        ratioLight >= 3.0,
        isTrue,
        reason:
            'Disabled text on light background should have ≥3:1 contrast for visibility, got ${ratioLight.toStringAsFixed(2)}:1',
      );

      expect(
        ratioDark >= 3.0,
        isTrue,
        reason:
            'Disabled text on dark background should have ≥3:1 contrast for visibility, got ${ratioDark.toStringAsFixed(2)}:1',
      );
    });
  });

  group('Color Contrast - Buttons', () {
    test('Primary button white text on gradient background (light mode)', () {
      // Arrange: White text on primary gradient
      // For gradients, we test against both start and end colors
      const textColor = Colors.white;
      const gradientStart = AppColors.primaryStart;
      const gradientEnd = AppColors.primaryEnd;

      // Act: Calculate contrast ratios
      final ratioStart = _calculateContrastRatio(textColor, gradientStart);
      final ratioEnd = _calculateContrastRatio(textColor, gradientEnd);

      // Assert: Both should meet 4.5:1 for text
      expect(
        ratioStart >= 4.5,
        isTrue,
        reason:
            'White text on primary gradient start should have ≥4.5:1 contrast, got ${ratioStart.toStringAsFixed(2)}:1',
      );

      expect(
        ratioEnd >= 4.5,
        isTrue,
        reason:
            'White text on primary gradient end should have ≥4.5:1 contrast, got ${ratioEnd.toStringAsFixed(2)}:1',
      );
    });

    test('Primary button white text on gradient background (dark mode)', () {
      // Arrange: White text on dark mode primary gradient
      const textColor = Colors.white;
      const gradientStart = AppColors.primaryStartDark;
      const gradientEnd = AppColors.primaryEndDark;

      // Act: Calculate contrast ratios
      final ratioStart = _calculateContrastRatio(textColor, gradientStart);
      final ratioEnd = _calculateContrastRatio(textColor, gradientEnd);

      // Assert: Both should meet 4.5:1 for text
      expect(
        ratioStart >= 4.5,
        isTrue,
        reason:
            'White text on dark mode primary gradient start should have ≥4.5:1 contrast, got ${ratioStart.toStringAsFixed(2)}:1',
      );

      expect(
        ratioEnd >= 4.5,
        isTrue,
        reason:
            'White text on dark mode primary gradient end should have ≥4.5:1 contrast, got ${ratioEnd.toStringAsFixed(2)}:1',
      );
    });

    test('Secondary button text contrast (light mode)', () {
      // Arrange: Button text on surface
      const textColor = AppColors.neutral600;
      const bgColor = Colors.white;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(textColor, bgColor);

      // Assert: Should meet 4.5:1 for text
      expect(
        ratio >= 4.5,
        isTrue,
        reason:
            'Secondary button text should have ≥4.5:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Secondary button border contrast (light mode)', () {
      // Arrange: Primary color border on surface
      const borderColor = AppColors.primarySolid;
      const bgColor = Colors.white;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(borderColor, bgColor);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Secondary button border should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });
  });

  group('Color Contrast - Input Fields', () {
    test('Input field text on glass background (light mode)', () {
      // Arrange: Text on glass background
      const textColor = AppColors.neutral600;
      // Glass background is 3% opacity white on neutral50
      const bgColor = AppColors.neutral50;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(textColor, bgColor);

      // Assert: Should meet 4.5:1 for text
      expect(
        ratio >= 4.5,
        isTrue,
        reason:
            'Input text should have ≥4.5:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Input field placeholder text provides adequate contrast', () {
      // Arrange: Placeholder at 60% opacity
      // neutral500 at 60% opacity on neutral50 background
      final placeholderColor = AppColors.neutral500.withValues(alpha: 0.6);
      const bgColor = AppColors.neutral50;

      // Act: Calculate contrast ratio with alpha blending
      final blendedColor = _blendColors(placeholderColor, bgColor);
      final ratio = _calculateContrastRatio(blendedColor, bgColor);

      // Assert: Placeholder should have at least 3:1 (WCAG requirement for non-actionable text)
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Input placeholder should have ≥3:1 contrast for visibility, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Input field border (focus state) meets UI component contrast', () {
      // Arrange: Gradient border at 30% opacity
      final borderStart = AppColors.primaryStart.withValues(alpha: 0.3);
      const bgColor = Colors.white;

      // Act: Calculate contrast ratio
      final blendedColor = _blendColors(borderStart, bgColor);
      final ratio = _calculateContrastRatio(blendedColor, bgColor);

      // Assert: Border should have at least 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Input field focus border should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });
  });

  group('Color Contrast - Item Cards', () {
    test('Task card gradient border provides adequate contrast', () {
      // Arrange: Task gradient on card background
      const gradientStart = AppColors.taskGradientStart;
      const cardBg = Colors.white;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(gradientStart, cardBg);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Task card border should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Note card gradient border provides adequate contrast', () {
      // Arrange: Note gradient on card background
      const gradientStart = AppColors.noteGradientStart;
      const cardBg = Colors.white;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(gradientStart, cardBg);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Note card border should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('List card gradient border provides adequate contrast', () {
      // Arrange: List gradient on card background
      const gradientStart = AppColors.listGradientStart;
      const cardBg = Colors.white;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(gradientStart, cardBg);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'List card border should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Completed task opacity maintains readable text', () {
      // Arrange: Text at 70% opacity
      const textColor = AppColors.neutral600;
      const bgColor = Colors.white;
      const opacity = 0.7;

      // Act: Calculate contrast with opacity
      final fadedColor = textColor.withValues(alpha: opacity);
      final blendedColor = _blendColors(fadedColor, bgColor);
      final ratio = _calculateContrastRatio(blendedColor, bgColor);

      // Assert: Should maintain at least 3:1 for readability
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Completed task text should maintain ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });
  });

  group('Color Contrast - Semantic Colors', () {
    test('Success color meets contrast requirements', () {
      // Arrange: Success color on light background
      const successColor = AppColors.success;
      const bgColor = AppColors.neutral50;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(successColor, bgColor);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Success color should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Warning color meets contrast requirements', () {
      // Arrange: Warning color on light background
      const warningColor = AppColors.warning;
      const bgColor = AppColors.neutral50;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(warningColor, bgColor);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Warning color should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Error color meets contrast requirements', () {
      // Arrange: Error color on light background
      const errorColor = AppColors.error;
      const bgColor = AppColors.neutral50;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(errorColor, bgColor);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Error color should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });

    test('Info color meets contrast requirements', () {
      // Arrange: Info color on light background
      const infoColor = AppColors.info;
      const bgColor = AppColors.neutral50;

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(infoColor, bgColor);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Info color should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });
  });

  group('Color Contrast - Dark Mode Specific', () {
    test('Dark mode gradient text remains readable', () {
      // Arrange: Dark mode gradient colors on dark background
      const gradientStart = AppColors.primaryStartDark;
      const gradientEnd = AppColors.primaryEndDark;
      const bgColor = AppColors.neutral950;

      // Act: Calculate contrast ratios
      final ratioStart = _calculateContrastRatio(gradientStart, bgColor);
      final ratioEnd = _calculateContrastRatio(gradientEnd, bgColor);

      // Assert: Both should provide adequate contrast
      expect(
        ratioStart >= 3.0,
        isTrue,
        reason:
            'Dark mode gradient start should have ≥3:1 contrast, got ${ratioStart.toStringAsFixed(2)}:1',
      );

      expect(
        ratioEnd >= 3.0,
        isTrue,
        reason:
            'Dark mode gradient end should have ≥3:1 contrast, got ${ratioEnd.toStringAsFixed(2)}:1',
      );
    });

    test('Dark mode borders provide adequate contrast', () {
      // Arrange: Dark mode border on dark surface
      const borderColor = AppColors.neutral700; // neutral700
      const bgColor = AppColors.neutral900; // neutral900

      // Act: Calculate contrast ratio
      final ratio = _calculateContrastRatio(borderColor, bgColor);

      // Assert: Should meet 3:1 for UI components
      expect(
        ratio >= 3.0,
        isTrue,
        reason:
            'Dark mode borders should have ≥3:1 contrast, got ${ratio.toStringAsFixed(2)}:1',
      );
    });
  });
}

/// Calculate the contrast ratio between two colors
///
/// Based on WCAG 2.1 formula:
/// (L1 + 0.05) / (L2 + 0.05)
/// where L1 is the relative luminance of the lighter color
/// and L2 is the relative luminance of the darker color
///
/// Returns a value between 1 and 21
double _calculateContrastRatio(Color foreground, Color background) {
  final luminance1 = _getRelativeLuminance(foreground);
  final luminance2 = _getRelativeLuminance(background);

  final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
  final darker = luminance1 > luminance2 ? luminance2 : luminance1;

  return (lighter + 0.05) / (darker + 0.05);
}

/// Calculate the relative luminance of a color
///
/// Based on WCAG 2.1 formula:
/// L = 0.2126 * R + 0.7152 * G + 0.0722 * B
/// where R, G, and B are the linearized RGB components
double _getRelativeLuminance(Color color) {
  // Convert RGB to decimal (0-1)
  final r = (color.r * 255.0).round() / 255.0;
  final g = (color.g * 255.0).round() / 255.0;
  final b = (color.b * 255.0).round() / 255.0;

  // Linearize RGB components
  final rLinear = _linearizeComponent(r);
  final gLinear = _linearizeComponent(g);
  final bLinear = _linearizeComponent(b);

  // Calculate luminance
  return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
}

/// Linearize an RGB component value
///
/// If the value is <= 0.03928, divide by 12.92
/// Otherwise, apply the formula: ((value + 0.055) / 1.055) ^ 2.4
double _linearizeComponent(double component) {
  if (component <= 0.03928) {
    return component / 12.92;
  } else {
    return ((component + 0.055) / 1.055).pow(2.4);
  }
}

/// Blend a foreground color with a background color based on alpha
///
/// This is used to calculate the effective color when transparency is applied
Color _blendColors(Color foreground, Color background) {
  final alpha = (foreground.a * 255.0).round() / 255.0;
  final invAlpha = 1.0 - alpha;

  final fgRed = (foreground.r * 255.0).round();
  final fgGreen = (foreground.g * 255.0).round();
  final fgBlue = (foreground.b * 255.0).round();
  final bgRed = (background.r * 255.0).round();
  final bgGreen = (background.g * 255.0).round();
  final bgBlue = (background.b * 255.0).round();

  return Color.fromARGB(
    255,
    (fgRed * alpha + bgRed * invAlpha).round(),
    (fgGreen * alpha + bgGreen * invAlpha).round(),
    (fgBlue * alpha + bgBlue * invAlpha).round(),
  );
}

/// Extension to add pow method for double
extension on double {
  double pow(double exponent) {
    return dart_math.pow(this, exponent).toDouble();
  }
}
