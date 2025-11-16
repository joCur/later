// ignore_for_file: dangling_library_doc_comment

/// Riverpod 3.0 Testing Patterns
///
/// This file documents the testing patterns established during the Riverpod 3.0
/// migration. Use these patterns as a reference for writing tests for future
/// Riverpod controllers and services.
library;

/// # Riverpod 3.0 Test Patterns
///
/// ## Overview
///
/// Riverpod 3.0 introduces several new testing features that simplify test setup
/// and improve test reliability:
///
/// 1. **ProviderContainer.test()** - Built-in test utility that auto-disposes
/// 2. **overrideWithBuild()** - Simpler widget test mocking
/// 3. **tester.container** - Direct container access in widget tests
///
/// ## Pattern 1: Pure Dart Service Tests
///
/// Services contain business logic and should be tested with pure Dart unit tests.
/// No Flutter or Riverpod dependencies needed.
///
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import 'package:mockito/mockito.dart';
///
/// void main() {
///   group('MyService', () {
///     late MockRepository mockRepo;
///     late MyService service;
///
///     setUp(() {
///       mockRepo = MockRepository();
///       service = MyService(repository: mockRepo);
///     });
///
///     test('should do something', () async {
///       // Arrange
///       when(mockRepo.getData()).thenAnswer((_) async => testData);
///
///       // Act
///       final result = await service.doSomething();
///
///       // Assert
///       expect(result, expectedValue);
///       verify(mockRepo.getData()).called(1);
///     });
///   });
/// }
/// ```
///
/// ## Pattern 2: Controller Tests with ProviderContainer.test()
///
/// Controllers manage state and coordinate between services and UI. Test them
/// using ProviderContainer.test() which auto-disposes the container.
///
/// ```dart
/// import 'package:flutter_riverpod/flutter_riverpod.dart';
/// import 'package:flutter_test/flutter_test.dart';
///
/// void main() {
///   group('MyController', () {
///     late MockMyService mockService;
///
///     setUp(() {
///       mockService = MockMyService();
///     });
///
///     test('should initialize with correct state', () {
///       // Arrange
///       when(mockService.loadData()).thenReturn(initialData);
///
///       // Act - NEW in 3.0: Use ProviderContainer.test()
///       final container = ProviderContainer.test(
///         overrides: [
///           myServiceProvider.overrideWithValue(mockService),
///         ],
///       );
///       // Container auto-disposes after test
///
///       addTearDown(container.dispose); // Optional: explicit disposal
///
///       // Assert
///       final state = container.read(myControllerProvider);
///       expect(state, equals(initialData));
///     });
///
///     test('should update state on action', () async {
///       // Arrange
///       when(mockService.loadData()).thenReturn(initialData);
///       when(mockService.performAction()).thenAnswer((_) async => newData);
///
///       final container = ProviderContainer.test(
///         overrides: [
///           myServiceProvider.overrideWithValue(mockService),
///         ],
///       );
///
///       addTearDown(container.dispose);
///
///       // Act
///       await container.read(myControllerProvider.notifier).performAction();
///
///       // Assert
///       verify(mockService.performAction()).called(1);
///     });
///   });
/// }
/// ```
///
/// ## Pattern 3: Widget Tests with overrideWithBuild()
///
/// Widget tests verify UI rendering and interactions. Use overrideWithBuild()
/// to mock provider data without creating full mock notifiers.
///
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import 'package:flutter_riverpod/flutter_riverpod.dart';
///
/// testWidgets('should render data correctly', (tester) async {
///   // Act
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         // NEW in 3.0: overrideWithBuild for simpler mocking
///         myControllerProvider.overrideWithBuild((ref, arg) {
///           return testData; // Return test data directly
///         }),
///       ],
///       child: testApp(MyWidget()),
///     ),
///   );
///
///   // NEW in 3.0: Access container directly
///   final container = tester.container;
///   final value = container.read(myControllerProvider);
///
///   // Assert
///   expect(find.text('Expected Text'), findsOneWidget);
///   expect(value, testData);
/// });
/// ```
///
/// ## Pattern 4: Async Controller Methods with Ref.mounted
///
/// Controllers with async methods should check `ref.mounted` before updating state
/// after await points to prevent disposed state updates.
///
/// ```dart
/// @riverpod
/// class MyController extends _$MyController {
///   @override
///   MyData build() => MyData.initial();
///
///   Future<void> performAsyncAction() async {
///     final service = ref.read(myServiceProvider);
///     final result = await service.doSomething();
///
///     // NEW in 3.0: Check if provider is still mounted
///     if (!ref.mounted) return;
///
///     state = result;
///   }
/// }
/// ```
///
/// **Note on Testing Async Methods:**
/// Controllers with animation delays or ref.mounted checks may be difficult to
/// test for full state updates in unit tests. Focus on verifying business logic
/// (service calls) rather than state updates. Full async behavior with delays
/// should be tested in widget/integration tests.
///
/// ## Pattern 5: Testing Error States
///
/// Test AsyncValue error handling by mocking service to throw errors.
///
/// ```dart
/// test('should handle errors gracefully', () async {
///   // Arrange
///   when(mockService.loadData())
///       .thenThrow(AppError(code: ErrorCode.networkTimeout));
///
///   final container = ProviderContainer.test(
///     overrides: [
///       myServiceProvider.overrideWithValue(mockService),
///     ],
///   );
///
///   addTearDown(container.dispose);
///
///   // Act
///   await container.read(myControllerProvider.notifier).loadData();
///
///   // Assert
///   final state = container.read(myControllerProvider);
///   expect(state.hasError, isTrue);
/// });
/// ```
///
/// ## Key Differences from Riverpod 2.x
///
/// 1. **ProviderContainer.test()** - No custom helper needed, built-in
/// 2. **Ref type** - Simplified to just `Ref` (no generic parameter)
/// 3. **AutoDispose** - Default behavior, no AutoDispose prefix needed
/// 4. **ref.mounted** - New safety check for async operations
/// 5. **overrideWithBuild()** - Simpler widget test mocking
/// 6. **tester.container** - Direct container access in widget tests
///
/// ## Common Pitfalls
///
/// 1. **Forgetting ref.mounted checks** - Can cause "setState after dispose" errors
/// 2. **Not waiting for async operations** - Use `await` before assertions
/// 3. **Testing animation delays** - Focus on business logic, not timing
/// 4. **Over-mocking** - Use overrideWithBuild() for simple data mocking
///
/// ## See Also
///
/// - Theme service tests: `test/features/theme/application/theme_service_test.dart`
/// - Theme controller tests: `test/features/theme/presentation/controllers/theme_controller_test.dart`
/// - Official Riverpod 3.0 testing guide: https://riverpod.dev/docs/how_to/testing

/// Helper function to create a test app with ProviderScope
///
/// Use this in widget tests to wrap widgets with proper provider setup.
/// This extends the existing testApp() helper from test_helpers.dart.
///
/// Example:
/// ```dart
/// testWidgets('my test', (tester) async {
///   await tester.pumpWidget(
///     testAppWithProviders(
///       MyWidget(),
///       overrides: [
///         myProvider.overrideWithValue(mockValue),
///       ],
///     ),
///   );
/// });
/// ```
// Note: This is a placeholder. The actual implementation should import
// and extend the testApp() helper from test_helpers.dart
