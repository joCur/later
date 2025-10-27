import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/molecules/app_bars/editable_app_bar_title.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/design_system/atoms/text/gradient_text.dart';

void main() {
  group('EditableAppBarTitle', () {
    testWidgets('displays GradientText initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(text: 'Test Title', onChanged: (_) {}),
            ),
          ),
        ),
      );

      // Should show GradientText in display mode
      expect(find.byType(GradientText), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows edit icon next to gradient text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(text: 'Test Title', onChanged: (_) {}),
            ),
          ),
        ),
      );

      // Should show edit icon
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('enters edit mode when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(text: 'Test Title', onChanged: (_) {}),
            ),
          ),
        ),
      );

      // Initially in display mode
      expect(find.byType(GradientText), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      // Tap to enter edit mode
      await tester.tap(find.byType(GradientText));
      await tester.pumpAndSettle();

      // Should now show TextField
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(GradientText), findsNothing);
    });

    testWidgets('TextField has correct initial text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Initial Text',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Tap to enter edit mode
      await tester.tap(find.text('Initial Text'));
      await tester.pumpAndSettle();

      // TextField should contain the initial text
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('Initial Text'));
    });

    testWidgets('calls onChanged when submitted with valid text', (
      tester,
    ) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Original',
                onChanged: (newText) {
                  changedText = newText;
                },
              ),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();

      // Change the text
      await tester.enterText(find.byType(TextField), 'Modified Text');
      await tester.pumpAndSettle();

      // Submit the text
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify callback was called with new text
      expect(changedText, equals('Modified Text'));
    });

    testWidgets('exits edit mode after submission', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(text: 'Test', onChanged: (_) {}),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should be back in display mode
      expect(find.byType(GradientText), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('does not call onChanged when text is empty', (tester) async {
      String? changedText;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Original',
                onChanged: (newText) {
                  changedText = newText;
                  callCount++;
                },
              ),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();

      // Clear the text
      await tester.enterText(find.byType(TextField), '   '); // Whitespace only
      await tester.pumpAndSettle();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Callback should not be called
      expect(callCount, equals(0));
      expect(changedText, isNull);
    });

    testWidgets('restores original text when submitted with empty text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(text: 'Original', onChanged: (_) {}),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();

      // Clear the text
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show original text
      expect(find.text('Original'), findsOneWidget);
      expect(find.byType(GradientText), findsOneWidget);
    });

    testWidgets('uses custom gradient when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Test',
                onChanged: (_) {},
                gradient: AppColors.noteGradient,
              ),
            ),
          ),
        ),
      );

      // Find the GradientText and verify it has the custom gradient
      final gradientText = tester.widget<GradientText>(
        find.byType(GradientText),
      );
      expect(gradientText.gradient, equals(AppColors.noteGradient));
    });

    testWidgets('uses custom text style when provided', (tester) async {
      const customStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Test',
                onChanged: (_) {},
                style: customStyle,
              ),
            ),
          ),
        ),
      );

      // Verify custom style is applied to GradientText
      final gradientText = tester.widget<GradientText>(
        find.byType(GradientText),
      );
      expect(gradientText.style, equals(customStyle));
    });

    testWidgets('displays custom hint text in TextField', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Test',
                onChanged: (_) {},
                hintText: 'Custom Hint',
              ),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Verify hint text
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('Custom Hint'));
    });

    testWidgets('TextField has no border decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(text: 'Test', onChanged: (_) {}),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Verify no border
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.border, equals(InputBorder.none));
    });

    testWidgets('only calls onChanged if text actually changed', (
      tester,
    ) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Original',
                onChanged: (_) {
                  callCount++;
                },
              ),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();

      // Submit without changing text
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Callback should not be called since text didn't change
      expect(callCount, equals(0));
    });

    testWidgets('trims whitespace from submitted text', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Original',
                onChanged: (newText) {
                  changedText = newText;
                },
              ),
            ),
          ),
        ),
      );

      // Enter edit mode
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();

      // Enter text with whitespace
      await tester.enterText(find.byType(TextField), '  New Text  ');
      await tester.pumpAndSettle();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should receive trimmed text
      expect(changedText, equals('New Text'));
    });

    testWidgets('uses AppTypography.h3 by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(text: 'Test', onChanged: (_) {}),
            ),
          ),
        ),
      );

      // Verify default style
      final gradientText = tester.widget<GradientText>(
        find.byType(GradientText),
      );
      expect(gradientText.style, equals(AppTypography.h3));
    });

    testWidgets('GradientText uses ellipsis overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Very Long Title That Should Overflow',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify overflow handling
      final gradientText = tester.widget<GradientText>(
        find.byType(GradientText),
      );
      expect(gradientText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('works with different gradient types', (tester) async {
      // Test with task gradient
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'Task Title',
                onChanged: (_) {},
                gradient: AppColors.taskGradient,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Task Title'), findsOneWidget);
      expect(find.byType(GradientText), findsOneWidget);

      // Rebuild with list gradient
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: 'List Title',
                onChanged: (_) {},
                gradient: AppColors.listGradient,
              ),
            ),
          ),
        ),
      );

      expect(find.text('List Title'), findsOneWidget);
      final gradientText = tester.widget<GradientText>(
        find.byType(GradientText),
      );
      expect(gradientText.gradient, equals(AppColors.listGradient));
    });

    testWidgets('updates displayed text when widget text changes', (
      tester,
    ) async {
      String displayText = 'Original';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: EditableAppBarTitle(
                    text: displayText,
                    onChanged: (_) {},
                  ),
                ),
                body: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      displayText = 'Updated';
                    });
                  },
                  child: const Text('Update'),
                ),
              ),
            );
          },
        ),
      );

      // Initially shows original text
      expect(find.text('Original'), findsOneWidget);

      // Update the text externally
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Should show updated text
      expect(find.text('Updated'), findsOneWidget);
      expect(find.text('Original'), findsNothing);
    });
  });
}
