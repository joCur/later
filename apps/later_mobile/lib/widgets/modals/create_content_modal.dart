import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/gradient_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_area_field.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/molecules/controls/segmented_control.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/temporal_flow_theme.dart';
import '../../core/utils/item_type_detector.dart'; // For ContentType enum
import '../../features/auth/presentation/controllers/auth_state_controller.dart';
import '../../features/spaces/domain/models/space.dart';
import '../../features/spaces/presentation/controllers/spaces_controller.dart';
import '../../features/spaces/presentation/controllers/current_space_controller.dart';
import '../../features/notes/presentation/controllers/notes_controller.dart';
// import '../../providers/spaces_provider.dart'; // TODO: Remove after Phase 8
import '../../providers/content_provider.dart';

/// Type option for Create Content content type selector
class TypeOption {
  const TypeOption({
    required this.label,
    required this.icon,
    required this.type,
    this.color,
  });

  final String label;
  final IconData icon;
  final ContentType type;
  final Color? color;
}

/// Action to take when closing the modal with unsaved changes
enum _CloseAction {
  /// Discard unsaved changes and close
  discard,

  /// Create the item and close immediately
  createAndClose,

  /// Cancel (stay open)
  cancel,
}

/// Create Content Modal widget
///
/// A responsive modal for creating new content (tasks, notes, and lists)
/// with explicit save and keyboard shortcuts.
///
/// Features:
/// - Responsive layout (mobile bottom sheet, desktop centered modal)
/// - Explicit save with keyboard shortcut support
/// - Manual type selection with pre-selected initial type
/// - Keyboard shortcuts (Esc to close, Cmd/Ctrl+Enter to create)
/// - Voice and image input buttons (placeholders)
/// - Space selector
class CreateContentModal extends ConsumerStatefulWidget {
  const CreateContentModal({
    super.key,
    required this.onClose,
    this.initialType,
  });

  /// Callback when modal is closed
  final VoidCallback onClose;

  /// Initial content type to pre-select (optional)
  final ContentType? initialType;

  @override
  ConsumerState<CreateContentModal> createState() => _CreateContentModalState();
}

class _CreateContentModalState extends ConsumerState<CreateContentModal>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _currentItemId;
  bool _isSaving = false;
  String? _selectedSpaceId; // Local state for space selection (modal-only)
  bool _showDescription = false; // State for TodoList description field

  // Check if we're creating a new item or editing an existing one
  bool get _isNewItem => _currentItemId == null;

  // Type selection for content creation - uses localized labels
  List<TypeOption> _getTypeOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      TypeOption(
        label: l10n.createModalTypeTodoList,
        icon: Icons.check_box_outlined,
        type: ContentType.todoList,
        color: AppColors.info,
      ),
      TypeOption(
        label: l10n.createModalTypeList,
        icon: Icons.list_alt,
        type: ContentType.list,
        color: AppColors.primarySolid,
      ),
      TypeOption(
        label: l10n.createModalTypeNote,
        icon: Icons.description_outlined,
        type: ContentType.note,
        color: AppColors.success,
      ),
    ];
  }

  ContentType? _selectedType; // User-selected type
  ListStyle _selectedListStyle = ListStyle.bullets; // Default list style

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _typeIconAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize selected type from widget parameter, default to note
    _selectedType = widget.initialType ?? ContentType.note;

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(() {
      setState(
        () {},
      ); // Rebuild when focus changes for input field glass effect
    });

    // Simplified modal animations for mobile-first design
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 300,
      ), // 300ms entrance (mobile-first)
      reverseDuration: const Duration(milliseconds: 250), // 250ms exit
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Simplified curve
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1), // Slide up from bottom
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut, // Smooth entrance
            reverseCurve: Curves.easeIn, // Smooth exit
          ),
        );

    // Initialize type icon animation controller
    _typeIconAnimationController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );

    // Start entrance animation
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize local space selection with current space
    // Safe to use ref.read here as BuildContext is ready
    if (_selectedSpaceId == null) {
      _selectedSpaceId = ref.read(currentSpaceControllerProvider).when(
        data: (currentSpace) => currentSpace?.id,
        loading: () => null,
        error: (error, stack) => null,
      );
      debugPrint(
        'CreateContent: didChangeDependencies - _selectedSpaceId initialized to: $_selectedSpaceId',
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    _typeIconAnimationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Simply trigger rebuild for button state updates
    // No auto-detection - user must manually select type if desired
    setState(() {});
  }

  /// Parse note input to extract title and content
  /// Returns a record with title and optional content
  ({String title, String? content}) _parseNoteInput() {
    final isMobile = context.isMobile;

    if (isMobile) {
      // Mobile: smart field parsing (first line = title, rest = content)
      final text = _textController.text;
      if (text.isEmpty) {
        return (title: '', content: null);
      }

      final lines = text.split('\n');
      final title = lines.first.trim();

      if (lines.length > 1) {
        final remainingLines = lines.sublist(1);
        final content = remainingLines.join('\n').trim();
        return (title: title, content: content.isEmpty ? null : content);
      }

      return (title: title, content: null);
    } else {
      // Desktop: separate fields
      final title = _noteTitleController.text.trim();
      final content = _noteContentController.text.trim();
      return (title: title, content: content.isEmpty ? null : content);
    }
  }

  Future<void> _saveItem() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final contentProvider = context.read<ContentProvider>();
    final currentSpace = ref.read(currentSpaceControllerProvider).when(
      data: (space) => space,
      loading: () => null,
      error: (error, stack) => null,
    );

    if (currentSpace == null) {
      return;
    }

    // Safety check: Ensure selected space ID is valid
    if (_selectedSpaceId == null) {
      return;
    }

    // Verify the selected space still exists
    final spaces = ref.read(spacesControllerProvider).when(
      data: (data) => data,
      loading: () => <Space>[],
      error: (error, stack) => <Space>[],
    );
    final spaceExists = spaces.any((s) => s.id == _selectedSpaceId);
    final targetSpaceId = spaceExists ? _selectedSpaceId! : currentSpace.id;

    // Determine content type (user-selected, defaults to note if not specified)
    final contentType = _selectedType ?? ContentType.note;

    // Safety check: Ensure user is authenticated
    final userId = ref.read(authStateControllerProvider).when(
      data: (user) => user?.id,
      loading: () => null,
      error: (error, stack) => null,
    );
    if (userId == null) {
      return; // Exit early - user should be redirected to auth screen by AuthGate
    }

    try {
      if (_currentItemId == null) {
        // Create new content based on type
        final id = const Uuid().v4();

        switch (contentType) {
          case ContentType.todoList:
            // Get description from controller, only if not empty
            final description = _descriptionController.text.trim();
            final todoList = TodoList(
              id: id,
              spaceId: targetSpaceId,
              userId: userId,
              name: text,
              description: description.isEmpty ? null : description,
            );
            await contentProvider.createTodoList(todoList);
            _currentItemId = id;
            break;

          case ContentType.list:
            // Create ListModel with proper constructor
            final listModel = ListModel(
              id: id,
              spaceId: targetSpaceId,
              userId: userId,
              name: text,
              style: _selectedListStyle,
            );
            await contentProvider.createList(listModel);
            _currentItemId = id;
            break;

          case ContentType.note:
            // Parse note input (smart parsing for mobile, separate fields for desktop)
            final parsed = _parseNoteInput();
            final note = Note(
              id: id,
              title: parsed.title,
              content: parsed.content,
              spaceId: targetSpaceId,
              userId: userId,
            );
            // Create note via Riverpod controller
            await ref
                .read(notesControllerProvider(targetSpaceId).notifier)
                .createNote(note);
            _currentItemId = id;
            break;
        }
      } else {
        // Update existing item (only works for Notes in this simple version)
        // For TodoLists and Lists, we don't support editing in quick capture
        if (contentType == ContentType.note) {
          // Get notes from Riverpod
          final notesAsync = ref.read(notesControllerProvider(targetSpaceId));
          final existingNote = notesAsync.when(
            data: (notes) => notes.cast<Note?>().firstWhere(
              (note) => note?.id == _currentItemId,
              orElse: () => null,
            ),
            loading: () => null,
            error: (error, stack) => null,
          );

          if (existingNote != null) {
            await ref
                .read(notesControllerProvider(targetSpaceId).notifier)
                .updateNote(
                  existingNote.copyWith(title: text),
                );
          }
        }
      }

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      rethrow; // Rethrow so _handleExplicitSave can handle the error
    }
  }

  /// Handles explicit save action from save button or keyboard shortcut
  Future<void> _handleExplicitSave() async {
    // For notes, validate based on the appropriate controller
    if (_selectedType == ContentType.note) {
      final isMobile = context.isMobile;
      final hasContent = isMobile
          ? _textController.text.trim().isNotEmpty
          : _noteTitleController.text.trim().isNotEmpty;

      if (!hasContent) return;
    } else {
      // For other types, use the default text controller
      final text = _textController.text.trim();
      if (text.isEmpty) return;
    }

    // Validate TodoList description length
    if (_selectedType == ContentType.todoList) {
      if (_descriptionController.text.length > 500) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.createModalTodoDescriptionTooLong),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    // Prevent multiple simultaneous saves
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Call the existing save logic
      await _saveItem();

      // Trigger haptic feedback and close immediately
      if (mounted) {
        HapticFeedback.mediumImpact();

        // Brief delay to allow haptic feedback to register
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _close();
        }
      }
    } catch (e) {
      // Error already logged in _saveItem, just ensure loading state is cleared
    }
  }

  Future<void> _handleKeyEvent(KeyEvent event) async {
    if (event is KeyDownEvent) {
      // Escape to close (with confirmation if unsaved)
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        await _handleClose();
        return;
      }

      // Cmd/Ctrl + Enter to create (explicit save)
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final isModifierPressed =
            HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;

        if (isModifierPressed) {
          // Use explicit save which includes success feedback and auto-close
          await _handleExplicitSave();
          return;
        }
      }
    }
  }

  void _close() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  Future<void> _handleBackdropTap() async {
    await _handleClose();
  }

  Future<void> _handleClose() async {
    final hasContent = _textController.text.trim().isNotEmpty;
    // Only show confirmation for new items with unsaved content
    final hasUnsavedChanges = hasContent && _isNewItem;

    if (hasUnsavedChanges) {
      // Show confirmation dialog with option to discard or create & close
      final action = await _showCloseConfirmation();
      if (action == _CloseAction.createAndClose) {
        // Create the item and close immediately (without delay)
        await _saveItem();
        if (mounted) {
          _close();
        }
      } else if (action == _CloseAction.discard) {
        // Discard and close
        _close();
      }
      // If action is null or cancel, do nothing (stay open)
    } else {
      // No unsaved changes, close immediately
      _close();
    }
  }

  Future<_CloseAction?> _showCloseConfirmation() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final surfaceColor = AppColors.surface(context);
    final l10n = AppLocalizations.of(context)!;

    return showDialog<_CloseAction>(
      context: context,
      barrierColor: (isDark ? AppColors.overlayDark : AppColors.overlayLight),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppSpacing.glassBlurRadius,
          sigmaY: AppSpacing.glassBlurRadius,
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              // Glass morphism: semi-transparent background for frosted glass effect
              color: surfaceColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
              border: Border.all(
                color: temporalTheme.primaryGradient.colors.first.withValues(
                  alpha: 0.3,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: temporalTheme.shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createModalCloseTitle,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.createModalCloseMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      text: l10n.createModalCloseCancel,
                      onPressed: () =>
                          Navigator.of(context).pop(_CloseAction.cancel),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    GhostButton(
                      text: l10n.createModalCloseDiscard,
                      onPressed: () =>
                          Navigator.of(context).pop(_CloseAction.discard),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    GradientButton(
                      label: l10n.createModalCloseCreate,
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(_CloseAction.createAndClose),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: _handleBackdropTap,
        child: Container(
          color: isMobile
              ? Colors.transparent
              : (isDark ? AppColors.overlayDark : AppColors.overlayLight)
                    .withValues(
                      alpha:
                          _fadeAnimation.value *
                          (isDark
                              ? AppColors.overlayDark.a
                              : AppColors.overlayLight.a),
                    ),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final surfaceColor = AppColors.surface(context);
    final primaryGradient = temporalTheme.primaryGradient;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SlideTransition(
      position: _slideAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {}, // Prevent tap through
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 300) {
              _close();
            }
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // Solid surface background (mobile-first bold design, no glass)
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24.0), // 24px for mobile-first design
                ),
                // 4px gradient border on top edge
                border: Border(
                  top: BorderSide(width: 4.0, color: primaryGradient.colors[0]),
                ),
              ),
              child: _buildModalContent(isMobile: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final surfaceColor = AppColors.surface(context);
    final primaryGradient = temporalTheme.primaryGradient;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap through
            child: Container(
              key: const Key('glass_modal_container'),
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.modalMaxWidth,
              ), // 560px
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
                border: Border.all(
                  color: primaryGradient.colors[0].withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: temporalTheme.shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  // Gradient shadow for glass effect
                  BoxShadow(
                    color: primaryGradient.colors[0].withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppSpacing.glassBlurRadius,
                    sigmaY: AppSpacing.glassBlurRadius,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      // Glass morphism: semi-transparent background
                      color: surfaceColor.withValues(alpha: 0.85),
                    ),
                    child: _buildModalContent(isMobile: false),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent({required bool isMobile}) {
    final typeSpecificFields = _buildTypeSpecificFields();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle (mobile only)
        if (isMobile) _buildDragHandle(),

        // Header
        _buildHeader(),

        // Input field
        _buildInputField(),

        // Type-specific fields (e.g., list style selector)
        if (typeSpecificFields != null) typeSpecificFields,

        // Keyboard shortcuts hint
        _buildAutoSaveIndicator(),

        // Space selector (right before create button)
        _buildSpaceSelectorRow(),

        // Footer with action button
        _buildFooter(isMobile: isMobile),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Center(
        child: Container(
          key: const Key('drag_handle'),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isMobile = context.isMobile;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile
            ? AppSpacing.lg
            : AppSpacing.md, // 24px on mobile (mobile-first design)
        isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // "Create" text
          Text(
            '${l10n.createModalTitle} ',
            style: AppTypography.h3.copyWith(color: AppColors.text(context)),
          ),

          // Inline type selector
          _buildInlineTypeSelector(),

          const Spacer(),

          // Close button
          Semantics(
            label: l10n.createModalCloseCancel,
            button: true,
            child: IconButton(
              key: const Key('close_button'),
              icon: Icon(Icons.close, color: AppColors.textSecondary(context)),
              onPressed: _handleClose,
              iconSize: 24,
              constraints: const BoxConstraints(
                minWidth: AppSpacing.minTouchTarget,
                minHeight: AppSpacing.minTouchTarget,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build inline type selector for the header (e.g., "Create Note")
  Widget _buildInlineTypeSelector() {
    final typeOptions = _getTypeOptions(context);
    // Find the selected option, default to Note if none selected
    final selectedOption = typeOptions.firstWhere(
      (option) => option.type == _selectedType,
      orElse: () =>
          typeOptions.firstWhere((option) => option.type == ContentType.note),
    );

    return PopupMenuButton<TypeOption>(
      key: const Key('inline_type_selector'),
      offset: const Offset(0, 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type icon
          Icon(selectedOption.icon, size: 20, color: selectedOption.color),
          const SizedBox(width: AppSpacing.xxs),
          // Type label with type-specific color
          Text(
            selectedOption.label,
            style: AppTypography.h3.copyWith(color: selectedOption.color),
          ),
          const SizedBox(width: 2),
          // Dropdown arrow with type-specific color
          Icon(Icons.arrow_drop_down, size: 20, color: selectedOption.color),
        ],
      ),
      itemBuilder: (context) {
        return typeOptions.map((option) {
          return PopupMenuItem<TypeOption>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option.icon,
                  key: Key('inline_type_icon_${option.label.toLowerCase()}'),
                  size: 20,
                  color: option.color ?? AppColors.text(context),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(option.label),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (option) {
        // Trigger haptic feedback on type selection
        HapticFeedback.lightImpact();
        setState(() {
          _selectedType = option.type;
        });
        // Animate the type icon change
        _typeIconAnimationController.forward(from: 0.0);
      },
    );
  }

  /// Get display label for a list style
  String _getStyleLabel(BuildContext context, ListStyle style) {
    final l10n = AppLocalizations.of(context)!;
    switch (style) {
      case ListStyle.bullets:
        return l10n.createModalListStyleBullets;
      case ListStyle.numbered:
        return l10n.createModalListStyleNumbered;
      case ListStyle.checkboxes:
        return l10n.createModalListStyleCheckboxes;
      case ListStyle.simple:
        return l10n.createModalListStyleSimple;
    }
  }

  /// Get icon for a list style
  IconData _getStyleIcon(ListStyle style) {
    switch (style) {
      case ListStyle.bullets:
        return Icons.format_list_bulleted;
      case ListStyle.numbered:
        return Icons.format_list_numbered;
      case ListStyle.checkboxes:
        return Icons.check_box_outlined;
      case ListStyle.simple:
        return Icons.list;
    }
  }

  /// Build List-specific fields (style selector)
  Widget _buildListFields() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.createModalListStyleLabel,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Use the reusable SegmentedControl component
          SegmentedControl<ListStyle>(
            options: ListStyle.values.map((style) {
              return SegmentedControlOption<ListStyle>(
                value: style,
                label: _getStyleLabel(context, style),
                icon: _getStyleIcon(style),
              );
            }).toList(),
            selectedValue: _selectedListStyle,
            onSelectionChanged: (value) {
              setState(() {
                _selectedListStyle = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Build mobile smart field for Notes (first line = title pattern)
  Widget _buildNoteFieldsMobile() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextAreaField(
        key: const Key('note_smart_field_mobile'),
        controller: _textController,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: 6,
        hintText: l10n.createModalNoteSmartFieldHint,
      ),
    );
  }

  /// Build desktop two-field layout for Notes
  Widget _buildNoteFieldsDesktop() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Title field
          TextInputField(
            key: const Key('note_title_field_desktop'),
            controller: _noteTitleController,
            hintText: l10n.createModalNoteTitleHint,
            autofocus: true,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              // Trigger rebuild to show/hide content field
              setState(() {});
            },
          ),
          // Content field (appears when title is not empty)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _noteTitleController.text.isNotEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      TextAreaField(
                        key: const Key('note_content_field_desktop'),
                        controller: _noteContentController,
                        hintText: l10n.createModalNoteContentHint,
                        maxLines: 4,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Build Note-specific fields (responsive)
  Widget _buildNoteFields() {
    final isMobile = context.isMobile;
    return isMobile ? _buildNoteFieldsMobile() : _buildNoteFieldsDesktop();
  }

  /// Build TodoList-specific fields (optional description)
  Widget _buildTodoListFields() {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            if (!_showDescription)
              // Show expandable link when collapsed
              Semantics(
                button: true,
                label: l10n.createModalTodoDescriptionAdd,
                hint: 'Tap to add optional description field',
                child: GestureDetector(
                  key: const Key('add_description_link'),
                  onTap: () {
                    setState(() {
                      _showDescription = true;
                    });
                    // Trigger light haptic feedback
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    height: 48, // Minimum touch target
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.createModalTodoDescriptionAdd,
                      style: AppTypography.labelMedium.copyWith(
                        color: temporalTheme.taskColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              )
            else
              // Show description field when expanded
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.createModalTodoDescriptionLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      // Small close button to collapse
                      Semantics(
                        label: 'Remove description field',
                        button: true,
                        child: IconButton(
                          key: const Key('remove_description_button'),
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.textSecondary(context),
                          ),
                          onPressed: () {
                            setState(() {
                              _showDescription = false;
                              _descriptionController.clear();
                            });
                            HapticFeedback.lightImpact();
                          },
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextAreaField(
                    key: const Key('todolist_description_field'),
                    controller: _descriptionController,
                    hintText: l10n.createModalTodoDescriptionHint,
                    maxLines: 3,
                    onChanged: (value) {
                      // Trigger rebuild for character count
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  // Character count indicator
                  Text(
                    '${_descriptionController.text.length}/500',
                    style: AppTypography.labelSmall.copyWith(
                      color: _descriptionController.text.length > 500
                          ? AppColors.error
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Common transition builder for smooth, consistent animations
  Widget _typeFieldTransitionBuilder(
    Widget child,
    Animation<double> animation,
  ) {
    // Use easeOutCubic for smoother, more natural entrance
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05), // Reduced from 0.1 for subtler movement
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: RepaintBoundary(
          child: child, // Optimize repaints during animation
        ),
      ),
    );
  }

  /// Build type-specific fields based on selected content type
  Widget? _buildTypeSpecificFields() {
    Widget? typeField;
    if (_selectedType == ContentType.list) {
      typeField = _buildListFields();
    } else if (_selectedType == ContentType.note) {
      typeField = _buildNoteFields();
    } else if (_selectedType == ContentType.todoList) {
      typeField = _buildTodoListFields();
    }

    if (typeField == null) return null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: _typeFieldTransitionBuilder,
      layoutBuilder: (currentChild, previousChildren) {
        // Ensure smooth layout transitions without jank
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Container(
        key: ValueKey<ContentType?>(_selectedType), // Unique key for each type
        child: typeField,
      ),
    );
  }

  Widget _buildInputField() {
    final isMobile = context.isMobile;
    final l10n = AppLocalizations.of(context)!;

    // For notes, we use type-specific fields instead of the default input field
    if (_selectedType == ContentType.note) {
      return const SizedBox.shrink();
    }

    // Get appropriate hint text based on content type
    String getHintText() {
      switch (_selectedType) {
        case ContentType.todoList:
          return l10n.createModalTodoListNameHint;
        case ContentType.list:
          return l10n.createModalListNameHint;
        case ContentType.note:
          return l10n.createModalNoteTitleHint; // Fallback, but note uses type-specific fields
        case null:
          return l10n.createModalNoteTitleHint;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
      ),
      child: TextInputField(
        key: const Key('capture_input'),
        controller: _textController,
        focusNode: _focusNode,
        autofocus: true,
        hintText: getHintText(),
      ),
    );
  }

  Widget _buildSpaceSelectorRow() {
    final isMobile = context.isMobile;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? AppSpacing.lg : AppSpacing.md,
        0,
        isMobile ? AppSpacing.lg : AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            l10n.createModalSaveToLabel,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          _buildSpaceSelector(),
        ],
      ),
    );
  }

  Widget _buildSpaceSelector() {
    final currentSpace = ref.watch(currentSpaceControllerProvider).when(
      data: (space) => space,
      loading: () => null,
      error: (error, stack) => null,
    );

    if (currentSpace == null) return const SizedBox.shrink();

    final spaces = ref.watch(spacesControllerProvider).when(
      data: (data) => data,
      loading: () => <Space>[],
      error: (error, stack) => <Space>[],
    );

    // Use local state to find the selected space for display
    // If _selectedSpaceId is null, fall back to currentSpace.id
    final selectedSpace = spaces.firstWhere(
      (s) => s.id == (_selectedSpaceId ?? currentSpace.id),
      orElse: () => currentSpace,
    );

    final String? spaceIcon = selectedSpace.icon;
    final String spaceName = selectedSpace.name;

    return PopupMenuButton<String>(
      key: const Key('space_selector'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spaceIcon != null)
            Text(spaceIcon, style: const TextStyle(fontSize: 16)),
          if (spaceIcon != null)
            const SizedBox(width: AppSpacing.xxs),
          Text(
            spaceName,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: AppColors.textSecondary(context),
          ),
        ],
      ),
      itemBuilder: (context) {
        return spaces.map((space) {
          final String spaceId = space.id;
          final String? icon = space.icon;
          final String name = space.name;

          return PopupMenuItem<String>(
            value: spaceId,
            child: Row(
              children: [
                if (icon != null)
                  Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpacing.xs),
                Text(name),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (spaceId) {
        // Update only local state, not global provider
        debugPrint(
          'CreateContent: Space selected in dropdown - spaceId: $spaceId',
        );
        if (mounted) {
          setState(() {
            _selectedSpaceId = spaceId;
            debugPrint(
              'CreateContent: _selectedSpaceId updated to: $_selectedSpaceId',
            );
          });
        }
      },
    );
  }

  Widget _buildAutoSaveIndicator() {
    final isMobile = context.isMobile;
    final l10n = AppLocalizations.of(context)!;

    // Platform-aware keyboard shortcut text
    String getKeyboardShortcutText() {
      try {
        final isMacOS = Platform.isMacOS;
        return isMacOS
            ? l10n.createModalKeyboardShortcutMac
            : l10n.createModalKeyboardShortcutOther;
      } catch (e) {
        // Fallback for web or platforms without Platform API
        return l10n.createModalKeyboardShortcutOther;
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
        AppSpacing.xs,
        isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Keyboard shortcuts hint (visible when focused, desktop only)
          if (!isMobile && _focusNode.hasFocus)
            Text(
              getKeyboardShortcutText(),
              key: const Key('keyboard_hints'),
              textAlign: TextAlign.right,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter({required bool isMobile}) {
    final l10n = AppLocalizations.of(context)!;
    // Get button text from selected type
    String buttonText;
    switch (_selectedType) {
      case ContentType.todoList:
        buttonText = l10n.createModalButtonTodoList;
        break;
      case ContentType.list:
        buttonText = l10n.createModalButtonList;
        break;
      case ContentType.note:
        buttonText = l10n.createModalButtonNote;
        break;
      case null:
        buttonText = l10n.createModalButtonGeneric;
        break;
    }

    // Determine if button should be enabled based on content type
    bool hasContent;
    if (_selectedType == ContentType.note) {
      // For notes, check the appropriate controller based on screen size
      hasContent = isMobile
          ? _textController.text.trim().isNotEmpty
          : _noteTitleController.text.trim().isNotEmpty;
    } else {
      // For other types, check the default text controller
      hasContent = _textController.text.trim().isNotEmpty;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: PrimaryButton(
            key: const Key('save_button'),
            text: buttonText,
            icon: Icons.check,
            onPressed: hasContent ? _handleExplicitSave : null,
            isLoading: _isSaving,
            isExpanded: true,
          ),
        ),
        // Bottom padding for mobile (safe area + keyboard)
        if (isMobile) SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}
