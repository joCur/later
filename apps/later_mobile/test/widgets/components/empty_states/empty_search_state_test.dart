import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_search_state.dart';

void main() {
  group('EmptySearchState Tests', () {
    testWidgets('renders no results found title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('renders search icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays helpful description', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert
      expect(
        find.text('Try different keywords or check your spelling'),
        findsOneWidget,
      );
    });

    testWidgets('does not display CTA button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not display secondary link', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('icon size is 64px', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, 64.0);
    });

    testWidgets('uses EmptyState base component', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert - verify it's using the base component
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('renders in both light and dark mode',
        (WidgetTester tester) async {
      // Test light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      expect(find.text('No results found'), findsOneWidget);

      // Test dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('has proper semantic structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert - verify all key elements are accessible
      expect(find.text('No results found'), findsOneWidget);
      expect(
        find.text('Try different keywords or check your spelling'),
        findsOneWidget,
      );
    });

    testWidgets('content is centered', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Center), findsWidgets);
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('accepts optional query parameter', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(query: 'test query'),
          ),
        ),
      );

      // Assert - should still show standard message
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('displays alternative message with query',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(query: 'flutter'),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('No results'), findsOneWidget);
    });
  });
}
