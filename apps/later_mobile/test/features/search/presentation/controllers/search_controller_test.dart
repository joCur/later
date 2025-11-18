import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/enums/content_type.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';
import 'package:later_mobile/features/search/presentation/controllers/search_controller.dart';
import 'package:later_mobile/features/search/application/services/search_service.dart';
import 'package:later_mobile/features/search/application/providers.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:riverpod/riverpod.dart';

@GenerateNiceMocks([MockSpec<SearchService>()])
import 'search_controller_test.mocks.dart';

void main() {
  late MockSearchService mockSearchService;
  late ProviderContainer container;

  setUp(() {
    mockSearchService = MockSearchService();
    container = ProviderContainer(
      overrides: [
        searchServiceProvider.overrideWithValue(mockSearchService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SearchController', () {
    test('build() returns empty list initially', () async {
      // Wait for initial build to complete
      final state = await container.read(searchControllerProvider.future);

      expect(state, isEmpty);
    });

    test('search() sets loading state immediately', () async {
      final query = SearchQuery(
        query: 'test',
        spaceId: 'space-1',
      );

      when(mockSearchService.search(any))
          .thenAnswer((_) async => Future.delayed(
                const Duration(milliseconds: 500),
                () => <SearchResult>[],
              ));

      final controller = container.read(searchControllerProvider.notifier);
      controller.search(query);

      // Should be in loading state immediately
      await Future.delayed(Duration.zero);
      final state = container.read(searchControllerProvider);
      expect(state.isLoading, true);
    });

    test('search() debounces multiple calls within 300ms', () async {
      final query1 = SearchQuery(query: 'test1', spaceId: 'space-1');
      final query2 = SearchQuery(query: 'test2', spaceId: 'space-1');
      final query3 = SearchQuery(query: 'test3', spaceId: 'space-1');

      // Mock each query separately
      when(mockSearchService.search(query1))
          .thenAnswer((_) async => <SearchResult>[]);
      when(mockSearchService.search(query2))
          .thenAnswer((_) async => <SearchResult>[]);
      when(mockSearchService.search(query3))
          .thenAnswer((_) async => <SearchResult>[]);

      // Keep provider alive by listening
      final subscription = container.listen(
        searchControllerProvider,
        (previous, next) {},
      );

      // Wait for initial build
      await container.read(searchControllerProvider.future);

      final controller = container.read(searchControllerProvider.notifier);

      // Call search three times rapidly
      controller.search(query1);
      await Future.delayed(const Duration(milliseconds: 100));
      controller.search(query2);
      await Future.delayed(const Duration(milliseconds: 100));
      controller.search(query3);

      // Wait for debounce to complete
      await Future.delayed(const Duration(milliseconds: 400));

      // Should only call service once with the last query
      verify(mockSearchService.search(query3)).called(1);
      verifyNever(mockSearchService.search(query1));
      verifyNever(mockSearchService.search(query2));

      // Clean up
      subscription.close();
    });

    test('search() updates state with results on success', () async {
      // Wait for initial build to complete
      await container.read(searchControllerProvider.future);

      final query = SearchQuery(query: 'test', spaceId: 'space-1');
      final results = [
        SearchResult(
          id: '1',
          type: ContentType.note,
          title: 'Test Note',
          subtitle: null,
          preview: 'Test content',
          tags: [],
          updatedAt: DateTime.now(),
          content: null,
        ),
      ];

      when(mockSearchService.search(query)).thenAnswer((_) async => results);

      // Listen to state changes
      List<SearchResult>? capturedResults;
      container.listen(
        searchControllerProvider,
        (previous, next) {
          if (next.hasValue && next.value!.isNotEmpty) {
            capturedResults = next.value;
          }
        },
      );

      final controller = container.read(searchControllerProvider.notifier);
      controller.search(query);

      // Wait for debounce and search to complete
      await Future.delayed(const Duration(milliseconds: 400));

      expect(capturedResults, equals(results));
    });

    test('search() handles AppError correctly', () async {
      final query = SearchQuery(query: 'test', spaceId: 'space-1');
      final error = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Database timeout',
      );

      when(mockSearchService.search(query)).thenThrow(error);

      final controller = container.read(searchControllerProvider.notifier);

      // Listen to state changes
      var hasError = false;
      Object? capturedError;
      container.listen(
        searchControllerProvider,
        (previous, next) {
          if (next.hasError) {
            hasError = true;
            capturedError = next.error;
          }
        },
      );

      controller.search(query);

      // Wait for debounce and search to complete
      await Future.delayed(const Duration(milliseconds: 400));

      expect(hasError, true);
      expect(capturedError, equals(error));
    });

    test('search() wraps unknown errors in AppError', () async {
      final query = SearchQuery(query: 'test', spaceId: 'space-1');
      final unknownError = Exception('Unknown error');

      when(mockSearchService.search(query)).thenThrow(unknownError);

      final controller = container.read(searchControllerProvider.notifier);

      // Listen to state changes
      var hasError = false;
      AppError? capturedError;
      container.listen(
        searchControllerProvider,
        (previous, next) {
          if (next.hasError) {
            hasError = true;
            capturedError = next.error as AppError;
          }
        },
      );

      controller.search(query);

      // Wait for debounce and search to complete
      await Future.delayed(const Duration(milliseconds: 400));

      expect(hasError, true);
      expect(capturedError, isA<AppError>());
      expect(capturedError!.code, equals(ErrorCode.unknownError));
    });

    test('clear() resets state to empty list', () async {
      final query = SearchQuery(query: 'test', spaceId: 'space-1');
      final results = [
        SearchResult(
          id: '1',
          type: ContentType.note,
          title: 'Test Note',
          subtitle: null,
          preview: 'Test content',
          tags: [],
          updatedAt: DateTime.now(),
          content: null,
        ),
      ];

      when(mockSearchService.search(query)).thenAnswer((_) async => results);

      final controller = container.read(searchControllerProvider.notifier);

      // Listen to state changes
      List<SearchResult>? capturedResults;
      container.listen(
        searchControllerProvider,
        (previous, next) {
          if (next.hasValue) {
            capturedResults = next.value;
          }
        },
      );

      // First, perform a search to get results
      controller.search(query);
      await Future.delayed(const Duration(milliseconds: 400));

      // Verify we have results
      expect(capturedResults, equals(results));

      // Now clear
      controller.clear();

      // State should be empty
      expect(capturedResults, isEmpty);
    });

    test('clear() cancels pending debounced search', () async {
      final query = SearchQuery(query: 'test', spaceId: 'space-1');

      when(mockSearchService.search(any))
          .thenAnswer((_) async => <SearchResult>[]);

      final controller = container.read(searchControllerProvider.notifier);

      // Start a search (will be debounced)
      controller.search(query);

      // Clear immediately (before debounce timer fires)
      await Future.delayed(const Duration(milliseconds: 100));
      controller.clear();

      // Wait past the debounce time
      await Future.delayed(const Duration(milliseconds: 400));

      // Service should never be called since we cleared before timer fired
      verifyNever(mockSearchService.search(any));
    });

    test('dispose() cancels debounce timer to prevent memory leaks', () async {
      final query = SearchQuery(query: 'test', spaceId: 'space-1');

      when(mockSearchService.search(any))
          .thenAnswer((_) async => <SearchResult>[]);

      final controller = container.read(searchControllerProvider.notifier);

      // Start a search (will be debounced)
      controller.search(query);

      // Dispose the container immediately
      await Future.delayed(const Duration(milliseconds: 100));
      container.dispose();

      // Wait past the debounce time
      await Future.delayed(const Duration(milliseconds: 400));

      // Service should never be called since we disposed before timer fired
      verifyNever(mockSearchService.search(any));
    });

    test('search() respects ref.mounted when updating state', () async {
      final query = SearchQuery(query: 'test', spaceId: 'space-1');
      final results = [
        SearchResult(
          id: '1',
          type: ContentType.note,
          title: 'Test Note',
          subtitle: null,
          preview: 'Test content',
          tags: [],
          updatedAt: DateTime.now(),
          content: null,
        ),
      ];

      // Simulate a slow search
      when(mockSearchService.search(query)).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 200),
          () => results,
        ),
      );

      final controller = container.read(searchControllerProvider.notifier);
      controller.search(query);

      // Dispose immediately after search starts (before it completes)
      await Future.delayed(const Duration(milliseconds: 350));
      container.dispose();

      // Wait for search to complete
      await Future.delayed(const Duration(milliseconds: 200));

      // Test passes if no exception is thrown
      // (ref.mounted check prevents updating disposed provider)
    });
  });
}
