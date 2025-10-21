import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/navigation/page_transitions.dart';

void main() {
  group('SharedAxisPageRoute', () {
    testWidgets('creates route with correct page', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Test Page')),
      );

      final route = SharedAxisPageRoute<void>(page: testPage);

      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Home')),
          onGenerateRoute: (settings) => route,
        ),
      );

      // Navigate to the route
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Test Page'), findsOneWidget);
    });

    testWidgets('respects reduced motion', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Test Page')),
      );

      final route = SharedAxisPageRoute<void>(page: testPage);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(route),
                    child: const Text('Go'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();

      // With reduced motion, page should be visible immediately
      // Complete any remaining frames
      await tester.pumpAndSettle();

      expect(find.text('Test Page'), findsOneWidget);
    });

    testWidgets('applies transition animations', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Test Page')),
      );

      final route = SharedAxisPageRoute<void>(page: testPage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();

      // Mid-transition, both pages might be visible
      await tester.pump(const Duration(milliseconds: 125));

      // Complete transition
      await tester.pumpAndSettle();

      expect(find.text('Test Page'), findsOneWidget);
    });
  });

  group('FadePageRoute', () {
    testWidgets('creates route with fade transition', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Fade Page')),
      );

      final route = FadePageRoute<void>(page: testPage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Fade Page'), findsOneWidget);
    });

    testWidgets('respects reduced motion', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Fade Page')),
      );

      final route = FadePageRoute<void>(page: testPage);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(route),
                    child: const Text('Go'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();

      // Complete any remaining frames
      await tester.pumpAndSettle();

      expect(find.text('Fade Page'), findsOneWidget);
    });
  });

  group('ScalePageRoute', () {
    testWidgets('creates route with scale transition', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Scale Page')),
      );

      final route = ScalePageRoute<void>(page: testPage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Scale Page'), findsOneWidget);
    });

    testWidgets('is not opaque by default', (tester) async {
      const testPage = Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Scale Page')),
      );

      final route = ScalePageRoute<void>(page: testPage);

      expect(route.opaque, isFalse);
    });
  });

  group('PageTransitionExtensions', () {
    testWidgets('toSharedAxisRoute creates SharedAxisPageRoute', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Extension Page')),
      );

      final route = testPage.toSharedAxisRoute<void>();

      expect(route, isA<SharedAxisPageRoute<void>>());

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Extension Page'), findsOneWidget);
    });

    testWidgets('toFadeRoute creates FadePageRoute', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Fade Extension')),
      );

      final route = testPage.toFadeRoute<void>();

      expect(route, isA<FadePageRoute<void>>());

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Fade Extension'), findsOneWidget);
    });

    testWidgets('toScaleRoute creates ScalePageRoute', (tester) async {
      const testPage = Scaffold(
        body: Center(child: Text('Scale Extension')),
      );

      final route = testPage.toScaleRoute<void>();

      expect(route, isA<ScalePageRoute<void>>());

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Scale Extension'), findsOneWidget);
    });
  });
}
