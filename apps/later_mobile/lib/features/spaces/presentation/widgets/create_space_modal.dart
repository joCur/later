import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/organisms/dialogs/upgrade_required_dialog.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/spaces_controller.dart';

/// Mode for the CreateSpaceModal
enum SpaceModalMode {
  /// Create a new space
  create,

  /// Edit an existing space
  edit,
}

/// Modal for creating and editing spaces.
///
/// Displays as:
/// - Bottom sheet on mobile (using showModalBottomSheet)
/// - Dialog on desktop (using showDialog)
///
/// Features:
/// - Name input with validation (required, 1-100 chars)
/// - Icon picker with emoji/icon options
/// - Color picker with predefined palette
/// - Generate unique UUID for space ID
/// - Save to Hive via SpacesController
/// - Auto-switch to newly created space
/// - Support for both create and edit modes
class CreateSpaceModal extends ConsumerStatefulWidget {
  const CreateSpaceModal({required this.mode, this.initialSpace, super.key});

  /// The mode for the modal (create or edit)
  final SpaceModalMode mode;

  /// Initial space data for edit mode
  final Space? initialSpace;

  @override
  ConsumerState<CreateSpaceModal> createState() => _CreateSpaceModalState();
}

class _CreateSpaceModalState extends ConsumerState<CreateSpaceModal> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  String? _selectedIcon;
  String? _selectedColor;
  String? _errorMessage;
  String? _submitErrorMessage; // Error message for submission failures
  bool _isSubmitting = false;

  // Curated emoji icons for spaces
  static const List<String> _iconOptions = [
    '💼', // Work
    '📚', // Study
    '🏠', // Home
    '💡', // Ideas
    '🎯', // Goals
    '⚡', // Energy
    '🌟', // Star
    '✨', // Sparkles
    '🎨', // Art
    '📝', // Notes
    '💪', // Strength
    '🚀', // Rocket
    '❤️', // Love
    '🎵', // Music
    '🍕', // Food
    '✈️', // Travel
    '📱', // Tech
    '💻', // Computer
    '🎮', // Gaming
    '📷', // Photography
    '🏋️', // Fitness
    '🧘', // Meditation
    '🌱', // Growth
    '🔥', // Fire
    '💎', // Diamond
    '🎓', // Education
    '🏆', // Achievement
    '🌈', // Rainbow
    '🎭', // Theater
    '🎪', // Circus
  ];

  // Color palette from design system
  static const List<String> _colorOptions = [
    '#6366F1', // Primary Indigo
    '#8B5CF6', // Secondary Violet
    '#F59E0B', // Accent Primary Amber
    '#14B8A6', // Accent Secondary Teal
    '#3B82F6', // Task Color Blue
    '#10B981', // Success Emerald
    '#EF4444', // Error Red
    '#EC4899', // Pink
    '#F97316', // Orange
    '#84CC16', // Lime
    '#06B6D4', // Cyan
    '#A855F7', // Purple
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialSpace?.name ?? '',
    );
    _nameFocusNode = FocusNode();
    _selectedIcon = widget.initialSpace?.icon;
    _selectedColor = widget.initialSpace?.color ?? _colorOptions[0];

    _nameController.addListener(_validateForm);
    _nameController.addListener(_clearSubmitError);
  }

  /// Clear submit error when user starts editing
  void _clearSubmitError() {
    if (_submitErrorMessage != null) {
      setState(() {
        _submitErrorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  /// Validate form and update error message
  void _validateForm() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _errorMessage = l10n.spaceModalValidationNameRequired;
      } else if (name.length > 100) {
        _errorMessage = l10n.spaceModalValidationNameLength;
      } else {
        _errorMessage = null;
      }
    });
  }

  /// Check if form is valid
  bool get _isFormValid {
    final name = _nameController.text.trim();
    return name.isNotEmpty && name.length <= 100;
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    if (!_isFormValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _submitErrorMessage = null; // Clear previous errors
    });

    final navigator = Navigator.of(context);

    // Safety check: Ensure user is authenticated
    final userAsync = ref.read(authStateControllerProvider);
    final userId = userAsync.when(
      data: (user) => user?.id,
      loading: () => null as String?,
      error: (error, stack) => null as String?,
    );
    if (userId == null) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isSubmitting = false;
          _submitErrorMessage = l10n.spaceModalErrorNotSignedIn;
        });
      }
      return;
    }

    final name = _nameController.text.trim();
    final space = Space(
      id: widget.mode == SpaceModalMode.edit
          ? widget.initialSpace!.id
          : const Uuid().v4(),
      name: name,
      userId: userId,
      icon: _selectedIcon,
      color: _selectedColor,
      isArchived: widget.initialSpace?.isArchived ?? false,
      createdAt: widget.initialSpace?.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.mode == SpaceModalMode.edit) {
        await ref.read(spacesControllerProvider.notifier).updateSpace(space);
      } else {
        await ref.read(spacesControllerProvider.notifier).createSpace(space);
      }

      // Operation succeeded - close modal
      if (mounted) {
        navigator.pop(true);
      }
    } on SpaceLimitReachedException catch (_) {
      // Anonymous user reached space limit - show upgrade dialog
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Close the modal first
        navigator.pop(false);

        // Show upgrade dialog
        final l10n = AppLocalizations.of(context)!;
        await showUpgradeRequiredDialog(
          context: context,
          message: l10n.authUpgradeLimitSpaces,
        );
      }
    } catch (e) {
      // Operation failed - show user-friendly error message
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitErrorMessage = e.toString();
        });
      }
    }
  }

  /// Build name input field
  Widget _buildNameInput(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.spaceModalLabelName,
      child: TextInputField(
        label: l10n.spaceModalLabelName,
        hintText: l10n.spaceModalHintName,
        controller: _nameController,
        focusNode: _nameFocusNode,
        errorText: _errorMessage,
        maxLength: 100,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  /// Build icon picker
  Widget _buildIconPicker(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.spaceModalLabelIcon,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: _iconOptions.map((icon) {
            final isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = icon;
                  _submitErrorMessage = null; // Clear error on interaction
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? AppColors.selectedDark
                            : AppColors.selectedLight)
                      : (AppColors.surfaceVariant(context)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  border: isSelected
                      ? Border.all(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primarySolid,
                          width: AppSpacing.borderWidthMedium,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                    if (isSelected)
                      const Positioned(
                        top: 2,
                        right: 2,
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primarySolid,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build color picker
  Widget _buildColorPicker(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.spaceModalLabelColor,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: _colorOptions.map((colorHex) {
            final isSelected = _selectedColor == colorHex;
            final color = Color(
              int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
            );

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorHex;
                  _submitErrorMessage = null; // Clear error on interaction
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primarySolid,
                          width: 3,
                        )
                      : Border.all(
                          color: isDark
                              ? AppColors.neutral700
                              : AppColors.neutral200,
                        ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(Icons.check, color: Colors.white, size: 24),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build error banner if there's a submit error
  Widget? _buildErrorBanner() {
    if (_submitErrorMessage == null) return null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              _submitErrorMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build form content
  Widget _buildFormContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name input
        _buildNameInput(isDark),
        const SizedBox(height: AppSpacing.lg),

        // Icon picker
        _buildIconPicker(isDark),
        const SizedBox(height: AppSpacing.lg),

        // Color picker
        _buildColorPicker(isDark),

        // Error banner (if any)
        if (_submitErrorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildErrorBanner()!,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomSheetContainer(
      title: widget.mode == SpaceModalMode.create
          ? l10n.spaceModalTitleCreate
          : l10n.spaceModalTitleEdit,
      primaryButtonText: widget.mode == SpaceModalMode.create
          ? l10n.spaceModalButtonCreate
          : l10n.spaceModalButtonSave,
      onPrimaryPressed: _isSubmitting ? null : _handleSubmit,
      isPrimaryButtonEnabled: !_isSubmitting && _isFormValid,
      isPrimaryButtonLoading: _isSubmitting,
      onSecondaryPressed: () => Navigator.of(context).pop(false),
      child: _buildFormContent(context),
    );
  }
}
