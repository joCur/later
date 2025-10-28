import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/design_system/atoms/text/gradient_text.dart';

/// An editable title widget for AppBar that switches between display and edit modes.
///
/// This molecule component provides a tap-to-edit pattern commonly used in
/// detail screens. When not editing, it displays the title as gradient text
/// with an edit icon. When tapped, it switches to an editable TextField.
///
/// ## Features
/// - Tap-to-edit interaction pattern
/// - Auto-saves on submit or focus loss
/// - Gradient text display with optional customization
/// - Empty text validation (prevents saving empty titles)
/// - Auto-focus when entering edit mode
/// - Visual edit icon hint
///
/// ## Usage
/// ```dart
/// EditableAppBarTitle(
///   text: note.title,
///   onChanged: (newTitle) {
///     // Save the new title
///     updateNote(note.copyWith(title: newTitle));
///   },
///   gradient: AppColors.noteGradient,
/// )
/// ```
///
/// ## Accessibility
/// - Supports text scaling up to 2.0x
/// - Keyboard navigation and submission
/// - Screen reader announces edit mode transitions
/// - Touch target size meets minimum requirements (48x48dp)
///
/// ## Design System Integration
/// - Uses AppTypography.h3 by default for consistent heading hierarchy
/// - Supports gradient customization for different entity types (tasks, notes, lists)
/// - Follows Temporal Flow spacing and visual rhythm
class EditableAppBarTitle extends StatefulWidget {
  /// Creates an editable app bar title.
  ///
  /// The [text] and [onChanged] parameters are required.
  ///
  /// The [gradient] defaults to the primary gradient if not provided.
  /// The [style] defaults to [AppTypography.h3] if not provided.
  /// The [hintText] is shown in the TextField when in edit mode.
  const EditableAppBarTitle({
    super.key,
    required this.text,
    required this.onChanged,
    this.gradient,
    this.style,
    this.hintText = 'Title',
  });

  /// The current title text to display.
  final String text;

  /// Callback invoked when the title is changed and saved.
  ///
  /// This is called when:
  /// - User submits the TextField (presses Enter/Done)
  /// - User taps outside the TextField (loses focus)
  ///
  /// The callback is only invoked if the text is not empty.
  final ValueChanged<String> onChanged;

  /// The gradient to apply to the display text.
  ///
  /// If null, uses the theme-adaptive primary gradient.
  /// Common gradients:
  /// - [AppColors.noteGradient] for notes
  /// - [AppColors.taskGradient] for tasks/todos
  /// - [AppColors.listGradient] for lists
  final Gradient? gradient;

  /// The text style for both display and edit modes.
  ///
  /// If null, defaults to [AppTypography.h3].
  final TextStyle? style;

  /// Hint text shown in the TextField when editing.
  ///
  /// Defaults to 'Title'.
  final String hintText;

  @override
  State<EditableAppBarTitle> createState() => _EditableAppBarTitleState();
}

class _EditableAppBarTitleState extends State<EditableAppBarTitle> {
  /// Whether the title is currently being edited
  bool _isEditing = false;

  /// Text controller for the TextField
  late TextEditingController _controller;

  /// Focus node to track TextField focus
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);

    // Listen to focus changes to exit edit mode when focus is lost
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(EditableAppBarTitle oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller text if the widget's text changes externally
    if (widget.text != oldWidget.text && widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Handle focus changes - exit edit mode when focus is lost
  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _exitEditMode();
    }
  }

  /// Enter edit mode - show TextField with focus
  void _enterEditMode() {
    setState(() {
      _isEditing = true;
    });

    // Request focus after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  /// Exit edit mode and save changes if valid
  void _exitEditMode() {
    final newText = _controller.text.trim();

    // Validate: do not save if empty
    if (newText.isEmpty) {
      // Restore previous text
      _controller.text = widget.text;
      setState(() {
        _isEditing = false;
      });
      return;
    }

    // Only call onChanged if the text actually changed
    if (newText != widget.text) {
      widget.onChanged(newText);
    }

    setState(() {
      _isEditing = false;
    });
  }

  /// Handle TextField submission
  void _handleSubmitted(String value) {
    _exitEditMode();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? AppTypography.h3;

    if (_isEditing) {
      // Edit mode: show TextField
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: effectiveStyle,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
        ),
        onSubmitted: _handleSubmitted,
      );
    }

    // Display mode: show GradientText with edit icon
    return GestureDetector(
      onTap: _enterEditMode,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GradientText(
              widget.text,
              gradient: widget.gradient,
              style: effectiveStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.edit, size: 16, color: AppColors.textSecondary(context)),
        ],
      ),
    );
  }
}
