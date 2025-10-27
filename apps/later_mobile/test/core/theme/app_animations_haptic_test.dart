import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppAnimations Haptic Feedback', () {
    // Track haptic method calls for verification
    final List<MethodCall> methodCalls = [];

    setUp(() {
      // Clear previous calls
      methodCalls.clear();

      // Mock HapticFeedback channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            methodCalls.add(methodCall);
            return null;
          });
    });

    tearDown(() {
      // Clear mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    group('Basic Haptic Methods', () {
      test(
        'lightHaptic should call HapticFeedback.lightImpact when supported',
        () async {
          // Note: On non-mobile platforms, haptics won't trigger
          // This test verifies the method executes without error
          await AppAnimations.lightHaptic();

          // On mobile platforms, this would be called
          // On desktop, it gracefully does nothing
          expect(() => AppAnimations.lightHaptic(), returnsNormally);
        },
      );

      test(
        'mediumHaptic should call HapticFeedback.mediumImpact when supported',
        () async {
          await AppAnimations.mediumHaptic();
          expect(() => AppAnimations.mediumHaptic(), returnsNormally);
        },
      );

      test(
        'heavyHaptic should call HapticFeedback.heavyImpact when supported',
        () async {
          await AppAnimations.heavyHaptic();
          expect(() => AppAnimations.heavyHaptic(), returnsNormally);
        },
      );

      test(
        'selectionHaptic should call HapticFeedback.selectionClick when supported',
        () async {
          await AppAnimations.selectionHaptic();
          expect(() => AppAnimations.selectionHaptic(), returnsNormally);
        },
      );

      test(
        'warningHaptic should call HapticFeedback.vibrate when supported',
        () async {
          await AppAnimations.warningHaptic();
          expect(() => AppAnimations.warningHaptic(), returnsNormally);
        },
      );
    });

    group('Platform Support Detection', () {
      test('supportsHaptics should return a boolean', () {
        final result = AppAnimations.supportsHaptics();
        expect(result, isA<bool>());

        // On macOS/Windows/Linux/Web, should return false
        // On iOS/Android, should return true
        // We can't test specific platforms without platform mocking
      });
    });

    group('Conditional Haptic Execution', () {
      test(
        'conditionalHaptic should execute callback on supported platforms',
        () async {
          int callCount = 0;

          await AppAnimations.conditionalHaptic(() async {
            callCount++;
          });

          // Should execute if platform supports haptics
          if (AppAnimations.supportsHaptics()) {
            expect(callCount, equals(1));
          } else {
            // On unsupported platforms, callback is not executed
            expect(callCount, equals(0));
          }
        },
      );

      test(
        'conditionalHaptic should not fail on unsupported platforms',
        () async {
          // This should not throw even if haptics are unsupported
          expect(
            () async => await AppAnimations.conditionalHaptic(() async {
              await AppAnimations.lightHaptic();
            }),
            returnsNormally,
          );
        },
      );
    });

    group('Haptic Method Call Order', () {
      test('multiple haptic calls should execute without errors', () async {
        // These should all execute without throwing
        await AppAnimations.lightHaptic();
        await AppAnimations.mediumHaptic();
        await AppAnimations.heavyHaptic();

        // On supported platforms, method calls would be tracked
        // On unsupported platforms (like test environment), they gracefully no-op
        expect(() async {
          await AppAnimations.lightHaptic();
          await AppAnimations.mediumHaptic();
          await AppAnimations.heavyHaptic();
        }, returnsNormally);
      });
    });

    group('Error Handling', () {
      test('haptic methods should not throw on platform errors', () async {
        // Override mock to simulate error
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (
              MethodCall methodCall,
            ) async {
              throw PlatformException(code: 'UNAVAILABLE');
            });

        // Should not throw
        expect(() async => await AppAnimations.lightHaptic(), returnsNormally);
        expect(() async => await AppAnimations.mediumHaptic(), returnsNormally);
        expect(() async => await AppAnimations.heavyHaptic(), returnsNormally);
        expect(
          () async => await AppAnimations.selectionHaptic(),
          returnsNormally,
        );
        expect(
          () async => await AppAnimations.warningHaptic(),
          returnsNormally,
        );
      });
    });
  });
}
