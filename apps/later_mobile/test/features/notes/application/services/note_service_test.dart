import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/notes/application/services/note_service.dart';
import 'package:later_mobile/features/notes/data/repositories/note_repository.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([NoteRepository])
import 'note_service_test.mocks.dart';

void main() {
  group('NoteService', () {
    late MockNoteRepository mockRepository;
    late NoteService service;

    setUp(() {
      mockRepository = MockNoteRepository();
      service = NoteService(repository: mockRepository);
    });

    group('getNotesForSpace', () {
      test('should load and sort notes by updatedAt descending', () async {
        // Arrange
        final testNotes = [
          Note(
            id: '1',
            title: 'Old Note',
            spaceId: 'space-1',
            userId: 'user-1',
            updatedAt: DateTime(2025),
          ),
          Note(
            id: '2',
            title: 'New Note',
            spaceId: 'space-1',
            userId: 'user-1',
            updatedAt: DateTime(2025, 1, 2),
          ),
          Note(
            id: '3',
            title: 'Newest Note',
            spaceId: 'space-1',
            userId: 'user-1',
            updatedAt: DateTime(2025, 1, 3),
          ),
        ];
        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => testNotes);

        // Act
        final result = await service.getNotesForSpace('space-1');

        // Assert
        expect(result.length, 3);
        expect(result[0].id, '3'); // Most recent first
        expect(result[1].id, '2');
        expect(result[2].id, '1'); // Oldest last
        verify(mockRepository.getBySpace('space-1')).called(1);
      });

      test('should return empty list when no notes exist', () async {
        // Arrange
        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => []);

        // Act
        final result = await service.getNotesForSpace('space-1');

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getBySpace('space-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Database error',
        );
        when(mockRepository.getBySpace('space-1')).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.getNotesForSpace('space-1'),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        when(mockRepository.getBySpace('space-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.getNotesForSpace('space-1'),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('createNote', () {
      test('should create note with valid title', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: 'New Note',
          content: 'Note content',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testNote);

        // Act
        final result = await service.createNote(testNote);

        // Assert
        expect(result, testNote);
        verify(mockRepository.create(testNote)).called(1);
      });

      test('should throw ValidationError when title is empty', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: '',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.createNote(testNote),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.create(any));
      });

      test('should throw ValidationError when title is only whitespace',
          () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: '   ',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.createNote(testNote),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.create(any));
      });

      test('should create note with valid title containing whitespace',
          () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: '  Valid Title  ',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testNote);

        // Act
        final result = await service.createNote(testNote);

        // Assert
        expect(result, testNote);
        verify(mockRepository.create(testNote)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: 'New Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        const expectedError = AppError(
          code: ErrorCode.databaseUniqueConstraint,
          message: 'Note already exists',
        );
        when(mockRepository.create(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.createNote(testNote),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: 'New Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.createNote(testNote),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('updateNote', () {
      test('should update note with valid title', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: 'Updated Note',
          content: 'Updated content',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenAnswer((_) async => testNote);

        // Act
        final result = await service.updateNote(testNote);

        // Assert
        expect(result, testNote);
        verify(mockRepository.update(testNote)).called(1);
      });

      test('should throw ValidationError when title is empty', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: '',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.updateNote(testNote),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.update(any));
      });

      test('should throw ValidationError when title is only whitespace',
          () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: '   ',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.updateNote(testNote),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.update(any));
      });

      test('should update note with valid title containing whitespace',
          () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: '  Updated Title  ',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenAnswer((_) async => testNote);

        // Act
        final result = await service.updateNote(testNote);

        // Assert
        expect(result, testNote);
        verify(mockRepository.update(testNote)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: 'Updated Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        const expectedError = AppError(
          code: ErrorCode.noteNotFound,
          message: 'Note not found',
        );
        when(mockRepository.update(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.updateNote(testNote),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        final testNote = Note(
          id: '1',
          title: 'Updated Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.updateNote(testNote),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('deleteNote', () {
      test('should delete note successfully', () async {
        // Arrange
        when(mockRepository.delete('note-1')).thenAnswer((_) async => {});

        // Act
        await service.deleteNote('note-1');

        // Assert
        verify(mockRepository.delete('note-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.noteNotFound,
          message: 'Note not found',
        );
        when(mockRepository.delete('note-1')).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.deleteNote('note-1'),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        when(mockRepository.delete('note-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.deleteNote('note-1'),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('toggleFavorite', () {
      test('should throw AppError indicating not implemented', () async {
        // Act & Assert
        expect(
          () => service.toggleFavorite('note-1'),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('archiveNote', () {
      test('should throw AppError indicating not implemented', () async {
        // Act & Assert
        expect(
          () => service.archiveNote('note-1'),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('unarchiveNote', () {
      test('should throw AppError indicating not implemented', () async {
        // Act & Assert
        expect(
          () => service.unarchiveNote('note-1'),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });
  });
}
