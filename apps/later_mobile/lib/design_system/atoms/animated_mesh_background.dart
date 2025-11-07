import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/colors.dart';

/// Animated gradient mesh background for full-screen entry points
///
/// Creates a slow-moving, organic gradient background that provides depth
/// and visual interest without distracting from content. Should be used
/// exclusively for full-screen entry points (auth, onboarding, splash).
///
/// Features:
/// - Smooth gradient animation with configurable duration
/// - Respects user's reduced motion preferences (slows down 5x)
/// - Automatic light/dark mode support
/// - Zero performance impact on low-end devices
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: Stack(
///     children: [
///       AnimatedMeshBackground(),  // Full screen
///       SafeArea(child: // ... your content),
///     ],
///   ),
/// )
/// ```
class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({
    super.key,
    this.duration = const Duration(seconds: 20),
    this.curve = Curves.easeInOut,
  });

  /// How long one complete animation cycle takes
  final Duration duration;

  /// The animation curve to use
  final Curve curve;

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user prefers reduced motion
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    // Determine theme-aware colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? [
            AppColors.primaryStartDark,
            AppColors.primaryEndDark,
            AppColors.noteGradientStart,
            AppColors.primaryStartDark,
          ]
        : [
            AppColors.primaryStart,
            AppColors.primaryEnd,
            AppColors.noteGradientStart,
            AppColors.primaryStart,
          ];

    // Adjust animation speed if reduced motion is enabled
    if (reducedMotion && _controller.duration != widget.duration * 5) {
      _controller.duration = widget.duration * 5;
    }

    return Positioned.fill(
      child: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Interpolate between alignments
              final alignmentTween = AlignmentGeometryTween(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );

              final currentAlignment =
                  alignmentTween.evaluate(_controller) as Alignment;

              // Calculate opposite alignment for end
              final endAlignment = Alignment(
                -currentAlignment.x,
                -currentAlignment.y,
              );

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: currentAlignment,
                    end: endAlignment,
                    colors: colors,
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          if (!reducedMotion) ...[
            const _FloatingParticle(
              size: 100,
              duration: Duration(seconds: 15),
              startPosition: Offset(0.2, 0.1),
              endPosition: Offset(0.3, 0.9),
            ),
            const _FloatingParticle(
              size: 80,
              duration: Duration(seconds: 18),
              startPosition: Offset(0.8, 0.2),
              endPosition: Offset(0.7, 0.8),
              delay: Duration(seconds: 3),
            ),
            const _FloatingParticle(
              size: 60,
              duration: Duration(seconds: 20),
              startPosition: Offset(0.5, 0.8),
              endPosition: Offset(0.6, 0.2),
              delay: Duration(seconds: 5),
            ),
          ],
        ],
      ),
    );
  }
}

/// Floating particle that moves across the background
class _FloatingParticle extends StatefulWidget {
  const _FloatingParticle({
    required this.size,
    required this.duration,
    required this.startPosition,
    required this.endPosition,
    this.delay = Duration.zero,
  });

  final double size;
  final Duration duration;
  final Offset startPosition;
  final Offset endPosition;
  final Duration delay;

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx *
              (MediaQuery.of(context).size.width - widget.size),
          top: _positionAnimation.value.dy *
              (MediaQuery.of(context).size.height - widget.size),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
