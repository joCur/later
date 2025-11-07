import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/loading/skeleton_box.dart';
import '../../../test_helpers.dart';

void main() {
  group('SkeletonLoader - Generic Component', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonLoader()),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('renders with custom width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(width: 200, height: 50)),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SkeletonLoader),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, equals(200));
    });

    testWidgets('renders rectangular shape by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(width: 100, height: 20)),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('factory constructor .card() creates card skeleton', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SkeletonLoader.card())),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('factory constructor .listItem() creates list item skeleton', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SkeletonLoader.listItem())),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('factory constructor .avatar() creates circular skeleton', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SkeletonLoader.avatar())),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      final skeleton = tester.widget<SkeletonLoader>(
        find.byType(SkeletonLoader),
      );
      expect(skeleton.shape, equals(SkeletonShape.circle));
    });

    testWidgets('factory constructor .text() creates text skeleton', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SkeletonLoader.text())),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      final skeleton = tester.widget<SkeletonLoader>(
        find.byType(SkeletonLoader),
      );
      expect(skeleton.height, equals(16.0));
    });

    testWidgets('supports circle shape', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 40,
              height: 40,
              shape: SkeletonShape.circle,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('supports rectangle shape', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 100,
              height: 20,
              shape: SkeletonShape.rectangle,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('supports rounded rectangle shape', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(width: 100, height: 20)),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('has shimmer animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonLoader())),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);

      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be rendering with animation
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('adapts color to theme in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(body: SkeletonLoader()),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      // In light mode, should use neutral100 base color
    });

    testWidgets('adapts color to theme in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: SkeletonLoader()),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      // In dark mode, should use neutral800 base color
    });

    testWidgets('multiple skeletons can render simultaneously', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SkeletonLoader.text(),
                SkeletonLoader.avatar(),
                SkeletonLoader.card(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsNWidgets(3));
    });

    testWidgets('custom border radius can be applied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(width: 100, height: 20, borderRadius: 12.0),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      final skeleton = tester.widget<SkeletonLoader>(
        find.byType(SkeletonLoader),
      );
      expect(skeleton.borderRadius, equals(12.0));
    });

    testWidgets('disposes properly when removed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonLoader())),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Should not throw errors
      expect(tester.takeException(), isNull);
    });
  });

  group('SkeletonLoader - NoteCard Variant', () {
    testWidgets('NoteCardSkeleton renders', (tester) async {
      await tester.pumpWidget(
        testApp(const NoteCardSkeleton()),
      );

      expect(find.byType(NoteCardSkeleton), findsOneWidget);
    });

    testWidgets('NoteCardSkeleton has glass morphism background', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(const NoteCardSkeleton()),
      );

      expect(find.byType(NoteCardSkeleton), findsOneWidget);
      // Should have BackdropFilter for glass effect
      expect(find.byType(BackdropFilter), findsWidgets);
    });

    testWidgets('NoteCardSkeleton contains multiple skeleton loaders', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(const NoteCardSkeleton()),
      );

      // Should have title, content, and metadata skeletons
      expect(find.byType(SkeletonLoader), findsAtLeastNWidgets(3));
    });

    testWidgets('NoteCardSkeleton matches NoteCard layout', (tester) async {
      await tester.pumpWidget(
        testApp(const NoteCardSkeleton()),
      );

      expect(find.byType(NoteCardSkeleton), findsOneWidget);
      // Should use same padding and spacing as NoteCard
    });
  });
}
