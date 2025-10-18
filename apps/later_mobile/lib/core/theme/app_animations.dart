import 'package:flutter/widgets.dart';

/// Animation constants for Later app
/// Defines durations, curves, and common animation patterns
class AppAnimations {
  AppAnimations._();

  // Duration constants (in milliseconds)
  static const int instantMs = 50; // Nearly instant
  static const int quickMs = 100; // Very quick
  static const int fastMs = 200; // Fast
  static const int normalMs = 300; // Standard
  static const int slowMs = 400; // Slow
  static const int slowerMs = 500; // Slower
  static const int sluggishMs = 800; // Very slow

  // Duration objects
  static const Duration instant = Duration(milliseconds: instantMs);
  static const Duration quick = Duration(milliseconds: quickMs);
  static const Duration fast = Duration(milliseconds: fastMs);
  static const Duration normal = Duration(milliseconds: normalMs);
  static const Duration slow = Duration(milliseconds: slowMs);
  static const Duration slower = Duration(milliseconds: slowerMs);
  static const Duration sluggish = Duration(milliseconds: sluggishMs);

  // Easing curves (Material Design motion)

  // Standard easing - used for most animations
  static const Curve standardCurve = Curves.easeInOut;

  // Emphasized easing - used for important state changes
  static const Curve emphasizedCurve = Curves.easeInOutCubic;

  // Deceleration - used for entering elements
  static const Curve decelerateCurve = Curves.easeOut;

  // Acceleration - used for exiting elements
  static const Curve accelerateCurve = Curves.easeIn;

  // Spring/bounce - used for playful interactions
  static const Curve springCurve = Curves.elasticOut;

  // Linear - used for continuous animations
  static const Curve linearCurve = Curves.linear;

  // Component-specific animation settings

  // FAB animations
  static const Duration fabPress = quick; // Scale down on press
  static const Duration fabRelease = fast; // Scale up on release
  static const Curve fabPressEasing = accelerateCurve;
  static const Curve fabReleaseEasing = springCurve;
  static const double fabPressScale = 0.95;

  // Modal/Dialog animations
  static const Duration modalEnter = normal; // 300ms slide up
  static const Duration modalExit = fast; // 200ms slide down
  static const Curve modalEnterEasing = decelerateCurve;
  static const Curve modalExitEasing = accelerateCurve;

  // Page transitions
  static const Duration pageTransition = normal; // 300ms
  static const Curve pageTransitionEasing = standardCurve;

  // Space switcher
  static const Duration spaceSwitchTarget = fast; // Target: <200ms
  static const Curve spaceSwitchEasing = emphasizedCurve;

  // Item card interactions
  static const Duration itemTap = quick; // 100ms ripple
  static const Duration itemHover = instant; // 50ms hover state
  static const Curve itemTapEasing = standardCurve;

  // Completion toggle animation
  static const Duration completionToggle = fast; // 200ms
  static const Curve completionToggleEasing = springCurve;
  static const double completionScalePeak = 1.05; // Brief scale up before settling

  // Button animations
  static const Duration buttonPress = quick;
  static const Duration buttonHover = instant;
  static const Curve buttonEasing = standardCurve;

  // Input field animations
  static const Duration inputFocus = fast;
  static const Duration inputError = normal;
  static const Curve inputEasing = standardCurve;

  // Snackbar/Toast animations
  static const Duration snackbarEnter = normal;
  static const Duration snackbarExit = fast;
  static const Duration snackbarDisplay = Duration(seconds: 3);

  // List animations
  static const Duration listItemInsert = normal;
  static const Duration listItemRemove = fast;
  static const Curve listItemEasing = emphasizedCurve;

  // Skeleton loader shimmer
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Curve shimmerEasing = linearCurve;

  // Pull to refresh
  static const Duration refreshIndicator = sluggish;

  // Scroll animations
  static const Duration scrollToTop = slow;
  static const Curve scrollEasing = emphasizedCurve;

  // Opacity fade
  static const Duration fadeIn = normal;
  static const Duration fadeOut = fast;
  static const Curve fadeEasing = linearCurve;

  // Scale animations (for emphasis)
  static const Duration scaleUp = fast;
  static const Duration scaleDown = quick;
  static const Curve scaleEasing = emphasizedCurve;

  // Slide animations
  static const Duration slideIn = normal;
  static const Duration slideOut = fast;
  static const Curve slideInEasing = decelerateCurve;
  static const Curve slideOutEasing = accelerateCurve;

  // Rotation (for loading spinners)
  static const Duration rotationFull = Duration(milliseconds: 1000);
  static const Curve rotationEasing = linearCurve;

  // Hero animations (for detail screen transitions)
  static const Duration heroTransition = normal;
  static const Curve heroEasing = emphasizedCurve;

  // Auto-save debounce (not an animation, but timing-related)
  static const Duration autoSaveDebounce = Duration(milliseconds: 500);

  // Undo timeout
  static const Duration undoTimeout = Duration(seconds: 5);

  // Common animation builders

  /// Creates a standard fade transition
  static Widget fadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Creates a slide from bottom transition (for modals)
  static Widget slideFromBottomTransition(
    Animation<double> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: modalEnterEasing,
      )),
      child: child,
    );
  }

  /// Creates a scale transition (for emphasis)
  static Widget scaleTransition(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
