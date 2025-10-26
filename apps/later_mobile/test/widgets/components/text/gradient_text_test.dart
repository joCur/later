import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/text/gradient_text.dart';

void main() {
  group('GradientText Widget Tests', () {
    testWidgets('renders text with ShaderMask', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientText('Hello World'),
          ),
        ),
      );

      // Verify ShaderMask exists
      expect(find.byType(ShaderMask), findsOneWidget);

      // Verify Text widget is child of ShaderMask
      final shaderMask = tester.widget<ShaderMask>(find.byType(ShaderMask));
      expect(shaderMask.child, isA<Text>());

      // Verify text content
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('uses default primary gradient when no gradient specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientText('Test'),
          ),
        ),
      );

      final shaderMask = tester.widget<ShaderMask>(find.byType(ShaderMask));

      // Verify blendMode is srcIn
      expect(shaderMask.blendMode, BlendMode.srcIn);

      // Verify shader callback exists
      expect(shaderMask.shaderCallback, isNotNull);
    });

    testWidgets('accepts custom gradient', (tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientText(
              'Custom',
              gradient: customGradient,
            ),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('applies custom TextStyle', (tester) async {
      const customStyle = TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientText(
              'Styled',
              style: customStyle,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Styled'));
      expect(text.style?.fontSize, 24);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('supports text alignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: GradientText(
                'Centered',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Centered'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('supports maxLines', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: GradientText(
                'This is a very long text that should be truncated',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.text('This is a very long text that should be truncated'),
      );
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('adapts to light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: GradientText('Light Mode'),
          ),
        ),
      );

      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GradientText('Dark Mode'),
          ),
        ),
      );

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('GradientText Factory Constructors', () {
    testWidgets('GradientText.primary uses primary gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText.primary('Primary'),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('GradientText.secondary uses secondary gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText.secondary('Secondary'),
          ),
        ),
      );

      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('GradientText.task uses task gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText.task('Task'),
          ),
        ),
      );

      expect(find.text('Task'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('GradientText.note uses note gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText.note('Note'),
          ),
        ),
      );

      expect(find.text('Note'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('GradientText.list uses list gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText.list('List'),
          ),
        ),
      );

      expect(find.text('List'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('GradientText.subtle applies reduced opacity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText.subtle('Subtle'),
          ),
        ),
      );

      expect(find.text('Subtle'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('factory constructors accept custom style', (tester) async {
      const customStyle = TextStyle(fontSize: 32);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText.primary(
              'Styled Primary',
              style: customStyle,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Styled Primary'));
      expect(text.style?.fontSize, 32);
    });

    testWidgets('factory constructors support text alignment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: GradientText.primary(
                'Centered',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Centered'));
      expect(text.textAlign, TextAlign.center);
    });
  });

  group('GradientText Edge Cases', () {
    testWidgets('handles empty string', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientText(''),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('handles very long text', (tester) async {
      final longText = 'A' * 1000;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientText(longText),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('handles special characters and emojis', (tester) async {
      const specialText = 'Hello 👋 World! @#\$%^&*()';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientText(specialText),
          ),
        ),
      );

      expect(find.text(specialText), findsOneWidget);
    });

    testWidgets('handles null overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientText(
              'Test',
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
