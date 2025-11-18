import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/enums/content_type.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/search/application/services/search_service.dart';
import 'package:later_mobile/features/search/data/repositories/search_repository.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SearchRepository>()])
import 'search_service_test.mocks.dart';

void main() {
  late SearchService searchService;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    searchService = SearchService(mockRepository);
  });

  group('SearchService', () {
    const testSpaceId = 'space-123';
    const testQuery = 'shopping';

    group('Constructor', () {
      test('should create instance with repository', () {
        expect(searchService, isNotNull);
      });
    });

    group('search method', () {
      test('should return empty list for empty query string', () async {
        // Arrange
        final query = SearchQuery(query: '', spaceId: testSpaceId);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, isEmpty);
        verifyNever(mockRepository.search(any));
      });

      test('should return empty list for whitespace-only query', () async {
        // Arrange
        final query = SearchQuery(query: '   ', spaceId: testSpaceId);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, isEmpty);
        verifyNever(mockRepository.search(any));
      });

      test('should throw validation error for empty spaceId', () async {
        // Arrange
        final query = SearchQuery(query: testQuery, spaceId: '');

        // Act & Assert
        expect(
          () => searchService.search(query),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.validationRequired,
            ),
          ),
        );
        verifyNever(mockRepository.search(any));
      });

      test('should trim whitespace from query string', () async {
        // Arrange
        final query = SearchQuery(query: '  shopping  ', spaceId: testSpaceId);

        final expectedResults = [
          SearchResult(
            id: 'note-1',
            type: ContentType.note,
            title: 'Shopping List',
            preview: 'Buy groceries',
            tags: const [],
            updatedAt: DateTime.now(),
            content: null,
          ),
        ];

        when(
          mockRepository.search(any),
        ).thenAnswer((_) async => expectedResults);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, expectedResults);
        final captured = verify(mockRepository.search(captureAny)).captured;
        final capturedQuery = captured.single as SearchQuery;
        expect(capturedQuery.query, 'shopping'); // Trimmed
      });

      test(
        'should throw validation error for query exceeding max length',
        () async {
          // Arrange
          final longQuery = 'a' * 501; // 501 characters
          final query = SearchQuery(query: longQuery, spaceId: testSpaceId);

          // Act & Assert
          expect(
            () => searchService.search(query),
            throwsA(
              isA<AppError>().having(
                (e) => e.code,
                'code',
                ErrorCode.validationOutOfRange,
              ),
            ),
          );
          verifyNever(mockRepository.search(any));
        },
      );

      test('should accept query at max length boundary (500 chars)', () async {
        // Arrange
        final maxQuery = 'a' * 500; // Exactly 500 characters
        final query = SearchQuery(query: maxQuery, spaceId: testSpaceId);

        final expectedResults = <SearchResult>[];
        when(
          mockRepository.search(any),
        ).thenAnswer((_) async => expectedResults);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, expectedResults);
        verify(mockRepository.search(any)).called(1);
      });

      test('should return empty list for empty contentTypes filter', () async {
        // Arrange
        final query = SearchQuery(
          query: testQuery,
          spaceId: testSpaceId,
          contentTypes: const [], // Empty list
        );

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, isEmpty);
        verifyNever(mockRepository.search(any));
      });

      test('should call repository with valid query', () async {
        // Arrange
        final query = SearchQuery(query: testQuery, spaceId: testSpaceId);

        final expectedResults = [
          SearchResult(
            id: 'note-1',
            type: ContentType.note,
            title: 'Shopping List',
            preview: 'Buy groceries',
            tags: const [],
            updatedAt: DateTime.now(),
            content: null,
          ),
        ];

        when(
          mockRepository.search(any),
        ).thenAnswer((_) async => expectedResults);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, expectedResults);
        verify(mockRepository.search(query)).called(1);
      });

      test('should call repository with contentTypes filter', () async {
        // Arrange
        final query = SearchQuery(
          query: testQuery,
          spaceId: testSpaceId,
          contentTypes: const [ContentType.note, ContentType.todoList],
        );

        final expectedResults = [
          SearchResult(
            id: 'note-1',
            type: ContentType.note,
            title: 'Shopping List',
            preview: 'Buy groceries',
            tags: const [],
            updatedAt: DateTime.now(),
            content: null,
          ),
        ];

        when(
          mockRepository.search(any),
        ).thenAnswer((_) async => expectedResults);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, expectedResults);
        verify(mockRepository.search(query)).called(1);
      });

      test('should call repository with tags filter', () async {
        // Arrange
        final query = SearchQuery(
          query: testQuery,
          spaceId: testSpaceId,
          tags: const ['work', 'important'],
        );

        final expectedResults = [
          SearchResult(
            id: 'note-1',
            type: ContentType.note,
            title: 'Shopping List',
            preview: 'Buy groceries',
            tags: const ['work'],
            updatedAt: DateTime.now(),
            content: null,
          ),
        ];

        when(
          mockRepository.search(any),
        ).thenAnswer((_) async => expectedResults);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, expectedResults);
        verify(mockRepository.search(query)).called(1);
      });

      test('should propagate repository errors as AppError', () async {
        // Arrange
        final query = SearchQuery(query: testQuery, spaceId: testSpaceId);

        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Database timeout',
        );

        when(mockRepository.search(any)).thenThrow(error);

        // Act & Assert
        expect(
          () => searchService.search(query),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.databaseTimeout,
            ),
          ),
        );
      });

      test('should wrap unknown errors as AppError', () async {
        // Arrange
        final query = SearchQuery(query: testQuery, spaceId: testSpaceId);

        when(mockRepository.search(any)).thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => searchService.search(query),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });

      test('should return empty list when repository returns empty', () async {
        // Arrange
        final query = SearchQuery(query: testQuery, spaceId: testSpaceId);

        when(mockRepository.search(any)).thenAnswer((_) async => []);

        // Act
        final result = await searchService.search(query);

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.search(query)).called(1);
      });
    });
  });
}
