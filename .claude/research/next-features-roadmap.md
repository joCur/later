# Research: Next Features to Implement for Later App

## Executive Summary

Based on comprehensive market research, competitive analysis, and user expectations for 2025, this document identifies the most critical features to implement next for the Later app. The research prioritizes features that align with Later's core philosophy: flexible organization that adapts to users rather than forcing rigid structures.

**Key Findings:**
- **Must-Have Features**: Search/filter capabilities, tags/labels system, due dates/reminders, and markdown support for notes
- **High-Value Features**: Mobile widgets, keyboard shortcuts, and recurring tasks
- **Differentiating Features**: Smart capture with NLP, offline-first with conflict resolution, and collaborative spaces

The app currently has a solid foundation with Supabase cloud storage, Riverpod 3.0 state management, comprehensive localization, and a beautiful design system. The next phase should focus on essential productivity features that users expect while maintaining Later's unique flexible approach.

## Research Scope

### What Was Researched
- Industry standards for productivity apps in 2025
- User expectations from task management and note-taking applications
- Competitive analysis of leading apps (Todoist, Things 3, Notion, Bear, Obsidian)
- Mobile app trends including widgets, shortcuts, and voice features
- Current Later app architecture and capabilities
- Missing features based on product planning documentation

### What Was Explicitly Excluded
- Complex project management features (Gantt charts, dependencies)
- Team collaboration features (for now - noted as P2 priority)
- Advanced automation/workflow engines
- Third-party integrations (calendar, email, etc.)
- Monetization features (subscriptions, premium tiers)

### Research Methodology
- Web search for productivity app trends and best practices (2025)
- Analysis of competitor feature sets
- Review of Later's product documentation and user personas
- Examination of current codebase architecture
- Industry standards for mobile app development

## Current State Analysis

### Existing Implementation

**✅ Already Implemented:**
- Supabase cloud storage with authentication and RLS
- Three content types: Notes, TodoLists, and Lists (custom lists)
- Spaces for contextual organization
- Basic CRUD operations for all content types
- User-defined content ordering (drag-and-drop)
- Tag support in Note model (database-ready)
- Basic search functionality in NoteRepository (title/content search)
- Auto-save functionality with debouncing
- Comprehensive error handling with localization
- Riverpod 3.0 state management with Clean Architecture
- Beautiful gradient-based design system
- Full English and German localization
- 1195+ tests with >70% coverage

**❌ Missing Core Features:**
- **Search**: No unified search UI or cross-space search
- **Tags/Labels**: Tags exist in Note model but no UI implementation
- **Due Dates/Reminders**: No date/time tracking for tasks
- **Recurring Tasks**: No repeat patterns for tasks
- **Markdown Support**: Plain text only in notes
- **Filters**: No filtering by tags, dates, or status
- **Mobile Widgets**: No home screen widgets
- **Keyboard Shortcuts**: Limited keyboard navigation
- **Attachments**: No file/image support in notes
- **Archive/Trash**: No soft delete functionality
- **Natural Language Processing**: No smart task parsing
- **Subtasks**: No hierarchical task structure
- **Quick Capture**: Basic modal exists but limited functionality

### Technical Debt and Limitations

**Current Limitations:**
1. Tags are in the Note model but not exposed in UI or other content types
2. No date fields in any content models
3. No recurrence logic or pattern storage
4. No soft delete/archive system
5. No full-text search index
6. No attachment storage strategy
7. No reminder/notification system
8. Limited quick capture functionality

**Architecture Strengths:**
- Clean separation with feature-first architecture
- Supabase provides PostgreSQL full-text search capabilities
- Repository pattern makes adding fields straightforward
- Riverpod 3.0 supports reactive data updates
- Error handling system is robust and extensible
- Localization system is well-established

### Industry Standards

**Must-Have Features (2025 Baseline):**

1. **Search & Filter**
   - Full-text search across all content
   - Search by tags, dates, status
   - Sub-50ms response time for local search
   - Search preview with context

2. **Tags/Labels System**
   - Create, edit, delete tags
   - Tag filtering and search
   - Multi-tag support
   - Tag autocomplete
   - Tag colors for visual distinction

3. **Due Dates & Reminders**
   - Set due dates on tasks
   - Local notifications
   - Overdue indicators
   - Date-based filtering
   - "Today", "Tomorrow", "This Week" views

4. **Recurring Tasks**
   - Daily, weekly, monthly, yearly patterns
   - Custom recurrence (every N days)
   - Skip/reschedule instances
   - Completion handling

5. **Rich Text/Markdown**
   - Bold, italic, strikethrough
   - Headers, lists (bullet/numbered)
   - Code blocks, quotes
   - Links (clickable)
   - Markdown shortcuts

**High-Value Features:**

6. **Mobile Widgets**
   - Quick capture widget
   - Today's tasks widget
   - Specific space widget
   - Configurable size variants

7. **Keyboard Shortcuts**
   - Quick capture (global)
   - Navigation between spaces
   - Create new items by type
   - Search activation
   - Complete/archive items

8. **Subtasks/Checklist**
   - Nested task items
   - Progress tracking
   - Completion cascading options

9. **Archive & Trash**
   - Soft delete with 30-day retention
   - Archive for completed items
   - Restore functionality
   - Bulk operations

10. **Attachments**
    - Image uploads
    - File attachments
    - Preview in note view
    - Cloud storage integration

**Differentiating Features:**

11. **Natural Language Processing**
    - "Buy milk tomorrow at 5pm" → task with due date
    - Extract tags from text
    - Date/time parsing
    - Smart defaults based on context

12. **Offline-First Sync**
    - Already partially implemented
    - Needs conflict resolution UI
    - Sync queue visibility
    - Offline indicator

13. **Collaboration**
    - Share spaces with read/write permissions
    - Real-time updates for shared content
    - Presence indicators
    - Activity history

## Technical Analysis

### Approach 1: Search & Filter System

**Description:**
Implement comprehensive search and filtering capabilities across all content types. Uses PostgreSQL full-text search with Supabase's built-in capabilities.

**Pros:**
- Critical user expectation - users expect search in any productivity app
- Supabase provides robust full-text search out of the box
- Repository already has basic search implementation
- Scales well with content growth
- Can be implemented incrementally (basic → advanced)

**Cons:**
- Requires UI for search bar, results, and filters
- Need to handle search across multiple content types
- Performance optimization needed for large datasets
- Requires search index maintenance

**Use Cases:**
- Find specific note from months ago
- Filter tasks by due date range
- Search by tags across all spaces
- Quick navigation to any content

**Implementation Complexity:** Medium

**Code Example:**
```dart
// Enhanced search with filters
class SearchFilters {
  final String? query;
  final List<String>? tags;
  final DateRange? dateRange;
  final ContentType? type;
  final String? spaceId;
  final bool? completed;
}

Future<SearchResults> unifiedSearch(SearchFilters filters) async {
  // Query notes, todoLists, and lists repositories
  // Combine results with relevance scoring
  // Return unified results with type information
}
```

**Priority:** 🔴 **MUST HAVE** - P0

### Approach 2: Tags/Labels System

**Description:**
Complete tag implementation with UI for creating, managing, and filtering by tags across all content types.

**Pros:**
- Foundation already exists (tags in Note model)
- Essential for flexible organization
- Aligns with Later's "your way" philosophy
- Enhances search and filtering capabilities
- Low technical complexity

**Cons:**
- Need to add tags field to TodoList and List models
- Requires database migration
- UI design for tag management needed
- Tag autocomplete adds complexity

**Use Cases:**
- Organize notes by project/topic
- Filter work vs personal tasks
- Create ad-hoc categories without rigid structure
- Cross-space organization

**Implementation Complexity:** Low-Medium

**Code Example:**
```dart
// Add to TodoList and List models
class TodoList {
  final List<String> tags;
  // ... other fields
}

// Tag management
class TagService {
  Future<List<String>> getAllTags(String userId);
  Future<List<String>> suggestTags(String input);
  Future<void> renameTag(String oldTag, String newTag);
  Future<void> deleteTag(String tag);
}
```

**Priority:** 🔴 **MUST HAVE** - P0

### Approach 3: Due Dates & Reminders

**Description:**
Add date/time tracking to tasks with local notifications for reminders.

**Pros:**
- Core expectation for task management apps
- Differentiates TodoLists from Notes
- Enables "Today", "Upcoming" views
- Can leverage device notifications
- High user value

**Cons:**
- Requires database schema changes
- Notification permissions and handling
- Timezone management complexity
- Need background notification service
- Notification state management

**Use Cases:**
- Set deadline for project milestone
- Daily reminder for recurring task
- "Today" view for focus
- Overdue task tracking

**Implementation Complexity:** Medium-High

**Code Example:**
```dart
// Add to TodoList model
class TodoList {
  final DateTime? dueDate;
  final bool hasReminder;
  final Duration? reminderOffset; // e.g., 1 hour before

  bool get isOverdue =>
    dueDate != null &&
    dueDate!.isBefore(DateTime.now()) &&
    completedItemCount < totalItemCount;
}

// Notification service
class ReminderService {
  Future<void> scheduleReminder(String itemId, DateTime dueDate);
  Future<void> cancelReminder(String itemId);
  Future<void> rescheduleReminder(String itemId, DateTime newDate);
}
```

**Priority:** 🟡 **HIGH VALUE** - P1

### Approach 4: Markdown Support for Notes

**Description:**
Add rich text editing with markdown support to notes. Preview and edit modes.

**Pros:**
- Standard feature in note-taking apps (Bear, Obsidian, Notion)
- Enhances note quality and organization
- Markdown is transferable between apps
- Many Flutter packages available
- Improves note-taking experience significantly

**Cons:**
- Need to choose markdown editor package
- Preview vs edit mode complexity
- Storage considerations (markdown vs HTML)
- Potential formatting issues on paste
- Increased UI complexity

**Use Cases:**
- Structured meeting notes with headers
- Code snippets in documentation
- Formatted project briefs
- Checklists within notes

**Implementation Complexity:** Medium

**Recommended Package:** `flutter_markdown` + `markdown_editable_textinput`

**Alternative:** `flutter_quill` for WYSIWYG experience

**Priority:** 🟡 **HIGH VALUE** - P1

### Approach 5: Recurring Tasks

**Description:**
Add recurrence patterns to TodoLists with automatic instance generation.

**Pros:**
- High user value for routine tasks
- Competitive feature in task apps
- Reduces manual task creation
- Good for habits and routines

**Cons:**
- Complex recurrence logic (RRULE standard)
- Instance generation and management
- Edit behavior (this instance vs all)
- Database design considerations
- Skip/reschedule handling

**Use Cases:**
- Daily morning routine checklist
- Weekly team meeting tasks
- Monthly bill payment reminders
- Yearly tax filing tasks

**Implementation Complexity:** High

**Code Example:**
```dart
class RecurrencePattern {
  final RecurrenceType type; // daily, weekly, monthly, yearly, custom
  final int interval; // every N days/weeks/months
  final List<int>? weekdays; // for weekly: [1,3,5] = Mon/Wed/Fri
  final DateTime? endDate;
  final int? occurrences;
}

class TodoList {
  final RecurrencePattern? recurrence;
  final String? parentRecurrenceId; // for generated instances

  TodoList generateNextInstance();
}
```

**Priority:** 🟢 **NICE TO HAVE** - P1/P2

### Approach 6: Mobile Widgets

**Description:**
Add Flutter home screen widgets for quick access and capture.

**Pros:**
- 2025 trend - expected by mobile users
- Increases app engagement
- Quick capture without opening app
- Platform-native integration
- High perceived value

**Cons:**
- Platform-specific implementation (iOS/Android differ)
- Limited UI space and interaction
- Data sync considerations
- Testing complexity
- Maintenance overhead

**Use Cases:**
- Quick capture from home screen
- Today's task widget
- Space-specific widget
- Progress overview widget

**Implementation Complexity:** Medium-High

**Flutter Package:** `home_widget`

**Priority:** 🟢 **NICE TO HAVE** - P2

### Approach 7: Archive & Trash System

**Description:**
Implement soft delete with trash bin and archive for completed items.

**Pros:**
- Prevents accidental data loss
- Industry standard feature
- Reduces clutter while preserving data
- Simple to implement
- High user confidence

**Cons:**
- Storage overhead
- Cleanup logic needed (30-day auto-delete)
- UI for trash/archive views
- Restore functionality complexity
- Migration for existing data

**Use Cases:**
- Accidentally deleted important note
- Archive completed projects
- Clean up UI without losing history
- Restore mistakenly archived item

**Implementation Complexity:** Low-Medium

**Code Example:**
```dart
// Add to all content models
class Note {
  final bool isArchived;
  final bool isTrashed;
  final DateTime? trashedAt;
}

// Repository methods
Future<void> archive(String id);
Future<void> trash(String id);
Future<void> restore(String id);
Future<void> permanentDelete(String id);
Future<void> cleanupTrash(); // Delete items trashed > 30 days ago
```

**Priority:** 🟡 **HIGH VALUE** - P1

## Tools and Libraries

### Option 1: flutter_markdown

**Purpose:** Markdown rendering and editing for notes
**Maturity:** Production-ready (pub.dev score: 130)
**License:** BSD-3-Clause
**Community:** Active, maintained by Flutter team
**Integration Effort:** Low
**Key Features:**
- Markdown to widget rendering
- Syntax highlighting support
- Extensible with custom renderers
- Lightweight and performant

**Recommendation:** Use for markdown preview

### Option 2: flutter_quill

**Purpose:** Rich text editing with WYSIWYG experience
**Maturity:** Production-ready
**License:** MIT
**Community:** Large, active development
**Integration Effort:** Medium
**Key Features:**
- WYSIWYG rich text editor
- Toolbar with formatting options
- Custom embeds support
- Delta format storage

**Recommendation:** Consider for advanced note editing

### Option 3: flutter_local_notifications

**Purpose:** Local notifications for reminders and due dates
**Maturity:** Production-ready (most popular notification package)
**License:** BSD-3-Clause
**Community:** Very active, well-maintained
**Integration Effort:** Medium
**Key Features:**
- Cross-platform (iOS/Android)
- Scheduled notifications
- Custom actions
- Notification channels

**Recommendation:** Essential for reminders feature

### Option 4: home_widget

**Purpose:** Flutter home screen widgets
**Maturity:** Production-ready
**License:** MIT
**Community:** Active development
**Integration Effort:** High
**Key Features:**
- iOS and Android widget support
- Data sharing between app and widget
- Multiple widget sizes
- Update mechanisms

**Recommendation:** Best option for widget implementation

### Option 5: sqflite

**Purpose:** Local database for offline search index (if needed)
**Maturity:** Production-ready
**License:** MIT
**Community:** Very active, de facto standard
**Integration Effort:** Low
**Key Features:**
- SQLite wrapper for Flutter
- FTS5 full-text search support
- Transactions and batch operations
- Migration support

**Recommendation:** Consider for offline-first search optimization

### Option 6: drift (formerly moor)

**Purpose:** Type-safe database layer with FTS5 support
**Maturity:** Production-ready
**License:** MIT
**Community:** Active, well-documented
**Integration Effort:** Medium
**Key Features:**
- Type-safe SQL queries
- Built-in FTS5 support
- Migration system
- Reactive queries

**Recommendation:** Alternative to raw sqflite for complex search

## Implementation Considerations

### Technical Requirements

**Database Schema Changes:**

```sql
-- Add tags to todo_lists and lists tables
ALTER TABLE todo_lists ADD COLUMN tags TEXT[] DEFAULT '{}';
ALTER TABLE lists ADD COLUMN tags TEXT[] DEFAULT '{}';

-- Add date/reminder fields to todo_lists
ALTER TABLE todo_lists ADD COLUMN due_date TIMESTAMP;
ALTER TABLE todo_lists ADD COLUMN has_reminder BOOLEAN DEFAULT FALSE;
ALTER TABLE todo_lists ADD COLUMN reminder_offset INTERVAL;

-- Add recurrence fields
ALTER TABLE todo_lists ADD COLUMN recurrence_pattern JSONB;
ALTER TABLE todo_lists ADD COLUMN parent_recurrence_id UUID;

-- Add archive/trash fields to all content tables
ALTER TABLE notes ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
ALTER TABLE notes ADD COLUMN is_trashed BOOLEAN DEFAULT FALSE;
ALTER TABLE notes ADD COLUMN trashed_at TIMESTAMP;

ALTER TABLE todo_lists ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
ALTER TABLE todo_lists ADD COLUMN is_trashed BOOLEAN DEFAULT FALSE;
ALTER TABLE todo_lists ADD COLUMN trashed_at TIMESTAMP;

ALTER TABLE lists ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
ALTER TABLE lists ADD COLUMN is_trashed BOOLEAN DEFAULT FALSE;
ALTER TABLE lists ADD COLUMN trashed_at TIMESTAMP;

-- Create full-text search index (PostgreSQL)
CREATE INDEX notes_search_idx ON notes USING gin(to_tsvector('english', title || ' ' || COALESCE(content, '')));
CREATE INDEX todo_lists_search_idx ON todo_lists USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));
CREATE INDEX lists_search_idx ON lists USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- Create tags index for fast tag queries
CREATE INDEX notes_tags_idx ON notes USING gin(tags);
CREATE INDEX todo_lists_tags_idx ON todo_lists USING gin(tags);
CREATE INDEX lists_tags_idx ON lists USING gin(tags);
```

**Performance Implications:**
- Full-text search indexes increase database size but dramatically improve search speed
- GIN indexes for tags enable fast tag-based filtering
- Recurring task generation should be done lazily (on-demand) not batch pre-generation
- Widget updates should be throttled to avoid battery drain

**Scalability Considerations:**
- Search should support pagination for large result sets
- Tag autocomplete should limit results to top N most-used tags
- Archive/trash views should have separate queries to avoid loading deleted items
- Notification scheduling should handle device restart/timezone changes

**Security Aspects:**
- Notification content should not expose sensitive information in preview
- Shared spaces need proper RLS policies for tags and dates
- Widget data should be encrypted when stored for widget access
- Search queries should be sanitized to prevent injection

### Integration Points

**How It Fits with Existing Architecture:**

1. **Search System:**
   - New `SearchService` in core/services
   - Unified search UI in home screen or dedicated screen
   - Repository methods already support basic search - enhance them
   - Riverpod providers for search state management

2. **Tags System:**
   - Extend existing tag field in Note model to TodoList and List
   - New `TagService` for tag management
   - Tag UI components in design_system/molecules
   - Tag filtering in controllers

3. **Due Dates & Reminders:**
   - New fields in TodoList model
   - `ReminderService` for notification scheduling
   - Date picker components
   - Integration with existing theme system

4. **Markdown Support:**
   - Replace plain TextField in note detail screen
   - Add markdown preview mode
   - Toolbar for formatting
   - Preserve existing auto-save behavior

**Required Modifications:**
- Database migration for new fields
- Model updates for all affected entities
- Repository methods for new query patterns
- Controller updates for new state
- UI screens for new features
- Localization strings for new features

**API Changes Needed:**
- No external API changes (all Supabase-based)
- Repository interface additions (backwards compatible)
- New provider exports

**Database Impacts:**
- Multiple migrations needed
- Index creation for performance
- RLS policy updates for new fields
- Data migration strategy for existing users

### Risks and Mitigation

**Potential Challenges:**

1. **Database Migration Complexity**
   - Risk: Breaking existing data during migrations
   - Mitigation: Test migrations thoroughly in local Supabase, use transactions, provide rollback plan

2. **Search Performance at Scale**
   - Risk: Slow search with 100,000+ items
   - Mitigation: Use PostgreSQL full-text search, implement pagination, add proper indexes

3. **Notification Permission Denial**
   - Risk: Users deny notification permission, reminders don't work
   - Mitigation: Graceful fallback with in-app due date indicators, explain value clearly

4. **Widget Data Sync**
   - Risk: Widget shows stale data or fails to update
   - Mitigation: Use proper widget update mechanisms, handle app lifecycle events

5. **Markdown Rendering Performance**
   - Risk: Large notes with complex markdown slow down UI
   - Mitigation: Lazy loading for long notes, optimize markdown rendering, use RepaintBoundary

6. **Recurrence Logic Bugs**
   - Risk: Edge cases in date calculations (DST, timezones, month ends)
   - Mitigation: Use proven RRULE library or date-time utilities, extensive test coverage

7. **Tag Proliferation**
   - Risk: Users create too many tags, system becomes cluttered
   - Mitigation: Tag suggestions, merge/rename functionality, archive unused tags

**Risk Mitigation Strategies:**

- **Incremental Development:** Implement features in phases, validate each before moving on
- **Feature Flags:** Use Riverpod providers to toggle features during development
- **Comprehensive Testing:** Unit tests for business logic, widget tests for UI, integration tests for workflows
- **User Feedback:** Beta testing with early adopters, analytics for feature usage
- **Documentation:** Clear user guides for new features, in-app tutorials/tooltips
- **Fallback Options:** Graceful degradation when features aren't available (e.g., no notifications permission)

**Fallback Options:**

- Search: Fall back to basic filtering if full-text search fails
- Notifications: Show in-app banners/badges if system notifications unavailable
- Widgets: Provide shortcuts to open app if widget data sync fails
- Markdown: Fall back to plain text if rendering fails
- Recurrence: Allow manual copying of tasks if recurrence fails

## Recommendations

### Recommended Implementation Roadmap

#### Phase 1: Foundation Features (Sprint 1-2, ~4 weeks)

**Goal:** Establish core productivity features that users expect immediately.

**Features:**
1. **Tags/Labels System** (2 weeks)
   - Database migration for tags on TodoList and List
   - Tag management UI (create, edit, delete)
   - Tag chip display in cards
   - Tag filter chips in home screen
   - Tag autocomplete in forms
   - Localization strings

2. **Archive & Trash System** (1 week)
   - Database migration for archive/trash fields
   - Soft delete implementation in repositories
   - Archive/trash views in UI
   - Restore functionality
   - 30-day cleanup logic
   - Localization strings

3. **Enhanced Search UI** (1 week)
   - Search bar in home screen or app bar
   - Basic search results view
   - Search by content type filter
   - Search by tag filter
   - Clear/cancel search
   - Localization strings

**Why This Order:**
- Tags are low-complexity and high-value, build momentum
- Archive/trash prevents data loss anxiety for new users
- Search leverages tags and provides immediate value
- All three work together to improve organization significantly

**Success Metrics:**
- 80% of users create at least one tag
- 50% of users use tag filtering
- 60% of users use search feature
- 0 data loss incidents reported

#### Phase 2: Time Management (Sprint 3-4, ~4 weeks)

**Goal:** Add temporal awareness to tasks, making Later a complete task manager.

**Features:**
1. **Due Dates for TodoLists** (2 weeks)
   - Database migration for due_date field
   - Date picker UI component
   - "Today", "Upcoming", "Overdue" filter views
   - Date display in cards with visual indicators
   - Date-based sorting options
   - Localization strings

2. **Reminders & Notifications** (2 weeks)
   - Database migration for reminder fields
   - Notification permission request flow
   - Reminder scheduling with flutter_local_notifications
   - Notification tap handling
   - Notification settings screen
   - Background notification service
   - Localization strings

**Why This Order:**
- Due dates are simpler and provide value immediately
- Notifications build on due dates
- Both features work together for task management
- High user demand for these features

**Success Metrics:**
- 70% of todo lists have due dates
- 40% of users enable notifications
- 90% notification delivery success rate
- Increased daily active users

#### Phase 3: Content Enhancement (Sprint 5-6, ~4 weeks)

**Goal:** Improve note-taking and task capabilities with richer content.

**Features:**
1. **Markdown Support for Notes** (2 weeks)
   - Integrate flutter_markdown for preview
   - Add markdown editor with toolbar
   - Edit/preview mode toggle
   - Markdown shortcuts (**, __, ##)
   - Syntax highlighting for code blocks
   - Localization strings

2. **Subtasks/Checklists** (2 weeks)
   - Database migration for subtask support
   - Subtask model and repository
   - Nested task UI in detail view
   - Progress calculation (N of M completed)
   - Reordering subtasks
   - Localization strings

**Why This Order:**
- Markdown significantly improves note quality
- Subtasks complete the task management feature set
- Both enhance existing features rather than adding new concepts

**Success Metrics:**
- 50% of notes use markdown formatting
- 40% of todo lists have subtasks
- Increased session duration (richer content = more time in app)

#### Phase 4: Advanced Features (Sprint 7-8, ~4 weeks)

**Goal:** Add power user features and mobile-specific enhancements.

**Features:**
1. **Recurring Tasks** (2 weeks)
   - Database design for recurrence patterns
   - Recurrence model and logic
   - Recurrence picker UI (daily/weekly/monthly/custom)
   - Instance generation on-demand
   - Edit behavior (this vs all instances)
   - Skip/reschedule functionality
   - Localization strings

2. **Mobile Widgets** (2 weeks)
   - Integrate home_widget package
   - Quick capture widget
   - Today's tasks widget
   - Widget configuration screen
   - Widget data sync mechanism
   - Platform-specific implementations

**Why This Order:**
- Recurring tasks are complex but high-value for routine management
- Widgets increase app visibility and engagement
- Both are "nice to have" rather than essential
- Good time to add differentiation features

**Success Metrics:**
- 20% of users create recurring tasks
- 30% of users add at least one widget
- 15% of new items created via widget
- Increased app opens from widget taps

### Alternative Phased Approach (Faster MVP)

If resources are constrained or rapid iteration is preferred:

**Quick Wins (2 weeks):**
1. Tags on all content types (1 week)
2. Archive/trash system (0.5 week)
3. Basic search enhancements (0.5 week)

**High-Impact Features (4 weeks):**
1. Due dates (1 week)
2. Reminders (1 week)
3. Markdown support (2 weeks)

**Polish & Differentiate (4 weeks):**
1. Recurring tasks (2 weeks)
2. Mobile widgets (2 weeks)

## Success Validation Framework

### Key Performance Indicators

**Feature Adoption Metrics:**
- % of users who create tags
- % of users who set due dates
- % of users who enable notifications
- % of users who use markdown formatting
- % of users who create recurring tasks
- % of users who install widgets

**Engagement Metrics:**
- Items created per user per week (target: increase by 30%)
- Search queries per session (target: 2+ searches per power user session)
- Daily active users (target: increase by 40%)
- Session duration (target: increase by 25% with richer content)

**Quality Metrics:**
- Feature discovery rate (do users find new features?)
- Feature usage retention (do they keep using them?)
- Error rates for new features (target: <0.5%)
- Notification delivery success (target: >95%)
- Search result relevance (qualitative user feedback)

**Business Metrics:**
- User retention (target: 70% monthly retention)
- App store ratings (target: maintain 4.5+ stars)
- Net Promoter Score (target: 40+)
- Support tickets related to new features (target: <5%)

### User Feedback Mechanisms

**In-App Feedback:**
- Feature-specific feedback prompts after first use
- In-app feedback button with context
- Star rating prompt after positive interactions

**Analytics Tracking:**
- Feature usage events (tag created, search performed, etc.)
- User flow analysis (where do users get stuck?)
- A/B testing for UI variations
- Performance monitoring (search latency, app load time)

**User Research:**
- Beta testing program for early feature access
- User interviews after each phase
- Usability testing for complex features (recurrence, markdown)
- Community forum for feature requests and discussions

**Metrics Dashboard:**
- Real-time feature adoption tracking
- Cohort analysis for retention
- Funnel analysis for onboarding
- Crash reports and error logs

## References

### Documentation Sources
- Todoist Features: https://todoist.com/features
- Things 3 Guide: https://culturedcode.com/things/
- Notion Documentation: https://notion.so
- Bear App Features: https://bear.app
- Obsidian Features: https://obsidian.md

### Articles and Resources
- "7 Key Features of the Best Task Management Software" (Kroolo)
- "Top 10 Productivity Apps Tools in 2025" (scmGalaxy)
- "Best Markdown Note Taking Apps in 2025" (NotePlan)
- "Things 3 vs Todoist in 2025" (Medium)
- "Four Mobile App Trends Shaping Digital Experiences in 2025" (TELUS Digital)

### API and Library References
- Flutter Markdown: https://pub.dev/packages/flutter_markdown
- Flutter Quill: https://pub.dev/packages/flutter_quill
- Flutter Local Notifications: https://pub.dev/packages/flutter_local_notifications
- Home Widget: https://pub.dev/packages/home_widget
- Drift (Moor): https://drift.simonbinder.eu/
- Supabase Full-Text Search: https://supabase.com/docs/guides/database/full-text-search

### Internal Documentation
- Later Product Planning: `.claude/docs/project-documentation/product-manager-output.md`
- CLAUDE.md: Project development guidelines
- README.md: Project overview and architecture

## Appendix

### Additional Notes

**Development Sequence Considerations:**

1. **Tags First** - Provides immediate organization value with low complexity
2. **Search Enhancement** - Leverages tags, provides discoverability
3. **Archive/Trash** - Prevents anxiety about deleting content
4. **Due Dates** - Fundamental time management feature
5. **Reminders** - Natural extension of due dates
6. **Markdown** - Significantly improves note quality
7. **Subtasks** - Completes hierarchical task management
8. **Recurring Tasks** - Advanced feature for power users
9. **Widgets** - Mobile-specific enhancement for engagement

**Feature Interdependencies:**

```
Tags → Search (search by tags)
Due Dates → Reminders (remind before due date)
Due Dates → Recurring Tasks (recurring due dates)
Markdown → Subtasks (checklist in markdown vs separate subtasks)
Archive → Search (exclude archived from default search)
```

**Testing Strategy:**

- Unit tests for all business logic (repositories, services)
- Widget tests for new UI components
- Integration tests for feature workflows
- Performance tests for search with large datasets
- Notification tests on real devices (iOS/Android)
- Widget tests on real devices (platform-specific)
- Accessibility tests for screen reader support
- Localization tests for German translations

**Migration Strategy for Existing Users:**

1. Database migrations applied automatically on app update
2. New fields default to sensible values (tags: empty array, archived: false)
3. Existing data unaffected - backward compatible
4. Onboarding tooltips explain new features
5. Changelog/what's new screen on first launch after update

**Localization Considerations:**

All new features must include:
- English strings in `app_en.arb`
- German translations in `app_de.arb`
- Contextual tooltips and help text
- Error messages for failure cases
- Success messages for confirmations

**Design System Integration:**

- Tag chips use existing chip components with gradient colors
- Date pickers follow material design guidelines
- Search bar uses existing input components
- Markdown toolbar uses existing button styles
- Notification icons use existing icon set
- Widget UI matches app's gradient aesthetic

### Questions for Further Investigation

1. **Natural Language Processing:**
   - Should we implement NLP for quick capture? (e.g., "buy milk tomorrow")
   - Library options: custom regex vs. ML-based parsing
   - Accuracy expectations vs. manual entry

2. **Collaboration Features:**
   - Priority for shared spaces? (P2 in original plan)
   - Real-time sync requirements vs. eventual consistency
   - Permission model complexity

3. **Attachments:**
   - File upload strategy (Supabase Storage vs. other)
   - Image preview performance
   - Storage limits and quota management

4. **Voice Input:**
   - Voice-to-text for quick capture?
   - Platform APIs vs. third-party service
   - Privacy implications

5. **Calendar Integration:**
   - Sync tasks to device calendar?
   - Import events as tasks?
   - API complexity and permissions

6. **Templates:**
   - User-created templates for spaces/lists?
   - Pre-built template library?
   - Template marketplace?

7. **Automation:**
   - Rule-based task creation? (if X then Y)
   - Zapier/webhook integration?
   - Complexity vs. value

8. **Analytics:**
   - Productivity insights? (tasks completed, time spent)
   - Privacy concerns with tracking
   - Dashboard UI complexity

9. **Export/Import:**
   - Data portability (JSON, Markdown, CSV)
   - Import from competitors (Todoist, Things, Notion)
   - Format compatibility

10. **Offline Search:**
    - Local FTS5 index for faster offline search?
    - Sync overhead for maintaining index
    - Supabase full-text search sufficient?

### Related Topics Worth Exploring

- **Progressive Web App (PWA):** Is a web version needed alongside mobile?
- **Desktop Apps:** Mac/Windows desktop apps vs. mobile-first focus
- **Apple Watch/Wear OS:** Complications and quick actions
- **Siri/Google Assistant:** Voice shortcuts integration
- **Share Extensions:** Capture from other apps (iOS/Android share sheet)
- **URL Schemes:** Deep linking to specific spaces/items
- **Backup/Restore:** Manual backup to device/cloud
- **Dark Mode Refinement:** Ensure new features work well in dark mode
- **Accessibility:** Screen reader support for new features
- **Performance Optimization:** App launch time, memory usage, battery impact

---

## Conclusion

Based on comprehensive market research and user expectations for 2025, **the most critical features to implement next are:**

### Must-Have (P0) - Do These First
1. **Tags/Labels System** - Essential for flexible organization, low complexity
2. **Archive & Trash** - Prevents data loss anxiety, builds user trust
3. **Enhanced Search** - Critical for content discoverability at scale

### High-Value (P1) - Do These Next
4. **Due Dates** - Core task management feature, expected by users
5. **Reminders** - Natural extension of due dates, high engagement
6. **Markdown Support** - Standard for note-taking apps, improves content quality
7. **Subtasks** - Completes task management feature set

### Nice-to-Have (P2) - Do Later
8. **Recurring Tasks** - Power user feature, complex but valuable
9. **Mobile Widgets** - Increases engagement, follows 2025 mobile trends
10. **Attachments** - Enhances notes, but lower priority

**The recommended implementation order is:**
1. Phase 1 (4 weeks): Tags, Archive/Trash, Search UI
2. Phase 2 (4 weeks): Due Dates, Reminders
3. Phase 3 (4 weeks): Markdown, Subtasks
4. Phase 4 (4 weeks): Recurring Tasks, Widgets

This roadmap positions Later as a competitive productivity app while maintaining its unique flexible philosophy. The features align with industry standards, user expectations, and 2025 trends without compromising Later's core values of simplicity and user-owned organization.
