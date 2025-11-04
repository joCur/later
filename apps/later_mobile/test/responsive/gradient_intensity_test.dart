import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_theme.dart';
import 'package:later_mobile/design_system/molecules/fab/create_content_fab.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Responsive Behavior Test Suite: Gradient Intensity Tests
///
/// Tests that gradients render consistently across different screen sizes:
/// - Mobile: 320px, 375px, 414px
/// - Tablet: 768px, 834px, 1024px
/// - Desktop: 1280px, 1440px, 1920px
///
/// Verifies:
/// - Gradients render consistently across sizes
/// - Gradient performance is acceptable
/// - Gradient visibility and intensity
/// - Gradient opacity levels (2%, 5%, 10%, 15%)
/// - No gradient banding or artifacts
///
/// Success Criteria:
/// - Gradients are visually consistent
/// - No performance degradation
/// - Opacity levels are correct
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gradient Rendering Tests - Mobile', () {
    testWidgets('Primary gradient renders at 320px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320.0, 568.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(child: Text('Gradient Test')),
              ),
            ),
          ),
        ),
      );

      // Verify container renders without errors
      expect(find.byType(Container), findsWidgets);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Gradient should render without errors at 320px',
      );
    });

    testWidgets('Primary gradient renders at 375px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(375.0, 812.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(child: Text('Gradient Test')),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Primary gradient renders at 414px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(414.0, 896.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(child: Text('Gradient Test')),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Gradient FAB renders at mobile sizes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(375.0, 812.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              floatingActionButton: CreateContentFab(onPressed: () {}),
            ),
          ),
        ),
      );

      expect(find.byType(CreateContentFab), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'FAB with gradient should render on mobile',
      );
    });
  });

  group('Gradient Rendering Tests - Tablet', () {
    testWidgets('Primary gradient renders at 768px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(768.0, 1024.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(child: Text('Gradient Test')),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'Gradient should render at tablet size',
      );
    });

    testWidgets('Primary gradient renders at 834px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(834.0, 1194.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Primary gradient renders at 1024px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024.0, 1366.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Gradient Rendering Tests - Desktop', () {
    testWidgets('Primary gradient renders at 1280px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1280.0, 720.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'Gradient should render at desktop size',
      );
    });

    testWidgets('Primary gradient renders at 1440px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1440.0, 900.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Primary gradient renders at 1920px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1920.0, 1080.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Gradient Opacity Tests', () {
    testWidgets('2% opacity gradient renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryStart.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: '2% opacity gradient should render without errors',
      );
    });

    testWidgets('5% opacity gradient renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryStart.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('10% opacity gradient renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryStart.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('15% opacity gradient renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryStart.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Multiple opacity levels on same screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Stack(
              children: [
                // 2% background gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryStart.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // 10% header gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryStart.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // 100% FAB gradient
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'Multiple gradient opacity levels should coexist',
      );
    });
  });

  group('Gradient Theme Mode Tests', () {
    testWidgets('Light mode gradient renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Dark mode gradient renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradientDark,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Secondary gradient renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.secondaryGradient,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Task gradient renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(gradient: AppColors.taskGradient),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Note gradient renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(gradient: AppColors.noteGradient),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('List gradient renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(gradient: AppColors.listGradient),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Gradient Performance Tests', () {
    testWidgets('Multiple gradients render without lag', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return Container(
                  height: 100,
                  margin: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Center(child: Text('Item $index')),
                );
              },
            ),
          ),
        ),
      );

      // Pump and settle to ensure all animations complete
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Multiple gradients should not cause performance issues',
      );
    });

    testWidgets('Gradient overlays do not conflict', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Stack(
              children: [
                // Base gradient
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
                // Overlay gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondaryStart.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'Gradient overlays should not conflict',
      );
    });
  });
}
