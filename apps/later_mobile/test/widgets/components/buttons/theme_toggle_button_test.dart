import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_theme.dart';
import 'package:later_mobile/providers/theme_provider.dart';
import 'package:later_mobile/widgets/components/buttons/theme_toggle_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(ThemeProvider themeProvider) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        home: const Scaffold(
          body: ThemeToggleButton(),
        ),
      ),
    );
  }

  group('ThemeToggleButton', () {
    testWidgets('should render IconButton', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should display icon based on current theme', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      // Icon should be present (dark_mode or light_mode depending on system)
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should have tooltip', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, isNotNull);
      expect(iconButton.tooltip, contains('Switch to'));
    });

    testWidgets('should use AnimatedSwitcher for icon transitions', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('AnimatedSwitcher should use correct animation duration', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      final animatedSwitcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );

      // Should use AppAnimations.quick (120ms)
      expect(animatedSwitcher.duration, const Duration(milliseconds: 120));
    });

    testWidgets('should be tappable', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      // Verify button exists and is tappable
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('Icon should have unique key', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      // Find the icon widget (works regardless of which icon is displayed)
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      final icon = icons.first;

      expect(icon.key, isNotNull);
      expect(icon.key, isA<ValueKey<bool>>());
    });

    testWidgets('should use Consumer to reactively update', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      // Consumer should be present for reactive updates
      expect(find.byType(Consumer<ThemeProvider>), findsOneWidget);
    });

    testWidgets('AnimatedSwitcher should have transition builder', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      final animatedSwitcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );

      expect(animatedSwitcher.transitionBuilder, isNotNull);
    });

    testWidgets('button should be semantically accessible', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      // Check semantics exist
      final semantics = tester.getSemantics(find.byType(IconButton));
      expect(semantics, isNotNull);
    });

    testWidgets('tooltip should reflect current theme state', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      // Tooltip should mention switching (to either light or dark)
      expect(
        iconButton.tooltip,
        anyOf(
          equals('Switch to light mode'),
          equals('Switch to dark mode'),
        ),
      );
    });

    testWidgets('icon should be appropriate for current theme', (tester) async {
      final themeProvider = ThemeProvider();
      await tester.pumpWidget(createTestWidget(themeProvider));

      // Should show either light_mode or dark_mode icon
      final hasLightIcon = find.byIcon(Icons.light_mode).evaluate().isNotEmpty;
      final hasDarkIcon = find.byIcon(Icons.dark_mode).evaluate().isNotEmpty;

      expect(hasLightIcon || hasDarkIcon, isTrue);
    });
  });
}
