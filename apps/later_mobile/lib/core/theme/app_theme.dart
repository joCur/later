import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Temporal Flow Design System - Theme Configuration
/// Integrates colors, typography, spacing, and animations into Material ThemeData
/// Supports gradient-infused design with glass morphism and soft shadows
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    final colorScheme = AppColors.lightColorScheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,

      // Typography - Using Google Fonts Inter
      textTheme: AppTypography.themedTextTheme(
        primaryText: AppColors.neutral600,
        headingText: AppColors.neutral700,
        secondaryText: AppColors.neutral500,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.neutral700,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.neutral700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
      ),

      // Card theme - 12px radius, subtle border
      cardTheme: CardThemeData(
        color: Colors.white,
        margin: const EdgeInsets.all(AppSpacing.cardSpacing),
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(
            color: AppColors.neutral200,
          ),
        ),
      ),

      // Elevated Button - Primary gradient (will need custom widget for gradient)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySolid,
          foregroundColor: Colors.white,
          shadowColor: AppColors.primarySolid.withValues(alpha: 0.3),
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontalMedium,
            vertical: AppSpacing.buttonPaddingVerticalMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          minimumSize: const Size(0, AppSpacing.touchTargetMedium),
        ),
      ),

      // Outlined Button - Subtle border with glass hover
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neutral700,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontalMedium,
            vertical: AppSpacing.buttonPaddingVerticalMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          side: const BorderSide(
            color: AppColors.neutral200,
          ),
          minimumSize: const Size(0, AppSpacing.touchTargetMedium),
        ),
      ),

      // Text Button - Ghost button style
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primarySolid,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontalMedium,
            vertical: AppSpacing.buttonPaddingVerticalMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          minimumSize: const Size(0, AppSpacing.touchTargetMedium),
        ),
      ),

      // FAB theme - Squircle shape (64×64px)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primarySolid,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevation3,
        focusElevation: AppSpacing.elevation4,
        hoverElevation: AppSpacing.elevation4,
        highlightElevation: AppSpacing.elevation6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: AppSpacing.fabSize,
          height: AppSpacing.fabSize,
        ),
      ),

      // Input decoration theme - Glass effect with gradient border on focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.neutral200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.neutral200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primarySolid,
            width: AppSpacing.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderWidthMedium,
          ),
        ),
        hintStyle: AppTypography.input.copyWith(
          color: AppColors.neutral400,
        ),
        labelStyle: AppTypography.inputLabel.copyWith(
          color: AppColors.neutral500,
        ),
        floatingLabelStyle: AppTypography.inputLabel.copyWith(
          color: AppColors.primarySolid,
        ),
      ),

      // Chip theme - Rounded pills
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        side: BorderSide.none,
      ),

      // Dialog theme - Glass morphism effect
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.glassLight,
        elevation: AppSpacing.elevation8,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
          side: const BorderSide(
            color: AppColors.glassBorderLight,
          ),
        ),
      ),

      // Bottom sheet theme - Glass morphism
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.glassLight,
        elevation: AppSpacing.elevation8,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.modalRadius),
          ),
          side: BorderSide(
            color: AppColors.glassBorderLight,
          ),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        elevation: AppSpacing.elevation6,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: AppSpacing.borderWidthThin,
        space: AppSpacing.sm,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.neutral700,
        size: 24,
      ),

      // Checkbox theme - Success gradient on checked
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColors.neutral300;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(
          color: AppColors.neutral400,
          width: AppSpacing.borderWidthMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySolid;
          }
          return AppColors.neutral400;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.neutral300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySolid;
          }
          return AppColors.neutral200;
        }),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.listItemPadding,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primarySolid,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      ),

      // Splash and highlight colors
      splashColor: AppColors.rippleLight,
      highlightColor: AppColors.selectedLight,
      hoverColor: AppColors.selectedLight,
      focusColor: AppColors.selectedLight,

      // Page transitions (will use custom spring animations)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    final colorScheme = AppColors.darkColorScheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral950,

      // Typography
      textTheme: AppTypography.themedTextTheme(
        primaryText: AppColors.neutral400,
        headingText: AppColors.neutral300,
        secondaryText: AppColors.neutral500,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral950,
        foregroundColor: AppColors.neutral300,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.neutral300,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        scrolledUnderElevation: 0,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.neutral900,
        margin: const EdgeInsets.all(AppSpacing.cardSpacing),
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(
            color: AppColors.neutral700,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySolid,
          foregroundColor: Colors.white,
          shadowColor: AppColors.primarySolid.withValues(alpha: 0.3),
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontalMedium,
            vertical: AppSpacing.buttonPaddingVerticalMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          minimumSize: const Size(0, AppSpacing.touchTargetMedium),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neutral300,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontalMedium,
            vertical: AppSpacing.buttonPaddingVerticalMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          side: const BorderSide(
            color: AppColors.neutral700,
          ),
          minimumSize: const Size(0, AppSpacing.touchTargetMedium),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryStartDark,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontalMedium,
            vertical: AppSpacing.buttonPaddingVerticalMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          minimumSize: const Size(0, AppSpacing.touchTargetMedium),
        ),
      ),

      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primarySolid,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevation3,
        focusElevation: AppSpacing.elevation4,
        hoverElevation: AppSpacing.elevation4,
        highlightElevation: AppSpacing.elevation6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: AppSpacing.fabSize,
          height: AppSpacing.fabSize,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral800.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.neutral700,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.neutral700,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryStartDark,
            width: AppSpacing.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderWidthMedium,
          ),
        ),
        hintStyle: AppTypography.input.copyWith(
          color: AppColors.neutral600,
        ),
        labelStyle: AppTypography.inputLabel.copyWith(
          color: AppColors.neutral500,
        ),
        floatingLabelStyle: AppTypography.inputLabel.copyWith(
          color: AppColors.primaryStartDark,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral800,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.neutral400,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        side: BorderSide.none,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.glassDark,
        elevation: AppSpacing.elevation8,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
          side: const BorderSide(
            color: AppColors.glassBorderDark,
          ),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.glassDark,
        elevation: AppSpacing.elevation8,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.modalRadius),
          ),
          side: BorderSide(
            color: AppColors.glassBorderDark,
          ),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.neutral200,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        elevation: AppSpacing.elevation6,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral700,
        thickness: AppSpacing.borderWidthThin,
        space: AppSpacing.sm,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.neutral300,
        size: 24,
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColors.neutral700;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(
          color: AppColors.neutral600,
          width: AppSpacing.borderWidthMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySolid;
          }
          return AppColors.neutral600;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.neutral700;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySolid;
          }
          return AppColors.neutral800;
        }),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.listItemPadding,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primarySolid,
        linearTrackColor: AppColors.neutral800,
        circularTrackColor: AppColors.neutral800,
      ),

      // Splash and highlight colors
      splashColor: AppColors.rippleDark,
      highlightColor: AppColors.selectedDark,
      hoverColor: AppColors.selectedDark,
      focusColor: AppColors.selectedDark,

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
