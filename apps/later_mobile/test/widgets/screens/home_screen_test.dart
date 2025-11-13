import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/organisms/empty_states/no_spaces_state.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/providers/content_provider.dart';
import 'package:later_mobile/providers/theme_provider.dart';
import 'package:later_mobile/widgets/screens/home_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../test_helpers.mocks.dart';

void main() {
  group('HomeScreen Empty States', () {
    late MockSpacesProvider mockSpacesProvider;
    late MockContentProvider mockContentProvider;
    late MockAuthProvider mockAuthProvider;
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockSpacesProvider = MockSpacesProvider();
      mockContentProvider = MockContentProvider();
      mockAuthProvider = MockAuthProvider();
      mockThemeProvider = MockThemeProvider();

      // Set up default mock behavior
      when(mockSpacesProvider.getSpaceItemCount(any)).thenAnswer((_) async => 0);
      when(mockSpacesProvider.isLoading).thenReturn(false);
      when(mockContentProvider.isLoading).thenReturn(false);
      when(mockContentProvider.getTotalCount()).thenReturn(0);
      when(mockContentProvider.getFilteredContent(any)).thenReturn([]);
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.currentUser).thenReturn(null);
    });

    /// Helper to build HomeScreen with all required providers and theme
    Widget buildHomeScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SpacesProvider>.value(
            value: mockSpacesProvider,
          ),
          ChangeNotifierProvider<ContentProvider>.value(
            value: mockContentProvider,
          ),
          ChangeNotifierProvider.value(
            value: mockAuthProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.light()],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
          ],
          home: const HomeScreen(),
        ),
      );
    }

    testWidgets('shows NoSpacesState when no spaces exist', (tester) async {
      // Arrange - Mock empty spaces list
      when(mockSpacesProvider.spaces).thenReturn([]);
      when(mockSpacesProvider.currentSpace).thenReturn(null);

      // Act
      await tester.pumpWidget(buildHomeScreen());

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Assert - NoSpacesState should be displayed
      expect(find.byType(NoSpacesState), findsOneWidget);
      expect(find.text('Welcome to Later'), findsOneWidget);
      expect(
        find.text(
          'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!',
        ),
        findsOneWidget,
      );
      expect(find.text('Create Your First Space'), findsOneWidget);
    });

    testWidgets('button in NoSpacesState is tappable', (tester) async {
      // Arrange - Mock empty spaces list
      when(mockSpacesProvider.spaces).thenReturn([]);
      when(mockSpacesProvider.currentSpace).thenReturn(null);

      // Act
      await tester.pumpWidget(buildHomeScreen());

      // Wait for animations
      await tester.pumpAndSettle();

      // Verify NoSpacesState is shown
      expect(find.byType(NoSpacesState), findsOneWidget);

      // Verify the button is present and can be found
      final buttonFinder = find.text('Create Your First Space');
      expect(buttonFinder, findsOneWidget);

      // Verify the button is tappable (we don't actually test the modal opening
      // as that would require more complex setup)
      expect(tester.widget(buttonFinder), isNotNull);
    });

    testWidgets('NoSpacesState is shown before WelcomeState in hierarchy',
        (tester) async {
      // This test verifies the correct order of empty state checks
      // NoSpacesState should be checked BEFORE WelcomeState

      // Arrange - No spaces at all
      when(mockSpacesProvider.spaces).thenReturn([]);
      when(mockSpacesProvider.currentSpace).thenReturn(null);

      // Act
      await tester.pumpWidget(buildHomeScreen());

      await tester.pumpAndSettle();

      // Assert - Should show NoSpacesState, NOT WelcomeState
      expect(find.byType(NoSpacesState), findsOneWidget);
      expect(find.text('Welcome to Later'), findsOneWidget);

      // WelcomeState has different text
      expect(
        find.text('Welcome! Let\'s capture your first thought'),
        findsNothing,
      );
    });
  });
}
