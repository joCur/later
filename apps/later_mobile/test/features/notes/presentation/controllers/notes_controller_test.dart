import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/notes/application/providers.dart';
import 'package:later_mobile/features/notes/application/services/note_service.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/notes/presentation/controllers/notes_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([NoteService])
import 'notes_controller_test.mocks.dart';

void main() {
  group('NotesController', () {
    late MockNoteService mockService;

    setUp(() {
      mockService = MockNoteService();
    });

    group('build (initialization)', () {
      test('should load notes for space on initialization', () async {
        // Arrange
        final testNotes = [
          Note(
            id: '1',
            title: 'Note 1',
            spaceId: 'space-1',
            userId: 'user-1',
          ),
          Note(
            id: '2',
            title: 'Note 2',
            spaceId: 'space-1',
            userId: 'user-1',
          ),
        ];
        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => testNotes);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state =
            await container.read(notesControllerProvider('space-1').future);

        // Assert
        expect(state, testNotes);
        verify(mockService.getNotesForSpace('space-1')).called(1);
      });

      test('should initialize with empty list when no notes exist', () async {
        // Arrange
        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => []);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state =
            await container.read(notesControllerProvider('space-1').future);

        // Assert
        expect(state, isEmpty);
      });
    });

    group('refresh', () {
      test('should set loading state then reload notes', () async {
        // Arrange
        final initialNotes = [
          Note(id: '1', title: 'Note 1', spaceId: 'space-1', userId: 'user-1'),
        ];
        final refreshedNotes = [
          Note(id: '1', title: 'Note 1', spaceId: 'space-1', userId: 'user-1'),
          Note(id: '2', title: 'Note 2', spaceId: 'space-1', userId: 'user-1'),
        ];

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => initialNotes);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Update mock to return refreshed notes
        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => refreshedNotes);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        final future = controller.refresh();

        // Verify loading state
        expect(
          container.read(notesControllerProvider('space-1')).isLoading,
          true,
        );

        // Wait for completion
        await future;

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasValue, true);
        expect(finalState.value?.length, 2);
        expect(finalState.hasError, false);
      });

      test('should set error state when refresh fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.networkTimeout,
          message: 'Network timeout',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => []);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Update mock to throw error on refresh
        when(mockService.getNotesForSpace('space-1'))
            .thenThrow(expectedError);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.refresh();

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });
    });

    group('createNote', () {
      test('should create note and add to beginning of state', () async {
        // Arrange
        final existingNotes = [
          Note(
            id: '1',
            title: 'Existing Note',
            spaceId: 'space-1',
            userId: 'user-1',
            updatedAt: DateTime(2025),
          ),
        ];
        final newNote = Note(
          id: '2',
          title: 'New Note',
          spaceId: 'space-1',
          userId: 'user-1',
          updatedAt: DateTime(2025, 1, 2),
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => existingNotes);
        when(mockService.createNote(any)).thenAnswer((_) async => newNote);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.createNote(newNote);

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.value?.length, 2);
        expect(finalState.value?.first.id, '2'); // New note at beginning
        expect(finalState.value?.last.id, '1');
        verify(mockService.createNote(newNote)).called(1);
      });

      test('should set error state when create fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'Title is required',
        );
        final newNote = Note(
          id: '1',
          title: '',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => []);
        when(mockService.createNote(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.createNote(newNote);

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final newNote = Note(
          id: '1',
          title: 'New Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => []);
        when(mockService.createNote(any)).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return newNote;
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        // Start creation but dispose immediately
        unawaited(controller.createNote(newNote));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('updateNote', () {
      test('should update note and re-sort by updatedAt', () async {
        // Arrange
        final note1 = Note(
          id: '1',
          title: 'Note 1',
          spaceId: 'space-1',
          userId: 'user-1',
          updatedAt: DateTime(2025, 1, 3),
        );
        final note2 = Note(
          id: '2',
          title: 'Note 2',
          spaceId: 'space-1',
          userId: 'user-1',
          updatedAt: DateTime(2025, 1, 2),
        );
        final note3 = Note(
          id: '3',
          title: 'Note 3',
          spaceId: 'space-1',
          userId: 'user-1',
          updatedAt: DateTime(2025),
        );

        // Initial state: [note1, note2, note3] (sorted by updatedAt desc)
        final initialNotes = [note1, note2, note3];

        // Update note3 with new updatedAt (should move to front)
        final updatedNote3 = note3.copyWith(
          title: 'Updated Note 3',
          updatedAt: DateTime(2025, 1, 4),
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => initialNotes);
        when(mockService.updateNote(any))
            .thenAnswer((_) async => updatedNote3);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.updateNote(note3);

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.value?.length, 3);
        // note3 should now be at the front (most recent)
        expect(finalState.value?[0].id, '3');
        expect(finalState.value?[0].title, 'Updated Note 3');
        expect(finalState.value?[1].id, '1');
        expect(finalState.value?[2].id, '2');
        verify(mockService.updateNote(note3)).called(1);
      });

      test('should not update state if note not found', () async {
        // Arrange
        final existingNote = Note(
          id: '1',
          title: 'Existing',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final nonExistentNote = Note(
          id: '999',
          title: 'Not Found',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [existingNote]);
        when(mockService.updateNote(any))
            .thenAnswer((_) async => nonExistentNote);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.updateNote(nonExistentNote);

        // Assert - state should remain unchanged
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first, existingNote);
      });

      test('should set error state when update fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.noteNotFound,
          message: 'Note not found',
        );
        final note = Note(
          id: '1',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note]);
        when(mockService.updateNote(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.updateNote(note);

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final note = Note(
          id: '1',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final updatedNote = note.copyWith(title: 'Updated Note');

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note]);
        when(mockService.updateNote(any)).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return updatedNote;
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        // Start update but dispose immediately
        unawaited(controller.updateNote(note));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('deleteNote', () {
      test('should delete note and remove from state', () async {
        // Arrange
        final note1 = Note(
          id: '1',
          title: 'Note 1',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final note2 = Note(
          id: '2',
          title: 'Note 2',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note1, note2]);
        when(mockService.deleteNote('1')).thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.deleteNote('1');

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.id, '2');
        verify(mockService.deleteNote('1')).called(1);
      });

      test('should set error state when delete fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.noteNotFound,
          message: 'Note not found',
        );
        final note = Note(
          id: '1',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note]);
        when(mockService.deleteNote('1')).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.deleteNote('1');

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final note = Note(
          id: '1',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note]);
        when(mockService.deleteNote('1')).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        // Start deletion but dispose immediately
        unawaited(controller.deleteNote('1'));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('toggleFavorite', () {
      test('should handle error from not implemented feature', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.unknownError,
          message: 'Favorite feature not yet implemented for notes',
        );
        final note = Note(
          id: '1',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note]);
        when(mockService.toggleFavorite('1')).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.toggleFavorite('1');

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });
    });

    group('archiveNote', () {
      test('should handle error from not implemented feature', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.unknownError,
          message: 'Archive feature not yet implemented for notes',
        );
        final note = Note(
          id: '1',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note]);
        when(mockService.archiveNote('1')).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.archiveNote('1');

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });
    });

    group('unarchiveNote', () {
      test('should handle error from not implemented feature', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.unknownError,
          message: 'Archive feature not yet implemented for notes',
        );
        final note = Note(
          id: '1',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        when(mockService.getNotesForSpace('space-1'))
            .thenAnswer((_) async => [note]);
        when(mockService.unarchiveNote('1')).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            noteServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(notesControllerProvider('space-1').future);

        // Act
        final controller =
            container.read(notesControllerProvider('space-1').notifier);
        await controller.unarchiveNote('1');

        // Assert
        final finalState = container.read(notesControllerProvider('space-1'));
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });
    });
  });
}
