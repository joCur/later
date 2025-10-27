import 'package:flutter/material.dart';
import '../../design_system/tokens/colors.dart';

/// Theme extension for custom Temporal Flow design tokens
/// Provides gradient-based color system with automatic light/dark mode handling
class TemporalFlowTheme extends ThemeExtension<TemporalFlowTheme> {

  /// Creates a TemporalFlowTheme with all required properties
  const TemporalFlowTheme({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.taskGradient,
    required this.noteGradient,
    required this.listGradient,
    required this.glassBackground,
    required this.glassBorder,
    required this.taskColor,
    required this.noteColor,
    required this.listColor,
    required this.shadowColor,
  });

  /// Light theme factory constructor
  factory TemporalFlowTheme.light() {
    return const TemporalFlowTheme(
      primaryGradient: AppColors.primaryGradient,
      secondaryGradient: AppColors.secondaryGradient,
      taskGradient: AppColors.taskGradient,
      noteGradient: AppColors.noteGradient,
      listGradient: AppColors.listGradient,
      glassBackground: AppColors.glassLight,
      glassBorder: AppColors.glassBorderLight,
      taskColor: AppColors.taskColor,
      noteColor: AppColors.noteColor,
      listColor: AppColors.listColor,
      shadowColor: AppColors.shadowLight,
    );
  }

  /// Dark theme factory constructor
  factory TemporalFlowTheme.dark() {
    return const TemporalFlowTheme(
      primaryGradient: AppColors.primaryGradientDark,
      secondaryGradient: AppColors.secondaryGradientDark,
      taskGradient: AppColors.taskGradient,
      noteGradient: AppColors.noteGradient,
      listGradient: AppColors.listGradient,
      glassBackground: AppColors.glassDark,
      glassBorder: AppColors.glassBorderDark,
      taskColor: AppColors.taskColor,
      noteColor: AppColors.noteColor,
      listColor: AppColors.listColor,
      shadowColor: AppColors.shadowDark,
    );
  }
  /// Main brand gradient (indigo → purple)
  final LinearGradient primaryGradient;

  /// Secondary brand gradient (amber → pink)
  final LinearGradient secondaryGradient;

  /// Task-specific gradient (red → orange)
  final LinearGradient taskGradient;

  /// Note-specific gradient (blue → cyan)
  final LinearGradient noteGradient;

  /// List-specific gradient (violet → violet)
  final LinearGradient listGradient;

  /// Glassmorphism background color
  final Color glassBackground;

  /// Glassmorphism border color
  final Color glassBorder;

  /// Task accent color
  final Color taskColor;

  /// Note accent color
  final Color noteColor;

  /// List accent color
  final Color listColor;

  /// Shadow color for elevation effects
  final Color shadowColor;

  @override
  TemporalFlowTheme copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    LinearGradient? taskGradient,
    LinearGradient? noteGradient,
    LinearGradient? listGradient,
    Color? glassBackground,
    Color? glassBorder,
    Color? taskColor,
    Color? noteColor,
    Color? listColor,
    Color? shadowColor,
  }) {
    return TemporalFlowTheme(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      taskGradient: taskGradient ?? this.taskGradient,
      noteGradient: noteGradient ?? this.noteGradient,
      listGradient: listGradient ?? this.listGradient,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      taskColor: taskColor ?? this.taskColor,
      noteColor: noteColor ?? this.noteColor,
      listColor: listColor ?? this.listColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  TemporalFlowTheme lerp(ThemeExtension<TemporalFlowTheme>? other, double t) {
    if (other is! TemporalFlowTheme) {
      return this;
    }

    return TemporalFlowTheme(
      primaryGradient: LinearGradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      secondaryGradient: LinearGradient.lerp(
        secondaryGradient,
        other.secondaryGradient,
        t,
      )!,
      taskGradient: LinearGradient.lerp(taskGradient, other.taskGradient, t)!,
      noteGradient: LinearGradient.lerp(noteGradient, other.noteGradient, t)!,
      listGradient: LinearGradient.lerp(listGradient, other.listGradient, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      taskColor: Color.lerp(taskColor, other.taskColor, t)!,
      noteColor: Color.lerp(noteColor, other.noteColor, t)!,
      listColor: Color.lerp(listColor, other.listColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}
