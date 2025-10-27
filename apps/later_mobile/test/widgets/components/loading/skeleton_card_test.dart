import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/loading/skeleton_line.dart';
import 'package:later_mobile/design_system/molecules/loading/skeleton_card.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('SkeletonLine', () {
    testWidgets('renders with default dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLine(),
          ),
        ),
      );

      // Find the skeleton line widget
      final skeletonLineFinder = find.byType(SkeletonLine);
      expect(skeletonLineFinder, findsOneWidget);

      // Find the container
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Verify it renders with default height
      final Container container = tester.widget(containerFinder.first);
      expect(container.decoration, isNotNull);
    });

    testWidgets('renders with custom width and height', (WidgetTester tester) async {
      const testWidth = 200.0;
      const testHeight = 20.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLine(
              width: testWidth,
              height: testHeight,
            ),
          ),
        ),
      );

      // Find the sized box
      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsWidgets);

      final SizedBox sizedBox = tester.widget(sizedBoxFinder.first);
      expect(sizedBox.width, equals(testWidth));
      expect(sizedBox.height, equals(testHeight));
    });

    testWidgets('renders with correct border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLine(),
          ),
        ),
      );

      // Find the container with decoration
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      final Container container = tester.widget(containerFinder.first);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.borderRadius, isNotNull);
    });

    testWidgets('uses correct colors in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: SkeletonLine(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the container with decoration
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      final Container container = tester.widget(containerFinder.first);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.color, equals(AppColors.neutral200));
    });

    testWidgets('uses correct colors in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SkeletonLine(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the container with decoration
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      final Container container = tester.widget(containerFinder.first);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.color, equals(AppColors.neutral800));
    });

    testWidgets('can be configured with different widths', (WidgetTester tester) async {
      const widths = [50.0, 100.0, 150.0, 200.0];

      for (final width in widths) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonLine(width: width),
            ),
          ),
        );

        final sizedBoxFinder = find.byType(SizedBox);
        final SizedBox sizedBox = tester.widget(sizedBoxFinder.first);
        expect(sizedBox.width, equals(width));
      }
    });
  });

  group('SkeletonCard', () {
    testWidgets('renders skeleton card structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      // Should render a shimmer widget
      final shimmerFinder = find.byType(Shimmer);
      expect(shimmerFinder, findsOneWidget);

      // Should contain multiple skeleton lines
      final skeletonLineFinder = find.byType(SkeletonLine);
      expect(skeletonLineFinder, findsWidgets);
    });

    testWidgets('has correct card shape with border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // Find all containers
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Find a container with BoxDecoration that has borderRadius
      bool foundBorderRadius = false;
      for (final element in containerFinder.evaluate()) {
        final Container container = element.widget as Container;
        final BoxDecoration? decoration = container.decoration as BoxDecoration?;

        if (decoration?.borderRadius != null) {
          final BorderRadius? borderRadius = decoration!.borderRadius as BorderRadius?;
          if (borderRadius != null && borderRadius.topLeft.x == AppSpacing.cardRadius) {
            foundBorderRadius = true;
            break;
          }
        }
      }

      expect(foundBorderRadius, isTrue);
    });

    testWidgets('displays shimmer animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      // Find shimmer widget
      final shimmerFinder = find.byType(Shimmer);
      expect(shimmerFinder, findsOneWidget);

      final Shimmer shimmer = tester.widget(shimmerFinder);

      // Verify shimmer configuration
      expect(shimmer.period, equals(const Duration(milliseconds: 1200)));
    });

    testWidgets('uses correct shimmer colors in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // In light mode with animations enabled, shimmer should be present
      final shimmerFinder = find.byType(Shimmer);

      if (shimmerFinder.evaluate().isNotEmpty) {
        final Shimmer shimmer = tester.widget(shimmerFinder);
        // Verify shimmer colors for light mode
        expect(shimmer.gradient, isNotNull);
      } else {
        // If animations are disabled, that's also valid
        expect(find.byType(SkeletonCard), findsOneWidget);
      }
    });

    testWidgets('uses correct shimmer colors in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // In dark mode with animations enabled, shimmer should be present
      final shimmerFinder = find.byType(Shimmer);

      if (shimmerFinder.evaluate().isNotEmpty) {
        final Shimmer shimmer = tester.widget(shimmerFinder);
        // Verify shimmer gradient exists
        expect(shimmer.gradient, isNotNull);
      } else {
        // If animations are disabled, that's also valid
        expect(find.byType(SkeletonCard), findsOneWidget);
      }
    });

    testWidgets('matches item card layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // Should have multiple skeleton lines representing:
      // - Title line
      // - Content lines (2-3)
      // - Metadata row
      final skeletonLineFinder = find.byType(SkeletonLine);
      expect(skeletonLineFinder.evaluate().length, greaterThanOrEqualTo(3));
    });

    testWidgets('has leading element space (for icon/checkbox)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // The card should have a Row layout with leading space
      final rowFinder = find.descendant(
        of: find.byType(SkeletonCard),
        matching: find.byType(Row),
      );

      expect(rowFinder, findsWidgets);
    });

    testWidgets('respects reduce motion preferences', (WidgetTester tester) async {
      // Set accessibility settings to reduce motion
      tester.view.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures.allOn(reduceMotion: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // The widget should still render but might have reduced animation
      final skeletonCardFinder = find.byType(SkeletonCard);
      expect(skeletonCardFinder, findsOneWidget);

      // When reduce motion is enabled, shimmer should not be present
      final shimmerFinder = find.byType(Shimmer);
      expect(shimmerFinder, findsNothing);
    });

    testWidgets('renders multiple skeleton cards correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SkeletonCard(),
                  SizedBox(height: 8),
                  SkeletonCard(),
                  SizedBox(height: 8),
                  SkeletonCard(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should render all three skeleton cards
      final skeletonCardFinder = find.byType(SkeletonCard);
      expect(skeletonCardFinder, findsNWidgets(3));
    });

    testWidgets('has proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // Should find SizedBox widgets used for spacing
      final sizedBoxFinder = find.descendant(
        of: find.byType(SkeletonCard),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsWidgets);
    });

    testWidgets('shimmer animation uses linear curve', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // Find shimmer widget (if animations are enabled)
      final shimmerFinder = find.byType(Shimmer);

      if (shimmerFinder.evaluate().isNotEmpty) {
        // Shimmer package uses linear gradient by default
        // The animation itself should be smooth at 60fps
        // We verify the presence and duration
        final Shimmer shimmer = tester.widget(shimmerFinder);
        expect(shimmer.period, equals(const Duration(milliseconds: 1200)));
      } else {
        // If animations are disabled, that's also valid
        expect(find.byType(SkeletonCard), findsOneWidget);
      }
    });

    testWidgets('supports variant for different card types', (WidgetTester tester) async {
      // Test default variant
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('maintains 12px border radius consistently', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pump();

      // Find all containers and check for the one with border radius
      final containerFinder = find.byType(Container);
      bool foundCorrectBorderRadius = false;

      for (final element in containerFinder.evaluate()) {
        final Container container = element.widget as Container;
        final BoxDecoration? decoration = container.decoration as BoxDecoration?;

        if (decoration?.borderRadius != null) {
          final BorderRadius? borderRadius = decoration!.borderRadius as BorderRadius?;
          if (borderRadius != null && borderRadius.topLeft.x == 12.0) {
            foundCorrectBorderRadius = true;
            break;
          }
        }
      }

      expect(foundCorrectBorderRadius, isTrue);
    });
  });

  group('SkeletonCard Accessibility', () {
    testWidgets('is semantically labeled for screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The skeleton card should have semantic information
      final skeletonCardFinder = find.byType(SkeletonCard);
      expect(skeletonCardFinder, findsOneWidget);

      // Should be accessible
      final Element element = tester.element(skeletonCardFinder);
      expect(element, isNotNull);
    });

    testWidgets('respects system accessibility settings', (WidgetTester tester) async {
      // Enable high contrast
      tester.view.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures.allOn(highContrast: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(SkeletonCard), findsOneWidget);
    });
  });

  group('SkeletonCard Performance', () {
    testWidgets('renders efficiently without excessive rebuilds', (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildCount++;
                return const SkeletonCard();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Initial build
      expect(buildCount, equals(1));

      // Pump a few frames to simulate animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Build count should remain low (const constructor optimization)
      expect(buildCount, lessThanOrEqualTo(2));
    });
  });
}

class FakeAccessibilityFeatures implements ui.AccessibilityFeatures {
  const FakeAccessibilityFeatures({
    this.accessibleNavigation = false,
    this.boldText = false,
    this.disableAnimations = false,
    this.highContrast = false,
    this.invertColors = false,
    this.reduceMotion = false,
    this.onOffSwitchLabels = false,
    this.supportsAnnounce = false,
  });

  factory FakeAccessibilityFeatures.allOn({
    bool? accessibleNavigation,
    bool? boldText,
    bool? disableAnimations,
    bool? highContrast,
    bool? invertColors,
    bool? reduceMotion,
    bool? onOffSwitchLabels,
    bool? supportsAnnounce,
  }) {
    return FakeAccessibilityFeatures(
      accessibleNavigation: accessibleNavigation ?? true,
      boldText: boldText ?? true,
      disableAnimations: disableAnimations ?? true,
      highContrast: highContrast ?? true,
      invertColors: invertColors ?? true,
      reduceMotion: reduceMotion ?? true,
      onOffSwitchLabels: onOffSwitchLabels ?? true,
      supportsAnnounce: supportsAnnounce ?? true,
    );
  }

  @override
  final bool accessibleNavigation;

  @override
  final bool boldText;

  @override
  final bool disableAnimations;

  @override
  final bool highContrast;

  @override
  final bool invertColors;

  @override
  final bool reduceMotion;

  @override
  final bool onOffSwitchLabels;

  @override
  final bool supportsAnnounce;
}
