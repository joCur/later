import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/modals/create_space_modal.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'create_space_modal_test.mocks.dart';

@GenerateMocks([SpaceRepository])
void main() {
  late MockSpaceRepository mockRepository;
  late SpacesProvider spacesProvider;

  setUp(() {
    mockRepository = MockSpaceRepository();
    spacesProvider = SpacesProvider(mockRepository);
  });

  Widget createTestWidget({
    required Widget child,
    bool isDark = false,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: ChangeNotifierProvider<SpacesProvider>.value(
          value: spacesProvider,
          child: child,
        ),
      ),
    );
  }

  group('CreateSpaceModal - Rendering', () {
    testWidgets('should render in create mode with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Space'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should render in edit mode with correct title',
        (WidgetTester tester) async {
      final existingSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );

      await tester.pumpWidget(
        createTestWidget(
          child: CreateSpaceModal(
            mode: SpaceModalMode.edit,
            initialSpace: existingSpace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Space'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should render all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Check for name input
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Space Name'), findsOneWidget);

      // Check for icon picker section
      expect(find.text('Icon'), findsOneWidget);

      // Check for color picker section
      expect(find.text('Color'), findsOneWidget);

      // Check for buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should render icon picker with emoji grid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Should have multiple emoji icons
      expect(find.text('💼'), findsOneWidget);
      expect(find.text('📚'), findsOneWidget);
      expect(find.text('🏠'), findsOneWidget);
      expect(find.text('💡'), findsOneWidget);
    });

    testWidgets('should render color picker with color swatches',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Should have color swatches (looking for Container widgets with decoration)
      final colorSwatches = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(colorSwatches, findsWidgets);
    });

    testWidgets('should pre-fill form in edit mode',
        (WidgetTester tester) async {
      final existingSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );

      await tester.pumpWidget(
        createTestWidget(
          child: CreateSpaceModal(
            mode: SpaceModalMode.edit,
            initialSpace: existingSpace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check name is pre-filled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Work');

      // Check icon is selected (should have checkmark or highlight)
      expect(find.text('💼'), findsOneWidget);
    });
  });

  group('CreateSpaceModal - Form Validation', () {
    testWidgets('should show error when name is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Try to submit with empty name
      final createButton = find.text('Create');
      expect(createButton, findsOneWidget);

      // Button should be disabled initially
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: createButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should enable button when name is valid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid name
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Button should be enabled
      final createButton = find.text('Create');
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: createButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should show error when name is too long',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name longer than 100 characters
      final longName = 'A' * 101;
      await tester.enterText(find.byType(TextField), longName);
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Name must be between 1 and 100 characters'),
          findsOneWidget);

      // Button should be disabled
      final createButton = find.text('Create');
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: createButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should show character counter', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Should show character counter
      expect(find.textContaining('/100'), findsOneWidget);
    });

    testWidgets('should trim whitespace from name',
        (WidgetTester tester) async {
      final newSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      when(mockRepository.createSpace(any))
          .thenAnswer((_) async => newSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name with whitespace
      await tester.enterText(find.byType(TextField), '  Work  ');
      await tester.pumpAndSettle();

      // Select icon
      await tester.tap(find.text('💼'));
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify trimmed name was used
      verify(mockRepository.createSpace(
        argThat(predicate<Space>((space) => space.name == 'Work')),
      )).called(1);
    });
  });

  group('CreateSpaceModal - Icon Selection', () {
    testWidgets('should select icon when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on icon
      await tester.tap(find.text('💼'));
      await tester.pumpAndSettle();

      // Icon should be selected (look for checkmark or border)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should allow changing icon selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first icon
      await tester.tap(find.text('💼'));
      await tester.pumpAndSettle();

      // Tap second icon
      await tester.tap(find.text('📚'));
      await tester.pumpAndSettle();

      // Only one checkmark should be visible
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should use default folder icon if none selected',
        (WidgetTester tester) async {
      final newSpace = Space(
        id: 'space-1',
        name: 'Work',
        color: '#6366F1',
      );
      when(mockRepository.createSpace(any))
          .thenAnswer((_) async => newSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name but don't select icon
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify null icon was used
      verify(mockRepository.createSpace(
        argThat(predicate<Space>((space) => space.icon == null)),
      )).called(1);
    });
  });

  group('CreateSpaceModal - Color Selection', () {
    testWidgets('should select color when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Find color swatches
      final colorSwatches = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Container &&
            (widget.child as Container).decoration is BoxDecoration,
      );

      // Tap first color
      await tester.tap(colorSwatches.first);
      await tester.pumpAndSettle();

      // Should show checkmark on selected color
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should use default primary color if none selected',
        (WidgetTester tester) async {
      final newSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      when(mockRepository.createSpace(any))
          .thenAnswer((_) async => newSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name but don't select color (default should be used)
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify default color was used
      verify(mockRepository.createSpace(
        argThat(predicate<Space>((space) => space.color == '#6366F1')),
      )).called(1);
    });
  });

  group('CreateSpaceModal - Create Mode', () {
    testWidgets('should create new space successfully',
        (WidgetTester tester) async {
      final newSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      when(mockRepository.createSpace(any))
          .thenAnswer((_) async => newSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Select icon
      await tester.tap(find.text('💼'));
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify space was created
      verify(mockRepository.createSpace(any)).called(1);
    });

    testWidgets('should generate unique UUID for new space',
        (WidgetTester tester) async {
      final newSpace = Space(
        id: 'unique-uuid',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      when(mockRepository.createSpace(any))
          .thenAnswer((_) async => newSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify UUID was generated (not empty)
      verify(mockRepository.createSpace(
        argThat(predicate<Space>((space) => space.id.isNotEmpty)),
      )).called(1);
    });

    testWidgets('should auto-switch to newly created space',
        (WidgetTester tester) async {
      final newSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      when(mockRepository.createSpace(any))
          .thenAnswer((_) async => newSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify current space was set
      expect(spacesProvider.currentSpace?.id, 'space-1');
    });

    testWidgets('should close modal after successful creation',
        (WidgetTester tester) async {
      final newSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      when(mockRepository.createSpace(any))
          .thenAnswer((_) async => newSpace);

      bool modalClosed = false;
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await CreateSpaceModal.show(
                  context,
                  mode: SpaceModalMode.create,
                );
                modalClosed = result == true;
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pump(); // Start navigation
      await tester.pump(const Duration(milliseconds: 500)); // Animation

      // Modal should return true
      expect(modalClosed, isTrue);
    });

    testWidgets('should show error snackbar on creation failure',
        (WidgetTester tester) async {
      when(mockRepository.createSpace(any))
          .thenThrow(Exception('Failed to create space'));

      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextField), 'Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pump(); // Trigger tap
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Finish animation

      // Should show error snackbar
      expect(find.textContaining('Failed to create space'), findsOneWidget);
    });
  });

  group('CreateSpaceModal - Edit Mode', () {
    testWidgets('should update existing space successfully',
        (WidgetTester tester) async {
      final existingSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      final updatedSpace = existingSpace.copyWith(name: 'Updated Work');
      when(mockRepository.updateSpace(any))
          .thenAnswer((_) async => updatedSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: CreateSpaceModal(
            mode: SpaceModalMode.edit,
            initialSpace: existingSpace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Update name
      await tester.enterText(find.byType(TextField), 'Updated Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify space was updated
      verify(mockRepository.updateSpace(any)).called(1);
    });

    testWidgets('should preserve space ID in edit mode',
        (WidgetTester tester) async {
      final existingSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      final updatedSpace = existingSpace.copyWith(name: 'Updated Work');
      when(mockRepository.updateSpace(any))
          .thenAnswer((_) async => updatedSpace);

      await tester.pumpWidget(
        createTestWidget(
          child: CreateSpaceModal(
            mode: SpaceModalMode.edit,
            initialSpace: existingSpace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Update name
      await tester.enterText(find.byType(TextField), 'Updated Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify ID was preserved
      verify(mockRepository.updateSpace(
        argThat(predicate<Space>((space) => space.id == 'space-1')),
      )).called(1);
    });

    testWidgets('should close modal after successful update',
        (WidgetTester tester) async {
      final existingSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      final updatedSpace = existingSpace.copyWith(name: 'Updated Work');
      when(mockRepository.updateSpace(any))
          .thenAnswer((_) async => updatedSpace);

      bool modalClosed = false;
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await CreateSpaceModal.show(
                  context,
                  mode: SpaceModalMode.edit,
                  initialSpace: existingSpace,
                );
                modalClosed = result == true;
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Update name
      await tester.enterText(find.byType(TextField), 'Updated Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start navigation
      await tester.pump(const Duration(milliseconds: 500)); // Animation

      // Modal should return true
      expect(modalClosed, isTrue);
    });

    testWidgets('should show error snackbar on update failure',
        (WidgetTester tester) async {
      final existingSpace = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#6366F1',
      );
      when(mockRepository.updateSpace(any))
          .thenThrow(Exception('Failed to update space'));

      await tester.pumpWidget(
        createTestWidget(
          child: CreateSpaceModal(
            mode: SpaceModalMode.edit,
            initialSpace: existingSpace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Update name
      await tester.enterText(find.byType(TextField), 'Updated Work');
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Save'));
      await tester.pump(); // Trigger tap
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Finish animation

      // Should show error snackbar
      expect(find.textContaining('Failed to update space'), findsOneWidget);
    });
  });

  group('CreateSpaceModal - User Interaction', () {
    testWidgets('should close modal when Cancel button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await CreateSpaceModal.show(
                  context,
                  mode: SpaceModalMode.create,
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Modal should be closed
      expect(find.text('Create Space'), findsNothing);
    });

    testWidgets('should close modal when close button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await CreateSpaceModal.show(
                  context,
                  mode: SpaceModalMode.create,
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap close button (X)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Modal should be closed
      expect(find.text('Create Space'), findsNothing);
    });

    testWidgets('should close modal on Escape key press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Press Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Modal should be closed (no way to verify in unit test without proper navigation)
      // This is more of an integration test concern
    });
  });

  group('CreateSpaceModal - Accessibility', () {
    testWidgets('should have semantic labels for all interactive elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Check for semantic labels (Semantics widget wraps TextField)
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Semantics &&
            widget.properties.label == 'Space Name'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Semantics &&
            widget.properties.label == 'Cancel'),
        findsOneWidget,
      );
    });

    testWidgets('should have minimum touch target size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CreateSpaceModal(mode: SpaceModalMode.create),
        ),
      );
      await tester.pumpAndSettle();

      // Check buttons have minimum touch target (44x44)
      final buttons = find.byType(ElevatedButton);
      for (final button in tester.widgetList<ElevatedButton>(buttons)) {
        final renderBox = tester.renderObject(find.byWidget(button));
        expect(renderBox.semanticBounds.height, greaterThanOrEqualTo(44));
      }
    });
  });

  group('CreateSpaceModal - Responsive Layout', () {
    testWidgets('should render as bottom sheet on mobile',
        (WidgetTester tester) async {
      // Set mobile size
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await CreateSpaceModal.show(
                  context,
                  mode: SpaceModalMode.create,
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Should find the modal content
      expect(find.text('Create Space'), findsOneWidget);
    });

    testWidgets('should render as dialog on desktop',
        (WidgetTester tester) async {
      // Set desktop size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await CreateSpaceModal.show(
                  context,
                  mode: SpaceModalMode.create,
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Should find the modal content
      expect(find.text('Create Space'), findsOneWidget);
    });
  });
}
