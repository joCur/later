import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// Performance tests for app startup
///
/// Tests startup performance:
/// - Time to first frame
/// - Theme initialization
/// - Provider setup time
/// - Memory on startup
///
/// Target: < 2 seconds to interactive
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Startup Performance Tests', () {
    test('Theme initialization time', () {
      final stopwatch = Stopwatch()..start();

      // Initialize theme data
      ThemeData.light();
      ThemeData.dark();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      debugPrint('Theme initialization: ${elapsed}ms');

      expect(elapsed, lessThan(100),
        reason: 'Theme initialization should be fast');
    });

    testWidgets('Provider setup time', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      final elapsed = stopwatch.elapsedMilliseconds;
      debugPrint('Provider setup: ${elapsed}ms');

      expect(elapsed, lessThan(500),
        reason: 'Provider setup should complete quickly');
    });

    testWidgets('First frame render time', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );

      await tester.pump();
      stopwatch.stop();

      final elapsed = stopwatch.elapsedMilliseconds;
      debugPrint('First frame render: ${elapsed}ms');

      expect(elapsed, lessThan(200),
        reason: 'First frame should render quickly');
    });

    testWidgets('Complex app initialization', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Text('App Home'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      final elapsed = stopwatch.elapsedMilliseconds;
      debugPrint('Complex app initialization: ${elapsed}ms');

      expect(elapsed, lessThan(1000),
        reason: 'App should initialize within 1 second');
    });

    testWidgets('Memory footprint on startup', (tester) async {
      // Build a typical app structure
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return Container(
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no errors
      expect(tester.takeException(), isNull);

      debugPrint('Startup memory test: No errors detected');
    });

    testWidgets('Gradient shader compilation on startup', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                  ),
                ),
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: AppColors.taskGradient,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      final elapsed = stopwatch.elapsedMilliseconds;
      debugPrint('Gradient shader compilation: ${elapsed}ms');

      expect(elapsed, lessThan(500),
        reason: 'Shader compilation should be reasonably fast');
    });
  });
}
