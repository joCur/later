---
title: Unified Item Management Feature
description: Seamless management of tasks, notes, and lists in a flexible, unified interface
feature: unified-item-management
version: 1.0.0
last-updated: 2025-10-18
status: approved
priority: P0
related-files:
  - ./user-journey.md
  - ./screen-states.md
  - ../../design-system/components/item-cards.md
dependencies:
  - offline-first-architecture
  - spaces-organization
---

# Unified Item Management Feature

## Feature Overview

Unified Item Management is the core of Later's "works how you think" philosophy. Users can create, view, edit, and organize tasks, notes, and lists without rigid categorization or forced workflows.

**Design Philosophy**: Flexibility without chaos. Items flow naturally between types based on user needs, not system constraints.

## User Story

**As a** Later user
**I want to** manage all my tasks, notes, and lists in one flexible interface
**So that I can** organize my thoughts and work without being forced into rigid categories

## Success Criteria

- Create any item type with equal ease (no preference bias)
- Visual distinction between types without overwhelming clutter
- Convert between types seamlessly (task → note, etc.)
- Mixed views (all items) and filtered views (tasks only)
- Search across all item types simultaneously
- Consistent interaction patterns regardless of item type

## Key User Personas

### Sarah Chen - Power User
**Need**: Quick switching between contexts, bulk operations, keyboard shortcuts
**Pain Point**: Rigid systems slow her down
**Solution**: Flexible item types, keyboard-first design, bulk actions

### Marcus Thompson - Student
**Need**: Mix of lecture notes, assignment tasks, reading lists
**Pain Point**: Tools force separation of related content
**Solution**: Unified view with smart filtering, related items linking

### Elena Rodriguez - Creative
**Need**: Visual mood boards, client notes, project tasks together
**Pain Point**: Switching between apps breaks creative flow
**Solution**: Rich media in notes, visual organization, flexible layouts

### David Park - Parent
**Need**: Simple capture of family tasks, shopping lists, meeting notes
**Pain Point**: Too many features, overwhelming interfaces
**Solution**: Smart defaults, progressive disclosure, simple views

## Core Functionality

### Item Types

#### Task
**Purpose**: Actionable items with optional due dates and completion status

**Key Attributes**:
- Title (required)
- Content/description (optional)
- Completion status (boolean)
- Due date (optional)
- Priority (optional: low, medium, high)
- Tags (optional)
- Space assignment

**Visual Identity**:
- Blue left border (4px)
- Checkbox (24x24px)
- Strikethrough when completed
- Due date badge (if set)

**Unique Features**:
- Checkbox toggle
- Recurring tasks (P1)
- Subtasks (P1)
- Time tracking (P2)

#### Note
**Purpose**: Free-form content for thoughts, meeting notes, ideas

**Key Attributes**:
- Title (optional, auto-generated from first line)
- Rich content (markdown supported)
- Tags (optional)
- Space assignment
- Creation/modification dates

**Visual Identity**:
- Amber left border (4px)
- Note icon (20x20px)
- Content preview (2-3 lines)
- Word/character count (optional)

**Unique Features**:
- Rich text formatting (P1)
- Image/file attachments (P1)
- Code blocks (P1)
- Linking to other notes (P2)

#### List
**Purpose**: Collections of related items (shopping, packing, checklists)

**Key Attributes**:
- Title (required)
- List items (array)
- Item completion status (per item)
- Tags (optional)
- Space assignment

**Visual Identity**:
- Violet left border (4px)
- List icon (20x20px)
- Item preview (first 3 items)
- Progress indicator ("3/10 items")

**Unique Features**:
- Bulk item operations
- Reorder items
- Convert to subtasks
- Templates (P2)

### Unified Views

#### All Items View (Default)
**Display**: Mixed item types in chronological or custom order

**Layout**:
```
┌─────────────────────────────────┐
│  Personal ▼         [🔍] [+]   │
│                                 │
│  [Task: Buy groceries]          │
│  [Note: Meeting notes...]       │
│  [List: Packing list]           │
│  [Task: Call dentist]           │
│  [Note: Project ideas...]       │
│                                 │
└─────────────────────────────────┘
```

**Features**:
- Visual distinction via color accent
- Consistent card height (unless expanded)
- Infinite scroll with virtualization
- Pull-to-refresh (mobile)

**Sorting Options**:
- Recent (default)
- Alphabetical
- Due date (tasks first)
- Custom manual order

#### Filtered Views

**Task View**:
- Shows only tasks
- Additional filters: Completed, Due today, Overdue, No date
- Sort by: Due date, Priority, Alphabetical
- Bulk operations: Mark complete, Delete, Move space

**Note View**:
- Shows only notes
- Additional filters: Has attachments, Tagged
- Sort by: Recent, Alphabetical, Length
- Grid view option (desktop)

**List View**:
- Shows only lists
- Additional filters: In progress, Completed
- Sort by: Recent, Alphabetical, Progress
- Quick duplicate for recurring lists

#### Search View
**Unified Search**: Across all item types simultaneously

**Layout**:
```
┌─────────────────────────────────┐
│  🔍 Search...                   │
│  ─────────────────────────────  │
│  Filters: [All] [Tasks] [Notes] │
│           [Lists] [This space]  │
│                                 │
│  Results (23)                   │
│  [Task: Buy milk] ...milk in... │
│  [Note: Grocery st...milk...]   │
│  [List: Shopping] ...milk...    │
│                                 │
└─────────────────────────────────┘
```

**Features**:
- Real-time search (<50ms)
- Search in titles and content
- Fuzzy matching
- Type filtering
- Space filtering
- Highlight matches

### Item Operations

#### Create
**Entry Points**:
- Floating Action Button (quick capture)
- Keyboard shortcut (Cmd/Ctrl+N)
- Context menu (right-click empty space)
- Share sheet (mobile)

**Default Behavior**:
- Opens quick capture modal
- Auto-detect item type from content
- Save to current space
- No mandatory fields except content

#### View/Read
**Single Tap/Click**:
- Opens item detail view
- Full-screen on mobile
- Side panel on desktop (optional)
- Preserves scroll position on back

**Item Detail Layout**:
```
┌─────────────────────────────────┐
│  ← [•••]                     [×]│
│                                 │
│  [Type Badge]                   │
│  Title (editable)               │
│                                 │
│  Content (editable)             │
│                                 │
│  ─────────────────────────────  │
│  Space: Personal           [▼]  │
│  Tags: [work] [important]       │
│  Created: Mar 15, 2025          │
│  Modified: Mar 18, 2025         │
│                                 │
└─────────────────────────────────┘
```

#### Edit
**Inline Editing** (Desktop):
- Double-click to edit
- Tab between fields
- Esc to cancel, Enter to save
- Auto-save on blur

**Modal Editing** (Mobile):
- Tap to open detail
- Tap field to edit
- Auto-save on change
- Back button saves and closes

**What's Editable**:
- Title (all types)
- Content (all types)
- Item type (convert between types)
- Space assignment
- Tags
- Due date (tasks)
- Priority (tasks)
- List items (lists)

#### Delete
**Trigger Methods**:
- Swipe left (mobile)
- Delete key (desktop, with selection)
- Action menu → Delete
- Bulk delete (multi-select mode)

**Confirmation**:
- Required for single delete
- Required for bulk delete
- No confirmation for undo-able operations

**Confirmation Dialog**:
```
┌─────────────────────────────────┐
│  Delete "Buy groceries"?        │
│                                 │
│  This action cannot be undone.  │
│                                 │
│  [Cancel]     [Delete]          │
└─────────────────────────────────┘
```

**Undo**:
- Toast notification: "Item deleted. [Undo]"
- 5-second undo window
- Restores to original position

#### Duplicate
**Use Cases**:
- Recurring lists (shopping, packing)
- Template tasks
- Experiment variations

**Behavior**:
- Copies all attributes
- Appends "Copy" to title
- Marks as not completed (tasks)
- Opens in edit mode

#### Convert Type
**Scenarios**:
- Task → Note (abandoned task becomes reference)
- Note → Task (idea becomes actionable)
- List → Tasks (checklist items become tasks)
- Task → List (task with subtasks)

**Conversion Rules**:
- Title preserved
- Content preserved
- Completion status: Tasks only
- Due date: Tasks only (cleared on conversion away)
- List items: Lists only (preserved as content for others)

**UI**:
- Action menu → "Convert to..."
- Shows available conversions
- Instant conversion, no confirmation
- Undo available

### Multi-Select Mode

#### Activation
**Mobile**:
- Long-press on item card
- Shows checkboxes on all items
- Action bar appears at bottom

**Desktop**:
- Click checkbox (appears on hover)
- Cmd/Ctrl+Click for toggle select
- Shift+Click for range select

#### Bulk Operations
**Available Actions**:
- Mark complete (tasks only)
- Move to space
- Add tags
- Delete
- Duplicate
- Export

**Action Bar**:
```
┌─────────────────────────────────┐
│  3 selected                     │
│  [Complete] [Move] [Tag] [...]  │
└─────────────────────────────────┘
```

**Cancel Multi-Select**:
- Tap/click outside
- Press Esc
- Tap "Cancel" button
- Complete an action (auto-exit)

### Drag and Drop

#### Desktop Behavior
**What's Draggable**:
- Individual item cards
- Multiple selected items
- List items within list

**Drop Targets**:
- Space list (move to space)
- Within list (reorder)
- List card (add to list)
- Empty space (manual positioning)

**Visual Feedback**:
- Card lifts (shadow level 3)
- Cursor changes to grabbing
- Drop zones highlight
- Invalid drops: red outline, shake

**Constraints**:
- Can't drag to invalid spaces (archived)
- Can't drop on itself
- Snap to grid/list positions

#### Mobile Alternative
- Long-press → Move to... menu
- Drag handles (reordering only)
- No free-form drag-drop

## Interaction Patterns

### Keyboard Shortcuts

**Global**:
- `Cmd/Ctrl+N`: New item (quick capture)
- `Cmd/Ctrl+F`: Focus search
- `Cmd/Ctrl+K`: Command palette
- `/`: Focus filter bar

**Item Operations**:
- `Enter`: Open selected item
- `Space`: Toggle checkbox (tasks)
- `e`: Edit selected item
- `d`: Duplicate selected item
- `Delete`: Delete with confirmation
- `Cmd/Ctrl+D`: Duplicate
- `Cmd/Ctrl+Shift+C`: Convert type

**Navigation**:
- `j/k` or `↓/↑`: Next/previous item
- `Esc`: Close detail view, cancel selection
- `Tab`: Next focusable element
- `1-9`: Switch to space (if <10 spaces)

**Multi-Select**:
- `Cmd/Ctrl+A`: Select all visible
- `Cmd/Ctrl+Click`: Toggle individual
- `Shift+Click`: Range select

### Gesture Support (Mobile/Tablet)

**Swipe Right** (Tasks):
- Toggle completion
- Threshold: 30% card width
- Visual: Teal background, checkmark icon

**Swipe Left**:
- Delete item
- Threshold: 50% card width
- Visual: Red background, trash icon

**Long Press**:
- Activate multi-select mode
- Duration: 500ms
- Haptic: Medium impact

**Pull to Refresh**:
- Trigger: Pull down >100px
- Action: Refresh items (sync if online)
- Visual: Spinner, "Last updated" timestamp

**Pinch**:
- Not used (avoid complexity)

## Responsive Design

### Mobile (320-767px)

**Layout**:
- Single column list
- Full-width cards
- Bottom-aligned FAB
- Bottom navigation bar

**Optimizations**:
- Shorter content previews (2 lines)
- Hidden metadata (expandable)
- Swipe actions primary
- Bottom sheets for actions

### Tablet (768-1023px)

**Layout**:
- Two-column grid (portrait)
- Three-column grid (landscape)
- Side navigation panel
- FAB or toolbar

**Optimizations**:
- Standard card size
- Hover states available
- Context menus
- Drag-and-drop

### Desktop (1024px+)

**Layout**:
- Three-column grid (standard)
- Four-column grid (wide screens)
- Persistent left sidebar (spaces)
- Top toolbar with filters

**Optimizations**:
- Keyboard shortcuts prominent
- Hover interactions
- Inline editing
- Multiple selection modes

## Accessibility Specifications

### Screen Reader

**Item Card Announcement**:
- "Task, Buy groceries, due today at 5 PM, uncompleted"
- "Note, Meeting notes with John, created March 15"
- "List, Packing list, 3 of 10 items completed"

**Actions Announced**:
- "Task marked as complete"
- "Item moved to Work space"
- "3 items selected"

### Keyboard Navigation

**Full keyboard support**:
- All actions accessible via keyboard
- Logical tab order
- Visible focus indicators
- Escape hatches (Esc key)

### Touch Accessibility

**Minimum targets**: 44x44dp for all interactive elements
**Spacing**: 8px minimum between targets
**Alternatives**: Every gesture has menu alternative

### Color Contrast

**All text meets WCAG AA**:
- Titles: 11.6:1 (AAA)
- Content: 7.3:1 (AAA)
- Metadata: 4.6:1 (AA)

**Item type colors**:
- Decorative only (not sole indicator)
- Icons and labels provide redundancy

## Performance Targets

- **Item render**: <16ms (60fps)
- **List scroll**: Smooth 60fps (virtualized)
- **Search response**: <50ms
- **Item save**: <100ms (local)
- **View switch**: <200ms transition
- **Bulk operation**: <500ms for 100 items

## Technical Constraints

- **Local-first**: All operations work offline
- **Database**: Efficient queries for large datasets (10,000+ items)
- **Memory**: <50MB for 1,000 items loaded
- **Sync**: Background, non-blocking
- **Search**: Indexed full-text search

## Related Documentation

- [User Journey](./user-journey.md) - Complete user flows
- [Screen States](./screen-states.md) - Visual specifications
- [Item Cards Component](../../design-system/components/item-cards.md) - Card specs
- [Quick Capture](../quick-capture/) - Item creation flow
- [Offline Architecture](../offline-first-architecture/) - Local storage

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved | **Priority**: P0
