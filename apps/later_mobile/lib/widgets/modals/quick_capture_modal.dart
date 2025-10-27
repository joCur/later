import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_area_field.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/temporal_flow_theme.dart';
import '../../core/utils/item_type_detector.dart';
import '../../data/models/item_model.dart';
import '../../data/models/list_model.dart';
import '../../data/models/todo_list_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/spaces_provider.dart';

/// Type option for Quick Capture content type selector
class TypeOption {
  const TypeOption({
    required this.label,
    required this.icon,
    required this.type,
    this.color,
  });

  final String label;
  final IconData icon;
  final ContentType? type; // null for "Auto"
  final Color? color;
}

/// Quick Capture Modal widget
///
/// A responsive modal for quickly capturing tasks, notes, and lists
/// with auto-save, type detection, and keyboard shortcuts.
///
/// Features:
/// - Responsive layout (mobile bottom sheet, desktop centered modal)
/// - Auto-save with debounce (500ms)
/// - Smart type detection
/// - Keyboard shortcuts (Esc to close, Cmd/Ctrl+Enter to save and close)
/// - Voice and image input buttons (placeholders)
/// - Space selector
class QuickCaptureModal extends StatefulWidget {
  const QuickCaptureModal({super.key, required this.onClose});

  /// Callback when modal is closed
  final VoidCallback onClose;

  @override
  State<QuickCaptureModal> createState() => _QuickCaptureModalState();
}

class _QuickCaptureModalState extends State<QuickCaptureModal>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  String? _currentItemId;
  bool _isSaving = false;
  bool _isSaved = false;
  String? _selectedSpaceId; // Local state for space selection (modal-only)

  // Type selection for content creation
  static const List<TypeOption> _typeOptions = [
    TypeOption(label: 'Auto', icon: Icons.auto_awesome, type: null),
    TypeOption(
      label: 'Todo',
      icon: Icons.check_box_outlined,
      type: ContentType.todoList,
      color: AppColors.info,
    ),
    TypeOption(
      label: 'List',
      icon: Icons.list_alt,
      type: ContentType.list,
      color: AppColors.primarySolid,
    ),
    TypeOption(
      label: 'Note',
      icon: Icons.description_outlined,
      type: ContentType.note,
      color: AppColors.success,
    ),
  ];

  ContentType? _selectedType; // null = Auto
  ContentType? _detectedType; // Tracks auto-detected type

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _typeIconAnimationController;
  late Animation<double> _typeIconScaleAnimation;

  @override
  void initState() {
    super.initState();
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

    _typeIconScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _typeIconAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start entrance animation
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize local space selection with current space
    // Safe to use context.read here as BuildContext is ready
    if (_selectedSpaceId == null) {
      final spacesProvider = context.read<SpacesProvider>();
      _selectedSpaceId = spacesProvider.currentSpace?.id;
      debugPrint(
        'QuickCapture: didChangeDependencies - _selectedSpaceId initialized to: $_selectedSpaceId',
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _typeIconAnimationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();

    // Cancel existing timer
    _debounceTimer?.cancel();

    if (text.isEmpty) {
      setState(() {
        _isSaving = false;
        _isSaved = false;
        _detectedType = null;
      });
      return;
    }

    // Detect type if in Auto mode
    if (_selectedType == null) {
      final newDetectedType = ItemTypeDetector.detectType(text);
      if (_detectedType != newDetectedType) {
        setState(() {
          _detectedType = newDetectedType;
        });
        _typeIconAnimationController.forward(from: 0.0);
      }
    }

    // Show saving indicator
    setState(() {
      _isSaving = true;
      _isSaved = false;
    });

    // Debounce save
    _debounceTimer = Timer(AppAnimations.autoSaveDebounce, () {
      _saveItem();
    });
  }

  Future<void> _saveItem() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final contentProvider = context.read<ContentProvider>();
    final spacesProvider = context.read<SpacesProvider>();
    final currentSpace = spacesProvider.currentSpace;

    if (currentSpace == null) {
      debugPrint('QuickCapture: Cannot save - no current space');
      return;
    }

    // Safety check: Ensure selected space ID is valid
    if (_selectedSpaceId == null) {
      debugPrint('QuickCapture: Cannot save - _selectedSpaceId is null');
      return;
    }

    // Verify the selected space still exists
    final spaceExists = spacesProvider.spaces.any(
      (s) => s.id == _selectedSpaceId,
    );
    final targetSpaceId = spaceExists ? _selectedSpaceId! : currentSpace.id;

    debugPrint(
      'QuickCapture: Creating item - _selectedSpaceId: $_selectedSpaceId, '
      'currentSpace: ${currentSpace.id}, targetSpaceId: $targetSpaceId, '
      'spaceExists: $spaceExists',
    );

    // Log fallback if space was deleted
    if (!spaceExists) {
      debugPrint(
        'Warning: Selected space no longer exists, falling back to current space',
      );
    }

    // Determine content type (either user-selected or auto-detected)
    final contentType = _selectedType ?? _detectedType ?? ContentType.note;

    try {
      if (_currentItemId == null) {
        // Create new content based on type
        final id = const Uuid().v4();

        switch (contentType) {
          case ContentType.todoList:
            final todoList = TodoList(
              id: id,
              spaceId: targetSpaceId,
              name: text,
              items: [],
            );
            await contentProvider.createTodoList(todoList, spacesProvider);
            _currentItemId = id;
            break;

          case ContentType.list:
            final listModel = ListModel(
              id: id,
              spaceId: targetSpaceId,
              name: text,
              items: [],
            );
            await contentProvider.createList(listModel, spacesProvider);
            _currentItemId = id;
            break;

          case ContentType.note:
            final note = Item(id: id, title: text, spaceId: targetSpaceId);
            await contentProvider.createNote(note, spacesProvider);
            _currentItemId = id;
            break;
        }
      } else {
        // Update existing item (only works for Notes in this simple version)
        // For TodoLists and Lists, we don't support editing in quick capture
        if (contentType == ContentType.note) {
          final existingNotes = contentProvider.notes;
          final existingNote = existingNotes.cast<Item?>().firstWhere(
            (note) => note?.id == _currentItemId,
            orElse: () => null,
          );

          if (existingNote != null) {
            await contentProvider.updateNote(
              existingNote.copyWith(title: text),
            );
          }
        }
      }

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });
    } catch (e) {
      debugPrint('QuickCapture: Error saving item - $e');
      setState(() {
        _isSaving = false;
        _isSaved = false;
      });
    }
  }

  Future<void> _handleKeyEvent(KeyEvent event) async {
    if (event is KeyDownEvent) {
      // Escape to close (with confirmation if unsaved)
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        await _handleClose();
        return;
      }

      // Cmd/Ctrl + Enter to save and close
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final isModifierPressed =
            HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;

        if (isModifierPressed) {
          // Cancel debounce and save immediately
          _debounceTimer?.cancel();
          await _saveItem();
          _close();
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
    final hasUnsavedChanges = hasContent && !_isSaved;

    if (hasUnsavedChanges) {
      // Show confirmation dialog
      final shouldClose = await _showCloseConfirmation();
      if (shouldClose == true) {
        // Save before closing
        await _saveItem();
        if (mounted) {
          _close();
        }
      }
    } else {
      // No unsaved changes, close immediately
      _close();
    }
  }

  Future<bool?> _showCloseConfirmation() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final surfaceColor = isDark ? AppColors.neutral900 : Colors.white;

    return showDialog<bool>(
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
                  'Save changes?',
                  style: AppTypography.h4.copyWith(
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'You have unsaved changes. Would you like to save them before closing?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      text: 'Discard',
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    GhostButton(
                      text: 'Save',
                      onPressed: () => Navigator.of(context).pop(true),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final surfaceColor = isDark ? AppColors.neutral900 : Colors.white;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final surfaceColor = isDark ? AppColors.neutral900 : Colors.white;
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

        // Toolbar
        _buildToolbar(),

        // Auto-save indicator
        _buildAutoSaveIndicator(),

        SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.sm),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

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
          Expanded(
            child: Semantics(
              label: 'Quick Capture',
              child: Text(
                'Quick Capture',
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ),
            ),
          ),
          Semantics(
            label: 'Close',
            button: true,
            child: IconButton(
              key: const Key('close_button'),
              icon: Icon(
                Icons.close,
                color: isDark ? AppColors.neutral500 : AppColors.neutral500,
              ),
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

  Widget _buildInputField() {
    final isMobile = context.isMobile;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
      ),
      child: TextAreaField(
        key: const Key('capture_input'),
        controller: _textController,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: 10,
        hintText: 'What\'s on your mind?',
      ),
    );
  }

  Widget _buildToolbar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
        AppSpacing.sm,
        isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
        0,
      ),
      child: Row(
        children: [
          // Voice button
          Semantics(
            label: 'Voice input',
            button: true,
            child: IconButton(
              key: const Key('voice_button'),
              icon: Icon(
                Icons.mic_outlined,
                color: isDark ? AppColors.neutral500 : AppColors.neutral500,
              ),
              onPressed: () {
                // TODO: Implement voice input
              },
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: AppSpacing.minTouchTarget,
                minHeight: AppSpacing.minTouchTarget,
              ),
            ),
          ),

          // Image button
          Semantics(
            label: 'Add image',
            button: true,
            child: IconButton(
              key: const Key('image_button'),
              icon: Icon(
                Icons.image_outlined,
                color: isDark ? AppColors.neutral500 : AppColors.neutral500,
              ),
              onPressed: () {
                // TODO: Implement image attachment
              },
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: AppSpacing.minTouchTarget,
                minHeight: AppSpacing.minTouchTarget,
              ),
            ),
          ),

          const Spacer(),

          // Type selector
          _buildTypeSelector(),
          const SizedBox(width: AppSpacing.xs),

          // Space selector
          _buildSpaceSelector(),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine which option to display
    // If user selected a type, use that, otherwise show detected or Auto
    final displayType = _selectedType ?? _detectedType;
    final selectedOption = _typeOptions.firstWhere(
      (option) => option.type == displayType,
      orElse: () => _typeOptions[0], // Default to Auto
    );

    return PopupMenuButton<TypeOption>(
      key: const Key('type_selector'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              key: const Key('type_icon_animated'),
              scale: _typeIconScaleAnimation,
              child: Icon(
                selectedOption.icon,
                size: 16,
                color:
                    selectedOption.color ??
                    (isDark ? AppColors.neutral400 : AppColors.neutral600),
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              selectedOption.label,
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.neutral400 : AppColors.neutral600,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isDark ? AppColors.neutral500 : AppColors.neutral500,
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return _typeOptions.map((option) {
          return PopupMenuItem<TypeOption>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option.icon,
                  key: Key('type_icon_${option.label.toLowerCase()}'),
                  size: 20,
                  color:
                      option.color ??
                      (isDark ? AppColors.neutral400 : AppColors.neutral600),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(option.label),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (option) {
        setState(() {
          _selectedType = option.type;
          // If user explicitly selects Auto, reset detected type
          if (option.type == null) {
            _detectedType = null;
            // Re-run detection on current text
            final text = _textController.text.trim();
            if (text.isNotEmpty) {
              _detectedType = ItemTypeDetector.detectType(text);
            }
          }
        });
      },
    );
  }

  Widget _buildSpaceSelector() {
    return Consumer<SpacesProvider>(
      builder: (context, spacesProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentSpace = spacesProvider.currentSpace;
        if (currentSpace == null) return const SizedBox.shrink();

        // Use local state to find the selected space for display
        // If _selectedSpaceId is null, fall back to currentSpace.id
        final selectedSpace = spacesProvider.spaces.firstWhere(
          (s) => s.id == (_selectedSpaceId ?? currentSpace.id),
          orElse: () => currentSpace,
        );

        return PopupMenuButton<String>(
          key: const Key('space_selector'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.neutral700 : AppColors.neutral200,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedSpace.icon != null)
                  Text(
                    selectedSpace.icon!,
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  selectedSpace.name,
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                ),
              ],
            ),
          ),
          itemBuilder: (context) {
            return spacesProvider.spaces.map((space) {
              return PopupMenuItem<String>(
                value: space.id,
                child: Row(
                  children: [
                    if (space.icon != null)
                      Text(space.icon!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(space.name),
                  ],
                ),
              );
            }).toList();
          },
          onSelected: (spaceId) {
            // Update only local state, not global provider
            debugPrint(
              'QuickCapture: Space selected in dropdown - spaceId: $spaceId',
            );
            if (mounted) {
              setState(() {
                _selectedSpaceId = spaceId;
                debugPrint(
                  'QuickCapture: _selectedSpaceId updated to: $_selectedSpaceId',
                );
              });
            }
          },
        );
      },
    );
  }

  Widget _buildAutoSaveIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

    // Platform-aware keyboard shortcut text
    String getKeyboardShortcutText() {
      try {
        final isMacOS = Platform.isMacOS;
        return isMacOS
            ? '⌘+Enter to save • Esc to close'
            : 'Ctrl+Enter to save • Esc to close';
      } catch (e) {
        // Fallback for web or platforms without Platform API
        return 'Ctrl+Enter to save • Esc to close';
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
          Row(
            key: const Key('autosave_indicator'),
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isSaving || _isSaved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSaving)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.neutral500,
                            ),
                          ),
                        )
                      else if (_isSaved)
                        const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.success,
                        ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        _isSaving ? 'Saving...' : 'Saved',
                        style: AppTypography.labelSmall.copyWith(
                          color: _isSaving
                              ? AppColors.neutral500
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // Keyboard shortcuts hint (visible when focused, desktop only)
          if (!isMobile && _focusNode.hasFocus)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                getKeyboardShortcutText(),
                key: const Key('keyboard_hints'),
                textAlign: TextAlign.right,
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
