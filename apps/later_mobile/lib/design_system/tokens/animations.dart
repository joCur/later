import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Temporal Flow Design System - Animation Tokens
/// Physics-based animations with spring curves for natural motion
/// Supports reduced motion accessibility
class AppAnimations {
  AppAnimations._();

  // ============================================================
  // DURATION CONSTANTS (Temporal Flow timing)
  // ============================================================

  /// Instant: 50ms - Nearly instant feedback
  static const int instantMs = 50;

  /// Quick: 120ms - Very quick interactions
  static const int quickMs = 120;

  /// Normal: 250ms - Standard animations (PRIMARY)
  static const int normalMs = 250;

  /// Gentle: 400ms - Gentle, graceful motion
  static const int gentleMs = 400;

  /// Slow: 600ms - Slow, deliberate motion
  static const int slowMs = 600;

  // Duration objects
  /// Instant duration (50ms)
  static const Duration instant = Duration(milliseconds: instantMs);

  /// Quick duration (120ms)
  static const Duration quick = Duration(milliseconds: quickMs);

  /// Normal duration (250ms) - DEFAULT
  static const Duration normal = Duration(milliseconds: normalMs);

  /// Gentle duration (400ms)
  static const Duration gentle = Duration(milliseconds: gentleMs);

  /// Slow duration (600ms)
  static const Duration slow = Duration(milliseconds: slowMs);

  // ============================================================
  // SPRING PHYSICS CONFIGURATIONS
  // ============================================================

  /// Default spring for most interactions
  /// Mass: 1, Stiffness: 180, Damping: 12
  static const SpringDescription defaultSpring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 12.0,
  );

  /// Gentle spring for softer animations
  /// Mass: 1, Stiffness: 120, Damping: 14
  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 120.0,
    damping: 14.0,
  );

  /// Snappy spring for quick interactions
  /// Mass: 0.8, Stiffness: 220, Damping: 10
  static const SpringDescription snappySpring = SpringDescription(
    mass: 0.8,
    stiffness: 220.0,
    damping: 10.0,
  );

  /// Bouncy spring for playful interactions
  /// Mass: 1, Stiffness: 200, Damping: 8
  static const SpringDescription bouncySpring = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 8.0,
  );

  /// Smooth spring for fluid transitions
  /// Mass: 1.2, Stiffness: 150, Damping: 15
  static const SpringDescription smoothSpring = SpringDescription(
    mass: 1.2,
    stiffness: 150.0,
    damping: 15.0,
  );

  // ============================================================
  // ANIMATION CURVES (Spring-based)
  // ============================================================

  /// Standard spring curve for most animations
  static const Curve springCurve = _SpringCurve(defaultSpring);

  /// Gentle spring curve for soft animations
  static const Curve gentleSpringCurve = _SpringCurve(gentleSpring);

  /// Snappy spring curve for quick interactions
  static const Curve snappySpringCurve = _SpringCurve(snappySpring);

  /// Bouncy spring curve for playful interactions
  static const Curve bouncySpringCurve = _SpringCurve(bouncySpring);

  /// Smooth spring curve for fluid transitions
  static const Curve smoothSpringCurve = _SpringCurve(smoothSpring);

  // Legacy curves for gradual migration
  /// Standard easing curve (for non-spring contexts)
  static const Curve standardCurve = Curves.easeInOut;

  /// Deceleration curve (entering elements)
  static const Curve decelerateCurve = Curves.easeOut;

  /// Acceleration curve (exiting elements)
  static const Curve accelerateCurve = Curves.easeIn;

  /// Linear curve (for continuous animations)
  static const Curve linearCurve = Curves.linear;

  // ============================================================
  // COMPONENT-SPECIFIC ANIMATIONS
  // ============================================================

  // FAB Animations
  /// FAB press duration (120ms)
  static const Duration fabPress = quick;

  /// FAB release duration (250ms)
  static const Duration fabRelease = normal;

  /// FAB press scale (0.92)
  static const double fabPressScale = 0.92;

  /// FAB press spring
  static const SpringDescription fabPressSpring = snappySpring;

  /// FAB release spring
  static const SpringDescription fabReleaseSpring = bouncySpring;

  /// FAB icon rotation duration (250ms)
  static const Duration fabIconRotation = normal;

  /// FAB pulsing glow duration (2000ms for hint)
  static const Duration fabPulseGlow = Duration(milliseconds: 2000);

  // Modal/Dialog Animations
  /// Modal enter duration (250ms)
  static const Duration modalEnter = normal;

  /// Modal exit duration (120ms)
  static const Duration modalExit = quick;

  /// Modal backdrop fade duration (250ms)
  static const Duration modalBackdropFade = normal;

  /// Modal enter spring
  static const SpringDescription modalEnterSpring = smoothSpring;

  /// Modal exit spring
  static const SpringDescription modalExitSpring = snappySpring;

  /// Modal slide offset for entrance
  static const Offset modalSlideOffset = Offset(0, 0.15);

  /// Modal scale for entrance
  static const double modalScaleStart = 0.95;

  // Item Card Animations
  /// Item card tap duration (120ms)
  static const Duration itemTap = quick;

  /// Item card hover duration (50ms)
  static const Duration itemHover = instant;

  /// Item card entrance stagger delay (30ms per item for Phase 5 - faster than 50ms)
  static const Duration itemEntranceStagger = Duration(milliseconds: 30);

  /// Item card entrance duration (250ms)
  static const Duration itemEntrance = normal;

  /// Item card entrance spring
  static const SpringDescription itemEntranceSpring = defaultSpring;

  /// Item card entrance slide offset (8px distance for Phase 5 mobile-first)
  static const double itemEntranceSlideDistance = 8.0;

  /// Item card entrance scale
  static const double itemEntranceScale = 0.97;

  /// Item card press scale (0.98 for Phase 5 micro-interaction)
  static const double itemPressScale = 0.98;

  /// Item card press duration (100ms)
  static const Duration itemPress = Duration(milliseconds: 100);

  /// Item card release duration (150ms with spring back)
  static const Duration itemRelease = Duration(milliseconds: 150);

  // Completion Toggle Animation
  /// Completion toggle duration (250ms)
  static const Duration completionToggle = normal;

  /// Completion toggle spring
  static const SpringDescription completionToggleSpring = bouncySpring;

  /// Completion scale peak (1.1 before settling)
  static const double completionScalePeak = 1.1;

  /// Completion overlay fade duration (400ms)
  static const Duration completionOverlayFade = gentle;

  // Button Animations
  /// Button press duration (120ms)
  static const Duration buttonPress = quick;

  /// Button hover duration (50ms)
  static const Duration buttonHover = instant;

  /// Button press scale (0.96)
  static const double buttonPressScale = 0.96;

  /// Button press spring
  static const SpringDescription buttonPressSpring = snappySpring;

  // Input Field Animations
  /// Input focus duration (250ms)
  static const Duration inputFocus = normal;

  /// Input error shake duration (400ms)
  static const Duration inputError = gentle;

  /// Input focus spring
  static const SpringDescription inputFocusSpring = defaultSpring;

  /// Input label slide duration (250ms)
  static const Duration inputLabelSlide = normal;

  // Page Transitions
  /// Page transition duration (250ms)
  static const Duration pageTransition = normal;

  /// Page transition spring
  static const SpringDescription pageTransitionSpring = smoothSpring;

  /// Page transition fade duration (250ms)
  static const Duration pageTransitionFade = normal;

  // Space Switcher
  /// Space switch duration (120ms for quick feedback)
  static const Duration spaceSwitch = quick;

  /// Space switch spring
  static const SpringDescription spaceSwitchSpring = snappySpring;

  // Swipe Actions
  /// Swipe action reveal duration (250ms)
  static const Duration swipeActionReveal = normal;

  /// Swipe action spring
  static const SpringDescription swipeActionSpring = defaultSpring;

  // Loading & Shimmer
  /// Shimmer cycle duration (1500ms)
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  /// Loading spinner rotation duration (1000ms)
  static const Duration spinnerRotation = Duration(milliseconds: 1000);

  /// Skeleton pulse duration (2000ms)
  static const Duration skeletonPulse = Duration(milliseconds: 2000);

  // Snackbar/Toast Animations
  /// Snackbar enter duration (250ms)
  static const Duration snackbarEnter = normal;

  /// Snackbar exit duration (120ms)
  static const Duration snackbarExit = quick;

  /// Snackbar display time (3 seconds)
  static const Duration snackbarDisplay = Duration(seconds: 3);

  /// Snackbar spring
  static const SpringDescription snackbarSpring = defaultSpring;

  // List Animations
  /// List item insert duration (250ms)
  static const Duration listItemInsert = normal;

  /// List item remove duration (120ms)
  static const Duration listItemRemove = quick;

  /// List item spring
  static const SpringDescription listItemSpring = defaultSpring;

  // Navigation Animations
  /// Bottom navigation indicator duration (250ms)
  static const Duration navigationIndicator = normal;

  /// Bottom navigation spring
  static const SpringDescription navigationSpring = smoothSpring;

  /// Sidebar expand/collapse duration (250ms)
  static const Duration sidebarToggle = normal;

  /// Sidebar spring
  static const SpringDescription sidebarSpring = defaultSpring;

  // Pull to Refresh
  /// Pull to refresh indicator duration (400ms)
  static const Duration refreshIndicator = gentle;

  // Scroll Animations
  /// Scroll to top duration (600ms)
  static const Duration scrollToTop = slow;

  /// Scroll animation curve
  static const Curve scrollCurve = Curves.easeInOutCubic;

  // Hero Animations
  /// Hero transition duration (250ms)
  static const Duration heroTransition = normal;

  /// Hero spring
  static const SpringDescription heroSpring = smoothSpring;

  // Delete/Destructive Actions
  /// Delete animation duration (400ms)
  static const Duration deleteAction = gentle;

  /// Shake animation duration (400ms)
  static const Duration shakeAnimation = gentle;

  // Auto-save & Undo (timing-related)
  /// Auto-save debounce (500ms)
  static const Duration autoSaveDebounce = Duration(milliseconds: 500);

  /// Undo timeout (5 seconds)
  static const Duration undoTimeout = Duration(seconds: 5);

  // ============================================================
  // HAPTIC FEEDBACK INTEGRATION
  // ============================================================

  /// Check if haptic feedback is supported on this platform
  /// Haptics are supported on iOS and Android
  static bool supportsHaptics() {
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Conditionally trigger haptic feedback only on supported platforms
  static Future<void> conditionalHaptic(Future<void> Function() hapticFn) async {
    if (supportsHaptics()) {
      try {
        await hapticFn();
      } catch (e) {
        // Silently catch haptic errors (device may not support haptics)
        // This ensures the app doesn't crash on devices without haptic support
      }
    }
  }

  /// Light haptic feedback (for subtle interactions)
  /// Use for: button presses, minor UI feedback
  static Future<void> lightHaptic() async {
    await conditionalHaptic(() async {
      await HapticFeedback.lightImpact();
    });
  }

  /// Medium haptic feedback (for standard interactions)
  /// Use for: checkbox toggles, FAB presses, standard actions
  static Future<void> mediumHaptic() async {
    await conditionalHaptic(() async {
      await HapticFeedback.mediumImpact();
    });
  }

  /// Heavy haptic feedback (for important actions)
  /// Use for: swipe action completion, important confirmations
  static Future<void> heavyHaptic() async {
    await conditionalHaptic(() async {
      await HapticFeedback.heavyImpact();
    });
  }

  /// Selection haptic feedback (for navigation and selection changes)
  /// Use for: navigation tab changes, item selection
  static Future<void> selectionHaptic() async {
    await conditionalHaptic(() async {
      await HapticFeedback.selectionClick();
    });
  }

  /// Warning haptic feedback (for destructive or warning actions)
  /// Use for: delete actions, error states, warnings
  static Future<void> warningHaptic() async {
    await conditionalHaptic(() async {
      await HapticFeedback.vibrate();
    });
  }

  // ============================================================
  // ANIMATION BUILDERS (Spring-based)
  // ============================================================

  /// Fade in with scale animation (entrance)
  // ignore: strict_raw_type
  static List<Effect> fadeInWithScale({
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return [
      FadeEffect(
        duration: duration ?? normal,
        delay: delay,
        curve: curve ?? springCurve,
      ),
      ScaleEffect(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1.0, 1.0),
        duration: duration ?? normal,
        delay: delay,
        curve: curve ?? springCurve,
      ),
    ];
  }

  /// Slide up with fade animation (modal entrance)
  // ignore: strict_raw_type
  static List<Effect> slideUpWithFade({
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return [
      SlideEffect(
        begin: modalSlideOffset,
        end: Offset.zero,
        duration: duration ?? modalEnter,
        delay: delay,
        curve: curve ?? smoothSpringCurve,
      ),
      FadeEffect(
        duration: duration ?? modalEnter,
        delay: delay,
        curve: Curves.easeOut,
      ),
    ];
  }

  /// Scale pulse animation (for emphasis)
  // ignore: strict_raw_type
  static List<Effect> scalePulse({
    Duration? duration,
    double peak = 1.05,
  }) {
    final halfDuration = (duration ?? quick).inMilliseconds ~/ 2;
    return [
      ScaleEffect(
        begin: const Offset(1.0, 1.0),
        end: Offset(peak, peak),
        duration: Duration(milliseconds: halfDuration),
        curve: bouncySpringCurve,
      ),
      ScaleEffect(
        begin: Offset(peak, peak),
        end: const Offset(1.0, 1.0),
        duration: Duration(milliseconds: halfDuration),
        delay: Duration(milliseconds: halfDuration),
        curve: bouncySpringCurve,
      ),
    ];
  }

  /// Shake animation (for errors)
  // ignore: strict_raw_type
  static List<Effect> shake({
    Duration? duration,
    double intensity = 10.0,
  }) {
    return [
      ShakeEffect(
        duration: duration ?? inputError,
        hz: 4,
        offset: Offset(intensity, 0),
        curve: Curves.easeInOut,
      ),
    ];
  }

  /// Shimmer effect (for loading states)
  // ignore: strict_raw_type
  static List<Effect> shimmer({
    Duration? duration,
  }) {
    return [
      ShimmerEffect(
        duration: duration ?? shimmerDuration,
        color: Colors.white.withValues(alpha: 0.5),
        angle: 0,
      ),
    ];
  }

  // ============================================================
  // REDUCED MOTION SUPPORT
  // ============================================================

  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get duration with reduced motion support
  /// Returns instant duration if reduced motion is preferred
  static Duration getDuration(BuildContext context, Duration duration) {
    return prefersReducedMotion(context) ? instant : duration;
  }

  /// Get spring with reduced motion support
  /// Returns more damped spring if reduced motion is preferred
  static SpringDescription getSpring(
    BuildContext context,
    SpringDescription spring,
  ) {
    if (prefersReducedMotion(context)) {
      return SpringDescription(
        mass: spring.mass,
        stiffness: spring.stiffness * 1.5,
        damping: spring.damping * 1.5,
      );
    }
    return spring;
  }

}

// ============================================================
// SPRING CURVE IMPLEMENTATION
// ============================================================

/// Custom spring curve that uses physics simulation
class _SpringCurve extends Curve {
  const _SpringCurve(this.spring);

  final SpringDescription spring;

  @override
  double transform(double t) {
    final simulation = SpringSimulation(spring, 0.0, 1.0, 0.0);
    return simulation.x(t);
  }
}
