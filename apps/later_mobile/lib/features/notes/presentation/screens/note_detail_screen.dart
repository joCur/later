import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/mixins/auto_save_mixin.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/molecules/app_bars/editable_app_bar_title.dart';
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

import 'package:later_mobile/core/utils/responsive_modal.dart';
import '../../application/providers.dart';
import '../../domain/models/note.dart';
import '../controllers/notes_controller.dart';

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
///
/// The screen now fetches note data by ID using the noteByIdProvider.
/// This enables deep linking and ensures data is always fresh from the source.
class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  /// ID of the note to display and edit
  final String noteId;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen>
    with AutoSaveMixin {
  // Text controllers (nullable until note loads)
  TextEditingController? _titleController;
  TextEditingController? _contentController;

  // Local state (nullable until note loads)
  Note? _currentNote;

  // Tag management
  final TextEditingController _tagController = TextEditingController();

  // Constants
  static const int _maxTagLength = 50;

  // Track if controllers have been initialized
  bool _controllersInitialized = false;

  /// Initialize text controllers when note data is available
  void _initializeControllers(Note note) {
    if (_controllersInitialized) return;

    _currentNote = note;
    _titleController = TextEditingController(text: note.title);
    _contentController = TextEditingController(text: note.content ?? '');

    // Listen to text changes for auto-save
    _titleController!.addListener(() => onFieldChanged());
    _contentController!.addListener(() => onFieldChanged());

    _controllersInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in build when data loads
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _contentController?.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// Save changes to the note
  @override
  Future<void> saveChanges() async {
    if (isSaving || _currentNote == null || _titleController == null || _contentController == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final currentNote = _currentNote!;
    final titleController = _titleController!;
    final contentController = _contentController!;

    // Validate title
    if (titleController.text.trim().isEmpty) {
      _showSnackBar(l10n.noteDetailTitleEmpty, isError: true);
      // Restore previous title
      titleController.text = currentNote.title;
      setState(() {
        hasChanges = false;
      });
      return;
    }

    if (!hasChanges) return;

    setState(() {
      isSaving = true;
    });

    try {
      // Update note
      final updated = currentNote.copyWith(
        title: titleController.text.trim(),
        content: contentController.text.trim().isEmpty
            ? null
            : contentController.text.trim(),
        updatedAt: DateTime.now(),
      );

      // Save via Riverpod controller
      await ref
          .read(notesControllerProvider(currentNote.spaceId).notifier)
          .updateNote(updated);

      setState(() {
        _currentNote = updated;
        hasChanges = false;
      });
    } catch (e) {
      _showSnackBar('${l10n.noteDetailSaveFailed}: $e', isError: true);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  /// Add a tag to the note
  Future<void> _addTag(String tag) async {
    if (_currentNote == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentNote = _currentNote!;
    final trimmedTag = tag.trim();

    // Validation
    if (trimmedTag.isEmpty) {
      _showSnackBar(l10n.noteDetailTagEmpty, isError: true);
      return;
    }

    if (trimmedTag.length > _maxTagLength) {
      _showSnackBar(
        l10n.noteDetailTagTooLong(_maxTagLength.toString()),
        isError: true,
      );
      return;
    }

    if (currentNote.tags.contains(trimmedTag)) {
      _showSnackBar(l10n.noteDetailTagExists, isError: true);
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      // Add tag to note
      final updated = currentNote.copyWith(
        tags: [...currentNote.tags, trimmedTag],
        updatedAt: DateTime.now(),
      );

      // Save via Riverpod controller
      await ref
          .read(notesControllerProvider(currentNote.spaceId).notifier)
          .updateNote(updated);

      setState(() {
        _currentNote = updated;
      });

      _tagController.clear();
      _showSnackBar(l10n.noteDetailTagAdded);
    } catch (e) {
      _showSnackBar('${l10n.noteDetailTagAddFailed}: $e', isError: true);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  /// Remove a tag from the note
  Future<void> _removeTag(String tag) async {
    if (_currentNote == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentNote = _currentNote!;

    try {
      setState(() {
        isSaving = true;
      });

      // Remove tag from note
      final updated = currentNote.copyWith(
        tags: currentNote.tags.where((t) => t != tag).toList(),
        updatedAt: DateTime.now(),
      );

      // Save via Riverpod controller
      await ref
          .read(notesControllerProvider(currentNote.spaceId).notifier)
          .updateNote(updated);

      setState(() {
        _currentNote = updated;
      });

      _showSnackBar(l10n.noteDetailTagRemoved);
    } catch (e) {
      _showSnackBar('${l10n.noteDetailTagRemoveFailed}: $e', isError: true);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  /// Show add tag dialog
  Future<void> _showAddTagDialog() async {
    final l10n = AppLocalizations.of(context)!;
    _tagController.clear();

    return ResponsiveModal.show<void>(
      context: context,
      child: BottomSheetContainer(
        title: l10n.noteDetailAddTagTitle,
        primaryButtonText: l10n.buttonAdd,
        showSecondaryButton: false,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          _addTag(_tagController.text);
        },
        child: TextInputField(
          controller: _tagController,
          label: l10n.noteDetailTagNameLabel,
          hintText: l10n.noteDetailTagNameHint,
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
  /// Note: Navigation is handled in _showDeleteConfirmation(), not here
  Future<void> _deleteNote() async {
    if (_currentNote == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentNote = _currentNote!;

    try {
      await ref
          .read(notesControllerProvider(currentNote.spaceId).notifier)
          .deleteNote(currentNote.id);

      // Navigation already handled in confirmation dialog
      // Success feedback is provided by UI update (note removed from list)
    } catch (e) {
      if (mounted) {
        _showSnackBar('${l10n.noteDetailDeleteFailed}: $e', isError: true);
      }
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation() async {
    if (_currentNote == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentNote = _currentNote!;

    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: l10n.noteDetailDeleteTitle,
      message: l10n.noteDetailDeleteMessage(currentNote.title),
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
    final l10n = AppLocalizations.of(context)!;
    final noteAsync = ref.watch(noteByIdProvider(widget.noteId));

    return noteAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(l10n.noteDetailLoadingTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.noteDetailErrorTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.noteDetailErrorMessage,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.buttonGoBack),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (note) {
        if (note == null) {
          // Note not found
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.noteDetailNotFoundTitle),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 64,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.noteDetailNotFoundMessage,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.buttonGoBack),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Initialize controllers with loaded data
        _initializeControllers(note);

        // Build the main UI
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              // Save before leaving
              await saveChanges();
              if (mounted && context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: EditableAppBarTitle(
                text: _currentNote?.title ?? '',
                onChanged: (newTitle) {
                  if (_titleController != null) {
                    _titleController!.text = newTitle;
                    saveChanges();
                  }
                },
                gradient: AppColors.noteGradient,
                hintText: l10n.noteDetailTitleHint,
              ),
              actions: [
                if (isSaving)
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
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: AppColors.error),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.noteDetailMenuDelete),
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
                      hintText: l10n.noteDetailContentHint,
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
                  if (_currentNote?.tags.isNotEmpty == true || true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.noteDetailTagsLabel,
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
                        if (_currentNote?.tags.isNotEmpty == true)
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: _currentNote!.tags.map((tag) {
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
                            l10n.noteDetailTagsEmpty,
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
      },
    );
  }
}
