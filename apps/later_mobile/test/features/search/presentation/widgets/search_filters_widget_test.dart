import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/chips/filter_chip.dart';
import 'package:later_mobile/features/search/presentation/widgets/search_filters_widget.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

import '../../../../test_helpers.dart';

void main() {
  group('SearchFiltersWidget - Initial Render', () {
    testWidgets('renders all 6 filter chips', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      // Verify 6 filter chips are rendered
      // 1. All, 2. Notes, 3. Tasks, 4. Lists, 5. Todo Items, 6. List Items
      expect(find.byType(TemporalFilterChip), findsNWidgets(6));
    });

    testWidgets('renders chips with correct localized labels', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      final context = tester.element(find.byType(SearchFiltersWidget));
      final l10n = AppLocalizations.of(context)!;

      // Verify all 6 chip labels are present
      expect(find.text(l10n.filterAll), findsOneWidget);
      expect(find.text(l10n.filterNotes), findsOneWidget);
      expect(find.text(l10n.filterTodoLists), findsOneWidget);
      expect(find.text(l10n.filterLists), findsOneWidget);
      expect(find.text(l10n.filterTodoItems), findsOneWidget);
      expect(find.text(l10n.filterListItems), findsOneWidget);
    });

    testWidgets('chips are wrapped in horizontal scrollable container',
        (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      // Verify SingleChildScrollView exists with horizontal scroll
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, equals(Axis.horizontal));
    });

    testWidgets('chips have correct spacing and padding', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      // Verify Wrap widget has correct spacing
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, equals(12.0)); // Actual spacing used in implementation
    });
  });

  group('SearchFiltersWidget - Default Selection State', () {
    testWidgets('"All" filter is selected by default', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      final context = tester.element(find.byType(SearchFiltersWidget));
      final l10n = AppLocalizations.of(context)!;

      // Find the "All" chip
      final allChip = tester.widget<TemporalFilterChip>(
        find.ancestor(
          of: find.text(l10n.filterAll),
          matching: find.byType(TemporalFilterChip),
        ),
      );

      // Verify "All" is selected by default
      expect(allChip.isSelected, isTrue);
    });

    testWidgets('other filters are not selected by default', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      final context = tester.element(find.byType(SearchFiltersWidget));
      final l10n = AppLocalizations.of(context)!;

      // Find and verify each non-"All" chip is not selected
      final filterLabels = [
        l10n.filterNotes,
        l10n.filterTodoLists,
        l10n.filterLists,
        l10n.filterTodoItems,
        l10n.filterListItems,
      ];

      for (final label in filterLabels) {
        final chip = tester.widget<TemporalFilterChip>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(TemporalFilterChip),
          ),
        );
        expect(chip.isSelected, isFalse, reason: '$label should not be selected');
      }
    });
  });

  group('SearchFiltersWidget - Localization', () {
    testWidgets('all chip labels use localized strings', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      final context = tester.element(find.byType(SearchFiltersWidget));
      final l10n = AppLocalizations.of(context)!;

      // Verify localized strings are used
      expect(find.text(l10n.filterAll), findsOneWidget);
      expect(find.text(l10n.filterNotes), findsOneWidget);
      expect(find.text(l10n.filterTodoLists), findsOneWidget);
      expect(find.text(l10n.filterLists), findsOneWidget);
      expect(find.text(l10n.filterTodoItems), findsOneWidget);
      expect(find.text(l10n.filterListItems), findsOneWidget);
    });

    testWidgets('chip labels match localized values', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SearchFiltersWidget(),
        ),
      );

      final context = tester.element(find.byType(SearchFiltersWidget));
      final l10n = AppLocalizations.of(context)!;

      // Get all chip widgets
      final chips = tester.widgetList<TemporalFilterChip>(
        find.byType(TemporalFilterChip),
      );

      // Extract labels from chips
      final chipLabels = chips.map((chip) => chip.label).toList();

      // Verify all localized labels are present in the widget tree
      final expectedLabels = [
        l10n.filterAll,
        l10n.filterNotes,
        l10n.filterTodoLists,
        l10n.filterLists,
        l10n.filterTodoItems,
        l10n.filterListItems,
      ];

      for (final expectedLabel in expectedLabels) {
        expect(
          chipLabels,
          contains(expectedLabel),
          reason: 'Chip labels should contain $expectedLabel',
        );
      }
    });
  });
}
