---
title: Quick Capture Component
description: The signature feature - comprehensive specification for quick capture modal and FAB
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../style-guide.md
  - ../tokens/animations.md
  - ./item-cards.md
---

# Quick Capture Component

## Overview

Quick Capture is the **signature interaction** of later - a fast, fluid way to capture thoughts without friction. It's accessed via a floating action button (FAB) and opens an intelligent modal that adapts to user intent.

## Design Philosophy

**Effortless Capture**: Users should be able to capture any thought in under 3 seconds - from tap to save.

**Intelligent Adaptation**: The modal intelligently detects whether the user is creating a task, note, or list based on content patterns.

**Fluid Motion**: Opening and closing animations use spring physics for a lively, responsive feel.

**Glass Morphism**: The modal uses frosted glass effects to feel elevated while maintaining context with the background.

---

## Floating Action Button (FAB)

### Visual Design

**Default State**
```dart
Container(
  width: 64,
  height: 64,
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppRadius.lg), // 16px (squircle feel)
    boxShadow: [
      BoxShadow(
        color: AppColors.primarySolid.withOpacity(0.4),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Icon(
    Lucide.plus,
    size: 28,
    color: Colors.white,
  ),
)
```

**Visual Properties**:
- Size: 64×64px
- Shape: Rounded square (16px radius) for distinctive "squircle" feel
- Gradient: Primary gradient (Indigo to Purple)
- Shadow: Large, soft shadow with primary color tint
- Icon: Plus icon, 28px, white

**Position**:
- Mobile: Bottom-right, 16px from edges (respects safe area)
- Tablet/Desktop: Bottom-right, 24px from edges

### Interactive States

**Hover State** (Desktop/Tablet)
```dart
AnimatedContainer(
  duration: AppAnimations.fast,
  transform: Matrix4.translationValues(0, -4, 0), // Lift 4px
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    boxShadow: [
      BoxShadow(
        color: AppColors.primarySolid.withOpacity(0.5),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  ),
)
```

**Changes**:
- Lifts 4px upward
- Shadow increases (blur: 16→24, offset: 8→12)
- Slight scale: 1.0 → 1.05
- Duration: 200ms, ease-out-quart

**Pressed State**
```dart
Transform.scale(
  scale: 0.92,
  child: FAB(),
)
```

**Changes**:
- Scale: 1.0 → 0.92
- Duration: 100ms
- Haptic: Medium impact
- Icon rotates 90° (plus becomes X-like hint)

**Active State** (When modal is open)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.secondaryStart, AppColors.secondaryEnd],
    ),
  ),
  child: Icon(
    Lucide.x, // Changes to X
    size: 28,
    color: Colors.white,
  ).animate()
    .rotate(
      duration: 300.ms,
      curve: Curves.elasticOut,
    ),
)
```

**Changes**:
- Icon: Plus → X with rotation animation
- Gradient: Primary → Secondary (visual indicator of mode change)
- Rotation: 0° → 45° with spring bounce

---

## Quick Capture Modal

### Modal Appearance

**Opening Animation**
```dart
// Background overlay fades in
Container(
  color: Colors.black.withOpacity(0.4),
).animate()
  .fadeIn(duration: 300.ms, curve: Curves.easeOutExpo);

// Modal scales and slides up with spring
Container(
  child: Modal(),
).animate()
  .scale(
    begin: Offset(0.9, 0.9),
    duration: 400.ms,
    curve: Curves.elasticOut, // Spring bounce
  )
  .slideY(
    begin: 0.1,
    duration: 400.ms,
    curve: Curves.easeOutExpo,
  )
  .fadeIn(duration: 300.ms);
```

**Sequence**:
1. FAB press triggers medium haptic
2. Background overlay fades in (300ms)
3. Modal scales from 0.9 to 1.0 with spring bounce
4. Modal slides up from 10% with ease-out
5. Input field auto-focuses
6. Keyboard slides up (iOS/Android)

**Haptic**: Medium impact on open

### Visual Design

**Modal Container**
```dart
Container(
  constraints: BoxConstraints(
    maxWidth: ContentWidth.modal, // 560px
    maxHeight: MediaQuery.of(context).size.height * 0.7,
  ),
  decoration: BoxDecoration(
    // Glass morphism effect
    color: Theme.of(context).brightness == Brightness.light
        ? Colors.white.withOpacity(0.95)
        : AppColors.neutral900.withOpacity(0.95),
    borderRadius: BorderRadius.circular(AppRadius.xl), // 20px
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [AppShadows.level4],
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: ModalContent(),
  ),
)
```

**Visual Properties**:
- Width: 560px max (full width on mobile with 16px margin)
- Height: 70% of screen max, grows with content
- Border Radius: 20px
- Background: 95% opacity white/dark with blur
- Border: 1px white with 20% opacity
- Shadow: Level 4 (dramatic)
- Backdrop Filter: 20px blur

**Position**:
- Mobile: Centered vertically, full width with 16px margin
- Tablet/Desktop: Centered on screen

### Modal Content Structure

```
┌──────────────────────────────────────────┐
│  [Type Indicators - Task/Note/List]     │
├──────────────────────────────────────────┤
│                                          │
│  [Auto-expanding text input area]       │
│  Multi-line, auto-grows                 │
│                                          │
├──────────────────────────────────────────┤
│  [Smart Suggestions Panel]              │
│  • Detected type hint                   │
│  • Quick tags                           │
│  • Due date shortcuts (tasks)           │
├──────────────────────────────────────────┤
│  [Action Buttons]                        │
│  [Cancel]              [Save]           │
└──────────────────────────────────────────┘
```

### Type Selection Row

**Layout**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  spacing: AppSpacing.sm,
  children: [
    TypeIndicator(
      type: ItemType.task,
      isSelected: selectedType == ItemType.task,
      onTap: () => setState(() => selectedType = ItemType.task),
    ),
    TypeIndicator(
      type: ItemType.note,
      isSelected: selectedType == ItemType.note,
      onTap: () => setState(() => selectedType = ItemType.note),
    ),
    TypeIndicator(
      type: ItemType.list,
      isSelected: selectedType == ItemType.list,
      onTap: () => setState(() => selectedType = ItemType.list),
    ),
  ],
)
```

**Type Indicator Button**
```dart
// Selected state
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  ),
  decoration: BoxDecoration(
    gradient: typeGradient, // Task/Note/List gradient
    borderRadius: BorderRadius.circular(AppRadius.sm),
    boxShadow: [
      BoxShadow(
        color: typeColor.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    spacing: AppSpacing.xs,
    children: [
      Icon(typeIcon, size: 20, color: Colors.white),
      Text(
        typeName,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)

// Unselected state
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  ),
  decoration: BoxDecoration(
    color: AppColors.neutral100,
    borderRadius: BorderRadius.circular(AppRadius.sm),
  ),
  child: Row(
    spacing: AppSpacing.xs,
    children: [
      Icon(typeIcon, size: 20, color: AppColors.neutral400),
      Text(
        typeName,
        style: TextStyle(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
)
```

**Interaction**:
- Tap to select type
- Smooth color transition (300ms)
- Scale animation on selection
- Haptic: Light impact on selection

### Input Area

**Text Field**
```dart
TextField(
  autofocus: true,
  maxLines: null, // Auto-expands
  minLines: 3,
  decoration: InputDecoration(
    hintText: _getHintText(), // Contextual based on type
    hintStyle: TextStyle(
      color: AppColors.neutral400,
      fontSize: 17,
    ),
    border: InputBorder.none,
    contentPadding: EdgeInsets.all(AppSpacing.lg),
  ),
  style: Theme.of(context).textTheme.bodyLarge,
  onChanged: (text) {
    _detectType(text); // Smart type detection
  },
)
```

**Behavior**:
- Auto-focuses on modal open
- Keyboard appears automatically
- Multi-line support with auto-expansion
- Max height: 50% of modal height
- Scrollable when exceeds max height
- Contextual hint text based on selected type

**Hint Text**:
- Task: "What do you need to do?"
- Note: "What's on your mind?"
- List: "Create a list..."

### Smart Type Detection

Automatically detects item type based on user input:

**Task Indicators**:
- Starts with action verbs (buy, call, email, finish, etc.)
- Contains due date mentions (today, tomorrow, next week)
- Contains "remind me" or "don't forget"
- Contains time mentions (at 3pm, by Friday)

**Note Indicators**:
- Longer text (> 100 characters)
- Multiple sentences
- Contains "I think", "remember that", "note to self"
- Lacks action verbs

**List Indicators**:
- Multiple lines with bullets or numbers
- Contains "list of", "things to"
- Multiple separate items separated by commas

**Implementation**:
```dart
void _detectType(String text) {
  if (text.isEmpty) return;

  // Task detection
  if (_hasTaskKeywords(text) || _hasDateMention(text)) {
    setState(() => suggestedType = ItemType.task);
  }
  // List detection
  else if (_hasListFormat(text)) {
    setState(() => suggestedType = ItemType.list);
  }
  // Default to note
  else {
    setState(() => suggestedType = ItemType.note);
  }

  // Show suggestion chip
  if (suggestedType != selectedType) {
    _showTypeSuggestion();
  }
}
```

### Smart Suggestions Panel

**Type Suggestion Chip**
```dart
if (suggestedType != null && suggestedType != selectedType)
  AnimatedContainer(
    duration: AppAnimations.fast,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: AppColors.infoBg,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        Icon(Lucide.lightbulb, size: 16, color: AppColors.info),
        Text(
          'This looks like a ${suggestedType.name}',
          style: TextStyle(
            color: AppColors.info,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() => selectedType = suggestedType);
            HapticFeedback.lightImpact();
          },
          child: Text('Switch'),
        ),
      ],
    ),
  ).animate()
    .fadeIn(duration: 200.ms)
    .slideY(begin: -0.5, duration: 200.ms);
```

**Quick Tag Suggestions** (Based on recent tags)
```dart
Wrap(
  spacing: AppSpacing.xs,
  children: recentTags.map((tag) {
    return ActionChip(
      label: Text('#$tag'),
      onPressed: () {
        _addTag(tag);
        HapticFeedback.selectionClick();
      },
      backgroundColor: AppColors.neutral100,
    );
  }).toList(),
)
```

**Due Date Shortcuts** (For tasks)
```dart
if (selectedType == ItemType.task)
  Row(
    spacing: AppSpacing.xs,
    children: [
      DateShortcut(label: 'Today', onTap: () => _setDueDate(today)),
      DateShortcut(label: 'Tomorrow', onTap: () => _setDueDate(tomorrow)),
      DateShortcut(label: 'This week', onTap: () => _setDueDate(thisWeek)),
      DateShortcut(label: 'Custom...', onTap: () => _showDatePicker()),
    ],
  )
```

### Action Buttons

**Button Row**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Cancel Button (Secondary)
    TextButton(
      onPressed: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();
      },
      child: Text(
        'Cancel',
        style: TextStyle(
          color: AppColors.neutral600,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Save Button (Primary)
    Container(
      decoration: BoxDecoration(
        gradient: selectedTypeGradient,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: selectedTypeColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _canSave ? _handleSave : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              spacing: AppSpacing.xs,
              children: [
                Icon(Lucide.check, size: 20, color: Colors.white),
                Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
)
```

**Save Button States**:

*Enabled*:
- Gradient matches selected type
- Full opacity
- Haptic: Medium impact on tap
- Success animation on save

*Disabled* (empty input):
- Neutral gray color
- 50% opacity
- No interaction

*Loading* (saving):
- Spinner replaces icon
- Text: "Saving..."
- No interaction

### Closing Animation

**User cancels or saves**:
```dart
// Modal scales down and fades
Container(
  child: Modal(),
).animate()
  .scale(
    end: Offset(0.95, 0.95),
    duration: 200.ms,
    curve: Curves.easeInOutQuint,
  )
  .fadeOut(duration: 200.ms);

// Background overlay fades out
Container(
  color: Colors.black.withOpacity(0.4),
).animate()
  .fadeOut(duration: 200.ms);

// FAB returns to normal state
FAB()
  .animate()
  .rotate(begin: 45, end: 0, duration: 300.ms) // X → Plus
  // Gradient animates back to primary
```

**On Save Success**:
```dart
// Show success indicator briefly
Container(
  child: Icon(Lucide.check, size: 32, color: AppColors.success),
).animate()
  .scale(
    begin: Offset(0.8, 0.8),
    duration: 300.ms,
    curve: Curves.elasticOut,
  )
  .fadeIn(duration: 200.ms)
  .then(delay: 500.ms) // Hold for 500ms
  .fadeOut(duration: 200.ms);

// Haptic: Success pattern (light, delay, light)
HapticFeedback.lightImpact();
Future.delayed(Duration(milliseconds: 50), () {
  HapticFeedback.lightImpact();
});
```

---

## Keyboard Shortcuts (Desktop)

**Global Shortcut**: `Cmd/Ctrl + N` - Opens quick capture

**Within Modal**:
- `Cmd/Ctrl + Enter` - Save
- `Escape` - Cancel/Close
- `Cmd/Ctrl + 1/2/3` - Switch to Task/Note/List
- `Tab` - Cycle through type selectors
- `Enter` (with modifier) - Save

---

## Responsive Behavior

### Mobile (Portrait)
- FAB: 64×64px, bottom-right
- Modal: Full width with 16px margin
- Modal: Slides up from bottom 20%
- Input: Full keyboard support
- Type indicators: Full width row

### Mobile (Landscape)
- FAB: Smaller (56×56px)
- Modal: Max width 600px, centered
- Reduced vertical padding
- Compact type indicators

### Tablet
- FAB: 72×72px (larger)
- Modal: 560px width, centered
- Full hover states
- Keyboard shortcuts enabled

### Desktop
- FAB: 80×80px (largest)
- Modal: 560px width, centered
- Full keyboard shortcuts
- Hover states on all interactive elements
- Mouse wheel scrolling in input

---

## Accessibility

### Screen Reader Support

**FAB**:
```dart
Semantics(
  label: 'Quick capture',
  hint: 'Opens quick capture modal to create tasks, notes, or lists',
  button: true,
  child: FAB(),
)
```

**Modal**:
```dart
Semantics(
  label: 'Quick capture modal',
  liveRegion: true,
  child: Modal(),
)
```

**Type Indicators**:
```dart
Semantics(
  label: 'Select item type: ${typeName}',
  selected: isSelected,
  button: true,
  child: TypeIndicator(),
)
```

### Keyboard Navigation

**Tab Order**:
1. Type indicator (Task)
2. Type indicator (Note)
3. Type indicator (List)
4. Text input
5. Quick actions (tags, dates)
6. Cancel button
7. Save button

**Focus Indicators**:
- 3px primary color outline
- 2px offset
- Visible on all interactive elements

### Reduced Motion

When `prefers-reduced-motion` is enabled:
- Opening animation: Instant appear with fade (100ms)
- Closing animation: Instant with fade (100ms)
- Spring bounces: Disabled
- Type selection: Crossfade only (no scale)
- All transitions: Max 150ms

---

## Edge Cases & States

### Empty State
- Save button disabled
- Hint text visible
- Gentle pulse animation on hint (respects reduced motion)

### Loading State (Saving)
- Save button shows spinner
- Input disabled
- Type selectors disabled
- User can't dismiss modal

### Error State (Save failed)
```dart
Container(
  color: AppColors.errorBg,
  padding: EdgeInsets.all(AppSpacing.sm),
  child: Row(
    children: [
      Icon(Lucide.alertCircle, color: AppColors.error),
      SizedBox(width: AppSpacing.xs),
      Text(
        'Failed to save. Please try again.',
        style: TextStyle(color: AppColors.error),
      ),
    ],
  ),
).animate()
  .fadeIn(duration: 200.ms)
  .slideY(begin: -0.5, duration: 200.ms);
```

### Offline State
- Show offline indicator
- Allow creation (queued for sync)
- Visual indicator of queued state

### Dismiss Behavior
- Tap outside modal: Dismiss (with confirmation if text entered)
- Swipe down: Dismiss (mobile only)
- Escape key: Dismiss
- Back button (Android): Dismiss

### Confirmation on Dismiss
```dart
if (hasUnsavedContent) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Discard changes?'),
      content: Text('You have unsaved content. Are you sure you want to close?'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Discard'),
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close modal
          },
        ),
      ],
    ),
  );
}
```

---

## Performance Optimizations

### Blur Performance
- Use `BackdropFilter` with caution (GPU intensive)
- Consider static blur for lower-end devices
- Provide option to disable glass effect in settings

### Animation Performance
- Use `Transform` properties (GPU accelerated)
- Wrap modal in `RepaintBoundary`
- Dispose animation controllers properly

### Keyboard Performance
- Debounce type detection (300ms)
- Optimize suggestion generation
- Cache recent tags/suggestions

---

## Flutter Implementation

### Quick Capture FAB

```dart
// lib/features/quick_capture/quick_capture_fab.dart

class QuickCaptureFAB extends StatefulWidget {
  @override
  _QuickCaptureFABState createState() => _QuickCaptureFABState();
}

class _QuickCaptureFABState extends State<QuickCaptureFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.base,
    );
  }

  Future<void> _openQuickCapture() async {
    HapticFeedback.mediumImpact();

    setState(() => _isModalOpen = true);
    _controller.forward();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickCaptureModal(),
    );

    setState(() => _isModalOpen = false);
    _controller.reverse();

    if (result != null) {
      // Handle saved item
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: _isModalOpen
                  ? AppColors.secondaryGradient
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySolid.withOpacity(0.4),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openQuickCapture,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Center(
                  child: AnimatedRotation(
                    turns: _isModalOpen ? 0.125 : 0, // 45 degrees
                    duration: AppAnimations.base,
                    curve: Curves.elasticOut,
                    child: Icon(
                      _isModalOpen ? Lucide.x : Lucide.plus,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Quick Capture Modal

```dart
// lib/features/quick_capture/quick_capture_modal.dart

class QuickCaptureModal extends StatefulWidget {
  @override
  _QuickCaptureModalState createState() => _QuickCaptureModalState();
}

class _QuickCaptureModalState extends State<QuickCaptureModal> {
  final TextEditingController _controller = TextEditingController();
  ItemType _selectedType = ItemType.task;
  ItemType? _suggestedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() => _suggestedType = null);
      return;
    }

    // Smart type detection (debounced in production)
    final detected = _detectType(text);
    if (detected != _selectedType) {
      setState(() => _suggestedType = detected);
    }
  }

  ItemType _detectType(String text) {
    // Simple detection logic (expand in production)
    if (text.contains(RegExp(r'\n.*\n'))) return ItemType.list;
    if (text.length > 100) return ItemType.note;
    if (text.toLowerCase().startsWith(RegExp(r'(buy|call|email|finish|do)'))) {
      return ItemType.task;
    }
    return ItemType.note;
  }

  Future<void> _handleSave() async {
    if (_controller.text.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      // Save logic here
      await Future.delayed(Duration(milliseconds: 500)); // Simulate save

      // Success haptic pattern
      HapticFeedback.lightImpact();
      await Future.delayed(Duration(milliseconds: 50));
      HapticFeedback.lightImpact();

      Navigator.pop(context, {
        'type': _selectedType,
        'content': _controller.text,
      });
    } catch (e) {
      setState(() => _isSaving = false);
      // Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Prevent dismissal when tapping modal
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ContentWidth.modal,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              margin: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white.withOpacity(0.95)
                    : AppColors.neutral900.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [AppShadows.level4],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTypeSelector(),
                        SizedBox(height: AppSpacing.md),
                        _buildInput(),
                        if (_suggestedType != null) ...[
                          SizedBox(height: AppSpacing.sm),
                          _buildSuggestion(),
                        ],
                        SizedBox(height: AppSpacing.lg),
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate()
              .scale(
                begin: Offset(0.9, 0.9),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutExpo)
              .fadeIn(duration: 300.ms),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ItemType.values.map((type) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: _TypeIndicator(
            type: type,
            isSelected: _selectedType == type,
            onTap: () {
              setState(() => _selectedType = type);
              HapticFeedback.lightImpact();
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInput() {
    return TextField(
      controller: _controller,
      autofocus: true,
      maxLines: null,
      minLines: 3,
      enabled: !_isSaving,
      decoration: InputDecoration(
        hintText: _getHintText(),
        hintStyle: TextStyle(color: AppColors.neutral400),
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(AppSpacing.md),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildSuggestion() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(Lucide.lightbulb, size: 16, color: AppColors.info),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'This looks like a ${_suggestedType!.name}',
              style: TextStyle(color: AppColors.info, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _selectedType = _suggestedType!);
              HapticFeedback.lightImpact();
            },
            child: Text('Switch'),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 200.ms)
      .slideY(begin: -0.5, duration: 200.ms);
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        _SaveButton(
          type: _selectedType,
          enabled: _controller.text.isNotEmpty && !_isSaving,
          isLoading: _isSaving,
          onPressed: _handleSave,
        ),
      ],
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case ItemType.task:
        return 'What do you need to do?';
      case ItemType.note:
        return 'What\'s on your mind?';
      case ItemType.list:
        return 'Create a list...';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

**Related Documentation**
- [Style Guide](../style-guide.md)
- [Animations](../tokens/animations.md)
- [Item Cards](./item-cards.md)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
