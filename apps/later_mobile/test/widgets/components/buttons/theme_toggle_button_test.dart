import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_theme.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/data/local/preferences_service.dart';
import 'package:later_mobile/features/theme/presentation/controllers/theme_controller.dart';
import 'package:later_mobile/design_system/atoms/buttons/theme_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock ThemeController for testing
class MockThemeController extends ThemeController {
  final ThemeMode initialMode;

  MockThemeController(this.initialMode);

  @override
  ThemeMode build() {
    return initialMode;
  }

  @override
  bool get isDarkMode => state == ThemeMode.dark;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
  }

  @override
  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.initialize();
  });

  Widget createTestWidget({ThemeMode initialThemeMode = ThemeMode.light}) {
    return ProviderScope(
      overrides: [
        themeControllerProvider.overrideWith(() => MockThemeController(initialThemeMode)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme.copyWith(
          extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.light()],
        ),
        darkTheme: AppTheme.darkTheme.copyWith(
          extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.dark()],
        ),
        themeMode: initialThemeMode,
        home: const Scaffold(body: ThemeToggleButton()),
      ),
    );
  }

  group('ThemeToggleButton', () {
    testWidgets('should render IconButton', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should display icon based on current theme', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Icon should be present (dark_mode or light_mode depending on system)
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should have tooltip', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, isNotNull);
      expect(iconButton.tooltip, contains('Switch to'));
    });

    testWidgets('should use AnimatedSwitcher for icon transitions', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('AnimatedSwitcher should use correct animation duration', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final animatedSwitcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );

      // Should use AppAnimations.quick (120ms)
      expect(animatedSwitcher.duration, const Duration(milliseconds: 120));
    });

    testWidgets('should be tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify button exists and is tappable
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('Icon should have unique key', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the icon widget (works regardless of which icon is displayed)
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      final icon = icons.first;

      expect(icon.key, isNotNull);
      expect(icon.key, isA<ValueKey<bool>>());
    });

    testWidgets('AnimatedSwitcher should have transition builder', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final animatedSwitcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );

      expect(animatedSwitcher.transitionBuilder, isNotNull);
    });

    testWidgets('button should be semantically accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check semantics exist
      final semantics = tester.getSemantics(find.byType(IconButton));
      expect(semantics, isNotNull);
    });

    testWidgets('tooltip should reflect current theme state (light mode)', (tester) async {
      await tester.pumpWidget(createTestWidget(initialThemeMode: ThemeMode.light));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      // In light mode, tooltip should say "Switch to dark mode"
      expect(iconButton.tooltip, equals('Switch to dark mode'));
    });

    testWidgets('tooltip should reflect current theme state (dark mode)', (tester) async {
      await tester.pumpWidget(createTestWidget(initialThemeMode: ThemeMode.dark));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      // In dark mode, tooltip should say "Switch to light mode"
      expect(iconButton.tooltip, equals('Switch to light mode'));
    });

    testWidgets('icon should show dark_mode icon in light theme', (tester) async {
      await tester.pumpWidget(createTestWidget(initialThemeMode: ThemeMode.light));

      // Should show dark_mode icon (moon) when in light mode
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, equals(Icons.dark_mode));
    });

    testWidgets('icon should show light_mode icon in dark theme', (tester) async {
      await tester.pumpWidget(createTestWidget(initialThemeMode: ThemeMode.dark));

      // Should show light_mode icon (sun) when in dark mode
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, equals(Icons.light_mode));
    });
  });
}
