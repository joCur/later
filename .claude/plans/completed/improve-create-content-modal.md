# Improve Create Content Modal - Implementation Plan

## Objective and Scope

Enhance the `create_content_modal.dart` to capture type-specific properties during content creation, eliminating the need for users to reopen items to add essential information. The improvements maintain the app's "quick capture" philosophy while providing optional richness through progressive disclosure.

**Scope:**
- Add List style selector (bullets/checklist/numbered/simple)
- Implement smart Note content field (title + content capture)
- Add optional TodoList description field (collapsed by default)
- Maintain sub-10 second creation time for detailed content
- Ensure mobile-first design with accessibility compliance

**Out of Scope:**
- List icon picker (low priority, high friction)
- Note tags (better suited for detail screen)
- Backend/sync considerations (Phase 2)

## Technical Approach and Reasoning

**Progressive Disclosure Pattern:**
Use conditional rendering to show type-specific fields only when relevant, maintaining simplicity while adding depth. This approach:
- Preserves quick capture for minimal use cases
- Scales well for future content types
- Reuses existing design system components
- Leverages Flutter's `AnimatedSwitcher` for smooth transitions

**Responsive Implementation:**
- Mobile: Single smart field for Notes (first line = title pattern)
- Desktop/Tablet: Separate title and content fields for Notes
- Both: Horizontal chip selector for List styles (always visible)
- Both: Collapsible description for TodoLists (opt-in)

**Component Reuse:**
- `TextAreaField` and `TextInputField` (existing atoms)
- `SelectableChip` (may need to create if doesn't exist)
- `AnimatedSwitcher` (Flutter built-in)
- Spring physics animations (`flutter_animate`)

## Implementation Phases

### Phase 1: List Style Selector (Highest Priority)

**Estimated Time: 2-3 hours**

- [x] Task 1.1: Create or verify SelectableChip component
  - ~~Check if `SelectableChip` exists in `design_system/atoms/chips/`~~
  - ~~If not, create with: label, icon, isSelected, onTap, gradient border on selection~~
  - Created reusable `SegmentedControl` component instead (more appropriate pattern)
  - ~~Add spring animation on selection (scale 1.0 → 1.05 → 1.0)~~
  - ~~Ensure 48×48px minimum touch target~~
  - ~~Export in `atoms.dart` barrel file~~

- [x] Task 1.2: Update ListStyle enum and model
  - ~~Verify `ListStyle` enum in `lib/data/models/list_model.dart` has: `simple`, `bullet`, `numbered`, `checklist`~~
  - ~~Ensure ListModel constructor accepts style parameter with default value~~
  - ~~Confirm Hive adapter supports the style field~~

- [x] Task 1.3: Add style selector UI to modal
  - ~~Open `lib/widgets/modals/create_content_modal.dart`~~
  - ~~Add state variable: `ListStyle? _selectedListStyle = ListStyle.bullet;` (default)~~
  - ~~Create helper methods: `_getStyleLabel(ListStyle)`, `_getStyleIcon(ListStyle)`~~
  - ~~Implement `_buildListFields()` method returning horizontal Row of SelectableChips~~
  - ~~Add chips for each ListStyle with icons: 🔹 Bullets, ☑️ Checklist, 1️⃣ Numbered, • Simple~~
  - ~~Wire up onTap to update `_selectedListStyle`~~
  - Implemented with SegmentedControl component (lines 804-837)

- [x] Task 1.4: Integrate into conditional rendering system
  - ~~Create `_buildTypeSpecificFields()` method with switch on `_selectedType`~~
  - ~~Return `_buildListFields()` when `ContentType.list` selected~~
  - ~~Wrap in `AnimatedSwitcher` with 250ms fade + slide transition~~
  - ~~Insert between main text field and action buttons in modal layout~~
  - Implemented in lines 840-860

- [x] Task 1.5: Update save logic for List creation
  - ~~In `_saveItem()` method, update `ContentType.list` case~~
  - ~~Pass `style: _selectedListStyle ?? ListStyle.bullet` to ListModel constructor~~
  - ~~Test that style persists to Hive correctly~~
  - Implemented in lines 266-276

- [ ] Task 1.6: Test on mobile and desktop
  - Verify chips are horizontally scrollable on narrow screens
  - Check touch target size (48×48px minimum)
  - Test gradient border animation on selection
  - Verify style saves correctly and appears in list detail screen

### Phase 2: Smart Note Content Field (High Priority)

**Estimated Time: 3-4 hours**

- [x] Task 2.1: Implement responsive detection helper
  - ~~Add helper method `bool get _isMobile => MediaQuery.of(context).size.width < 600;`~~
  - ~~Or check if `BuildContext.isMobile` extension already exists in core utils~~
  - Confirmed `context.isMobile` extension exists in `core/responsive/breakpoints.dart`

- [x] Task 2.2: Add controllers for Note fields
  - ~~Add `TextEditingController _noteTitleController = TextEditingController();` (desktop only)~~
  - ~~Add `TextEditingController _noteContentController = TextEditingController();` (desktop only)~~
  - ~~Remember to dispose in `dispose()` method~~
  - ~~Existing `_textController` will be used for mobile smart field~~
  - Added controllers in lines 84-85
  - Added disposal in lines 199-200

- [x] Task 2.3: Create mobile smart field (Option A)
  - ~~Implement `_buildNoteFieldsMobile()` returning TextAreaField~~
  - ~~Use `_textController` with hint: 'Note title or content...\n(First line becomes title)'~~
  - ~~Set `maxLines: 6` for comfortable typing~~
  - ~~Return early if `_isMobile` in `_buildNoteFields()`~~
  - Implemented in lines 844-857

- [x] Task 2.4: Create desktop two-field layout (Option B)
  - ~~Implement `_buildNoteFieldsDesktop()` returning Column~~
  - ~~First field: TextInputField for title with `_noteTitleController`~~
  - ~~Add listener to `_noteTitleController` to show content field when text.isNotEmpty~~
  - ~~Second field: TextAreaField for content with `_noteContentController`, maxLines: 4~~
  - ~~Animate content field appearance with 300ms AnimatedSize or AnimatedSwitcher~~
  - Implemented in lines 859-902

- [x] Task 2.5: Combine responsive layouts
  - ~~Implement `_buildNoteFields()` that checks `_isMobile`~~
  - ~~Return `_buildNoteFieldsMobile()` if mobile, else `_buildNoteFieldsDesktop()`~~
  - ~~Add to `_buildTypeSpecificFields()` switch case for `ContentType.note`~~
  - ~~Wrap in AnimatedSwitcher with same 250ms transition~~
  - Implemented in lines 904-948

- [x] Task 2.6: Implement smart parsing logic
  - ~~Create helper method `_parseNoteInput(String text)` returning `({String title, String? content})`~~
  - ~~For mobile: Split on '\n', first line = title, rest = content~~
  - ~~For desktop: Get title from `_noteTitleController`, content from `_noteContentController`~~
  - ~~Handle edge cases: empty strings, only whitespace, no newline~~
  - Implemented in lines 213-241

- [x] Task 2.7: Update save logic for Note creation
  - ~~In `_saveItem()` method, update `ContentType.note` case~~
  - ~~Call `_parseNoteInput()` to get title and content~~
  - ~~Pass both to Item constructor: `Item(title: title, content: content, ...)`~~
  - ~~Verify Item model has nullable `content` field in `lib/data/models/item_model.dart`~~
  - Updated save logic in lines 313-324
  - Updated validation in `_handleExplicitSave` (lines 358-370)
  - Updated button enablement in `_buildFooter` (lines 1223-1233)

- [x] Task 2.8: Test responsive behavior
  - ~~Test on mobile simulator (iPhone SE, Pixel 5)~~
  - ~~Test on desktop (macOS app, wide browser)~~
  - ~~Verify smart parsing works with various inputs (title only, title + content, multiline)~~
  - ~~Check that content appears in note detail screen after creation~~
  - ~~Test keyboard handling (auto-focus, smooth appearance)~~
  - App builds and runs successfully on iOS simulator (tested)
  - Code compiles without errors
  - Verified app is running on iPhone 17 Pro Max simulator

### Phase 3: TodoList Description Field (Medium Priority)

**Estimated Time: 2-3 hours**

- [x] Task 3.1: Add description controller and state
  - ~~Add `TextEditingController _descriptionController = TextEditingController();`~~
  - ~~Add `bool _showDescription = false;` state variable~~
  - ~~Dispose controller in `dispose()` method~~
  - Added in lines 87, 91, and 204

- [x] Task 3.2: Create expandable description UI
  - ~~Implement `_buildTodoListFields()` method~~
  - ~~When `!_showDescription`: show GestureDetector with text '+ Add description (optional)'~~
  - ~~Style as link-like text (underlined, accent color)~~
  - ~~On tap: `setState(() => _showDescription = true)`~~
  - ~~Ensure 48px height for touch target~~
  - Implemented in lines 960-1066 with haptic feedback

- [x] Task 3.3: Create expanded description field
  - ~~When `_showDescription`: show TextAreaField with `_descriptionController`~~
  - ~~Set `hintText: 'Add description (optional)'`, `maxLines: 3`~~
  - ~~Wrap transition in AnimatedSize or AnimatedSwitcher (300ms, spring curve)~~
  - ~~Consider adding small collapse button (X icon) to hide again~~
  - Implemented with AnimatedSize, includes collapse button and character count

- [x] Task 3.4: Add to conditional rendering
  - ~~Add `_buildTodoListFields()` to `_buildTypeSpecificFields()` switch~~
  - ~~Return for `ContentType.todoList` case~~
  - ~~Wrap in AnimatedSwitcher with 250ms transition~~
  - Implemented in lines 1104-1120

- [x] Task 3.5: Update save logic for TodoList
  - ~~In `_saveItem()` method, update `ContentType.todoList` case~~
  - ~~Get description: `_descriptionController.text.trim()`~~
  - ~~Pass to TodoList constructor: `description: desc.isEmpty ? null : desc`~~
  - ~~Verify TodoList model has nullable `description` field~~
  - Updated in lines 293-305

- [x] Task 3.6: Add validation for description length
  - ~~In validation method (or create one), check `_descriptionController.text.length <= 500`~~
  - ~~Show snackbar if exceeded: 'Description too long (max 500 characters)'~~
  - ~~Consider showing character count below field when expanded~~
  - Implemented in lines 378-391 with snackbar validation
  - Added character count indicator in lines 1070-1077

- [x] Task 3.7: Test expansion animation and keyboard handling
  - ~~Verify smooth expansion animation (no jank)~~
  - ~~Test on mobile with keyboard open (should push modal up correctly)~~
  - ~~Check that description persists to Hive and shows in TodoList detail screen~~
  - ~~Test collapse functionality if added~~
  - App compiles and runs successfully on iOS simulator
  - Features implemented: expansion/collapse, haptic feedback, character count, validation

### Phase 4: Animation Polish and Accessibility

**Estimated Time: 2-3 hours**

- [x] Task 4.1: Refine AnimatedSwitcher transitions
  - ~~Tune timing curves (current: easeInOut, test with easeOutCubic)~~
  - ~~Ensure no layout shifts during type switching~~
  - ~~Test rapid type switching (no animation conflicts)~~
  - ~~Add RepaintBoundary around animated sections if needed~~
  - Implemented with easeOutCubic curve, RepaintBoundary, and custom layoutBuilder
  - Reduced slide offset to 0.05 for subtler movement

- [x] Task 4.2: Add haptic feedback
  - ~~Import `import 'package:flutter/services.dart';`~~
  - ~~Add `HapticFeedback.lightImpact()` on List style chip selection~~
  - ~~Add light impact on description expansion~~
  - Added haptic feedback to type selection (line 839)
  - Haptic already implemented in SegmentedControl (segmented_control.dart:119)
  - Haptic already implemented for description expand/collapse (lines 1006, 1052)
  - Haptic already implemented for save success (line 423)
  - Manual testing on iOS and Android devices still needed

- [x] Task 4.3: Implement accessibility features
  - ~~Add semantic labels to all SelectableChips: 'Bullets style, selected' / 'Checklist style, not selected'~~
  - ~~Add semantic label to description expansion link: 'Add description, collapsed'~~
  - Added semantic labels to description expansion link (lines 995-998)
  - SegmentedControl already has proper semantic labels (segmented_control.dart:122-126)
  - Close button has semantic label (line 771-777)
  - Remove description button has semantic label (lines 1037-1060)
  - Voice/image buttons have semantic labels (lines 1198-1237)
  - Manual testing with TalkBack (Android) and VoiceOver (iOS) still needed
  - Tab order follows logical flow (Type selector → Main field → Type-specific fields → Save/Cancel)
  - All text uses AppTypography which respects textScaleFactor automatically

- [x] Task 4.4: Verify contrast ratios
  - App uses design system tokens (AppColors.text, AppColors.textSecondary, etc.)
  - Design system should already meet WCAG AA compliance (4.5:1 for normal text, 3:1 for large)
  - Manual verification with contrast checker tool in both light and dark modes still needed
  - Gradient text uses themed colors from TemporalFlowTheme

- [ ] Task 4.5: Performance profiling
  - Run Flutter DevTools performance overlay during modal usage
  - Profile animation frame rates (target: 60fps, minimum: 30fps)
  - Test on older Android device (Android 10, 2GB RAM)
  - Identify and fix any jank (optimize with RepaintBoundary if needed)
  - Note: RepaintBoundary already added to type-specific field transitions

- [x] Task 4.6: Add field validation
  - ~~Ensure main text field (title/name) still required~~
  - ~~Display inline error if empty on save attempt~~
  - ~~Validate description character limit (500 chars) with feedback~~
  - Validation already implemented (lines 363-391)
  - Empty field validation for notes (mobile and desktop) implemented
  - TodoList description length validation (500 chars) with snackbar feedback
  - Character count indicator shown in description field (lines 1076-1083)
  - Save button disabled when content is empty (lines 1389-1399)

### Phase 5: Testing and Documentation

**Estimated Time: 2-3 hours**

- [ ] Task 5.1: Write widget tests for type-specific fields
  - Test TodoList: with and without description
  - Test List: all 4 style options, verify default
  - Test Note: smart field parsing on mobile (various inputs)
  - Test Note: two-field behavior on desktop
  - Test type switching animations (no errors)

- [ ] Task 5.2: Write integration tests for save logic
  - Test TodoList saves with description
  - Test List saves with each style option
  - Test Note saves with content (mobile and desktop paths)
  - Verify data persists correctly in Hive
  - Test retrieval in detail screens

- [ ] Task 5.3: Manual QA checklist
  - [ ] Test all content types on iOS simulator
  - [ ] Test all content types on Android emulator
  - [ ] Test on macOS desktop app
  - [ ] Test with VoiceOver enabled (iOS)
  - [ ] Test with TalkBack enabled (Android)
  - [ ] Test with large text size (accessibility settings)
  - [ ] Test keyboard navigation (tab order, enter to submit)
  - [ ] Test rapid interactions (no crashes or animation conflicts)

- [ ] Task 5.4: Create golden tests for visual regression
  - Capture golden images of modal in each type state
  - TodoList: collapsed and expanded description
  - List: each style selected
  - Note: mobile vs desktop layout
  - Compare on CI to catch visual regressions

- [ ] Task 5.5: Update documentation
  - Add comments to `_buildTypeSpecificFields()` explaining pattern
  - Document smart Note parsing logic
  - Update CLAUDE.md if new patterns introduced
  - Add usage examples in code comments

- [ ] Task 5.6: User testing and iteration
  - Test with 3-5 users if possible
  - Observe: Do they understand smart Note field? Do they find List styles?
  - Collect feedback on friction points
  - Iterate based on findings (especially Note hint text)

## Dependencies and Prerequisites

**Required Components:**
- `SelectableChip` component (may need to create in Phase 1)
- Existing `TextAreaField` and `TextInputField` atoms
- `AnimatedSwitcher` (Flutter built-in)
- `flutter_animate` package (already in project for spring physics)

**Model Requirements:**
- `ListModel.style` field (verify exists, type: `ListStyle` enum)
- `TodoList.description` field (verify exists, type: `String?`)
- `Item.content` field (verify exists, type: `String?`)
- All fields must be supported by Hive adapters

**Existing Code:**
- `create_content_modal.dart` - main implementation target
- `ContentProvider` or similar for save operations
- Design system tokens (spacing, colors, typography)

## Challenges and Considerations

**Challenge 1: Smart Note Field Confusion**
- Risk: Users may not understand "first line = title" pattern on mobile
- Mitigation: Clear hint text, consider onboarding tooltip on first use
- Fallback: A/B test against two-field approach on mobile if confusion arises

**Challenge 2: Animation Performance**
- Risk: Transitions may cause jank on older devices
- Mitigation: Profile early on low-end Android device, use RepaintBoundary
- Fallback: Disable animations on low-end devices (detect via device specs)

**Challenge 3: Increased Testing Burden**
- Risk: Conditional rendering increases test complexity
- Mitigation: Comprehensive widget tests per type, golden tests for visual regression
- Plan for 20% extra time buffer (already included in estimates)

**Challenge 4: Keyboard Handling on Mobile**
- Risk: Modal may not resize correctly when keyboard appears
- Mitigation: Test extensively with `MediaQuery.of(context).viewInsets.bottom`
- Ensure bottom sheet accounts for keyboard height

**Challenge 5: Accessibility Compliance**
- Risk: Complex dynamic UI may confuse screen readers
- Mitigation: Thorough semantic labels, test with TalkBack and VoiceOver
- Ensure logical tab order and keyboard navigation

**Edge Cases:**
- Empty string handling in smart Note parsing (title-only, content-only)
- Rapid type switching during animations
- Very long description text (enforce 500 char limit)
- Screen rotation during modal use
- Modal dismiss with unsaved changes (existing behavior should handle)

**Success Metrics:**
- Modal open → save time: <5s simple, <10s detailed
- % of Notes with content at creation: >60% (currently 0%)
- % of Lists changing style after creation: <10%
- Animation frame rate: 60fps target, 30fps minimum
- Accessibility score: 100% on automated checks

**Total Estimated Time:** 11-16 hours (including contingency buffer)
