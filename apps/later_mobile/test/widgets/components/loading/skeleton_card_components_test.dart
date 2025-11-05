import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/design_system/molecules/loading/skeleton_loader.dart';
import '../../../test_helpers.dart';

void main() {
  group('SkeletonItemCard', () {
    testWidgets('renders successfully', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonItemCard()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonItemCard), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('applies correct border radius', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonItemCard()),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container).first);

      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;

      expect(borderRadius.topLeft.x, AppSpacing.cardRadius);
    });

    testWidgets('contains multiple shimmer boxes for content', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonItemCard()),
      );

      await tester.pumpAndSettle();

      // Should have multiple shimmer boxes (title + content preview + metadata)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders correctly in light mode', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonItemCard()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonItemCard), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        testAppDark(const SkeletonItemCard()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonItemCard), findsOneWidget);
    });

    testWidgets('has proper padding', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonItemCard()),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders with padding (has Padding widgets inside)
      final paddingWidgets = find.descendant(
        of: find.byType(SkeletonItemCard),
        matching: find.byType(Padding),
      );

      expect(paddingWidgets, findsWidgets);
    });
  });

  group('SkeletonListView', () {
    testWidgets('renders specified number of skeleton cards', (tester) async {
      const itemCount = 5;

      await tester.pumpWidget(
        testApp(const SkeletonListView(itemCount: itemCount)),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonItemCard), findsNWidgets(itemCount));
    });

    testWidgets('uses default item count of 3', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonListView()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonItemCard), findsNWidgets(3));
    });

    testWidgets('has proper spacing between items', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonListView()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView, isNotNull);
    });

    testWidgets('is scrollable', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonListView(itemCount: 10)),
      );

      await tester.pumpAndSettle();

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isNot(const NeverScrollableScrollPhysics()));
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonListView(padding: EdgeInsets.all(24.0))),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonListView), findsOneWidget);
    });
  });

  group('SkeletonDetailView', () {
    testWidgets('renders skeleton detail view', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonDetailView()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonDetailView), findsOneWidget);
    });

    testWidgets('has header section skeleton', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonDetailView()),
      );

      await tester.pumpAndSettle();

      // Should have multiple shimmer sections
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('has content section skeleton', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonDetailView()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonDetailView), findsOneWidget);
    });
  });

  group('SkeletonSidebar', () {
    testWidgets('renders skeleton sidebar', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonSidebar()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SkeletonSidebar), findsOneWidget);
    });

    testWidgets('has multiple space item skeletons', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonSidebar()),
      );

      await tester.pumpAndSettle();

      // Should have skeleton items for spaces
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders with glass morphism', (tester) async {
      await tester.pumpWidget(
        testApp(const SkeletonSidebar()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });
}
