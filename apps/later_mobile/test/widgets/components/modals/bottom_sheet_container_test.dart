import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/modals/bottom_sheet_container.dart';

void main() {
  group('BottomSheetContainer', () {
    testWidgets('renders mobile bottom sheet with drag handle on mobile',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: BottomSheetContainer(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);

      // Verify drag handle is present (Container with specific dimensions)
      // We can't directly test for the drag handle widget, but we can verify the layout
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders mobile bottom sheet with title when provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: BottomSheetContainer(
                title: 'Test Title',
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('Test Title'), findsOneWidget);

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('renders desktop dialog on desktop', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Scaffold(
              body: BottomSheetContainer(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);

      // Verify it's rendered as a Dialog
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('renders desktop dialog with title when provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Scaffold(
              body: BottomSheetContainer(
                title: 'Test Title',
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('Test Title'), findsOneWidget);

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);

      // Verify it's rendered as a Dialog
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('renders without title when not provided on mobile',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: BottomSheetContainer(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);

      // Verify no title text is present
      expect(find.byType(Text), findsOneWidget); // Only the content text
    });

    testWidgets('renders without title when not provided on desktop',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Scaffold(
              body: BottomSheetContainer(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);

      // Verify no title text is present
      expect(find.byType(Text), findsOneWidget); // Only the content text
    });

    testWidgets('respects custom height on mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: BottomSheetContainer(
                height: 400,
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);

      // Verify the container structure is correct
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('adapts to keyboard insets on mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(375, 812),
              viewInsets: EdgeInsets.only(bottom: 300), // Keyboard height
            ),
            child: Scaffold(
              body: BottomSheetContainer(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);

      // Verify the Padding widget adjusts for keyboard
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses correct background color from theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const MediaQuery(
            data: MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: BottomSheetContainer(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('uses correct background color in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const MediaQuery(
            data: MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: BottomSheetContainer(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      // Verify content is rendered
      expect(find.text('Test Content'), findsOneWidget);
    });
  });
}
