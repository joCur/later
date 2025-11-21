# Research: Due Dates & Reminders Implementation for Later App

## Executive Summary

This research focuses on implementing due dates and reminder notifications for the Later app, building upon the general roadmap findings. Due dates and reminders are **high-value P1 features** that are expected by users of task management apps in 2025. This feature will transform Later from a flexible organizer into a complete time-aware task management system.

**Key Findings:**
- **Due dates already exist** at the TodoItem level (database-ready) but not at the TodoList level
- **flutter_local_notifications** is the industry standard package with excellent timezone support
- **Two-level implementation** recommended: TodoList due dates + TodoItem due dates for flexibility
- **Notification permission UX** requires careful design with primer dialogs
- **Timezone handling** is critical for accurate notification delivery
- **Multiple reminder options** (at time, before time) align with user expectations

**Recommendation:** Implement a phased approach starting with TodoList due dates and basic reminders, then expand to TodoItem-level granularity and advanced reminder options.

## Research Scope

### What Was Researched
- Current Later app database schema and models (TodoList, TodoItem)
- TodoItem already has `due_date` field in database (since initial schema)
- flutter_local_notifications package capabilities and best practices
- Timezone handling patterns for cross-platform notifications
- Notification permission UX patterns and best practices (2025)
- Competitive analysis of reminder patterns (Todoist, Things 3, TickTick)
- Integration points with existing Later architecture
- Error handling for notification failures

### What Was Explicitly Excluded
- Recurring tasks (separate complex feature - Phase 4 in roadmap)
- Location-based reminders (out of scope for MVP)
- Smart AI-powered reminder suggestions (future enhancement)
- Calendar integration (third-party integration)
- SMS or email reminders (push notifications only)
- Collaboration/shared task reminders (Phase 2+ feature)

### Research Methodology
- Codebase analysis of existing data models and architecture
- Database schema examination (initial_schema.sql)
- Package documentation review (flutter_local_notifications via Context7)
- Web research on notification best practices (2025)
- UX pattern analysis for permission requests
- Industry standard analysis for task management reminders

## Current State Analysis

### Existing Implementation

**✅ Already Implemented:**
- **TodoItem model has `due_date` field** (DateTime?, line 55 in todo_item.dart)
- Database schema has `due_date TIMESTAMPTZ` column in `todo_items` table (line 48 in initial_schema.sql)
- TodoItem `fromJson`/`toJson` handles due_date serialization
- TodoItem `copyWith` includes `clearDueDate` parameter for explicit clearing
- Priority field exists for TodoItems (high/medium/low)
- Tags field exists for TodoItems (List<String>)
- Clean Architecture with feature-first organization
- Riverpod 3.0 state management
- Comprehensive error handling system with ErrorCode enum
- Localization system (English + German)

**❌ Missing for Due Dates & Reminders:**
- **No due date UI** for setting/editing dates on TodoItems or TodoLists
- **No TodoList-level due dates** (only TodoItems have this field)
- **No reminder/notification fields** in models or database
- **No notification service** or scheduling logic
- **No notification permissions** handling
- **No reminder offset configuration** (e.g., "remind 1 hour before")
- **No "Today", "Upcoming", "Overdue" views** in UI
- **No date picker components** in design system
- **No visual indicators** for due dates in cards
- **No notification settings** screen
- **No background notification service** setup

### Technical Debt and Limitations

**Current Limitations:**
1. TodoList model has no date-related fields (need migration)
2. No notification permission service exists
3. No flutter_local_notifications package installed
4. No timezone package installed for proper scheduling
5. No notification channel configuration for Android
6. No notification handlers for tap/dismiss actions
7. No pending notifications tracking
8. No notification cleanup on task completion/deletion

**Architecture Strengths:**
- Feature-first architecture makes adding notification feature straightforward
- Repository pattern allows easy model extension
- Riverpod providers can manage notification state reactively
- Error handling system ready for notification-specific errors
- Localization system ready for notification text

### Industry Standards

**Must-Have Features (2025 Task Management Apps):**

1. **Due Date Setting**
   - Date picker UI (native platform pickers)
   - Time picker UI (optional time component)
   - Natural language input (nice-to-have)
   - Quick shortcuts ("Today", "Tomorrow", "Next Week")
   - Clear/remove due date option

2. **Reminder/Notification Options**
   - At time of due date (default if time specified)
   - Before due date (15 min, 30 min, 1 hour, 1 day, custom)
   - Multiple reminders per task (advanced feature)
   - Recurring reminders for habits (requires recurrence feature)

3. **Visual Indicators**
   - Color coding: Green (upcoming), Yellow (today), Red (overdue)
   - Icon badges showing due date proximity
   - Subtle date display on cards
   - Prominent display in detail view

4. **Filtering & Views**
   - "Today" view - tasks due today
   - "Upcoming" view - tasks due in next 7 days
   - "Overdue" view - tasks past due date
   - Filter by date range
   - Sort by due date

5. **Notification Features**
   - Push notifications at reminder time
   - Notification tap opens task detail
   - Mark complete from notification (iOS/Android actions)
   - Snooze reminder option (advanced)
   - Notification history/log (advanced)

**High-Value UX Patterns:**

6. **Permission Request Flow**
   - **Primer dialog** before system permission request
   - Explain value proposition clearly
   - Show at optimal time (after user adds first due date)
   - Graceful fallback if permission denied

7. **Notification Content Design**
   - Clear task title
   - Due time if applicable
   - Space name for context
   - Action buttons (Complete, View)
   - No sensitive info in preview

8. **Settings & Preferences**
   - Enable/disable notifications globally
   - Default reminder offset preference
   - Notification sound customization
   - Quiet hours / Do Not Disturb respect
   - Per-space notification settings (advanced)

## Technical Analysis

### Approach 1: TodoList-Level Due Dates (Recommended First Phase)

**Description:**
Add due_date and reminder fields to the TodoList model, allowing entire lists to have deadlines. This is simpler than item-level dates and covers common use cases like project deadlines.

**Pros:**
- Simpler UI - one date picker in TodoList detail screen
- Common use case: "Complete this list by Friday"
- Less notification noise (one per list vs. many per list)
- Easier to implement initially
- Good for project/milestone tracking

**Cons:**
- Less granular than item-level due dates
- TodoItems already have due_date field (will be underutilized)
- Doesn't help with individual task deadlines within a list
- May require both list and item dates eventually

**Use Cases:**
- "Complete project proposal by Monday"
- "Finish vacation planning before trip date"
- "Team sprint ends Friday"

**Implementation Complexity:** Low-Medium

**Database Migration:**
```sql
-- Add due date and reminder fields to todo_lists table
ALTER TABLE todo_lists ADD COLUMN due_date TIMESTAMPTZ;
ALTER TABLE todo_lists ADD COLUMN has_reminder BOOLEAN DEFAULT false;
ALTER TABLE todo_lists ADD COLUMN reminder_offset_minutes INTEGER; -- e.g., 60 = 1 hour before

-- Create index for date-based queries
CREATE INDEX idx_todo_lists_due_date ON todo_lists(due_date) WHERE due_date IS NOT NULL;
```

**Model Changes:**
```dart
// In TodoList model
class TodoList {
  final DateTime? dueDate;
  final bool hasReminder;
  final int? reminderOffsetMinutes; // null = at time of due date

  bool get isOverdue =>
    dueDate != null &&
    dueDate!.isBefore(DateTime.now()) &&
    completedItemCount < totalItemCount;

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
           dueDate!.month == now.month &&
           dueDate!.day == now.day;
  }

  bool get isDueSoon {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final diff = dueDate!.difference(now);
    return diff.inHours > 0 && diff.inHours <= 24;
  }
}
```

**Priority:** 🟡 **HIGH VALUE** - P1 (Phase 2A)

---

### Approach 2: TodoItem-Level Due Dates (Existing Field Enhancement)

**Description:**
Utilize the existing `due_date` field in TodoItems and add UI + notifications for individual task deadlines. More granular control over task timing.

**Pros:**
- Field already exists in database (zero migration needed)
- Model already handles due_date serialization
- More granular control (each item has own deadline)
- Matches TodoItem's purpose (individual actionable tasks)
- Aligns with competitive apps (Todoist, Things 3)

**Cons:**
- More complex UI (date picker for each item)
- Potential for notification noise (many items = many notifications)
- TodoList cards need to show "next due item" aggregation
- More reminders to manage for users

**Use Cases:**
- "Call client tomorrow at 2pm"
- "Submit expense report by Friday"
- "Review PR before end of day"

**Implementation Complexity:** Low (field exists) to Medium (UI + notifications)

**Required Changes:**
- No database migration needed (field exists!)
- Add UI for setting due_date on TodoItem detail/edit
- Add reminder fields to TodoItem model (new migration)
- Implement notification scheduling per item
- Update TodoList cards to show "next due" summary

**Model Enhancement:**
```dart
// Extend TodoItem model
class TodoItem {
  // Existing fields
  final DateTime? dueDate; // Already exists!

  // New fields for reminders
  final bool hasReminder;
  final int? reminderOffsetMinutes;

  // Computed properties
  bool get isOverdue =>
    dueDate != null &&
    dueDate!.isBefore(DateTime.now()) &&
    !isCompleted;

  bool get isDueToday { /* same as TodoList */ }
  bool get isDueSoon { /* same as TodoList */ }
}
```

**Database Migration (for reminders only):**
```sql
-- Add reminder fields to todo_items table (due_date already exists!)
ALTER TABLE todo_items ADD COLUMN has_reminder BOOLEAN DEFAULT false;
ALTER TABLE todo_items ADD COLUMN reminder_offset_minutes INTEGER;

-- Index already exists for due_date queries
```

**Priority:** 🟡 **HIGH VALUE** - P1 (Phase 2B)

---

### Approach 3: Hybrid Two-Level Due Dates (Best Long-Term Solution)

**Description:**
Support due dates at BOTH TodoList level (for project deadlines) AND TodoItem level (for task deadlines). This provides maximum flexibility.

**Pros:**
- Covers all use cases (project + task deadlines)
- Users choose appropriate granularity
- TodoList due date can serve as default for items
- Most flexible approach
- Matches user mental models

**Cons:**
- Most complex implementation (two notification systems)
- UI needs to clarify list vs. item due dates
- Potential confusion (which date matters?)
- More settings to manage

**Use Cases:**
- Project due Monday (list date) with tasks due throughout week (item dates)
- Weekly review list (list date) with individual prep tasks (item dates)

**Implementation Complexity:** Medium-High

**Recommended Approach:**
1. Phase 2A: Implement TodoList due dates first (simpler MVP)
2. Phase 2B: Enable TodoItem due dates (field exists, add UI)
3. Phase 2C: Add intelligent aggregation (show most urgent date on cards)

**Priority:** 🟢 **NICE TO HAVE** - P1/P2 (Full implementation across phases)

---

## Notification Service Architecture

### Approach: ReminderService with flutter_local_notifications

**Package Selection:**
- **Primary:** flutter_local_notifications v19.1.0+ (latest stable)
- **Dependency:** timezone v0.10.1+ (required for scheduling)
- **Optional:** flutter_timezone v1.0.8+ (auto-detect device timezone)

**Service Structure:**

```dart
// lib/features/notifications/data/services/reminder_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class ReminderService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Initialization
  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize plugin with Android/iOS settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Use primer dialog
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notificationsPlugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Schedule reminder for TodoList
  Future<void> scheduleListReminder({
    required String listId,
    required String listName,
    required DateTime dueDate,
    int offsetMinutes = 0, // 0 = at time, 60 = 1 hour before, etc.
  }) async {
    final scheduledDate = dueDate.subtract(Duration(minutes: offsetMinutes));
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      listId.hashCode, // Unique notification ID
      listName,
      offsetMinutes == 0
        ? 'Due now'
        : 'Due in ${_formatOffset(offsetMinutes)}',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'later_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for tasks and lists',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'list:$listId', // For navigation on tap
    );
  }

  // Cancel reminder
  Future<void> cancelReminder(String itemId) async {
    await _notificationsPlugin.cancel(itemId.hashCode);
  }

  // Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  // Get pending reminders
  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate
      // e.g., "list:uuid" -> navigate to list detail
      // e.g., "item:uuid" -> navigate to item detail
    }
  }

  String _formatOffset(int minutes) {
    if (minutes < 60) return '$minutes minutes';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    final days = hours ~/ 24;
    return '$days ${days == 1 ? 'day' : 'days'}';
  }
}
```

**Riverpod Provider:**

```dart
// lib/features/notifications/data/services/providers.dart

@riverpod
ReminderService reminderService(Ref ref) {
  final service = ReminderService();
  // Initialize on first access
  service.initialize();
  return service;
}
```

---

## Notification Permission Handling

### Best Practice: Two-Phase Permission Request

**Phase 1: Primer Dialog (Custom UI)**

Show a custom dialog explaining the value BEFORE requesting system permission:

```dart
// lib/features/notifications/presentation/widgets/notification_primer_dialog.dart

class NotificationPrimerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.notificationPrimerTitle), // "Stay on Top of Your Tasks"
      content: Text(l10n.notificationPrimerMessage),
      // "Get reminded about upcoming tasks and deadlines so you never miss what matters."
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.buttonNotNow),
        ),
        PrimaryButton(
          text: l10n.buttonEnableNotifications,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
```

**Phase 2: System Permission Request (iOS/Android)**

Only after user accepts primer dialog:

```dart
// lib/features/notifications/application/services/notification_permission_service.dart

class NotificationPermissionService {
  final FlutterLocalNotificationsPlugin _plugin;

  Future<bool> requestPermission(BuildContext context) async {
    // Step 1: Show primer dialog
    final userAgreed = await showDialog<bool>(
      context: context,
      builder: (_) => NotificationPrimerDialog(),
    );

    if (userAgreed != true) return false;

    // Step 2: Request system permission
    if (Platform.isIOS) {
      final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      // Android 13+ requires runtime permission
      final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  Future<bool> checkPermission() async {
    // Check current permission status
    // Implementation depends on platform
  }
}
```

**When to Request Permission:**

1. **Optimal Timing:** When user first sets a due date with reminder enabled
2. **Not Immediately:** Never on first app launch (too pushy)
3. **Contextual:** After user shows intent to use reminders
4. **Frequency:** Only ask once per session if denied

**Graceful Fallback:**

If permission denied:
- Show in-app badges/indicators for due dates
- Display "Upcoming" section in home screen
- Show overdue banner at top of app
- Offer to re-enable in settings

---

## UI/UX Implementation

### Date Picker Component

**Design System Integration:**

```dart
// lib/design_system/molecules/date_time_picker.dart

class DateTimePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? initialTime;
  final ValueChanged<DateTime?> onDateChanged;
  final bool includeTime;

  // Uses Material DatePicker + TimePicker
  // Styled to match Later's gradient design
  // Quick shortcuts: Today, Tomorrow, Next Week
  // Clear button to remove date
}
```

**TodoList Detail Screen Integration:**

Add date section in TodoListDetailScreen:

```dart
// In lib/features/todo_lists/presentation/screens/todo_list_detail_screen.dart

// Add after title field
DateTimePicker(
  initialDate: todoList.dueDate,
  includeTime: true,
  onDateChanged: (date) {
    // Update TodoList due date
    // Prompt for reminder settings if date set
  },
)

// If date is set, show reminder toggle
if (todoList.dueDate != null)
  ReminderToggle(
    enabled: todoList.hasReminder,
    offsetMinutes: todoList.reminderOffsetMinutes,
    onChanged: (enabled, offset) {
      // Update reminder settings
      // Request notification permission if first time
    },
  )
```

### Visual Indicators

**Card Display:**

```dart
// In TodoListCard
if (todoList.dueDate != null)
  Row(
    children: [
      Icon(
        Icons.calendar_today,
        size: 14,
        color: _getDueDateColor(),
      ),
      SizedBox(width: 4),
      Text(
        _formatDueDate(),
        style: TextStyle(
          fontSize: 12,
          color: _getDueDateColor(),
          fontWeight: todoList.isOverdue ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  )

Color _getDueDateColor() {
  if (todoList.isOverdue) return Colors.red;
  if (todoList.isDueToday) return Colors.orange;
  if (todoList.isDueSoon) return Colors.amber;
  return Colors.grey;
}

String _formatDueDate() {
  final l10n = AppLocalizations.of(context)!;
  if (todoList.isOverdue) return l10n.overdue;
  if (todoList.isDueToday) return l10n.dueToday;
  // Otherwise: "Due Jan 15" or "Due Jan 15 at 3:00 PM"
}
```

### Filter Views

**Home Screen Filters:**

Add filter chips to ContentFilterController:

```dart
enum ContentFilter {
  all,
  notes,
  todoLists,
  lists,
  dueToday,      // NEW: Tasks due today
  upcoming,      // NEW: Tasks due within 7 days
  overdue,       // NEW: Tasks past due date
}
```

Implement filtering in TodoListsController:

```dart
Future<List<TodoList>> getFilteredLists(String spaceId, ContentFilter filter) async {
  final allLists = await repository.getBySpace(spaceId);

  switch (filter) {
    case ContentFilter.dueToday:
      return allLists.where((list) => list.isDueToday).toList();
    case ContentFilter.upcoming:
      return allLists.where((list) =>
        list.dueDate != null &&
        list.dueDate!.isAfter(DateTime.now()) &&
        list.dueDate!.isBefore(DateTime.now().add(Duration(days: 7)))
      ).toList();
    case ContentFilter.overdue:
      return allLists.where((list) => list.isOverdue).toList();
    default:
      return allLists;
  }
}
```

---

## Tools and Libraries

### Option 1: flutter_local_notifications (RECOMMENDED)

**Purpose:** Local push notifications with scheduling
**Maturity:** Production-ready (most popular Flutter notification package)
**License:** BSD-3-Clause
**Community:** Very active, maintained by MaikuB
**Integration Effort:** Medium
**pub.dev:** ^19.1.0 (latest stable)

**Key Features:**
- Cross-platform (iOS, Android, macOS, Linux, Windows)
- Scheduled notifications with exact timing
- Timezone-aware scheduling via `zonedSchedule()`
- Notification channels (Android)
- Custom actions (Complete, Snooze)
- Notification tap handling
- Pending notifications query
- Background execution support

**Why Recommended:**
- Industry standard for Flutter local notifications
- Excellent documentation and examples
- Active maintenance and community support
- Handles timezone complexities properly
- Works with Android 13+ permission requirements
- Supports exact alarms (critical for reminders)

**Installation:**
```yaml
dependencies:
  flutter_local_notifications: ^19.1.0
  timezone: ^0.10.1
```

---

### Option 2: timezone (REQUIRED DEPENDENCY)

**Purpose:** Timezone data and date/time calculations
**Maturity:** Production-ready (Dart team official package)
**License:** BSD-3-Clause
**Community:** Official Dart package
**Integration Effort:** Low
**pub.dev:** ^0.10.1

**Key Features:**
- Timezone database (IANA Time Zone Database)
- `TZDateTime` for timezone-aware dates
- DST (Daylight Saving Time) handling
- Location-based timezone conversion
- Required by flutter_local_notifications

**Why Required:**
- Ensures reminders fire at correct local time
- Handles DST transitions automatically
- Critical for accurate scheduling
- Prevents "remind at 2pm" issues when traveling

---

### Option 3: flutter_timezone (OPTIONAL)

**Purpose:** Auto-detect device timezone
**Maturity:** Production-ready
**License:** MIT
**Integration Effort:** Low
**pub.dev:** ^1.0.8

**Key Features:**
- Get device timezone name (e.g., "America/New_York")
- Platform-specific implementations
- Single method call

**Why Optional:**
- Convenience for auto-setting timezone
- Can use `DateTime.now().timeZoneName` instead
- Helpful but not critical

---

### Option 4: permission_handler (RECOMMENDED)

**Purpose:** Cross-platform permission handling
**Maturity:** Production-ready
**License:** MIT
**Community:** Very active
**Integration Effort:** Low
**pub.dev:** ^11.3.1

**Key Features:**
- Check permission status
- Request permissions
- Open app settings
- Handle multiple permission types
- Works with notification permissions

**Why Recommended:**
- Simplifies permission checking
- Provides consistent API across platforms
- Handles edge cases (denied, restricted, etc.)
- Good UX for permission settings navigation

---

## Implementation Considerations

### Technical Requirements

**1. Package Dependencies:**

```yaml
# pubspec.yaml additions
dependencies:
  flutter_local_notifications: ^19.1.0
  timezone: ^0.10.1
  permission_handler: ^11.3.1  # For permission checks
```

**2. Android Configuration:**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->

<!-- Add permissions above <application> tag -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/> <!-- Android 13+ -->

<!-- Add receivers inside <application> tag -->
<receiver
    android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />

<receiver
    android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
</receiver>
```

**3. iOS Configuration:**

No additional configuration needed beyond notification permissions request in code.

**4. Database Migrations:**

```sql
-- Migration: Add due dates to todo_lists (if implementing list-level dates)
-- File: supabase/migrations/YYYYMMDDHHMMSS_add_todo_list_due_dates.sql

ALTER TABLE todo_lists ADD COLUMN due_date TIMESTAMPTZ;
ALTER TABLE todo_lists ADD COLUMN has_reminder BOOLEAN DEFAULT false;
ALTER TABLE todo_lists ADD COLUMN reminder_offset_minutes INTEGER;

CREATE INDEX idx_todo_lists_due_date ON todo_lists(due_date)
WHERE due_date IS NOT NULL;

-- Migration: Add reminder fields to todo_items
-- File: supabase/migrations/YYYYMMDDHHMMSS_add_todo_item_reminders.sql

-- Note: due_date already exists in todo_items from initial schema!
ALTER TABLE todo_items ADD COLUMN has_reminder BOOLEAN DEFAULT false;
ALTER TABLE todo_items ADD COLUMN reminder_offset_minutes INTEGER;

-- Index already exists: idx_todo_items_list_sort
```

**5. Error Codes:**

Add new error codes to ErrorCode enum:

```dart
// lib/core/error/error_codes.dart

enum ErrorCode {
  // ... existing codes ...

  // Notification errors
  notificationPermissionDenied,
  notificationScheduleFailed,
  notificationCancelFailed,
  notificationInvalidDate,
  notificationTimezoneError,
}
```

Add localized error messages:

```json
// lib/l10n/app_en.arb
{
  "errorNotificationPermissionDenied": "Notification permission was denied. You can enable it in Settings.",
  "errorNotificationScheduleFailed": "Failed to schedule reminder. Please try again.",
  "errorNotificationInvalidDate": "Invalid due date. Please select a future date.",
}
```

---

### Performance Implications

**Notification Scheduling:**
- Scheduling a notification is nearly instantaneous (~1ms)
- Device handles actual firing in background (no app wake needed)
- Max pending notifications: 64 on iOS, unlimited on Android
- Recommendation: Cancel completed/deleted task notifications immediately

**Battery Impact:**
- Local notifications are battery-efficient (OS-managed)
- No network requests (unlike push notifications)
- `exactAllowWhileIdle` mode works around Android Doze

**Database Queries:**
- Adding due_date indexes keeps queries fast
- Filter queries (due today, overdue) are O(n) but n is small per space
- Consider caching due date filters in controller state

**UI Performance:**
- Date picker is lightweight Material component
- Visual indicators add minimal rendering overhead
- Use RepaintBoundary on cards if needed

---

### Scalability Considerations

**Notification Limits:**
- iOS: 64 pending notifications max
- Android: No practical limit
- Strategy: Prioritize nearest due dates, cancel old notifications

**Data Volume:**
- Due dates add 16 bytes per record (TIMESTAMPTZ)
- Reminder fields add ~8 bytes per record (BOOLEAN + INTEGER)
- Indexes add storage but improve query speed
- Minimal impact: 1000 tasks = ~24KB additional data

**Query Optimization:**
- Use indexes for date-based filtering
- Pagination for "upcoming" views if needed
- Cache filter results in controller state
- Invalidate cache on task completion/date change

---

### Security Aspects

**Notification Content:**
- ✅ DO: Show task title and due time
- ✅ DO: Show space name for context
- ❌ DON'T: Show task descriptions (may contain sensitive info)
- ❌ DON'T: Show more than 2 lines of text in preview

**Payload Data:**
- Use minimal payload: `"list:uuid"` or `"item:uuid"`
- Don't include user data in payload
- Validate payload on navigation

**Permission Handling:**
- Never force permission request
- Respect user's denial decision
- Provide clear value proposition

**RLS Policies:**
- Ensure due_date fields respect existing RLS policies
- No additional RLS changes needed (user_id already enforced)

---

### Integration Points

**How It Fits with Existing Architecture:**

1. **Feature Structure:**
   ```
   lib/features/notifications/
   ├── data/
   │   ├── services/
   │   │   ├── reminder_service.dart
   │   │   └── notification_permission_service.dart
   │   └── repositories/  (if needed for persistent settings)
   ├── application/
   │   └── providers.dart
   └── presentation/
       ├── widgets/
       │   ├── notification_primer_dialog.dart
       │   └── reminder_settings_widget.dart
       └── screens/
           └── notification_settings_screen.dart
   ```

2. **Controller Integration:**
   - TodoListsController schedules/cancels notifications on create/update/delete
   - TodoItemsController handles item-level notifications (if implemented)
   - Controllers call ReminderService via provider

3. **Repository Integration:**
   - No changes to repositories (just new fields in models)
   - Models handle serialization of new fields

4. **UI Integration:**
   - DateTimePicker in design_system/molecules
   - Date indicator in TodoListCard (molecules)
   - Filter chips in HomeScreen (organisms)

**Required Modifications:**

1. **Models:**
   - Extend TodoList with due date fields
   - Extend TodoItem with reminder fields
   - Update `copyWith`, `fromJson`, `toJson` methods

2. **Repositories:**
   - No logic changes (fields handled automatically)
   - Consider adding `getByDueDateRange()` query method

3. **Controllers:**
   - TodoListsController: Schedule notification on create/update
   - TodoListsController: Cancel notification on delete/complete
   - Add filter methods for due date views

4. **Design System:**
   - Create DateTimePicker molecule
   - Create ReminderSettings molecule
   - Update TodoListCard with date display

5. **Localization:**
   - Add notification-related strings (20-30 new keys)
   - Add error messages for notification failures
   - Add date formatting strings

**API Changes Needed:**

- No external API changes (Supabase handles new fields automatically)
- Repository interface additions:
  ```dart
  // Optional convenience methods
  Future<List<TodoList>> getListsDueToday(String spaceId);
  Future<List<TodoList>> getListsDueInRange(String spaceId, DateTime start, DateTime end);
  Future<List<TodoList>> getOverdueLists(String spaceId);
  ```

**Database Impacts:**

- 2 migrations needed (list dates + item reminders)
- 2 indexes created (list due_date)
- No breaking changes to existing data
- Backward compatible (null due dates allowed)

---

### Risks and Mitigation

**Potential Challenges:**

1. **Notification Permission Denied**
   - **Risk:** Users deny permission, reminders don't work
   - **Mitigation:**
     - Use primer dialog to explain value first
     - Graceful fallback to in-app indicators
     - Offer to re-enable in settings with clear instructions
     - Don't require notifications to use due dates

2. **Timezone Confusion**
   - **Risk:** Reminders fire at wrong time when traveling
   - **Mitigation:**
     - Always use `tz.TZDateTime` for scheduling
     - Initialize timezone database properly
     - Test with multiple timezones
     - Display due time in user's local timezone

3. **Android Doze Mode**
   - **Risk:** Notifications delayed when device idle
   - **Mitigation:**
     - Use `AndroidScheduleMode.exactAllowWhileIdle`
     - Request SCHEDULE_EXACT_ALARM permission
     - Explain to users why permission is needed

4. **iOS Notification Limit (64)**
   - **Risk:** Can't schedule all reminders if user has many tasks
   - **Mitigation:**
     - Prioritize nearest due dates
     - Schedule only next 7 days of reminders
     - Reschedule when app opens (replenish queue)

5. **Stale Notifications**
   - **Risk:** Notification fires after task completed
   - **Mitigation:**
     - Cancel notification immediately on task completion
     - Cancel notification on task deletion
     - Clean up stale notifications on app start

6. **Date Picker UX Confusion**
   - **Risk:** Users unclear on time component (date only vs. date+time)
   - **Mitigation:**
     - Clear UI labels ("Date" vs. "Date & Time")
     - Default to date-only reminders (9am local time)
     - Optional time picker toggle
     - Preview text: "Remind me on Jan 15 at 9:00 AM"

7. **Performance with Many Due Dates**
   - **Risk:** Slow queries when filtering by due date
   - **Mitigation:**
     - Use database indexes on due_date column
     - Implement pagination for large result sets
     - Cache filter results in controller state
     - Limit "upcoming" view to 7 days

**Risk Mitigation Strategies:**

- **Incremental Development:** Start with TodoList dates, then add TodoItem dates
- **Feature Flags:** Use Riverpod provider to toggle feature during development
- **Comprehensive Testing:**
  - Unit tests for date logic (isOverdue, isDueToday, etc.)
  - Widget tests for date picker UI
  - Integration tests for notification scheduling
  - Manual tests on real devices (iOS + Android)
  - Timezone tests (simulate travel)
- **User Feedback:** Beta test with early adopters, collect feedback on UX
- **Documentation:** In-app tutorial for first due date setup
- **Fallback Options:** Due dates work without notifications (in-app indicators)

**Fallback Options:**

- **No Notification Permission:** Show in-app "Due Today" section, badges, banners
- **Notification Failure:** Log error, show in-app message, allow retry
- **Timezone Error:** Fallback to device local time
- **Date Picker Error:** Fallback to text input for date

---

## Recommendations

### Recommended Implementation Roadmap

#### Phase 2A: TodoList Due Dates (Sprint 3, ~2 weeks)

**Goal:** Add due date capability to TodoLists with basic reminders

**Tasks:**
1. **Database Migration (Day 1)**
   - Create migration for todo_lists due date fields
   - Add indexes for performance
   - Test migration on local Supabase

2. **Package Installation (Day 1)**
   - Add flutter_local_notifications, timezone, permission_handler
   - Configure Android manifest
   - Test notification initialization

3. **Model Updates (Day 2)**
   - Extend TodoList model with due date fields
   - Update `copyWith`, `fromJson`, `toJson`
   - Add computed properties (isOverdue, isDueToday, isDueSoon)
   - Write model unit tests

4. **ReminderService Implementation (Days 3-4)**
   - Create ReminderService class
   - Implement initialize(), scheduleListReminder(), cancelReminder()
   - Create Riverpod provider
   - Write service unit tests

5. **Permission Service (Day 5)**
   - Create NotificationPermissionService
   - Implement primer dialog
   - Implement permission request flow
   - Write permission unit tests

6. **UI Components (Days 6-8)**
   - Create DateTimePicker molecule
   - Create ReminderSettings widget
   - Update TodoListDetailScreen with date picker
   - Add date display to TodoListCard
   - Write widget tests

7. **Controller Integration (Days 9-10)**
   - Update TodoListsController to schedule/cancel notifications
   - Add filter methods (getDueToday, getOverdue, etc.)
   - Update error handling for notification errors
   - Write controller unit tests

8. **Localization (Day 11)**
   - Add English strings for notifications, date labels, errors
   - Add German translations
   - Test with both locales

9. **Testing & Polish (Days 12-14)**
   - Integration tests for full flow
   - Test on real iOS + Android devices
   - Test timezone handling
   - Test permission denial flow
   - Fix bugs, polish UI

**Success Metrics:**
- Users can set due dates on TodoLists
- Notifications fire at correct times
- Permission flow has >70% acceptance rate
- Zero timezone-related bugs
- All tests passing (unit + integration)

---

#### Phase 2B: TodoItem Due Dates (Sprint 4, ~1 week)

**Goal:** Enable due dates at TodoItem granularity

**Tasks:**
1. **Database Migration (Day 1)**
   - Add reminder fields to todo_items (due_date already exists!)
   - Test migration

2. **Model Updates (Day 2)**
   - Extend TodoItem model with reminder fields
   - Update serialization methods
   - Add computed properties
   - Write model unit tests

3. **UI Components (Days 3-4)**
   - Add date picker to TodoItem edit/detail
   - Update TodoItemCard with date indicator
   - Add "Next Due" summary to TodoListCard

4. **Controller Integration (Day 5)**
   - Update TodoItemsController to schedule/cancel notifications
   - Update TodoListsController to show "next due item"

5. **Testing (Days 6-7)**
   - Integration tests
   - Device testing
   - Bug fixes

**Success Metrics:**
- Users can set due dates on individual TodoItems
- TodoList cards show "Next due: Jan 15 at 2pm"
- Notifications work correctly for items

---

#### Phase 2C: Advanced Features (Future Enhancement)

**Optional enhancements for later:**

1. **Multiple Reminders Per Task** (1 week)
   - Allow 2-3 reminders per task
   - UI for managing multiple reminders
   - Database: Change reminder_offset_minutes to JSONB array

2. **Snooze Functionality** (3 days)
   - Notification action to snooze
   - Reschedule reminder for 15 min, 1 hour, etc.

3. **Smart Reminder Suggestions** (1 week)
   - ML-based optimal reminder times
   - Based on user completion patterns
   - "Most users complete tasks like this in the morning"

4. **Recurring Reminders** (Depends on Recurring Tasks feature)
   - Daily/weekly reminder for recurring tasks
   - Separate from main Recurring Tasks implementation

5. **Location-Based Reminders** (2 weeks)
   - "Remind me when I arrive at office"
   - Requires geofencing package
   - Battery implications

---

### Alternative Phased Approach (Faster MVP)

If resources are constrained:

**Week 1: TodoList Due Dates (No Reminders)**
- Just add due_date field to TodoList
- Simple date picker UI
- Visual indicators (overdue, due today)
- No notifications yet

**Week 2: Basic Reminders**
- Add flutter_local_notifications
- Single reminder at due time (no offset)
- Simple permission request
- Basic notification scheduling

**Week 3: Polish + TodoItem Dates**
- Add reminder offset options (before due time)
- Primer dialog for permissions
- TodoItem due dates
- Filter views

---

## Success Validation Framework

### Key Performance Indicators

**Feature Adoption Metrics:**
- % of TodoLists with due dates set (target: 60%)
- % of TodoItems with due dates set (target: 40%)
- % of users who enable notifications (target: 50%)
- Average reminder offset chosen (insight metric)

**Engagement Metrics:**
- Daily active users increase (target: +20%)
- Tasks completed on due date (target: 70%)
- Notification tap-through rate (target: 40%)
- "Due Today" view usage (target: 50% of users)

**Quality Metrics:**
- Notification delivery success rate (target: >95%)
- Notification fired at correct time (target: >99%)
- Permission request acceptance rate (target: >60%)
- Crash rate related to notifications (target: <0.1%)

**User Satisfaction:**
- Feature discovery rate (do users find date picker?)
- Feature retention (do they keep using it after 1 week?)
- User feedback sentiment (app store reviews mentioning reminders)
- Support tickets related to notifications (target: <5%)

### User Feedback Mechanisms

**In-App Feedback:**
- Prompt after first due date set: "How was this experience?"
- Prompt after first notification received: "Did this reminder help?"
- In-app feedback button in notification settings

**Analytics Tracking:**
- Event: "due_date_set" (list vs. item, with_reminder: bool)
- Event: "notification_permission_requested"
- Event: "notification_permission_granted/denied"
- Event: "notification_received"
- Event: "notification_tapped"
- Event: "filter_applied" (due_today, upcoming, overdue)
- Event: "task_completed_on_due_date"

**User Research:**
- Beta test with 20-30 early adopters
- Post-feature survey: "What do you like/dislike about reminders?"
- User interviews: Observe date setting workflow
- A/B test reminder offset defaults (0 min vs. 1 hour)

**Metrics Dashboard:**
- Real-time notification delivery tracking
- Permission acceptance funnel
- Due date usage over time
- Most common reminder offsets
- Notification error logs

---

## References

### Documentation Sources
- flutter_local_notifications package: https://pub.dev/packages/flutter_local_notifications
- flutter_local_notifications README: https://github.com/MaikuB/flutter_local_notifications
- timezone package: https://pub.dev/packages/timezone
- permission_handler: https://pub.dev/packages/permission_handler
- Android notification best practices: https://developer.android.com/develop/ui/views/notifications
- iOS notification best practices: https://developer.apple.com/design/human-interface-guidelines/notifications

### Articles and Resources
- "Flutter Local Notifications: A Complete Guide" (dahalniranjan.com.np, 2025)
- "Handling Notification Permissions in Flutter for Android 13" (LinkedIn)
- "Privacy UX: Better Notifications And Permission Requests" (Smashing Magazine)
- "How to Use Local Notifications in Flutter" (FreeCodeCamp)
- "Scheduling Notifications with Local Notifications in Flutter" (Medium, FlutDev)

### API and Library References
- Context7 flutter_local_notifications docs (accessed via MCP)
- Later app CLAUDE.md architecture documentation
- Later app initial_schema.sql database schema
- Later app existing TodoItem model (with due_date field)

### Internal Documentation
- `.claude/research/next-features-roadmap.md` - General roadmap research
- `apps/later_mobile/lib/features/todo_lists/domain/models/todo_list.dart` - TodoList model
- `apps/later_mobile/lib/features/todo_lists/domain/models/todo_item.dart` - TodoItem model
- `supabase/migrations/20251103230632_initial_schema.sql` - Database schema
- `apps/later_mobile/lib/core/error/error_codes.dart` - Error handling system

---

## Appendix

### Additional Notes

**Implementation Sequence Rationale:**

1. **TodoList dates first** because:
   - Simpler user mental model (one date per project)
   - Fewer notifications to manage
   - Covers common use case (project deadlines)
   - Easier to test and validate

2. **TodoItem dates second** because:
   - Field already exists in database (lower risk)
   - Builds on proven notification system from Phase 2A
   - Provides granular control for power users
   - Can leverage existing UI patterns

3. **Advanced features last** because:
   - Core functionality must be stable first
   - User feedback informs advanced needs
   - Avoid over-engineering for unused features

**Notification Best Practices:**

- **Content:** Clear, concise, actionable (task title + due time)
- **Timing:** Respect user's reminder offset preference
- **Frequency:** One notification per task (no spam)
- **Actions:** Quick actions in notification (Complete, View)
- **Privacy:** No sensitive info in notification preview
- **Persistence:** Notification stays until dismissed or task completed

**Testing Strategy:**

- **Unit Tests:**
  - Model date logic (isOverdue, isDueToday, etc.)
  - ReminderService scheduling logic
  - Date formatting functions
  - Error handling for invalid dates

- **Widget Tests:**
  - DateTimePicker component
  - ReminderSettings widget
  - TodoListCard date display
  - Primer dialog

- **Integration Tests:**
  - Full flow: Set due date → Enable reminder → Receive notification
  - Permission request flow
  - Notification tap navigation
  - Filter views (due today, overdue)

- **Device Tests:**
  - iOS: Test notification permissions, appearance, tap handling
  - Android: Test notification channels, exact alarms, Doze mode
  - Timezone tests: Change device timezone, verify notification time
  - Background tests: Notification fires when app closed

**Migration Strategy:**

- Migrations are additive (no data loss risk)
- New fields nullable (backward compatible)
- Existing TodoItems with due_date unaffected
- No changes to existing RLS policies
- Users can continue using app without setting due dates

**Localization Requirements:**

All new features require both English and German strings:

- Date labels: "Due Date", "Reminder", "At time", "Before"
- Quick shortcuts: "Today", "Tomorrow", "Next Week", "Clear"
- Filter labels: "Due Today", "Upcoming", "Overdue"
- Notification text: "Due now", "Due in 1 hour", etc.
- Permission primer: Title, message, buttons
- Error messages: Permission denied, schedule failed, invalid date
- Settings: Notification preferences, default reminder offset

**Design System Integration:**

- DateTimePicker uses existing input styling (GlassTextField)
- Reminder settings use existing toggle/slider components
- Date indicators on cards use existing gradient color system
- Red (overdue), Orange (today), Amber (soon), Grey (later)
- Icons from existing icon set (Icons.calendar_today, Icons.alarm)
- Primer dialog uses existing AlertDialog styling

**Accessibility Considerations:**

- Date picker must work with screen readers (semantic labels)
- Date indicators must have sufficient color contrast
- Notification content must be readable by TalkBack/VoiceOver
- Quick shortcuts must have clear labels
- Error messages must announce via screen reader
- All interactive elements must meet 48×48px touch target size

---

### Questions for Further Investigation

1. **Natural Language Date Input:**
   - Should we support "tomorrow at 3pm" text parsing?
   - Library options: intl, dart_date, custom regex
   - Accuracy vs. complexity trade-off

2. **Calendar Sync:**
   - Should due dates sync to device calendar?
   - iOS/Android calendar APIs complexity
   - User permission implications

3. **Notification Grouping:**
   - Should multiple task reminders be grouped?
   - Android notification channels
   - User preference for grouping vs. separate

4. **Time Zone Edge Cases:**
   - What happens when user travels across timezones?
   - Should reminder reschedule to maintain local time?
   - Or maintain absolute UTC time?

5. **Recurring Task Reminders:**
   - How do reminders work for recurring tasks?
   - One notification per instance?
   - Or single notification that recreates task?

6. **List Completion vs. Item Completion:**
   - If TodoList has due date, what happens when all items complete?
   - Auto-mark list as complete?
   - Or require explicit list completion?

7. **Overdue Behavior:**
   - Should overdue tasks get repeated reminders?
   - Or just one notification at due time?
   - User preference for "nag mode"?

8. **Notification Sounds:**
   - Custom sound for task reminders?
   - Different sound for overdue tasks?
   - User customization?

9. **Batch Operations:**
   - "Set due date for all items in list"
   - "Set reminder for all tasks due this week"
   - Bulk date editing

10. **Analytics:**
    - Track notification effectiveness (tasks completed after notification)
    - Optimal reminder offset based on user behavior
    - Best times for task completion

---

### Related Topics Worth Exploring

- **Voice Input:** "Remind me to call John tomorrow" via Siri/Google Assistant
- **Apple Watch:** Complications showing upcoming tasks
- **Widgets:** Home screen widget showing "Due Today" count
- **Shortcuts:** iOS Shortcuts integration for quick task creation with due dates
- **Share Extension:** Capture from other apps with due date
- **Email Reminders:** Optional email reminder in addition to push (P3)
- **SMS Reminders:** Optional SMS for critical tasks (P3)
- **Desktop Notifications:** Mac/Windows desktop app with notifications
- **Web Push:** PWA with web push notifications
- **Task Dependencies:** "Remind me of Task B when Task A is complete"
- **Smart Scheduling:** AI suggests optimal due dates based on task complexity
- **Focus Mode:** "Hide overdue tasks during focus time"

---

## Conclusion

Due dates and reminders are **essential P1 features** for positioning Later as a competitive task management app in 2025. The implementation is well-supported by existing architecture and proven packages.

### Critical Success Factors

1. **Leverage Existing TodoItem.dueDate Field**
   - Field already exists in database and model
   - Zero migration risk for item-level dates
   - Focus on UI and notifications

2. **Use flutter_local_notifications**
   - Industry standard, production-ready
   - Excellent timezone support
   - Active maintenance and community

3. **Implement Two-Phase Permission Request**
   - Primer dialog BEFORE system permission
   - Explain value clearly
   - Results in >60% acceptance rate

4. **Start with TodoList Due Dates**
   - Simpler MVP, faster validation
   - Covers common use case (project deadlines)
   - Foundation for item-level dates

5. **Graceful Fallback Without Notifications**
   - Due dates work without permission
   - In-app indicators (badges, banners, filters)
   - Don't force notification requirement

### Recommended Implementation Order

**Phase 2A (2 weeks):** TodoList due dates + basic reminders
- Database migration for TodoList
- flutter_local_notifications setup
- Date picker UI
- Permission request with primer
- Basic notification scheduling

**Phase 2B (1 week):** TodoItem due dates
- Utilize existing due_date field
- Add reminder fields (migration)
- Item-level date picker
- Per-item notifications

**Phase 2C (Future):** Advanced features
- Multiple reminders
- Snooze functionality
- Smart suggestions
- Recurring reminders (depends on Recurring Tasks)

### Expected Impact

**User Value:**
- Never miss important deadlines
- Proactive task management (vs. reactive)
- Reduced mental load ("app will remind me")
- Better time awareness

**App Positioning:**
- Competitive with Todoist, Things 3, TickTick
- Essential feature for task management category
- Increases user retention and daily active usage
- Foundation for recurring tasks (Phase 4)

**Technical Foundation:**
- Notification system enables future features (widgets, watch, shortcuts)
- Date filtering enables productivity insights
- Permission service reusable for other permissions

This implementation will make Later a **complete time-aware task management system** while maintaining its core philosophy of flexible, user-owned organization.
