import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/enums/content_type.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';
import 'package:later_mobile/features/search/presentation/controllers/search_filters_controller.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SearchFiltersController', () {
    test('build() returns default filters (all types, no tags)', () {
      final filters = container.read(searchFiltersControllerProvider);

      expect(filters.contentTypes, isNull);
      expect(filters.tags, isNull);
      expect(filters.hasActiveFilters, false);
    });

    test('setContentTypes() updates contentTypes filter', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setContentTypes([ContentType.note, ContentType.todoList]);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, equals([ContentType.note, ContentType.todoList]));
      expect(filters.hasActiveFilters, true);
    });

    test('setContentTypes() with null clears contentTypes filter', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      // First set some types
      controller.setContentTypes([ContentType.note]);
      expect(
        container.read(searchFiltersControllerProvider).hasActiveFilters,
        true,
      );

      // Then clear
      controller.setContentTypes(null);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, isNull);
      expect(filters.hasActiveFilters, false);
    });

    test('setContentTypes() with empty list is treated as no filter', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setContentTypes([]);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, isEmpty);
      expect(filters.hasActiveFilters, false);
    });

    test('setTags() updates tags filter', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setTags(['work', 'urgent']);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.tags, equals(['work', 'urgent']));
      expect(filters.hasActiveFilters, true);
    });

    test('setTags() with null clears tags filter', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      // First set some tags
      controller.setTags(['work']);
      expect(
        container.read(searchFiltersControllerProvider).hasActiveFilters,
        true,
      );

      // Then clear
      controller.setTags(null);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.tags, isNull);
      expect(filters.hasActiveFilters, false);
    });

    test('setTags() with empty list is treated as no filter', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setTags([]);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.tags, isEmpty);
      expect(filters.hasActiveFilters, false);
    });

    test('reset() clears all filters', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      // Set multiple filters
      controller.setContentTypes([ContentType.note]);
      controller.setTags(['work']);

      // Verify filters are set
      var filters = container.read(searchFiltersControllerProvider);
      expect(filters.hasActiveFilters, true);

      // Reset
      controller.reset();

      // Verify all filters cleared
      filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, isNull);
      expect(filters.tags, isNull);
      expect(filters.hasActiveFilters, false);
    });

    test('hasActiveFilters returns true when contentTypes is set', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setContentTypes([ContentType.note]);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when tags is set', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setTags(['work']);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when both filters are set', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setContentTypes([ContentType.note]);
      controller.setTags(['work']);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.hasActiveFilters, true);
    });

    test('hasActiveFilters returns false when no filters are set', () {
      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.hasActiveFilters, false);
    });

    test('hasActiveFilters returns false when filters are empty lists', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      controller.setContentTypes([]);
      controller.setTags([]);

      final filters = container.read(searchFiltersControllerProvider);
      expect(filters.hasActiveFilters, false);
    });

    test('multiple setContentTypes() calls update state correctly', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      // First call
      controller.setContentTypes([ContentType.note]);
      var filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, equals([ContentType.note]));

      // Second call
      controller.setContentTypes([ContentType.todoList, ContentType.list]);
      filters = container.read(searchFiltersControllerProvider);
      expect(
        filters.contentTypes,
        equals([ContentType.todoList, ContentType.list]),
      );
    });

    test('multiple setTags() calls update state correctly', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      // First call
      controller.setTags(['work']);
      var filters = container.read(searchFiltersControllerProvider);
      expect(filters.tags, equals(['work']));

      // Second call
      controller.setTags(['personal', 'urgent']);
      filters = container.read(searchFiltersControllerProvider);
      expect(filters.tags, equals(['personal', 'urgent']));
    });

    test('contentTypes and tags filters are independent', () {
      final controller =
          container.read(searchFiltersControllerProvider.notifier);

      // Set contentTypes
      controller.setContentTypes([ContentType.note]);
      var filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, isNotNull);
      expect(filters.tags, isNull);

      // Set tags (should not affect contentTypes)
      controller.setTags(['work']);
      filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, equals([ContentType.note]));
      expect(filters.tags, equals(['work']));

      // Clear contentTypes (should not affect tags)
      controller.setContentTypes(null);
      filters = container.read(searchFiltersControllerProvider);
      expect(filters.contentTypes, isNull);
      expect(filters.tags, equals(['work']));
    });
  });
}
