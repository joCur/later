# Backward Compatibility Aliases Removal Plan

## Objective and Scope

Remove all backward compatibility aliases from the theme system (`app_colors.dart`, `app_spacing.dart`, and `app_animations.dart`) by:
1. Replacing 314 usages across 22 files with their modern equivalents
2. Removing deprecated alias definitions from theme files
3. Removing corresponding TODO comments

This is a code quality improvement with no functional impact - purely internal refactoring to eliminate technical debt.

## Technical Approach and Reasoning

**Strategy**: Automated bulk replacement using the Edit tool with `replace_all: true`

**Reasoning**:
- 314 total replacements make manual editing error-prone and time-consuming
- Clear 1:1 mappings documented in research make automation safe
- Automated approach ensures consistency and completeness
- Risk is minimal - internal refactoring with no API changes

**Order of Execution**:
1. Animation aliases first (0 usages - immediate deletion)
2. Color aliases second (276 usages across 18 files)
3. Spacing aliases third (38 usages across 11 files)
4. Remove definitions last (after all usages replaced)

**Verification Strategy**:
- Run tests after each phase
- Visual inspection of high-usage files
- Compile-time verification (no errors = no missed usages)

## Implementation Phases

### Phase 1: Remove Animation Aliases (0 usages)
- [ ] Task 1.1: Delete animation alias definitions and TODO
  - Read `lib/core/theme/app_animations.dart` to verify current state
  - Remove lines 541-564 (entire backward compatibility section)
  - Remove TODO comment at line 544
  - No file updates needed (0 usages found)

### Phase 2: Replace Color Alias Usages (276 usages across 18 files)
- [ ] Task 2.1: Replace primary color aliases
  - Replace `AppColors.primaryAmber` → `AppColors.primarySolid` across all files
  - Replace `AppColors.primaryAmberLight` → `AppColors.primaryLight` across all files

- [ ] Task 2.2: Replace neutral/gray color aliases
  - Replace `AppColors.neutralBlack` → `AppColors.neutral900`
  - Replace `AppColors.neutralGray100` → `AppColors.neutral100`
  - Replace `AppColors.neutralGray200` → `AppColors.neutral200`
  - Replace `AppColors.neutralGray300` → `AppColors.neutral300`
  - Replace `AppColors.neutralGray600` → `AppColors.neutral600`
  - Replace `AppColors.neutralGray700` → `AppColors.neutral700`

- [ ] Task 2.3: Replace semantic background/surface aliases
  - Replace `AppColors.backgroundLight` → `AppColors.neutral50`
  - Replace `AppColors.backgroundDark` → `AppColors.neutral950`
  - Replace `AppColors.surfaceLight` → `Colors.white`
  - Replace `AppColors.surfaceLightVariant` → `AppColors.neutral100`
  - Replace `AppColors.surfaceDark` → `AppColors.neutral900`
  - Replace `AppColors.surfaceDarkVariant` → `AppColors.neutral800`

- [ ] Task 2.4: Replace border color aliases
  - Replace `AppColors.borderLight` → `AppColors.neutral200`
  - Replace `AppColors.borderDark` → `AppColors.neutral700`

- [ ] Task 2.5: Replace text color aliases
  - Replace `AppColors.textPrimaryLight` → `AppColors.neutral600`
  - Replace `AppColors.textPrimaryDark` → `AppColors.neutral400`
  - Replace `AppColors.textSecondaryLight` → `AppColors.neutral500`
  - Replace `AppColors.textSecondaryDark` → `AppColors.neutral500`
  - Replace `AppColors.textDisabledLight` → `AppColors.neutral400`
  - Replace `AppColors.textDisabledDark` → `AppColors.neutral600`

- [ ] Task 2.6: Replace accent color aliases
  - Replace `AppColors.accentGreen` → `AppColors.success`
  - Replace `AppColors.accentBlue` → `AppColors.info`
  - Replace `AppColors.accentViolet` → `AppColors.primarySolid`

- [ ] Task 2.7: Replace item border color aliases
  - Replace `AppColors.itemBorderTask` → `AppColors.taskGradientStart`
  - Replace `AppColors.itemBorderNote` → `AppColors.noteGradientStart`
  - Replace `AppColors.itemBorderList` → `AppColors.listGradientStart`

- [ ] Task 2.8: Replace FAB gradient alias
  - Replace `AppColors.fabGradient` → `AppColors.primaryGradient`

### Phase 3: Replace Spacing Alias Usages (38 usages across 11 files)
- [ ] Task 3.1: Replace spacing aliases
  - Replace `AppSpacing.xxxs` → `AppSpacing.xxs` (2px not in base scale)
  - Replace `AppSpacing.cardMargin` → `AppSpacing.sm`
  - Replace `AppSpacing.chipRadius` → `AppSpacing.xs`
  - Replace `AppSpacing.gapSM` → `AppSpacing.xs`
  - Replace `AppSpacing.gapMD` → `AppSpacing.sm`
  - Replace `AppSpacing.gapLG` → `AppSpacing.md`
  - Replace `AppSpacing.itemBorderWidth` → `AppSpacing.borderWidthAccent`
  - Replace `AppSpacing.touchTargetFAB` → `AppSpacing.fabSize`

### Phase 4: Remove Alias Definitions from Theme Files
- [ ] Task 4.1: Remove color alias definitions
  - Read `lib/core/theme/app_colors.dart` to verify all usages replaced
  - Remove lines 583-635 (entire backward compatibility section)
  - Remove TODO comment at line 586

- [ ] Task 4.2: Remove spacing alias definitions
  - Read `lib/core/theme/app_spacing.dart` to verify all usages replaced
  - Remove lines 413-442 (entire backward compatibility section)
  - Remove TODO comment at line 416

### Phase 5: Verification and Testing
- [ ] Task 5.1: Run automated tests
  - Execute `flutter test` to verify no breakage
  - All existing tests should pass without modification
  - Any failures indicate missed usages or incorrect mappings

- [ ] Task 5.2: Verify compilation
  - Run `flutter analyze` to check for any errors
  - No compilation errors = no missed usages
  - Clean analyzer output confirms success

- [ ] Task 5.3: Visual verification (optional but recommended)
  - Build and run the app
  - Test in both light and dark modes
  - Inspect high-usage screens (QuickCaptureModal, SpaceSwitcherModal, HomeScreen)
  - Compare visual appearance before/after (should be identical)

## Dependencies and Prerequisites

**Required**:
- No external dependencies
- Working Flutter environment (3.27+, Dart 3.6+)
- Access to all files in `apps/later_mobile/lib/`

**Optional**:
- Visual regression testing tools (for extra verification)
- Git branch for safe experimentation

## Challenges and Considerations

**Challenge 1: High Number of Replacements**
- 314 total replacements across 22 files
- Mitigation: Use `replace_all: true` for consistency, run tests after each phase

**Challenge 2: Potential for Missing Usages**
- Search patterns might miss dynamic references or string-based lookups
- Mitigation: Compiler will catch any missed usages as undefined references

**Challenge 3: Colors.white Import**
- `AppColors.surfaceLight` maps to `Colors.white` (Flutter SDK)
- Mitigation: Verify `Colors` is imported in files using this replacement

**Challenge 4: Merge Conflicts**
- 22 files being modified could conflict with other branches
- Mitigation: Complete quickly (estimated 50 minutes), communicate to team

**Challenge 5: Visual Regression**
- Incorrect mappings could break UI consistency
- Mitigation: Follow documented mappings exactly, test in both light/dark modes

**Edge Cases**:
- Dynamic property access (e.g., `AppColors['primaryAmber']`) - not found in search
- Comments referencing old names - acceptable to leave
- Documentation files - should be updated separately if needed

**Success Criteria**:
1. All tests pass
2. No compilation errors
3. No remaining references to deprecated aliases (grep verification)
4. Visual consistency maintained in light and dark modes
5. TODO comments removed from theme files
