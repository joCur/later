import 'package:flutter/material.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';

/// Temporal Flow page transitions with shared axis and gradient fade effects
///
/// Provides custom page route transitions that align with the Temporal Flow design system.
/// All transitions use spring physics and gradient overlays for smooth, branded navigation.

/// Shared axis page route with gradient fade overlay
///
/// The entering page slides in from the right while fading in.
/// The exiting page slides out to the left while fading out.
/// A gradient overlay provides a smooth transition between pages.
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  SharedAxisPageRoute({
    required Widget page,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppAnimations.pageTransition,
          reverseTransitionDuration: AppAnimations.pageTransition,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            // Check for reduced motion preference
            final reducedMotion = AppAnimations.prefersReducedMotion(context);
            if (reducedMotion) {
              // Instant transition for reduced motion
              return child;
            }

            return _SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

/// Internal widget for shared axis transition effects
class _SharedAxisTransition extends StatelessWidget {
  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Entering page animation
    final enterSlide = Tween<Offset>(
      begin: const Offset(0.3, 0.0), // Slide in from right (30%)
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppAnimations.springCurve,
      ),
    );

    final enterFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      ),
    );

    // Exiting page animation
    final exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0), // Slide out to left (30%)
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: AppAnimations.springCurve,
      ),
    );

    final exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOut,
      ),
    );

    // Gradient overlay during transition
    final gradientOverlay = _buildGradientOverlay(
      context,
      animation,
      isDark,
    );

    // Build the transition
    return Stack(
      children: [
        // Exiting page (if any)
        if (secondaryAnimation.status != AnimationStatus.dismissed)
          SlideTransition(
            position: exitSlide,
            child: FadeTransition(
              opacity: exitFade,
              child: child,
            ),
          ),

        // Gradient overlay
        if (animation.status != AnimationStatus.completed) gradientOverlay,

        // Entering page
        SlideTransition(
          position: enterSlide,
          child: FadeTransition(
            opacity: enterFade,
            child: child,
          ),
        ),
      ],
    );
  }

  /// Build gradient overlay that fades during transition
  Widget _buildGradientOverlay(
    BuildContext context,
    Animation<double> animation,
    bool isDark,
  ) {
    final gradient = isDark
        ? AppColors.primaryGradientDark
        : AppColors.primaryGradient;

    // Overlay opacity peaks at 50% of transition, then fades out
    final overlayOpacity = Tween<double>(
      begin: 0.0,
      end: 0.15, // 15% opacity at peak
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeIn,
        ),
      ),
    );

    final overlayFadeOut = Tween<double>(
      begin: 0.15,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(
          0.5,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = animation.value < 0.5
            ? overlayOpacity.value
            : overlayFadeOut.value;

        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradient.colors[0].withValues(alpha: opacity),
                    gradient.colors[1].withValues(alpha: opacity),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Fade page route (simple fade in/out)
///
/// Simpler transition for less prominent navigation actions.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({
    required Widget page,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppAnimations.pageTransitionFade,
          reverseTransitionDuration: AppAnimations.pageTransitionFade,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            // Check for reduced motion preference
            final reducedMotion = AppAnimations.prefersReducedMotion(context);
            if (reducedMotion) {
              return child;
            }

            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Scale page route (modal-style appearance)
///
/// Used for modal-like pages that appear on top of existing content.
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  ScalePageRoute({
    required Widget page,
    super.settings,
    super.maintainState,
    super.fullscreenDialog = true, // Default to fullscreen dialog behavior
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppAnimations.modalEnter,
          reverseTransitionDuration: AppAnimations.modalExit,
          opaque: false, // Allow seeing through to background
          barrierColor: AppColors.overlayDark.withValues(alpha: 0.7),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            // Check for reduced motion preference
            final reducedMotion = AppAnimations.prefersReducedMotion(context);
            if (reducedMotion) {
              return child;
            }

            final scale = Tween<double>(
              begin: AppAnimations.modalScaleStart,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppAnimations.springCurve,
              ),
            );

            final fade = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return ScaleTransition(
              scale: scale,
              child: FadeTransition(
                opacity: fade,
                child: child,
              ),
            );
          },
        );
}

/// Helper methods for building routes
extension PageTransitionExtensions on Widget {
  /// Build a shared axis page route for this widget
  Route<T> toSharedAxisRoute<T>({RouteSettings? settings}) {
    return SharedAxisPageRoute<T>(
      page: this,
      settings: settings,
    );
  }

  /// Build a fade page route for this widget
  Route<T> toFadeRoute<T>({RouteSettings? settings}) {
    return FadePageRoute<T>(
      page: this,
      settings: settings,
    );
  }

  /// Build a scale page route for this widget
  Route<T> toScaleRoute<T>({RouteSettings? settings}) {
    return ScalePageRoute<T>(
      page: this,
      settings: settings,
    );
  }
}
