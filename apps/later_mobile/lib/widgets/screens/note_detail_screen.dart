import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../data/models/item_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/spaces_provider.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import '../../core/utils/responsive_modal.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';
import 'package:later_mobile/design_system/molecules/app_bars/editable_app_bar_title.dart';

/// Note Detail Screen for viewing and editing Note content
///
/// Features:
/// - Editable Note title in AppBar with note gradient
/// - Large multiline TextField for content
/// - Tag management (add/remove tags as chips)
/// - Auto-save with debounce (2000ms)
/// - Menu: Delete note, Add to favorites (future)
/// - Loading indicator when saving
/// - Empty state support
/// - Error handling with SnackBar messages
class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.note});

  /// Note to display and edit
  final Item note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  // Text controllers
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // Local state
  late Item _currentNote;
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _hasChanges = false;

  // Tag management
  final TextEditingController _tagController = TextEditingController();

  // Constants
  static const int _autoSaveDelayMs = 2000;
  static const int _maxTagLength = 50;

  @override
  void initState() {
    super.initState();

    // Initialize current note
    _currentNote = widget.note;

    // Initialize text controllers
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content ?? '');

    // Listen to text changes for auto-save
    _titleController.addListener(_onTitleChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.removeListener(_onTitleChanged);
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// Handle title changes and trigger debounced save
  void _onTitleChanged() {
    setState(() {
      _hasChanges = true;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: _autoSaveDelayMs), () {
      _saveChanges();
    });
  }

  /// Handle content changes and trigger debounced save
  void _onContentChanged() {
    setState(() {
      _hasChanges = true;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: _autoSaveDelayMs), () {
      _saveChanges();
    });
  }

  /// Save changes to the note
  Future<void> _saveChanges() async {
    if (_isSaving) return;

    // Validate title
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Title cannot be empty', isError: true);
      // Restore previous title
      _titleController.text = _currentNote.title;
      setState(() {
        _hasChanges = false;
      });
      return;
    }

    if (!_hasChanges) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Update note
      final updated = _currentNote.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim().isEmpty
            ? null
            : _contentController.text.trim(),
        updatedAt: DateTime.now(),
      );

      // Save via provider
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateNote(updated);

      setState(() {
        _currentNote = updated;
        _hasChanges = false;
      });
    } catch (e) {
      _showSnackBar('Failed to save changes: $e', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Add a tag to the note
  Future<void> _addTag(String tag) async {
    final trimmedTag = tag.trim();

    // Validation
    if (trimmedTag.isEmpty) {
      _showSnackBar('Tag cannot be empty', isError: true);
      return;
    }

    if (trimmedTag.length > _maxTagLength) {
      _showSnackBar(
        'Tag is too long (max $_maxTagLength characters)',
        isError: true,
      );
      return;
    }

    if (_currentNote.tags.contains(trimmedTag)) {
      _showSnackBar('Tag already exists', isError: true);
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      // Add tag to note
      final updated = _currentNote.copyWith(
        tags: [..._currentNote.tags, trimmedTag],
        updatedAt: DateTime.now(),
      );

      // Save via provider
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateNote(updated);

      setState(() {
        _currentNote = updated;
      });

      _tagController.clear();
      _showSnackBar('Tag added');
    } catch (e) {
      _showSnackBar('Failed to add tag: $e', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Remove a tag from the note
  Future<void> _removeTag(String tag) async {
    try {
      setState(() {
        _isSaving = true;
      });

      // Remove tag from note
      final updated = _currentNote.copyWith(
        tags: _currentNote.tags.where((t) => t != tag).toList(),
        updatedAt: DateTime.now(),
      );

      // Save via provider
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateNote(updated);

      setState(() {
        _currentNote = updated;
      });

      _showSnackBar('Tag removed');
    } catch (e) {
      _showSnackBar('Failed to remove tag: $e', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Show add tag dialog
  Future<void> _showAddTagDialog() async {
    _tagController.clear();

    return ResponsiveModal.show<void>(
      context: context,
      child: BottomSheetContainer(
        title: 'Add Tag',
        primaryButtonText: 'Add',
        showSecondaryButton: false,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          _addTag(_tagController.text);
        },
        child: TextInputField(
          controller: _tagController,
          label: 'Tag Name',
          hintText: 'Enter tag name',
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _addTag(value);
          },
        ),
      ),
    );
  }

  /// Delete the note
  Future<void> _deleteNote() async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final spacesProvider = Provider.of<SpacesProvider>(
        context,
        listen: false,
      );

      await provider.deleteNote(_currentNote.id, spacesProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) _showSnackBar('Note deleted');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to delete note: $e', isError: true);
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Note',
      message: 'Are you sure you want to delete "${_currentNote.title}"?\n\n'
          'This action cannot be undone.',
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(); // Return to previous screen
      await _deleteNote();
    }
  }

  /// Show SnackBar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Save before leaving
          await _saveChanges();
          if (mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: EditableAppBarTitle(
            text: _currentNote.title,
            onChanged: (newTitle) {
              _titleController.text = newTitle;
              _saveChanges();
            },
            gradient: AppColors.noteGradient,
            hintText: 'Note title',
          ),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Text('Delete Note'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content TextField
              TextField(
                key: const Key('note_content_field'),
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Start writing your note...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  border: InputBorder.none,
                ),
                style: AppTypography.bodyMedium,
                maxLines: null, // Auto-expanding
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Tags section
              if (_currentNote.tags.isNotEmpty || true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tags',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: _showAddTagDialog,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Tag chips
                    if (_currentNote.tags.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: _currentNote.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            labelStyle: AppTypography.bodySmall,
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: AppColors.noteLight.withValues(
                              alpha: 0.3,
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'No tags yet. Tap + to add tags.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
