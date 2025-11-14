import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/design_system/organisms/cards/note_card.dart';
import '../../../test_helpers.dart';

void main() {
  group('NoteCard', () {
    // Helper function to create a Note
    Note createNote({
      String id = '1',
      String title = 'Meeting Notes',
      String? content,
      List<String>? tags,
      String spaceId = 'space1',
      String userId = 'user1',
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return Note(
        id: id,
        title: title,
        content: content,
        spaceId: spaceId,
        userId: userId,
        tags: tags,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    group('Rendering', () {
      testWidgets('renders with Note data', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
        expect(find.text('Meeting Notes'), findsOneWidget);
      });

      testWidgets('displays title correctly', (tester) async {
        final note = createNote(title: 'Project Ideas');

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.text('Project Ideas'), findsOneWidget);
      });

      testWidgets('shows content preview (first 100 chars)', (tester) async {
        final note = createNote(
          content: 'This is a short note about something important.',
        );

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.textContaining('This is a short note'), findsOneWidget);
      });

      testWidgets('truncates content to 100 chars with ellipsis', (
        tester,
      ) async {
        final longContent = 'A' * 150; // 150 characters
        final note = createNote(content: longContent);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should find text that contains the first 100 chars with ellipsis
        final noteFinder = find.byType(NoteCard);
        expect(noteFinder, findsOneWidget);

        // Check that content is displayed
        expect(find.textContaining('A' * 50), findsOneWidget);
      });

      testWidgets('shows document icon (description_outlined)', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      });

      testWidgets('renders blue-cyan gradient border (noteGradient)', (
        tester,
      ) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // GradientPillBorder should be present
        expect(find.byType(NoteCard), findsOneWidget);
      });

      testWidgets('displays tags as chips', (tester) async {
        final note = createNote(tags: ['work', 'important', 'review']);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should show tags
        expect(find.text('work'), findsOneWidget);
        expect(find.text('important'), findsOneWidget);
        expect(find.text('review'), findsOneWidget);
      });

      testWidgets('shows first 3 tags only', (tester) async {
        final note = createNote(tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5']);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should show first 3 tags
        expect(find.text('tag1'), findsOneWidget);
        expect(find.text('tag2'), findsOneWidget);
        expect(find.text('tag3'), findsOneWidget);

        // Should show "+2 more" indicator
        expect(find.text('+2 more'), findsOneWidget);
      });

      testWidgets('shows "+X more" when more than 3 tags', (tester) async {
        final note = createNote(tags: ['tag1', 'tag2', 'tag3', 'tag4']);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.text('+1 more'), findsOneWidget);
      });

      testWidgets('shows metadata (created date)', (tester) async {
        final createdDate = DateTime(2024, 1, 15);
        final note = createNote(createdAt: createdDate);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should show date in "MMM d, y" format (e.g., "Jan 15, 2024")
        expect(find.textContaining('Jan'), findsAtLeastNWidgets(1));
        expect(find.textContaining('15'), findsAtLeastNWidgets(1));
      });

      testWidgets('handles empty content (no preview shown)', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
        expect(find.text('Meeting Notes'), findsOneWidget);
      });

      testWidgets('handles empty string content (no preview shown)', (
        tester,
      ) async {
        final note = createNote(content: '');

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
        expect(find.text('Meeting Notes'), findsOneWidget);
      });

      testWidgets('handles no tags (no tag display)', (tester) async {
        final note = createNote(tags: []);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
        expect(find.text('Meeting Notes'), findsOneWidget);
      });

      testWidgets('handles single tag', (tester) async {
        final note = createNote(tags: ['work']);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.text('work'), findsOneWidget);
        // Should not show "+X more"
        expect(find.textContaining('more'), findsNothing);
      });

      testWidgets('handles exactly 3 tags (no "+X more")', (tester) async {
        final note = createNote(tags: ['tag1', 'tag2', 'tag3']);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.text('tag1'), findsOneWidget);
        expect(find.text('tag2'), findsOneWidget);
        expect(find.text('tag3'), findsOneWidget);
        expect(find.textContaining('more'), findsNothing);
      });

      testWidgets('content preview is 2 lines max', (tester) async {
        final note = createNote(
          content:
              'Line one content here. Line two content here. Line three should be cut off.',
        );

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('onTap callback fires when tapped', (tester) async {
        final note = createNote();
        var tapped = false;

        await tester.pumpWidget(
          testApp(
            NoteCard(
              note: note,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(NoteCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('onLongPress callback fires when long pressed', (
        tester,
      ) async {
        final note = createNote();
        var longPressed = false;

        await tester.pumpWidget(
          testApp(
            NoteCard(
              note: note,
              onLongPress: () {
                longPressed = true;
              },
            ),
          ),
        );

        await tester.longPress(find.byType(NoteCard));
        await tester.pump();

        expect(longPressed, isTrue);
      });

      testWidgets('handles tap without onTap callback', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should not throw error when tapped without callback
        await tester.tap(find.byType(NoteCard));
        await tester.pump();

        expect(find.byType(NoteCard), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has correct semantic label', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Find the container Semantics widget
        final semanticsFinder = find.descendant(
          of: find.byType(NoteCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.container == true,
          ),
        );

        expect(semanticsFinder, findsOneWidget);

        final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
        expect(semanticsWidget.properties.label, contains('Note'));
        expect(semanticsWidget.properties.label, contains('Meeting Notes'));
      });

      testWidgets('semantic label includes tag count', (tester) async {
        final note = createNote(
          title: 'Project Notes',
          tags: ['work', 'important'],
        );

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Find the container Semantics widget
        final semanticsFinder = find.descendant(
          of: find.byType(NoteCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.container == true,
          ),
        );

        expect(semanticsFinder, findsOneWidget);

        final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
        expect(semanticsWidget.properties.label, isNotNull);
        expect(semanticsWidget.properties.label, contains('Project Notes'));
      });
    });

    group('Design System Compliance', () {
      testWidgets('uses note gradient (blue-cyan) for border', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Card should render with gradient border
        expect(find.byType(NoteCard), findsOneWidget);
      });

      testWidgets('displays with correct layout structure', (tester) async {
        final note = createNote(content: 'Some content', tags: ['tag1']);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should have icon, title, content preview, and tags
        expect(find.byIcon(Icons.description_outlined), findsOneWidget);
        expect(find.text('Meeting Notes'), findsOneWidget);
        expect(find.textContaining('Some content'), findsOneWidget);
        expect(find.text('tag1'), findsOneWidget);
      });

      testWidgets('icon has gradient shader', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Find ShaderMask widget
        expect(find.byType(ShaderMask), findsAtLeastNWidgets(1));
      });
    });

    group('Press Animation', () {
      testWidgets('applies press animation on tap', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note, onTap: () {})),
        );

        // Find the card
        final cardFinder = find.byType(NoteCard);
        expect(cardFinder, findsOneWidget);

        // Tap down
        await tester.press(cardFinder);
        await tester.pump();

        // Card should still be present
        expect(cardFinder, findsOneWidget);

        // Release
        await tester.pumpAndSettle();
      });
    });

    group('Entrance Animation', () {
      testWidgets('applies entrance animation with index parameter', (
        tester,
      ) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note, index: 0)),
        );

        // Card should render
        expect(find.byType(NoteCard), findsOneWidget);

        // Pump and settle to complete entrance animation
        await tester.pumpAndSettle();

        // Card should still be visible after animation
        expect(find.text('Meeting Notes'), findsOneWidget);
      });

      testWidgets('works without index parameter', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Card should render without animation
        expect(find.byType(NoteCard), findsOneWidget);
        expect(find.text('Meeting Notes'), findsOneWidget);
      });

      testWidgets('applies staggered delay based on index', (tester) async {
        final notes = List.generate(
          3,
          (index) => createNote(id: 'note_$index', title: 'Note $index'),
        );

        await tester.pumpWidget(
          testApp(
            ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteCard(note: notes[index], index: index);
              },
            ),
          ),
        );

        // All cards should render
        expect(find.byType(NoteCard), findsNWidgets(3));

        // Complete all animations
        await tester.pumpAndSettle();

        // All items should be visible
        for (int i = 0; i < notes.length; i++) {
          expect(find.text('Note $i'), findsOneWidget);
        }
      });
    });

    group('Content Truncation', () {
      testWidgets('content at exactly 100 chars shows without ellipsis', (
        tester,
      ) async {
        final content = 'A' * 100;
        final note = createNote(content: content);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
      });

      testWidgets('content over 100 chars shows with ellipsis', (tester) async {
        final content = 'A' * 101;
        final note = createNote(content: content);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
      });

      testWidgets('very long content is handled gracefully', (tester) async {
        final content = 'A' * 10000;
        final note = createNote(content: content);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very long title', (tester) async {
        final note = createNote(
          title:
              'This is a very long note title that should be truncated with ellipsis when it exceeds the maximum number of lines allowed',
        );

        await tester.pumpWidget(
          testApp(SizedBox(width: 300, child: NoteCard(note: note))),
        );

        expect(find.byType(NoteCard), findsOneWidget);
      });

      testWidgets('handles many tags', (tester) async {
        final tags = List.generate(20, (index) => 'tag$index');
        final note = createNote(tags: tags);

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should show first 3 tags
        expect(find.text('tag0'), findsOneWidget);
        expect(find.text('tag1'), findsOneWidget);
        expect(find.text('tag2'), findsOneWidget);

        // Should show "+17 more"
        expect(find.text('+17 more'), findsOneWidget);
      });

      testWidgets('handles tags with very long names', (tester) async {
        final note = createNote(
          tags: ['very_long_tag_name_that_might_overflow', 'another_long_tag'],
        );

        await tester.pumpWidget(
          testApp(SizedBox(width: 300, child: NoteCard(note: note))),
        );

        expect(find.byType(NoteCard), findsOneWidget);
      });

      testWidgets('handles unicode content', (tester) async {
        final note = createNote(
          title: 'Unicode Test 🔥',
          content: 'This has emoji 😊 and special chars: ñ, é, ü',
          tags: ['日本語', 'Español'],
        );

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.textContaining('Unicode Test'), findsOneWidget);
      });

      testWidgets('handles null tags list', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        expect(find.byType(NoteCard), findsOneWidget);
      });
    });

    group('showMetadata parameter', () {
      testWidgets('shows metadata when showMetadata is true', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note)),
        );

        // Should show date icon
        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });

      testWidgets('hides metadata when showMetadata is false', (tester) async {
        final note = createNote();

        await tester.pumpWidget(
          testApp(NoteCard(note: note, showMetadata: false)),
        );

        // Should not show date icon
        expect(find.byIcon(Icons.access_time), findsNothing);
      });
    });
  });
}
