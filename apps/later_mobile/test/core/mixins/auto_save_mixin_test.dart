import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/mixins/auto_save_mixin.dart';

// Test widget that uses the AutoSaveMixin
class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => TestWidgetState();
}

class TestWidgetState extends State<TestWidget> with AutoSaveMixin {
  int saveCallCount = 0;
  bool shouldThrowError = false;
  List<String> saveHistory = [];

  @override
  Future<void> saveChanges() async {
    saveCallCount++;
    saveHistory.add('save_${DateTime.now().millisecondsSinceEpoch}');

    if (shouldThrowError) {
      throw Exception('Save failed');
    }

    // Simulate async save operation
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Test widget with custom autoSaveDelayMs
class TestWidgetCustomDelay extends StatefulWidget {
  const TestWidgetCustomDelay({super.key});

  @override
  State<TestWidgetCustomDelay> createState() => TestWidgetCustomDelayState();
}

class TestWidgetCustomDelayState extends State<TestWidgetCustomDelay>
    with AutoSaveMixin {
  int saveCallCount = 0;

  @override
  int get autoSaveDelayMs => 500; // Custom 500ms delay

  @override
  Future<void> saveChanges() async {
    saveCallCount++;
    // Simulate async save operation
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  group('AutoSaveMixin', () {
    testWidgets('initializes with correct default values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      expect(state.isSaving, false, reason: 'isSaving should start as false');
      expect(
        state.hasChanges,
        false,
        reason: 'hasChanges should start as false',
      );
      expect(
        state.debounceTimer,
        null,
        reason: 'debounceTimer should start as null',
      );
      expect(
        state.autoSaveDelayMs,
        2000,
        reason: 'autoSaveDelayMs should default to 2000',
      );
    });

    testWidgets('onFieldChanged sets hasChanges to true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      expect(state.hasChanges, false);

      state.onFieldChanged();

      expect(
        state.hasChanges,
        true,
        reason: 'onFieldChanged should set hasChanges to true',
      );
    });

    testWidgets('onFieldChanged starts debounce timer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      expect(state.debounceTimer, null);

      state.onFieldChanged();

      expect(
        state.debounceTimer,
        isNotNull,
        reason: 'onFieldChanged should start a debounce timer',
      );
      expect(
        state.debounceTimer!.isActive,
        true,
        reason: 'debounce timer should be active',
      );
    });

    testWidgets('onFieldChanged cancels previous timer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Start first timer
      state.onFieldChanged();
      final firstTimer = state.debounceTimer;
      expect(firstTimer, isNotNull);
      expect(firstTimer!.isActive, true);

      // Start second timer (should cancel first)
      state.onFieldChanged();
      final secondTimer = state.debounceTimer;

      expect(
        firstTimer.isActive,
        false,
        reason: 'First timer should be canceled',
      );
      expect(secondTimer, isNotNull, reason: 'Second timer should be created');
      expect(
        secondTimer!.isActive,
        true,
        reason: 'Second timer should be active',
      );
      expect(
        secondTimer,
        isNot(equals(firstTimer)),
        reason: 'Second timer should be different from first',
      );
    });

    testWidgets('onFieldChanged executes optional onChanged callback', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      var callbackExecuted = false;

      state.onFieldChanged(
        onChanged: () {
          callbackExecuted = true;
        },
      );

      expect(
        callbackExecuted,
        true,
        reason: 'onChanged callback should be executed',
      );
    });

    testWidgets('saveChanges is called after debounce delay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      expect(state.saveCallCount, 0);

      // Trigger field change
      state.onFieldChanged();

      // Should not save immediately
      expect(
        state.saveCallCount,
        0,
        reason: 'Save should not be called immediately',
      );

      // Wait for debounce delay
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Extra time for async

      expect(
        state.saveCallCount,
        1,
        reason: 'Save should be called after debounce delay',
      );
    });

    testWidgets('multiple rapid changes result in single save call', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Trigger multiple rapid changes
      state.onFieldChanged();
      await tester.pump(const Duration(milliseconds: 100));

      state.onFieldChanged();
      await tester.pump(const Duration(milliseconds: 100));

      state.onFieldChanged();
      await tester.pump(const Duration(milliseconds: 100));

      state.onFieldChanged();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        state.saveCallCount,
        0,
        reason: 'Save should not be called during rapid changes',
      );

      // Wait for debounce delay after last change
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Extra time for async

      expect(
        state.saveCallCount,
        1,
        reason: 'Save should be called only once after rapid changes',
      );
    });

    testWidgets('cancelDebounceTimer cancels active timer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Start timer
      state.onFieldChanged();
      expect(state.debounceTimer, isNotNull);
      expect(state.debounceTimer!.isActive, true);

      // Cancel timer
      state.cancelDebounceTimer();

      expect(
        state.debounceTimer,
        isNull,
        reason: 'debounceTimer should be null after cancel',
      );
    });

    testWidgets('cancelDebounceTimer prevents saveChanges from being called', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Start timer
      state.onFieldChanged();
      expect(state.saveCallCount, 0);

      // Cancel timer before it fires
      await tester.pump(const Duration(milliseconds: 500));
      state.cancelDebounceTimer();

      // Wait past debounce delay
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        state.saveCallCount,
        0,
        reason: 'Save should not be called after timer is canceled',
      );
    });

    testWidgets('dispose cancels debounce timer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Start timer
      state.onFieldChanged();
      final timer = state.debounceTimer;
      expect(timer, isNotNull);
      expect(timer!.isActive, true);

      // Dispose widget
      await tester.pumpWidget(Container());

      expect(
        timer.isActive,
        false,
        reason: 'Timer should be canceled after dispose',
      );
    });

    testWidgets('custom autoSaveDelayMs override works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidgetCustomDelay())),
      );

      final state = tester.state<TestWidgetCustomDelayState>(
        find.byType(TestWidgetCustomDelay),
      );

      expect(
        state.autoSaveDelayMs,
        500,
        reason: 'Custom autoSaveDelayMs should override default',
      );
    });

    testWidgets('custom delay timing works correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidgetCustomDelay())),
      );

      final state = tester.state<TestWidgetCustomDelayState>(
        find.byType(TestWidgetCustomDelay),
      );

      // Trigger change
      state.onFieldChanged();

      // Should not save before custom delay
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        state.saveCallCount,
        0,
        reason: 'Should not save before custom delay',
      );

      // Should save after custom delay
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 100)); // Extra time

      expect(
        state.saveCallCount,
        1,
        reason: 'Should save after custom delay of 500ms',
      );
    });

    testWidgets('hasChanges flag workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Initial state
      expect(state.hasChanges, false);

      // User makes changes
      state.onFieldChanged();
      expect(state.hasChanges, true);

      // After save completes, screen should reset hasChanges
      // (This is screen's responsibility, testing the pattern)
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate screen resetting hasChanges after save
      state.hasChanges = false;
      expect(state.hasChanges, false);
    });

    testWidgets('isSaving flag workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Initial state
      expect(state.isSaving, false);

      // Screen would set isSaving during save
      // (Testing the pattern - screen's responsibility)
      state.isSaving = true;
      expect(state.isSaving, true);

      state.isSaving = false;
      expect(state.isSaving, false);
    });

    testWidgets('mixin works with multiple TextEditingControllers', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Simulate multiple controllers calling onFieldChanged
      state.onFieldChanged(); // Title changed
      await tester.pump(const Duration(milliseconds: 100));

      state.onFieldChanged(); // Content changed
      await tester.pump(const Duration(milliseconds: 100));

      state.onFieldChanged(); // Title changed again
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        state.saveCallCount,
        0,
        reason: 'Should not save during rapid changes',
      );

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        state.saveCallCount,
        1,
        reason: 'Should save once after all changes',
      );
    });

    testWidgets('mixin handles widget rebuild correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      state.onFieldChanged();
      final timerBeforeRebuild = state.debounceTimer;

      // Trigger rebuild
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final timerAfterRebuild = state.debounceTimer;

      expect(
        timerBeforeRebuild,
        equals(timerAfterRebuild),
        reason: 'Timer should persist across rebuilds',
      );
    });

    testWidgets('cancelDebounceTimer is safe when no timer exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      expect(state.debounceTimer, null);

      // Should not throw when canceling null timer
      expect(
        () => state.cancelDebounceTimer(),
        returnsNormally,
        reason: 'cancelDebounceTimer should handle null timer gracefully',
      );

      expect(state.debounceTimer, null);
    });

    testWidgets('mixin state persists across multiple save cycles', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // First save cycle
      state.onFieldChanged();
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 100));
      expect(state.saveCallCount, 1);

      // Second save cycle
      state.onFieldChanged();
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 100));
      expect(state.saveCallCount, 2);

      // Third save cycle
      state.onFieldChanged();
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 100));
      expect(state.saveCallCount, 3);

      expect(
        state.saveHistory.length,
        3,
        reason: 'All saves should be tracked',
      );
    });
  });
}
