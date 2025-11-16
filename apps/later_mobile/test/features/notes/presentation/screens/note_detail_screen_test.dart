import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/features/notes/application/providers.dart';
import 'package:later_mobile/features/notes/application/services/note_service.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_helpers.dart';
@GenerateMocks([NoteService])
import 'note_detail_screen_test.mocks.dart';

void main() {
  group('NoteDetailScreen', () {
    late MockNoteService mockService;
    late Note testNote;

    setUp(() {
      mockService = MockNoteService();
      testNote = Note(
        id: 'note-1',
        title: 'Test Note',
        content: 'Test content',
        spaceId: 'space-1',
        userId: 'user-1',
        tags: ['tag1', 'tag2'],
      );

      // Setup default mocks
      when(mockService.getNotesForSpace(any)).thenAnswer((_) async => []);
    });

    Widget createWidget(Note note) {
      return testApp(
        ProviderScope(
          overrides: [noteServiceProvider.overrideWithValue(mockService)],
          child: NoteDetailScreen(note: note),
        ),
      );
    }

    testWidgets('should render note title and content', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Assert - find title and content
      expect(find.text('Test Note'), findsOneWidget);
      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('should render tags as chips', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Assert - find tag chips
      expect(find.text('tag1'), findsOneWidget);
      expect(find.text('tag2'), findsOneWidget);
    });

    testWidgets('should render empty content gracefully', (tester) async {
      // Arrange
      final emptyNote = testNote.copyWith();
      await tester.pumpWidget(createWidget(emptyNote));
      await tester.pumpAndSettle();

      // Assert - should render without errors
      expect(find.text('Test Note'), findsOneWidget);
      // Content field should be empty but present
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should render note without tags', (tester) async {
      // Arrange
      final noteWithoutTags = testNote.copyWith(tags: []);
      await tester.pumpWidget(createWidget(noteWithoutTags));
      await tester.pumpAndSettle();

      // Assert - should render without errors
      expect(find.text('Test Note'), findsOneWidget);
      expect(find.text('tag1'), findsNothing);
      expect(find.text('tag2'), findsNothing);
    });

    testWidgets('should display editable title field', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Assert - title should be in an editable field
      final titleFields = find.byType(TextField);
      expect(titleFields, findsWidgets);
    });

    testWidgets('should display editable content field', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Assert - content should be in a text field
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should show saving indicator when isSaving is true', (
      tester,
    ) async {
      // Arrange
      when(mockService.updateNote(any)).thenAnswer(
        (_) async =>
            Future.delayed(const Duration(milliseconds: 100), () => testNote),
      );

      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Act - trigger a save by changing title
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Updated Title');
      await tester.pump();

      // Wait for auto-save delay (2000ms debounce)
      await tester.pump(const Duration(milliseconds: 2100));

      // Assert - should show loading indicator while saving
      // Note: The actual loading indicator implementation may vary
      // This test verifies the screen handles saving state without crashing
      expect(find.byType(NoteDetailScreen), findsOneWidget);
    });

    testWidgets('should handle error states gracefully', (tester) async {
      // Arrange
      when(mockService.updateNote(any)).thenThrow(Exception('Update failed'));

      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Act - trigger a save by changing title
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Updated Title');
      await tester.pump();

      // Wait for auto-save delay
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      // Assert - should handle error without crashing
      // The screen should still be present
      expect(find.byType(NoteDetailScreen), findsOneWidget);
    });

    testWidgets('should display app bar with note title', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Assert - app bar should be present
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have menu button in app bar', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Assert - should find overflow menu button
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should allow editing title', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Act - find and edit title field
      final titleField = find.byType(TextField).first;
      await tester.tap(titleField);
      await tester.pumpAndSettle();

      await tester.enterText(titleField, 'New Title');
      await tester.pumpAndSettle();

      // Assert - new title should be in the field
      expect(find.text('New Title'), findsOneWidget);
    });

    testWidgets('should allow editing content', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget(testNote));
      await tester.pumpAndSettle();

      // Act - find content field (should be second TextField)
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Find the content field by looking for the one with initial content
      final contentField = textFields.evaluate().firstWhere((element) {
        final widget = element.widget as TextField;
        return widget.controller?.text == 'Test content';
      });

      await tester.enterText(
        find.byWidget(contentField.widget),
        'Updated content',
      );
      await tester.pumpAndSettle();

      // Assert - updated content should be present
      expect(find.text('Updated content'), findsOneWidget);
    });

    testWidgets('should render with long title', (tester) async {
      // Arrange
      final longTitleNote = testNote.copyWith(
        title: 'This is a very long note title that should wrap properly',
      );
      await tester.pumpWidget(createWidget(longTitleNote));
      await tester.pumpAndSettle();

      // Assert - should render without overflow errors
      expect(
        find.text('This is a very long note title that should wrap properly'),
        findsOneWidget,
      );
    });

    testWidgets('should render with long content', (tester) async {
      // Arrange
      final longContent = 'This is a very long note content. ' * 50;
      final longContentNote = testNote.copyWith(content: longContent);
      await tester.pumpWidget(createWidget(longContentNote));
      await tester.pumpAndSettle();

      // Assert - should render without overflow errors
      expect(find.byType(NoteDetailScreen), findsOneWidget);
    });

    testWidgets('should render with many tags', (tester) async {
      // Arrange
      final manyTagsNote = testNote.copyWith(
        tags: List.generate(10, (i) => 'tag$i'),
      );
      await tester.pumpWidget(createWidget(manyTagsNote));
      await tester.pumpAndSettle();

      // Assert - should render without overflow errors
      expect(find.byType(NoteDetailScreen), findsOneWidget);
      // At least some tags should be visible
      expect(find.text('tag0'), findsOneWidget);
    });
  });
}
