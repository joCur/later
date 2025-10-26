import 'dart:async';
import 'package:flutter/material.dart';

/// Mixin providing auto-save functionality with debouncing for detail screens.
///
/// This mixin eliminates common boilerplate for screens that need to:
/// - Automatically save changes after user stops editing
/// - Debounce rapid changes to avoid excessive saves
/// - Track save state and change state
/// - Clean up resources properly
///
/// ## Features
///
/// - **Debounced Auto-save**: Changes trigger a debounced save operation
/// - **State Management**: Tracks `isSaving` and `hasChanges` flags
/// - **Timer Management**: Handles debounce timer lifecycle automatically
/// - **Configurable Delay**: Override `autoSaveDelayMs` to customize debounce duration
///
/// ## Usage Example
///
/// ```dart
/// class _NoteDetailScreenState extends State<NoteDetailScreen>
///     with AutoSaveMixin {
///   late TextEditingController _titleController;
///
///   @override
///   void initState() {
///     super.initState();
///     _titleController = TextEditingController(text: widget.note.title);
///
///     // Connect controller to auto-save
///     _titleController.addListener(() => onFieldChanged());
///   }
///
///   @override
///   Future<void> saveChanges() async {
///     if (isSaving || !hasChanges) return;
///
///     setState(() => isSaving = true);
///
///     try {
///       // Screen-specific save logic
///       await provider.updateNote(...);
///       setState(() => hasChanges = false);
///     } catch (e) {
///       // Error handling
///     } finally {
///       setState(() => isSaving = false);
///     }
///   }
///
///   @override
///   void dispose() {
///     _titleController.dispose();
///     super.dispose(); // Calls AutoSaveMixin.dispose()
///   }
/// }
/// ```
///
/// ## Configuration
///
/// Override `autoSaveDelayMs` to customize the debounce delay:
///
/// ```dart
/// @override
/// int get autoSaveDelayMs => 1000; // 1 second instead of default 2 seconds
/// ```
///
/// ## State Management
///
/// The mixin provides three state properties:
///
/// - `isSaving`: `true` when a save operation is in progress
/// - `hasChanges`: `true` when user has made changes since last save
/// - `debounceTimer`: Active debounce timer (null when no timer is active)
///
/// ## Implementation Requirements
///
/// Classes using this mixin must:
///
/// 1. **Implement `saveChanges()` method**: Define screen-specific save logic
/// 2. **Call `onFieldChanged()`**: Connect to input listeners (e.g., TextEditingController)
/// 3. **Call `super.dispose()`**: Ensure timer cleanup in dispose method
///
/// ## Best Practices
///
/// - Call `onFieldChanged()` from input listeners (TextEditingController, etc.)
/// - Check `isSaving` flag before starting save operations to prevent concurrent saves
/// - Check `hasChanges` flag to avoid unnecessary save operations
/// - Reset `hasChanges = false` after successful save
/// - Always call `super.dispose()` to ensure proper cleanup
mixin AutoSaveMixin<T extends StatefulWidget> on State<T> {
  /// Active debounce timer.
  ///
  /// When non-null, indicates a save operation is scheduled.
  /// Automatically canceled when a new change occurs or when disposed.
  Timer? debounceTimer;

  /// Indicates whether a save operation is currently in progress.
  ///
  /// Use this flag to:
  /// - Prevent concurrent save operations
  /// - Show loading indicators in the UI
  /// - Disable user interactions during save
  ///
  /// Example:
  /// ```dart
  /// if (isSaving) {
  ///   return CircularProgressIndicator();
  /// }
  /// ```
  bool isSaving = false;

  /// Indicates whether the user has made changes since the last save.
  ///
  /// Use this flag to:
  /// - Skip unnecessary save operations when no changes exist
  /// - Show unsaved changes indicators in the UI
  /// - Prompt user before navigating away
  ///
  /// Set to `true` by `onFieldChanged()`.
  /// Should be reset to `false` after successful save.
  ///
  /// Example:
  /// ```dart
  /// await provider.updateNote(...);
  /// setState(() => hasChanges = false);
  /// ```
  bool hasChanges = false;

  /// Debounce delay in milliseconds.
  ///
  /// Override this getter to customize the debounce duration:
  ///
  /// ```dart
  /// @override
  /// int get autoSaveDelayMs => 1000; // 1 second
  /// ```
  ///
  /// Default: 2000ms (2 seconds)
  int get autoSaveDelayMs => 2000;

  /// Abstract method that must be implemented by the screen.
  ///
  /// This method should contain the screen-specific save logic:
  /// - Validate input data
  /// - Call provider/repository methods
  /// - Update local state
  /// - Handle errors
  ///
  /// ## Implementation Pattern
  ///
  /// ```dart
  /// @override
  /// Future<void> saveChanges() async {
  ///   // 1. Check guards
  ///   if (isSaving || !hasChanges) return;
  ///
  ///   // 2. Validate input
  ///   if (_titleController.text.trim().isEmpty) {
  ///     _showError('Title cannot be empty');
  ///     return;
  ///   }
  ///
  ///   // 3. Set saving state
  ///   setState(() => isSaving = true);
  ///
  ///   try {
  ///     // 4. Perform save operation
  ///     final updated = _currentNote.copyWith(
  ///       title: _titleController.text.trim(),
  ///       updatedAt: DateTime.now(),
  ///     );
  ///     await provider.updateNote(updated);
  ///
  ///     // 5. Update state on success
  ///     setState(() {
  ///       _currentNote = updated;
  ///       hasChanges = false;
  ///     });
  ///   } catch (e) {
  ///     // 6. Handle errors
  ///     _showError('Failed to save: $e');
  ///   } finally {
  ///     // 7. Reset saving state
  ///     setState(() => isSaving = false);
  ///   }
  /// }
  /// ```
  Future<void> saveChanges();

  /// Handles field changes and triggers debounced save.
  ///
  /// Call this method from input listeners to trigger auto-save:
  ///
  /// ```dart
  /// _titleController.addListener(() => onFieldChanged());
  /// ```
  ///
  /// For screen-specific logic, use the optional `onChanged` callback:
  ///
  /// ```dart
  /// _titleController.addListener(() {
  ///   onFieldChanged(onChanged: () {
  ///     // Screen-specific logic (e.g., character count)
  ///     print('Title length: ${_titleController.text.length}');
  ///   });
  /// });
  /// ```
  ///
  /// ## Behavior
  ///
  /// 1. Sets `hasChanges = true`
  /// 2. Executes optional `onChanged` callback
  /// 3. Cancels any existing debounce timer
  /// 4. Starts new debounce timer
  /// 5. Calls `saveChanges()` when timer completes
  ///
  /// Parameters:
  /// - `onChanged`: Optional callback for screen-specific logic
  void onFieldChanged({VoidCallback? onChanged}) {
    // Mark that changes have been made
    hasChanges = true;

    // Execute optional callback for screen-specific logic
    if (onChanged != null) {
      onChanged();
    }

    // Cancel previous debounce timer
    cancelDebounceTimer();

    // Start new debounce timer
    debounceTimer = Timer(Duration(milliseconds: autoSaveDelayMs), () {
      saveChanges();
    });
  }

  /// Cancels the active debounce timer if one exists.
  ///
  /// This method is called automatically by:
  /// - `onFieldChanged()` when a new change occurs
  /// - `dispose()` during cleanup
  ///
  /// You can also call it manually to cancel a pending save:
  ///
  /// ```dart
  /// void _onCancel() {
  ///   cancelDebounceTimer();
  ///   Navigator.of(context).pop();
  /// }
  /// ```
  void cancelDebounceTimer() {
    debounceTimer?.cancel();
    debounceTimer = null;
  }

  /// Disposes resources used by the mixin.
  ///
  /// Automatically cancels the debounce timer to prevent memory leaks.
  ///
  /// **IMPORTANT**: Always call `super.dispose()` in your screen's dispose method:
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _titleController.dispose();
  ///   _contentController.dispose();
  ///   super.dispose(); // Calls AutoSaveMixin.dispose()
  /// }
  /// ```
  @override
  void dispose() {
    cancelDebounceTimer();
    super.dispose();
  }
}
