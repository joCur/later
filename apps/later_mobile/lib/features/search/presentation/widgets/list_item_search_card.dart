import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Search result card for ListItem child items.
///
/// Displays:
/// - ListItem title
/// - Parent context: "in [List Name]" subtitle
/// - Notes preview (if available)
/// - List-specific styling/gradient
/// - Style indicator (bullet/numbered/checklist)
///
/// On tap: Navigates to parent ListDetailScreen
class ListItemSearchCard extends StatefulWidget {
  const ListItemSearchCard({
    super.key,
    required this.listItem,
    required this.parentName,
    this.onTap,
  });

  final ListItem listItem;
  final String parentName;
  final VoidCallback? onTap;

  @override
  State<ListItemSearchCard> createState() => _ListItemSearchCardState();
}

class _ListItemSearchCardState extends State<ListItemSearchCard> {
  bool _isHovered = false;

  /// Build style indicator icon based on parent list style
  Widget _buildStyleIndicator() {
    const gradient = AppColors.listGradient;

    // For search results, we don't know the parent list style
    // Default to bullet point icon
    return SizedBox(
      width: 24,
      height: 24,
      child: ShaderMask(
        shaderCallback: (bounds) => gradient.createShader(bounds),
        child: const Icon(
          Icons.fiber_manual_record,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build title
  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.listItem.title,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.text(context),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build parent context subtitle
  Widget _buildParentContext(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.list_alt,
          size: 12,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            l10n.searchResultInList(widget.parentName),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build notes preview if available
  Widget? _buildNotesPreview(BuildContext context) {
    if (widget.listItem.notes == null || widget.listItem.notes!.isEmpty) {
      return null;
    }

    // Truncate to 100 characters
    final notes = widget.listItem.notes!;
    final preview = notes.length > 100
        ? '${notes.substring(0, 100)}...'
        : notes;

    return Text(
      preview,
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary(context),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background color with list-specific tint
    final baseBgColor = AppColors.surface(context);
    final tintColor = AppColors.typeLightBg('list', isDark: isDark);
    final backgroundColor = Color.alphaBlend(
      tintColor.withValues(alpha: 0.05),
      baseBgColor,
    );

    // Hover background
    final hoverBackgroundColor = AppColors.surfaceVariant(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? hoverBackgroundColor : backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.listGradientStart.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Style indicator
              _buildStyleIndicator(),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    _buildTitle(context),
                    const SizedBox(height: 4),

                    // Parent context
                    _buildParentContext(context),

                    // Notes preview
                    if (_buildNotesPreview(context) != null) ...[
                      const SizedBox(height: 4),
                      _buildNotesPreview(context)!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
