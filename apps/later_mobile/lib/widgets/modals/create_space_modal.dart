import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../data/models/space_model.dart';
import '../../providers/spaces_provider.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';

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
/// - Save to Hive via SpacesProvider
/// - Auto-switch to newly created space
/// - Support for both create and edit modes
class CreateSpaceModal extends StatefulWidget {
  const CreateSpaceModal({
    required this.mode,
    this.initialSpace,
    super.key,
  });

  /// The mode for the modal (create or edit)
  final SpaceModalMode mode;

  /// Initial space data for edit mode
  final Space? initialSpace;

  @override
  State<CreateSpaceModal> createState() => _CreateSpaceModalState();
}

class _CreateSpaceModalState extends State<CreateSpaceModal> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  String? _selectedIcon;
  String? _selectedColor;
  String? _errorMessage;
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  /// Validate form and update error message
  void _validateForm() {
    setState(() {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _errorMessage = 'Name is required';
      } else if (name.length > 100) {
        _errorMessage = 'Name must be between 1 and 100 characters';
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
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final spacesProvider = context.read<SpacesProvider>();

    try {
      final name = _nameController.text.trim();
      final space = Space(
        id: widget.mode == SpaceModalMode.edit
            ? widget.initialSpace!.id
            : const Uuid().v4(),
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        itemCount: widget.initialSpace?.itemCount ?? 0,
        isArchived: widget.initialSpace?.isArchived ?? false,
        createdAt: widget.initialSpace?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.mode == SpaceModalMode.edit) {
        await spacesProvider.updateSpace(space);
      } else {
        await spacesProvider.addSpace(space);
      }

      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.mode == SpaceModalMode.edit
                  ? 'Failed to update space'
                  : 'Failed to create space',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Build name input field
  Widget _buildNameInput(bool isDark) {
    return Semantics(
      label: 'Space Name',
      child: TextInputField(
        label: 'Space Name',
        hintText: 'Enter space name',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
          style: AppTypography.labelLarge.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                      : (isDark
                          ? AppColors.surfaceDarkVariant
                          : AppColors.surfaceLightVariant),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  border: isSelected
                      ? Border.all(
                          color: isDark
                              ? AppColors.primaryAmberLight
                              : AppColors.primaryAmber,
                          width: AppSpacing.borderWidthMedium,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    if (isSelected)
                      const Positioned(
                        top: 2,
                        right: 2,
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primaryAmber,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: AppTypography.labelLarge.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                              ? AppColors.primaryAmberLight
                              : AppColors.primaryAmber,
                          width: 3,
                        )
                      : Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      title: widget.mode == SpaceModalMode.create ? 'Create Space' : 'Edit Space',
      primaryButtonText: widget.mode == SpaceModalMode.create ? 'Create' : 'Save',
      onPrimaryPressed: _isSubmitting ? null : _handleSubmit,
      isPrimaryButtonEnabled: !_isSubmitting && _isFormValid,
      isPrimaryButtonLoading: _isSubmitting,
      onSecondaryPressed: () => Navigator.of(context).pop(false),
      child: _buildFormContent(context),
    );
  }
}
