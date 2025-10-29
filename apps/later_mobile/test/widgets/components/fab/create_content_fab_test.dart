import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/molecules/fab/create_content_fab.dart';

void main() {
  Widget createTestApp({required Widget child}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [TemporalFlowTheme.light()],
      ),
      home: Scaffold(body: child),
    );
  }

  group('CreateContentFab', () {
    testWidgets('renders FAB with icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: CreateContentFab(onPressed: () {})),
      );

      expect(find.byType(CreateContentFab), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        createTestApp(
          child: CreateContentFab(
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(CreateContentFab));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('has correct size', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: CreateContentFab(onPressed: () {})),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CreateContentFab),
          matching: find.byType(Container),
        ),
      );

      // Mobile-First Bold Design: 56x56px circular FAB
      expect(container.constraints?.maxWidth, 56);
      expect(container.constraints?.maxHeight, 56);
    });

    testWidgets('renders with custom icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: CreateContentFab(icon: Icons.edit, onPressed: () {}),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('renders with tooltip', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: CreateContentFab(
            onPressed: () {},
            tooltip: 'Test Tooltip',
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
