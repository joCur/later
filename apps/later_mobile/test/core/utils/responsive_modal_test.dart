import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/utils/responsive_modal.dart';

void main() {
  group('ResponsiveModal', () {
    testWidgets('shows bottom sheet on mobile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      await ResponsiveModal.show<void>(
                        context: context,
                        child: const Text('Modal Content'),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal content is displayed
      expect(find.text('Modal Content'), findsOneWidget);

      // Close the modal
      await tester.tapAt(const Offset(10, 10)); // Tap outside
      await tester.pumpAndSettle();
    });

    testWidgets('shows dialog on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      await ResponsiveModal.show<void>(
                        context: context,
                        child: const Text('Modal Content'),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal content is displayed
      expect(find.text('Modal Content'), findsOneWidget);

      // Close the modal
      await tester.tapAt(const Offset(10, 10)); // Tap outside
      await tester.pumpAndSettle();
    });

    testWidgets('passes result back correctly on mobile', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await ResponsiveModal.show<String>(
                        context: context,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop('test-result'),
                          child: const Text('Close with Result'),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Close with result
      await tester.tap(find.text('Close with Result'));
      await tester.pumpAndSettle();

      // Verify result was passed back
      expect(result, 'test-result');
    });

    testWidgets('passes result back correctly on desktop', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await ResponsiveModal.show<String>(
                        context: context,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop('test-result'),
                          child: const Text('Close with Result'),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Close with result
      await tester.tap(find.text('Close with Result'));
      await tester.pumpAndSettle();

      // Verify result was passed back
      expect(result, 'test-result');
    });

    testWidgets('respects isScrollControlled parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      await ResponsiveModal.show<void>(
                        context: context,
                        child: const Text('Modal Content'),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal content is displayed
      expect(find.text('Modal Content'), findsOneWidget);
    });

    testWidgets('barrierDismissible true allows dismissing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      await ResponsiveModal.show<void>(
                        context: context,
                        child: const Text('Modal Content'),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal content is displayed
      expect(find.text('Modal Content'), findsOneWidget);

      // Tap outside to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Verify modal is dismissed
      expect(find.text('Modal Content'), findsNothing);
    });

    testWidgets('supports generic type parameter', (tester) async {
      int? result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await ResponsiveModal.show<int>(
                        context: context,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(42),
                          child: const Text('Return Number'),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Close with integer result
      await tester.tap(find.text('Return Number'));
      await tester.pumpAndSettle();

      // Verify integer result was passed back
      expect(result, 42);
    });
  });
}
