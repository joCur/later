import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/tokens/colors.dart';

void main() {
  group('TemporalFlowTheme', () {
    group('Factory Constructors', () {
      test('light() creates theme with light mode colors', () {
        final theme = TemporalFlowTheme.light();

        expect(theme.primaryGradient, equals(AppColors.primaryGradient));
        expect(theme.secondaryGradient, equals(AppColors.secondaryGradient));
        expect(theme.taskGradient, equals(AppColors.taskGradient));
        expect(theme.noteGradient, equals(AppColors.noteGradient));
        expect(theme.listGradient, equals(AppColors.listGradient));
        expect(theme.glassBackground, equals(AppColors.glassLight));
        expect(theme.glassBorder, equals(AppColors.glassBorderLight));
        expect(theme.taskColor, equals(AppColors.taskColor));
        expect(theme.noteColor, equals(AppColors.noteColor));
        expect(theme.listColor, equals(AppColors.listColor));
        expect(theme.shadowColor, equals(AppColors.shadowLight));
      });

      test('dark() creates theme with dark mode colors', () {
        final theme = TemporalFlowTheme.dark();

        expect(theme.primaryGradient, equals(AppColors.primaryGradientDark));
        expect(
          theme.secondaryGradient,
          equals(AppColors.secondaryGradientDark),
        );
        expect(theme.taskGradient, equals(AppColors.taskGradient));
        expect(theme.noteGradient, equals(AppColors.noteGradient));
        expect(theme.listGradient, equals(AppColors.listGradient));
        expect(theme.glassBackground, equals(AppColors.glassDark));
        expect(theme.glassBorder, equals(AppColors.glassBorderDark));
        expect(theme.taskColor, equals(AppColors.taskColor));
        expect(theme.noteColor, equals(AppColors.noteColor));
        expect(theme.listColor, equals(AppColors.listColor));
        expect(theme.shadowColor, equals(AppColors.shadowDark));
      });
    });

    group('copyWith', () {
      test('copyWith() returns new instance with same values when no args', () {
        final original = TemporalFlowTheme.light();
        final copied = original.copyWith();

        expect(copied.primaryGradient, equals(original.primaryGradient));
        expect(copied.secondaryGradient, equals(original.secondaryGradient));
        expect(copied.taskGradient, equals(original.taskGradient));
        expect(copied.noteGradient, equals(original.noteGradient));
        expect(copied.listGradient, equals(original.listGradient));
        expect(copied.glassBackground, equals(original.glassBackground));
        expect(copied.glassBorder, equals(original.glassBorder));
        expect(copied.taskColor, equals(original.taskColor));
        expect(copied.noteColor, equals(original.noteColor));
        expect(copied.listColor, equals(original.listColor));
        expect(copied.shadowColor, equals(original.shadowColor));
      });

      test('copyWith() updates only specified properties', () {
        final original = TemporalFlowTheme.light();
        const customGradient = LinearGradient(
          colors: [Colors.red, Colors.blue],
        );
        const customColor = Colors.green;

        final modified = original.copyWith(
          primaryGradient: customGradient,
          glassBackground: customColor,
        );

        expect(modified.primaryGradient, equals(customGradient));
        expect(modified.glassBackground, equals(customColor));
        // Other properties should remain unchanged
        expect(modified.secondaryGradient, equals(original.secondaryGradient));
        expect(modified.taskGradient, equals(original.taskGradient));
        expect(modified.glassBorder, equals(original.glassBorder));
      });
    });

    group('lerp', () {
      test('lerp() at t=0.0 returns first theme', () {
        final light = TemporalFlowTheme.light();
        final dark = TemporalFlowTheme.dark();

        final result = light.lerp(dark, 0.0);

        expect(result.glassBackground, equals(light.glassBackground));
        expect(result.glassBorder, equals(light.glassBorder));
        expect(result.shadowColor, equals(light.shadowColor));
      });

      test('lerp() at t=1.0 returns second theme', () {
        final light = TemporalFlowTheme.light();
        final dark = TemporalFlowTheme.dark();

        final result = light.lerp(dark, 1.0);

        expect(result.glassBackground, equals(dark.glassBackground));
        expect(result.glassBorder, equals(dark.glassBorder));
        expect(result.shadowColor, equals(dark.shadowColor));
      });

      test('lerp() at t=0.5 produces interpolated values', () {
        final light = TemporalFlowTheme.light();
        final dark = TemporalFlowTheme.dark();

        final result = light.lerp(dark, 0.5);

        // Check that interpolated colors are between light and dark
        expect(
          result.glassBackground,
          equals(Color.lerp(light.glassBackground, dark.glassBackground, 0.5)),
        );
        expect(
          result.glassBorder,
          equals(Color.lerp(light.glassBorder, dark.glassBorder, 0.5)),
        );
        expect(
          result.shadowColor,
          equals(Color.lerp(light.shadowColor, dark.shadowColor, 0.5)),
        );
      });

      test('lerp() properly interpolates gradients', () {
        final light = TemporalFlowTheme.light();
        final dark = TemporalFlowTheme.dark();

        final result = light.lerp(dark, 0.5);

        // Verify that gradients are interpolated (not null)
        expect(result.primaryGradient, isNotNull);
        expect(result.secondaryGradient, isNotNull);
        expect(result.taskGradient, isNotNull);
        expect(result.noteGradient, isNotNull);
        expect(result.listGradient, isNotNull);

        // Check that gradients have the same structure
        expect(
          result.primaryGradient.colors.length,
          equals(light.primaryGradient.colors.length),
        );
      });

      test('lerp() with null returns this', () {
        final theme = TemporalFlowTheme.light();

        final result = theme.lerp(null, 0.5);

        expect(result, equals(theme));
      });

      test('lerp() handles extreme t values without errors', () {
        final light = TemporalFlowTheme.light();
        final dark = TemporalFlowTheme.dark();

        // Test t < 0 - should not throw
        expect(() => light.lerp(dark, -0.5), returnsNormally);

        // Test t > 1 - should not throw
        expect(() => light.lerp(dark, 1.5), returnsNormally);

        // Verify result is valid (non-null colors)
        final resultNegative = light.lerp(dark, -0.5);
        expect(resultNegative.glassBackground, isNotNull);

        final resultOverOne = light.lerp(dark, 1.5);
        expect(resultOverOne.glassBackground, isNotNull);
      });
    });

    group('Gradient Properties', () {
      test('gradients maintain correct color stops', () {
        final theme = TemporalFlowTheme.light();

        // Verify that gradients have two colors
        expect(theme.primaryGradient.colors.length, equals(2));
        expect(theme.secondaryGradient.colors.length, equals(2));
        expect(theme.taskGradient.colors.length, equals(2));
        expect(theme.noteGradient.colors.length, equals(2));
        expect(theme.listGradient.colors.length, equals(2));

        // Verify gradient begin/end alignment
        expect(
          theme.primaryGradient.begin,
          equals(AppColors.primaryGradient.begin),
        );
        expect(
          theme.primaryGradient.end,
          equals(AppColors.primaryGradient.end),
        );
      });

      test('type-specific gradients are theme-independent', () {
        final light = TemporalFlowTheme.light();
        final dark = TemporalFlowTheme.dark();

        // Task, note, and list gradients should be same in both themes
        expect(light.taskGradient, equals(dark.taskGradient));
        expect(light.noteGradient, equals(dark.noteGradient));
        expect(light.listGradient, equals(dark.listGradient));
      });

      test('type-specific colors are theme-independent', () {
        final light = TemporalFlowTheme.light();
        final dark = TemporalFlowTheme.dark();

        // Task, note, and list colors should be same in both themes
        expect(light.taskColor, equals(dark.taskColor));
        expect(light.noteColor, equals(dark.noteColor));
        expect(light.listColor, equals(dark.listColor));
      });
    });
  });
}
