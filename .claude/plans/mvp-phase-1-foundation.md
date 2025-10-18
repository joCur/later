# Later MVP - Phase 1: Foundation & Local-First Core

## Objective and Scope

Build the foundational MVP for Later app focusing on **local-first functionality** with offline-capable item management. This phase establishes the core architecture, local database, basic UI components, and essential features without requiring backend sync or authentication.

**What's In Scope:**
- Flutter project setup with design system implementation
- Local database (Hive) for offline-first storage
- Basic item management (create, read, update, delete tasks/notes/lists)
- Space organization with switching capability
- Quick capture modal
- Responsive layouts (mobile-first, then tablet/desktop)
- Core UI components (item cards, buttons, inputs)

**What's Out of Scope (Future Phases):**
- Supabase backend integration and sync
- User authentication
- Cross-device sync
- Collaboration/sharing features
- Advanced search and filtering
- Natural language processing
- Voice input

## Technical Approach and Reasoning

### Architecture Decisions

**1. Local-First with Hive**
- **Why Hive:** Fast, lightweight, pure Dart NoSQL database perfect for offline-first
- **Reasoning:** Build and validate core features locally before adding backend complexity
- **Benefit:** Free development, no API quotas, instant testing

**2. Flutter with Material 3**
- **Why Material 3:** Modern design system with excellent theming support
- **Reasoning:** Cross-platform from day one, matches design system requirements
- **Benefit:** Single codebase for mobile, tablet, desktop, web

**3. Provider for State Management**
- **Why Provider:** Simple, officially recommended, minimal boilerplate
- **Reasoning:** MVP doesn't need complex state management; Provider handles local state well
- **Benefit:** Easy to understand, migrate later if needed

**4. Repository Pattern**
- **Why Repository:** Abstraction layer between data source and UI
- **Reasoning:** Easy to swap Hive for Supabase later without changing business logic
- **Benefit:** Clean architecture, testable, flexible

### Data Model Design

```dart
// Core models designed for both local and eventual backend sync
Item {
  String id;                    // UUID for future sync
  ItemType type;                // task, note, list
  String title;
  String? content;
  String spaceId;               // Foreign key to Space
  bool isCompleted;             // For tasks
  DateTime? dueDate;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;
  String? syncStatus;           // null (local-only), 'pending', 'synced'
}

Space {
  String id;                    // UUID
  String name;
  String? icon;
  String? color;
  int itemCount;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;
}
```

## Implementation Phases

### Phase 1.1: Project Setup & Design System ✅ COMPLETED

- [x] **Task 1.1.1: Initialize Flutter Project**
  - Create new Flutter project with latest stable version
  - Configure `pubspec.yaml` with required dependencies (provider, hive, hive_flutter, uuid, intl, path_provider)
  - Set up folder structure following conventions from DEVELOPER_QUICKSTART.md
  - Configure platform-specific settings (iOS, Android, Web, Desktop)
  - Create `.env` template for future Supabase config (but don't use it yet)

- [x] **Task 1.1.2: Implement Design System Foundation**
  - Create `lib/core/theme/app_colors.dart` with all color tokens from design documentation
  - Create `lib/core/theme/app_typography.dart` with Inter font family and type scale
  - Create `lib/core/theme/app_spacing.dart` with 8px base unit system
  - Create `lib/core/theme/app_animations.dart` with duration and easing constants
  - Create `lib/core/theme/app_theme.dart` combining all tokens into light/dark ThemeData
  - Test theme switching functionality

- [x] **Task 1.1.3: Responsive Utilities**
  - Create `lib/core/responsive/breakpoints.dart` with isMobile/isTablet/isDesktop helpers
  - Create `lib/core/responsive/adaptive_spacing.dart` for responsive padding/margins
  - Implement LayoutBuilder wrapper widget for adaptive layouts
  - Test breakpoint detection on different screen sizes

- [x] **Task 1.1.4: Initialize Local Database**
  - Set up Hive initialization in `main.dart`
  - Create `lib/data/models/item_model.dart` with Hive type adapter
  - Create `lib/data/models/space_model.dart` with Hive type adapter
  - Run `build_runner` to generate adapters
  - Create `lib/data/local/hive_database.dart` wrapper for box operations
  - Write unit tests for model serialization/deserialization

### Phase 1.2: Core Data Layer & Business Logic

- [ ] **Task 1.2.1: Repository Implementation**
  - Create `lib/data/repositories/item_repository.dart` with CRUD operations
  - Implement `createItem()`, `getItems()`, `updateItem()`, `deleteItem()`
  - Create `lib/data/repositories/space_repository.dart` with CRUD operations
  - Implement `createSpace()`, `getSpaces()`, `updateSpace()`, `deleteSpace()`
  - Add filtering methods: `getItemsBySpace()`, `getItemsByType()`
  - Write repository unit tests with mock data

- [ ] **Task 1.2.2: State Management Setup**
  - Create `lib/providers/items_provider.dart` extending ChangeNotifier
  - Implement item state: `List<Item> items`, loading states, error handling
  - Add methods: `addItem()`, `updateItem()`, `deleteItem()`, `toggleCompletion()`
  - Create `lib/providers/spaces_provider.dart` extending ChangeNotifier
  - Implement space state: `List<Space> spaces`, `currentSpace`
  - Add methods: `addSpace()`, `switchSpace()`, `updateSpace()`
  - Integrate repositories into providers

- [ ] **Task 1.2.3: Seed Data & Default Space**
  - Create `lib/data/local/seed_data.dart` for first-run initialization
  - Generate default "Personal" space on first app launch
  - Create sample items (2 tasks, 1 note, 1 list) for onboarding
  - Implement first-run detection logic
  - Test clean install experience

### Phase 1.3: Core UI Components

- [ ] **Task 1.3.1: Button Components**
  - Create `lib/widgets/components/buttons/primary_button.dart`
  - Create `lib/widgets/components/buttons/secondary_button.dart`
  - Create `lib/widgets/components/buttons/ghost_button.dart`
  - Implement all button states (default, hover, pressed, disabled, loading)
  - Support sizes (small: 32px, medium: 40px, large: 48px)
  - Add haptic feedback for mobile
  - Test accessibility (semantic labels, focus indicators)

- [ ] **Task 1.3.2: Input Field Components**
  - Create `lib/widgets/components/inputs/text_input_field.dart`
  - Implement states (default, focus, error, disabled)
  - Add validation feedback support
  - Create `lib/widgets/components/inputs/text_area_field.dart` for multiline
  - Support auto-focus and keyboard actions
  - Test with screen readers

- [ ] **Task 1.3.3: Item Card Component**
  - Create `lib/widgets/components/cards/item_card.dart`
  - Implement three variants: TaskCard, NoteCard, ListCard
  - Add 4px colored left border (blue/amber/violet)
  - Implement leading element (checkbox for tasks, icon for others)
  - Add title (H4, max 2 lines with ellipsis)
  - Add content preview (2 lines on mobile, 3 on desktop)
  - Add metadata row (space indicator, date, item count for lists)
  - Implement all states (default, hover, selected, pressed)
  - Add gesture handlers (tap to open, long-press for future multi-select)
  - Test responsive behavior across breakpoints

- [ ] **Task 1.3.4: Floating Action Button (FAB)**
  - Create `lib/widgets/components/fab/quick_capture_fab.dart`
  - Implement 56x56dp visual size with 64x64dp touch target
  - Use accent-primary amber color with gradient
  - Add level 3 elevation shadow
  - Position bottom-right with 16dp margin
  - Implement scale animation (0.95 on press)
  - Add hero animation for modal transition
  - Test visibility rules (hide on scroll, show on scroll up)

### Phase 1.4: Main Screens & Navigation

- [ ] **Task 1.4.1: Navigation Setup**
  - Create `lib/widgets/navigation/bottom_navigation_bar.dart` for mobile
  - Implement 3 tabs: Home (spaces view), Search (placeholder), Settings
  - Use active/inactive states with icons
  - Create `lib/widgets/navigation/app_sidebar.dart` for desktop
  - Implement collapsible sidebar (240px expanded, 72px collapsed)
  - Add space list with item counts
  - Support keyboard navigation (1-9 for first 9 spaces)
  - Test responsive switching (bottom nav on mobile, sidebar on desktop)

- [ ] **Task 1.4.2: Home/Workspace Screen**
  - Create `lib/widgets/screens/home_screen.dart` as main entry point
  - Implement top app bar with space switcher, search icon, menu
  - Add filter chips (All, Tasks, Notes, Lists)
  - Implement item list view using ListView.builder for performance
  - Load items from ItemsProvider based on currentSpace
  - Show empty state with helpful CTA when no items exist
  - Add pull-to-refresh gesture
  - Implement FAB for quick capture
  - Test with different item counts (empty, few items, many items)

- [ ] **Task 1.4.3: Space Switcher Modal**
  - Create `lib/widgets/modals/space_switcher_modal.dart`
  - Display as bottom sheet on mobile, dialog on desktop
  - Show list of all spaces with icons, names, item counts
  - Highlight currently selected space
  - Add search/filter input at top
  - Implement "Create New Space" button at bottom
  - Add slide-up animation (300ms, spring easing)
  - Support keyboard navigation and shortcuts
  - Test space switching performance (<200ms)

- [ ] **Task 1.4.4: Item Detail Screen**
  - Create `lib/widgets/screens/item_detail_screen.dart`
  - Show as full screen on mobile, modal on desktop
  - Implement editable title field (auto-save on blur)
  - Implement editable content area with auto-expanding TextFormField
  - Add space selector dropdown
  - Add date picker for tasks
  - Add tags input (chips with add/remove)
  - Show metadata (created, modified timestamps)
  - Implement auto-save with debounce (500ms after last keystroke)
  - Add delete button with confirmation
  - Support keyboard shortcuts (Esc to close, Cmd/Ctrl+S to force save)

### Phase 1.5: Quick Capture Feature

- [ ] **Task 1.5.1: Quick Capture Modal UI**
  - Create `lib/widgets/modals/quick_capture_modal.dart`
  - Display as bottom sheet on mobile (with drag handle), centered modal on desktop
  - Auto-focus input field on open
  - Implement multiline text input (3-5 lines)
  - Add type selector (Auto, Task, Note, List) with icons
  - Add space selector dropdown (defaults to current space)
  - Show character count for long inputs
  - Implement backdrop blur effect
  - Add close button and keyboard shortcut (Esc)

- [ ] **Task 1.5.2: Smart Type Detection**
  - Create `lib/core/utils/item_type_detector.dart`
  - Implement heuristics for type detection:
    - Task: Contains action verbs (buy, call, send, etc.) or short imperative sentences
    - List: Contains bullets, numbers, or multiple newlines
    - Note: Default for longer text or paragraphs
  - Show detected type in UI with ability to override
  - Test with various input samples

- [ ] **Task 1.5.3: Quick Capture Logic**
  - Implement save handler that creates item via ItemsProvider
  - Clear input after successful save
  - Show brief success toast notification
  - Handle validation (minimum title length)
  - Implement auto-save on modal dismiss if content exists
  - Add keyboard shortcut globally (Cmd/Ctrl+N) to trigger quick capture
  - Test offline creation and persistence

### Phase 1.6: Item Management Operations

- [ ] **Task 1.6.1: Item Completion Toggle**
  - Implement checkbox tap handler in TaskCard
  - Update item `isCompleted` status via ItemsProvider
  - Apply strikethrough and opacity styling to completed tasks
  - Add subtle animation (scale 1.0 → 1.05 → 1.0)
  - Persist completion state to Hive immediately
  - Test rapid toggling performance

- [ ] **Task 1.6.2: Item Editing**
  - Implement tap handler to open ItemDetailScreen
  - Support inline editing for quick changes
  - Implement debounced auto-save (500ms after last change)
  - Show saving indicator during save operation
  - Handle validation errors gracefully
  - Test with network disabled (should work offline)

- [ ] **Task 1.6.3: Item Deletion**
  - Add delete button in ItemDetailScreen menu
  - Implement confirmation dialog ("Delete this item?")
  - Remove item from Hive via ItemsProvider
  - Show undo snackbar for 5 seconds (allows recovery)
  - Implement actual deletion after undo timeout
  - Update item count in space metadata
  - Test deletion with various item types

- [ ] **Task 1.6.4: Type Conversion**
  - Add "Convert to..." option in item menu
  - Allow conversion between task ↔ note ↔ list
  - Preserve title and content during conversion
  - Handle special fields (checkbox state, list items)
  - Show confirmation for destructive conversions
  - Update UI immediately after conversion

### Phase 1.7: Space Management

- [ ] **Task 1.7.1: Create New Space**
  - Create `lib/widgets/modals/create_space_modal.dart`
  - Implement name input with validation (required, 1-100 chars)
  - Add icon picker with emoji/icon options
  - Add color picker with predefined palette
  - Generate unique UUID for space ID
  - Save to Hive via SpacesProvider
  - Auto-switch to newly created space
  - Test duplicate name handling

- [ ] **Task 1.7.2: Edit Space**
  - Add edit option in space switcher long-press menu
  - Reuse create space modal in edit mode
  - Allow changing name, icon, color
  - Prevent deleting space if it contains items
  - Update all references in UI
  - Test with items present in space

- [ ] **Task 1.7.3: Delete/Archive Space**
  - Add delete option in space settings
  - Show warning if space contains items
  - Offer "Move items to..." option before deletion
  - Implement soft delete (archive flag) instead of hard delete
  - Hide archived spaces from main list (add "Show archived" toggle)
  - Test recovery of archived spaces

### Phase 1.8: Polish & Testing

- [ ] **Task 1.8.1: Loading States & Skeletons**
  - Create `lib/widgets/components/loading/skeleton_card.dart`
  - Show skeleton loaders while data loads
  - Implement shimmer animation effect
  - Add loading indicators for long operations
  - Test on slow devices

- [ ] **Task 1.8.2: Empty States**
  - Create empty state for spaces with no items
  - Show helpful message with quick capture CTA
  - Create empty state for new app install (welcome message)
  - Design empty search results state (for future search)
  - Test with new user flow

- [ ] **Task 1.8.3: Error Handling**
  - Implement global error handler in main.dart
  - Create user-friendly error messages
  - Add retry mechanisms for failed operations
  - Log errors for debugging (without sensitive data)
  - Test with invalid data scenarios

- [ ] **Task 1.8.4: Accessibility Audit**
  - Test with TalkBack (Android) and VoiceOver (iOS)
  - Verify all interactive elements have semantic labels
  - Check color contrast ratios (WCAG AA: 4.5:1 for text)
  - Verify minimum touch targets (44x44dp)
  - Test keyboard navigation on desktop
  - Ensure focus indicators are visible
  - Test with screen reader and verify announcements

- [ ] **Task 1.8.5: Performance Optimization**
  - Profile app with Flutter DevTools
  - Optimize item list rendering (use ListView.builder, keys)
  - Implement lazy loading for large lists (paginate at 100 items)
  - Minimize rebuild scope (use const constructors)
  - Test with 1000+ items in a space
  - Verify 60fps during scrolling and animations
  - Measure app launch time (<2s target)

- [ ] **Task 1.8.6: Widget Testing**
  - Write widget tests for critical components (ItemCard, QuickCapture, SpaceSwitcher)
  - Write unit tests for providers (items operations, space operations)
  - Write integration tests for core flows (create item, switch space, complete task)
  - Achieve >70% code coverage for core logic
  - Set up CI for automated testing (GitHub Actions)

## Dependencies and Prerequisites

### Development Environment
- **Flutter SDK**: 3.24+ (stable channel)
- **Dart**: 3.5+
- **IDE**: VS Code or Android Studio with Flutter plugins
- **Devices**: iOS Simulator, Android Emulator, or physical devices
- **Git**: For version control

### Flutter Packages
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.0

  # Local Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Utilities
  uuid: ^4.5.0                    # Generate UUIDs for items/spaces
  intl: ^0.19.0                   # Date formatting
  path_provider: ^2.1.4           # Get app directories

  # UI Enhancements
  flutter_slidable: ^3.1.0        # Swipe actions

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.12
  flutter_lints: ^4.0.0
```

### Design Assets
- Inter font family (loaded via Google Fonts or bundled)
- Icon set (Material Icons included, custom icons if needed)
- Design tokens JSON (reference: `.claude/docs/design-documentation/assets/design-tokens.json`)

### Documentation References
- DEVELOPER_QUICKSTART.md for setup instructions
- design-documentation/ for all visual specifications
- product-manager-output.md for user stories and requirements

## Challenges and Considerations

### Technical Challenges

**Challenge 1: State Management Complexity**
- **Issue**: Managing state across items, spaces, and UI
- **Mitigation**: Use Provider with clear separation of concerns; repositories handle data, providers handle state
- **Fallback**: If Provider becomes unwieldy, consider Riverpod migration

**Challenge 2: Hive Performance with Large Datasets**
- **Issue**: Hive can slow down with 10,000+ items
- **Mitigation**: Use lazy loading, pagination, and indices for filtering
- **Monitoring**: Profile with DevTools, set performance budgets

**Challenge 3: Responsive Layout Complexity**
- **Issue**: Supporting mobile, tablet, desktop with single codebase
- **Mitigation**: Use LayoutBuilder and breakpoint helpers consistently
- **Testing**: Test on all target platforms regularly

**Challenge 4: Auto-Save Debouncing**
- **Issue**: Too frequent saves can impact performance, too slow loses data
- **Mitigation**: 500ms debounce with immediate save on navigation away
- **Testing**: Test rapid typing and abrupt app closure scenarios

### UX Considerations

**Consideration 1: First-Time User Experience**
- Provide helpful onboarding with sample data
- Use empty states with clear CTAs
- Progressively introduce features (don't overwhelm)

**Consideration 2: Offline-First Clarity**
- Users should never doubt that their data is saved
- Show immediate feedback for all actions
- Use auto-save exclusively (no manual save buttons)

**Consideration 3: Performance Perception**
- Use skeleton loaders instead of spinners
- Optimize for perceived performance (show UI immediately, load data after)
- Target <200ms for space switching

**Consideration 4: Accessibility from Day One**
- Build semantic structure from the start
- Test with screen readers during development
- Meet WCAG AA standards before launch

### Migration Path to Phase 2

**Preparing for Supabase Integration:**
- Use UUID for all IDs (compatible with Postgres)
- Include `syncStatus` field in models (not used yet, but ready)
- Repository pattern allows easy swap from Hive to Supabase
- Keep models simple and serializable (JSON-compatible)

**Data Migration Strategy:**
- Export Hive data to JSON format
- Import JSON to Supabase when user creates account
- Provide "Sync & Backup" feature in Phase 2

## Success Criteria

### Functional Requirements
- ✅ Users can create tasks, notes, and lists locally
- ✅ Users can organize items into spaces
- ✅ Users can switch between spaces quickly (<200ms)
- ✅ Users can complete tasks with checkbox toggle
- ✅ Users can edit and delete items
- ✅ Quick capture works with keyboard shortcut
- ✅ App works completely offline
- ✅ Data persists across app restarts

### Performance Requirements
- ✅ App launches in <2 seconds
- ✅ Space switching completes in <200ms
- ✅ Scrolling maintains 60fps with 100+ items
- ✅ Auto-save debounce works smoothly without data loss

### Quality Requirements
- ✅ Zero crashes during normal operation
- ✅ Passes accessibility audit (TalkBack, VoiceOver)
- ✅ WCAG AA color contrast compliance
- ✅ All interactive elements ≥44x44dp touch targets
- ✅ Widget test coverage >70% for core logic

### User Experience Requirements
- ✅ Clear visual distinction between item types (color border + icon)
- ✅ Intuitive navigation (bottom nav on mobile, sidebar on desktop)
- ✅ Helpful empty states guide users
- ✅ Confirmation for destructive actions only
- ✅ Loading states prevent perceived lag

## Next Phase Preview

**Phase 2: Supabase Backend & Sync** will introduce:
- Supabase CLI setup with local development
- Database schema migrations (items, spaces tables)
- Row-Level Security policies
- Authentication (email + OAuth providers)
- Real-time sync with conflict resolution
- Multi-device support

Phase 1 establishes the foundation that makes Phase 2 integration straightforward through the repository abstraction layer.

---

**Total Estimated Effort**: 3-4 weeks for single developer
**Priority**: P0 - Must complete before Phase 2
**Status**: Ready for implementation
