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

- [ ] Task 1.1: Create or verify SelectableChip component
  - Check if `SelectableChip` exists in `design_system/atoms/chips/`
  - If not, create with: label, icon, isSelected, onTap, gradient border on selection
  - Add spring animation on selection (scale 1.0 → 1.05 → 1.0)
  - Ensure 48×48px minimum touch target
  - Export in `atoms.dart` barrel file

- [ ] Task 1.2: Update ListStyle enum and model
  - Verify `ListStyle` enum in `lib/data/models/list_model.dart` has: `simple`, `bullet`, `numbered`, `checklist`
  - Ensure ListModel constructor accepts style parameter with default value
  - Confirm Hive adapter supports the style field

- [ ] Task 1.3: Add style selector UI to modal
  - Open `lib/widgets/modals/create_content_modal.dart`
  - Add state variable: `ListStyle? _selectedListStyle = ListStyle.bullet;` (default)
  - Create helper methods: `_getStyleLabel(ListStyle)`, `_getStyleIcon(ListStyle)`
  - Implement `_buildListFields()` method returning horizontal Row of SelectableChips
  - Add chips for each ListStyle with icons: 🔹 Bullets, ☑️ Checklist, 1️⃣ Numbered, • Simple
  - Wire up onTap to update `_selectedListStyle`

- [ ] Task 1.4: Integrate into conditional rendering system
  - Create `_buildTypeSpecificFields()` method with switch on `_selectedType`
  - Return `_buildListFields()` when `ContentType.list` selected
  - Wrap in `AnimatedSwitcher` with 250ms fade + slide transition
  - Insert between main text field and action buttons in modal layout

- [ ] Task 1.5: Update save logic for List creation
  - In `_saveItem()` method, update `ContentType.list` case
  - Pass `style: _selectedListStyle ?? ListStyle.bullet` to ListModel constructor
  - Test that style persists to Hive correctly

- [ ] Task 1.6: Test on mobile and desktop
  - Verify chips are horizontally scrollable on narrow screens
  - Check touch target size (48×48px minimum)
  - Test gradient border animation on selection
  - Verify style saves correctly and appears in list detail screen

### Phase 2: Smart Note Content Field (High Priority)

**Estimated Time: 3-4 hours**

- [ ] Task 2.1: Implement responsive detection helper
  - Add helper method `bool get _isMobile => MediaQuery.of(context).size.width < 600;`
  - Or check if `BuildContext.isMobile` extension already exists in core utils

- [ ] Task 2.2: Add controllers for Note fields
  - Add `TextEditingController _noteTitleController = TextEditingController();` (desktop only)
  - Add `TextEditingController _noteContentController = TextEditingController();` (desktop only)
  - Remember to dispose in `dispose()` method
  - Existing `_textController` will be used for mobile smart field

- [ ] Task 2.3: Create mobile smart field (Option A)
  - Implement `_buildNoteFieldsMobile()` returning TextAreaField
  - Use `_textController` with hint: 'Note title or content...\n(First line becomes title)'
  - Set `maxLines: 6` for comfortable typing
  - Return early if `_isMobile` in `_buildNoteFields()`

- [ ] Task 2.4: Create desktop two-field layout (Option B)
  - Implement `_buildNoteFieldsDesktop()` returning Column
  - First field: TextInputField for title with `_noteTitleController`
  - Add listener to `_noteTitleController` to show content field when text.isNotEmpty
  - Second field: TextAreaField for content with `_noteContentController`, maxLines: 4
  - Animate content field appearance with 300ms AnimatedSize or AnimatedSwitcher

- [ ] Task 2.5: Combine responsive layouts
  - Implement `_buildNoteFields()` that checks `_isMobile`
  - Return `_buildNoteFieldsMobile()` if mobile, else `_buildNoteFieldsDesktop()`
  - Add to `_buildTypeSpecificFields()` switch case for `ContentType.note`
  - Wrap in AnimatedSwitcher with same 250ms transition

- [ ] Task 2.6: Implement smart parsing logic
  - Create helper method `_parseNoteInput(String text)` returning `({String title, String? content})`
  - For mobile: Split on '\n', first line = title, rest = content
  - For desktop: Get title from `_noteTitleController`, content from `_noteContentController`
  - Handle edge cases: empty strings, only whitespace, no newline

- [ ] Task 2.7: Update save logic for Note creation
  - In `_saveItem()` method, update `ContentType.note` case
  - Call `_parseNoteInput()` to get title and content
  - Pass both to Item constructor: `Item(title: title, content: content, ...)`
  - Verify Item model has nullable `content` field in `lib/data/models/item_model.dart`

- [ ] Task 2.8: Test responsive behavior
  - Test on mobile simulator (iPhone SE, Pixel 5)
  - Test on desktop (macOS app, wide browser)
  - Verify smart parsing works with various inputs (title only, title + content, multiline)
  - Check that content appears in note detail screen after creation
  - Test keyboard handling (auto-focus, smooth appearance)

### Phase 3: TodoList Description Field (Medium Priority)

**Estimated Time: 2-3 hours**

- [ ] Task 3.1: Add description controller and state
  - Add `TextEditingController _descriptionController = TextEditingController();`
  - Add `bool _showDescription = false;` state variable
  - Dispose controller in `dispose()` method

- [ ] Task 3.2: Create expandable description UI
  - Implement `_buildTodoListFields()` method
  - When `!_showDescription`: show GestureDetector with text '+ Add description (optional)'
  - Style as link-like text (underlined, accent color)
  - On tap: `setState(() => _showDescription = true)`
  - Ensure 48px height for touch target

- [ ] Task 3.3: Create expanded description field
  - When `_showDescription`: show TextAreaField with `_descriptionController`
  - Set `hintText: 'Add description (optional)'`, `maxLines: 3`
  - Wrap transition in AnimatedSize or AnimatedSwitcher (300ms, spring curve)
  - Consider adding small collapse button (X icon) to hide again

- [ ] Task 3.4: Add to conditional rendering
  - Add `_buildTodoListFields()` to `_buildTypeSpecificFields()` switch
  - Return for `ContentType.todoList` case
  - Wrap in AnimatedSwitcher with 250ms transition

- [ ] Task 3.5: Update save logic for TodoList
  - In `_saveItem()` method, update `ContentType.todoList` case
  - Get description: `_descriptionController.text.trim()`
  - Pass to TodoList constructor: `description: desc.isEmpty ? null : desc`
  - Verify TodoList model has nullable `description` field

- [ ] Task 3.6: Add validation for description length
  - In validation method (or create one), check `_descriptionController.text.length <= 500`
  - Show snackbar if exceeded: 'Description too long (max 500 characters)'
  - Consider showing character count below field when expanded

- [ ] Task 3.7: Test expansion animation and keyboard handling
  - Verify smooth expansion animation (no jank)
  - Test on mobile with keyboard open (should push modal up correctly)
  - Check that description persists to Hive and shows in TodoList detail screen
  - Test collapse functionality if added

### Phase 4: Animation Polish and Accessibility

**Estimated Time: 2-3 hours**

- [ ] Task 4.1: Refine AnimatedSwitcher transitions
  - Tune timing curves (current: easeInOut, test with easeOutCubic)
  - Ensure no layout shifts during type switching
  - Test rapid type switching (no animation conflicts)
  - Add RepaintBoundary around animated sections if needed

- [ ] Task 4.2: Add haptic feedback
  - Import `import 'package:flutter/services.dart';`
  - Add `HapticFeedback.lightImpact()` on List style chip selection
  - Add light impact on description expansion
  - Test on iOS and Android devices (not just simulator)

- [ ] Task 4.3: Implement accessibility features
  - Add semantic labels to all SelectableChips: 'Bullets style, selected' / 'Checklist style, not selected'
  - Add semantic label to description expansion link: 'Add description, collapsed'
  - Test with TalkBack (Android) and VoiceOver (iOS)
  - Verify tab order: Type selector → Space → Main field → Type-specific fields → Save/Cancel
  - Ensure all text respects `MediaQuery.of(context).textScaleFactor`

- [ ] Task 4.4: Verify contrast ratios
  - Use contrast checker tool on all text/background combinations
  - Ensure WCAG AA compliance (4.5:1 for normal text, 3:1 for large)
  - Check gradient text on glassmorphic backgrounds
  - Test in both light and dark modes

- [ ] Task 4.5: Performance profiling
  - Run Flutter DevTools performance overlay during modal usage
  - Profile animation frame rates (target: 60fps, minimum: 30fps)
  - Test on older Android device (Android 10, 2GB RAM)
  - Identify and fix any jank (optimize with RepaintBoundary if needed)

- [ ] Task 4.6: Add field validation
  - Ensure main text field (title/name) still required
  - Display inline error if empty on save attempt
  - Validate description character limit (500 chars) with feedback
  - Test all validation states with screen reader

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
