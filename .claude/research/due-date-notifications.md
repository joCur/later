# Research: Due Date Notifications for Todo Items

## Executive Summary

This research explores implementing local notifications for todo item due dates in the Later Flutter app. The recommended approach uses **flutter_local_notifications** with timezone-aware scheduling to notify users when tasks are due. This solution aligns with the app's offline-first architecture and requires minimal dependencies while providing reliable, platform-native notifications.

**Key Recommendations:**
- Use `flutter_local_notifications` (v17+) for local, timezone-aware notifications
- Implement a `NotificationService` following the existing repository pattern
- Schedule notifications when todo items with due dates are created/updated
- Handle Android 13+ exact alarm permissions appropriately
- Reschedule notifications on app startup and after device reboots

The implementation requires adding 3 dependencies (`flutter_local_notifications`, `timezone`, `permission_handler`), creating a notification service, and updating the `TodoListRepository` to integrate notification scheduling with todo item CRUD operations.

## Research Scope

### What Was Researched
- Local notification libraries for Flutter (flutter_local_notifications vs awesome_notifications)
- Timezone-aware notification scheduling approaches
- Platform-specific requirements (Android permissions, iOS background modes)
- Battery optimization and reliability considerations (Doze mode, background limitations)
- Architectural patterns for notification services in Flutter
- Integration with existing offline-first, Hive-based architecture

### What Was Explicitly Excluded
- Push notifications (Firebase Cloud Messaging) - not needed for offline-first approach
- Background task scheduling with WorkManager - unnecessary for simple due date notifications
- Server-side notification scheduling - app is currently local-only (Phase 1)
- Recurring/periodic notifications - todo items have specific due dates, not recurring patterns

### Research Methodology
- Analyzed current codebase architecture (Hive models, repository pattern, provider state management)
- Compared popular Flutter notification packages
- Reviewed official documentation and code examples for flutter_local_notifications
- Investigated platform-specific limitations and permission requirements
- Consulted architectural best practices for Flutter service layer integration

## Current State Analysis

### Existing Implementation

**Data Model:**
The `TodoItem` model already has a `dueDate` field (line 68-69 in `todo_list_model.dart`):
```dart
/// Optional due date for the todo item
@HiveField(4)
final DateTime? dueDate;
```

**Current Architecture:**
- **Data Layer**: Hive for local storage, repository pattern for data access
- **State Management**: Provider (not Riverpod/Bloc)
- **Existing Services**: `SpaceItemCountService` provides an example service pattern
- **Repository Pattern**: `TodoListRepository` handles CRUD operations for todo lists/items
- **Offline-First**: 100% local, no cloud sync (Phase 1)

**No Notification System:**
Currently, due dates are stored but there's no notification mechanism when they're reached. Users must manually check their todo lists to see overdue items.

### Industry Standards

**Local Notifications Best Practices (2025):**
- Use platform-native notification APIs for reliability and battery efficiency
- Request permissions explicitly and educate users on their importance
- Handle timezone changes and daylight saving time automatically
- Reschedule notifications after device reboots
- Allow users to customize notification preferences
- Keep notification messages clear and actionable
- Respect platform notification limits (iOS: 64 pending notifications max)
- Handle battery optimization modes gracefully

**Flutter-Specific Patterns:**
- Separate notification logic into a dedicated service class
- Use repository pattern to keep UI layer decoupled from notification scheduling
- Initialize notification service on app startup
- Store notification IDs to allow cancellation/rescheduling
- Test notification delivery on both Android and iOS thoroughly

## Technical Analysis

### Approach 1: flutter_local_notifications

**Description:**
The `flutter_local_notifications` package is a cross-platform plugin that translates native Android and iOS notification APIs into Flutter. It provides direct access to platform notification features with minimal abstraction, giving developers full control over notification behavior.

**Pros:**
- **Mature and well-maintained**: Most popular Flutter notification package, actively maintained
- **Direct platform API access**: Translates native functions, giving fine-grained control
- **Timezone-aware scheduling**: Built-in support via `zonedSchedule()` with timezone package
- **High trust score**: 9.4/10 with 94 code examples in Context7
- **Platform-native**: Uses AlarmManager on Android, UserNotifications on iOS
- **Minimal overhead**: No middleware layer, direct communication with platform APIs
- **Google-recommended**: Default choice for official Flutter samples

**Cons:**
- **More manual setup**: Requires platform-specific configuration (AndroidManifest, AppDelegate)
- **Less abstraction**: Developers handle platform differences explicitly
- **Permission management**: Requires separate `permission_handler` package or manual implementation
- **Platform-specific code**: Need to configure both Android and iOS separately

**Use Cases:**
- Apps requiring precise notification timing (alarm/reminder apps)
- Offline-first applications without cloud infrastructure
- Projects where developers want full control over notification behavior
- Apps with simple notification needs that don't require advanced features like badge management

**Code Example:**
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Schedule a notification at a specific time
await flutterLocalNotificationsPlugin.zonedSchedule(
  todoItem.id.hashCode, // Unique notification ID
  'Task Due: ${todoItem.title}',
  todoItem.description ?? 'Your task is due now',
  tz.TZDateTime.from(todoItem.dueDate!, tz.local),
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'due_date_channel',
      'Due Date Reminders',
      channelDescription: 'Notifications for task due dates',
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
  uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
);
```

### Approach 2: awesome_notifications

**Description:**
`awesome_notifications` provides a middleware layer between Flutter and native notification APIs, handling platform complexity automatically. It offers additional features like built-in badge management, notification interception, and handling manufacturer-specific Android differences.

**Pros:**
- **Feature-rich**: Badge management, notification grouping, advanced scheduling built-in
- **Handles platform complexity**: Abstracts differences between Android distributions (Samsung, Xiaomi, etc.)
- **Unified API**: More consistent across platforms, less platform-specific code
- **High trust score**: 9.2/10 with 113 code examples
- **Better middleware**: Automatically handles edge cases and manufacturer quirks

**Cons:**
- **Incompatible with other plugins**: Cannot coexist with flutter_local_notifications
- **Less frequent updates**: Maintained less actively than flutter_local_notifications
- **Licensing for cloud features**: FCM integration requires paid license (local notifications are free)
- **More opinionated**: Less control over low-level notification behavior
- **Larger package size**: Additional middleware adds overhead

**Use Cases:**
- Apps requiring advanced notification features (badges, rich media, complex grouping)
- Projects targeting many Android manufacturers (Samsung, Xiaomi, Huawei)
- Teams wanting less platform-specific configuration
- Apps planning to use cloud push notifications (with paid license)

**Code Example:**
```dart
import 'package:awesome_notifications/awesome_notifications.dart';

// Schedule a notification
await AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: todoItem.id.hashCode,
    channelKey: 'due_date_channel',
    title: 'Task Due: ${todoItem.title}',
    body: todoItem.description ?? 'Your task is due now',
    notificationLayout: NotificationLayout.Default,
  ),
  schedule: NotificationCalendar.fromDate(date: todoItem.dueDate!),
);
```

### Approach 3: WorkManager + Local Notifications

**Description:**
Combine `workmanager` package with `flutter_local_notifications` to schedule background tasks that check for due dates and trigger notifications. WorkManager wraps Android's WorkManager and iOS background fetch APIs.

**Pros:**
- **Survives app termination**: Can trigger notifications even when app is fully closed
- **Battery-optimized**: OS-managed background task scheduling
- **Flexible timing**: Can check for upcoming due dates periodically
- **Additional processing**: Can perform other background work when checking due dates

**Cons:**
- **Unpredictable timing**: OS controls when background tasks run, not exact timing
- **iOS limitations**: iOS severely restricts background task frequency and reliability
- **Complexity**: Requires two packages and additional coordination logic
- **Overkill for simple use case**: Unnecessary for straightforward due date notifications
- **Doze mode issues**: Android battery optimization may delay or skip background tasks

**Use Cases:**
- Apps requiring complex background processing beyond notifications
- Scenarios needing notification logic that depends on external factors
- Apps that need to perform multiple tasks when checking due dates
- Projects where exact timing is less critical than reliability

**Code Example:**
```dart
// Register background task
Workmanager().registerPeriodicTask(
  'check-due-dates',
  'checkDueDates',
  frequency: Duration(hours: 1),
);

// Background task handler
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Check Hive for upcoming due dates
    // Trigger notifications for due items
    return Future.value(true);
  });
}
```

## Tools and Libraries

### Option 1: flutter_local_notifications

- **Purpose**: Cross-platform local notification scheduling and display
- **Maturity**: Production-ready, v17+ (as of 2025)
- **License**: MIT License (fully open source)
- **Community**: Large and active, 5000+ stars on GitHub
- **Integration Effort**: Medium
  - Add 3 dependencies to pubspec.yaml
  - Configure AndroidManifest.xml (permissions, receivers)
  - Configure iOS AppDelegate
  - Initialize on app startup
  - Integrate with existing repository pattern
- **Key Features**:
  - Timezone-aware scheduling with `zonedSchedule()`
  - Platform-specific notification customization
  - Notification cancellation and management
  - Retrieve pending notification requests
  - Notification action handling
  - Support for notification channels (Android 8+)
  - Badge number management (iOS)

**Dependencies Required:**
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
  permission_handler: ^11.0.0
```

### Option 2: awesome_notifications

- **Purpose**: Feature-rich notification system with middleware abstraction
- **Maturity**: Production-ready, actively maintained
- **License**: Apache 2.0 (local notifications free, FCM requires paid license)
- **Community**: Medium-sized, active Discord community
- **Integration Effort**: Medium to High
  - Single package installation
  - Platform-specific configuration (less than flutter_local_notifications)
  - Initialize with notification channels
  - Conflicts with any existing notification plugins
- **Key Features**:
  - Badge management built-in
  - Notification interception and event handling
  - Manufacturer-specific Android handling
  - Rich notification layouts
  - Notification scheduling with various patterns
  - Notification grouping and threading

**Note**: Incompatible with flutter_local_notifications. Cannot be used together.

### Option 3: timezone Package (Required Companion)

- **Purpose**: Timezone database and datetime conversion for notification scheduling
- **Maturity**: Production-ready, maintained by Dart team
- **License**: BSD 3-Clause
- **Community**: Official Dart package, highly stable
- **Integration Effort**: Low
  - Add to dependencies
  - Initialize timezone database on app startup
  - Use `tz.TZDateTime` for scheduled notifications
- **Key Features**:
  - Complete timezone database
  - Daylight saving time handling
  - Timezone conversion utilities
  - Used by flutter_local_notifications for accurate scheduling

### Option 4: permission_handler

- **Purpose**: Request runtime permissions on Android and iOS
- **Maturity**: Production-ready, widely used
- **License**: MIT License
- **Community**: Large, 1500+ stars
- **Integration Effort**: Low
  - Add to dependencies
  - Request notification permissions before scheduling
  - Handle permission denial gracefully
- **Key Features**:
  - Unified permission API across platforms
  - Check current permission status
  - Request permissions with rationale
  - Open app settings for manual permission grant

## Implementation Considerations

### Technical Requirements

**Dependencies:**
- `flutter_local_notifications: ^17.0.0` (core notification functionality)
- `timezone: ^0.9.2` (timezone-aware scheduling)
- `permission_handler: ^11.0.0` (runtime permission management)

**Platform Configuration:**

**Android (AndroidManifest.xml):**
```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />

<!-- Notification receivers -->
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
</receiver>
```

**Android (build.gradle):**
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

**iOS (AppDelegate.swift):**
```swift
import UserNotifications

override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
  if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
  }
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

**iOS (Info.plist):** No additional configuration needed for basic local notifications.

**Performance Implications:**
- Scheduling notifications: <10ms per notification
- App startup initialization: ~50-100ms
- Memory footprint: Minimal (~1-2MB for notification service)
- Battery impact: Negligible (scheduled alarms are OS-managed)
- Storage: Notification IDs could be stored in Hive for management (optional)

**Scalability Considerations:**
- iOS limit: Maximum 64 pending notifications per app
- Android: No hard limit, but recommended to keep reasonable (<100)
- Strategy: Cancel/reschedule old notifications when creating new ones
- Recommendation: Limit to upcoming 30 days of due dates to stay under iOS limit

**Security Aspects:**
- Permissions requested at runtime, user can deny
- Notification content is stored locally on device
- No data transmission (offline-first architecture)
- Notification IDs derived from todo item IDs (deterministic)

### Integration Points

**How It Fits with Existing Architecture:**

1. **Service Layer**: Create `NotificationService` in `lib/core/services/`
   - Follows existing pattern (`SpaceItemCountService`)
   - Handles notification plugin initialization
   - Provides methods: `scheduleDueDateNotification()`, `cancelNotification()`, `cancelAllNotifications()`

2. **Repository Layer**: Update `TodoListRepository`
   - Call `NotificationService` when creating/updating todo items with due dates
   - Cancel notifications when todo items are completed or deleted
   - Reschedule notifications when due dates are changed

3. **Provider Layer**: `ContentProvider` remains unchanged
   - Repositories handle notification scheduling internally
   - UI layer remains decoupled from notification logic

4. **Initialization**: Update `main.dart`
   - Initialize timezone database
   - Initialize notification plugin
   - Request notification permissions

**Required Modifications:**

**File Structure:**
```
lib/
├── core/
│   └── services/
│       ├── space_item_count_service.dart (existing)
│       └── notification_service.dart (new)
├── data/
│   └── repositories/
│       └── todo_list_repository.dart (modify)
└── main.dart (modify)
```

**API Changes Needed:**
- No breaking changes to existing APIs
- `TodoListRepository` internally calls `NotificationService`
- Public repository methods remain the same

**Database Impacts:**
- No schema changes required
- Optional: Store notification IDs in TodoItem model for advanced management
- Due dates already exist in model

### Risks and Mitigation

**Potential Challenges:**

1. **Permission Denial**
   - **Risk**: Users may deny notification permissions
   - **Mitigation**:
     - Explain value of notifications before requesting permission
     - Gracefully handle denial (app still functions without notifications)
     - Provide in-app setting to re-request permissions via system settings

2. **Android 13+ Exact Alarm Restrictions**
   - **Risk**: Android 13+ requires special permission for exact alarms
   - **Mitigation**:
     - Use `SCHEDULE_EXACT_ALARM` permission with runtime request
     - Fallback to inexact scheduling if permission denied
     - Educate users on importance of exact timing for due dates

3. **iOS 64 Notification Limit**
   - **Risk**: Users with many scheduled tasks exceed iOS limit
   - **Mitigation**:
     - Only schedule notifications for next 30 days
     - Implement notification cleanup on app startup
     - Cancel old/completed todo notifications automatically

4. **Battery Optimization Interference**
   - **Risk**: Android Doze mode or manufacturer battery savers may delay notifications
   - **Mitigation**:
     - Use `exactAllowWhileIdle` scheduling mode
     - Guide users to whitelist app from battery optimization (optional)
     - Set realistic expectations for notification timing

5. **Timezone Changes**
   - **Risk**: Notifications scheduled for wrong time after timezone change
   - **Mitigation**:
     - Use `tz.TZDateTime` for timezone-aware scheduling
     - Store due dates in UTC in database
     - Reschedule notifications on app startup if timezone changed

6. **Device Reboot**
   - **Risk**: Scheduled notifications lost after device restart
   - **Mitigation**:
     - Configure boot receiver in AndroidManifest
     - Reschedule all pending notifications on app startup
     - Check for missed notifications on startup

**Risk Mitigation Strategies:**

- **Testing**: Thoroughly test on both platforms with various scenarios (Doze mode, timezone changes, reboots)
- **Graceful Degradation**: App remains fully functional even if notifications fail
- **User Control**: Provide settings to enable/disable due date notifications
- **Monitoring**: Log notification scheduling success/failure for debugging

**Fallback Options:**

1. **In-App Reminders**: Display overdue tasks prominently in UI if notifications fail
2. **Inexact Scheduling**: Fall back to inexact timing if exact alarm permission denied
3. **Manual Reschedule**: Provide manual "Reschedule Notifications" button in settings

## Recommendations

### Recommended Approach

**Primary Recommendation: flutter_local_notifications**

Use `flutter_local_notifications` with timezone-aware scheduling for the following reasons:

1. **Alignment with Architecture**:
   - Fits naturally with offline-first, local storage approach
   - No cloud infrastructure needed
   - Works seamlessly with existing Hive database

2. **Maturity and Reliability**:
   - Most popular and battle-tested Flutter notification package
   - Active maintenance and community support
   - High trust score (9.4/10) and extensive documentation

3. **Simplicity for Use Case**:
   - Due date notifications are straightforward: trigger at specific time
   - No need for advanced features (badges, rich media, complex grouping)
   - Direct platform API access provides predictable behavior

4. **Future-Proof**:
   - When Phase 2 adds Supabase sync, can integrate with push notifications separately
   - No conflicts with future cloud notification strategy
   - Flexible enough to add features later (snooze, recurring reminders)

**Alternative Approach If Constraints Change:**

If the project requires:
- **Advanced notification features** (rich media, complex grouping) → Consider `awesome_notifications`
- **Multi-manufacturer Android support** (extensive Samsung/Xiaomi testing) → Consider `awesome_notifications`
- **Cloud push + local notifications** → Consider `awesome_notifications` with paid license

**Phased Implementation Strategy:**

**Phase 1: Core Notification Setup (1-2 days)**
1. Add dependencies to pubspec.yaml
2. Configure Android permissions and receivers
3. Configure iOS AppDelegate
4. Create `NotificationService` with initialization and basic scheduling
5. Test notification display on both platforms

**Phase 2: Repository Integration (1 day)**
1. Update `TodoListRepository.createTodoList()` to schedule notifications
2. Update `TodoListRepository.updateTodoList()` to reschedule notifications
3. Handle notification cancellation on todo completion/deletion
4. Test CRUD operations trigger notifications correctly

**Phase 3: Permission Handling (1 day)**
1. Implement permission request flow in `main.dart`
2. Add UI to explain notification value before requesting
3. Handle permission denial gracefully
4. Add settings option to re-request permissions

**Phase 4: Robustness & Edge Cases (1-2 days)**
1. Implement notification rescheduling on app startup
2. Handle timezone changes
3. Implement iOS 64-notification limit management
4. Test battery optimization scenarios
5. Test device reboot notification persistence

**Phase 5: Polish & User Control (1 day)**
1. Add notification enable/disable toggle in settings
2. Implement notification time customization (e.g., notify 1 hour before due)
3. Add sound/vibration preferences
4. Test complete user flow

**Total Estimated Implementation Time: 5-7 days**

### Implementation Architecture

**Recommended Code Structure:**

```dart
// lib/core/services/notification_service.dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async { ... }
  static Future<bool> requestPermissions() async { ... }
  static Future<void> scheduleDueDateNotification(TodoItem item) async { ... }
  static Future<void> cancelNotification(String todoItemId) async { ... }
  static Future<void> rescheduleAllNotifications() async { ... }
}

// lib/data/repositories/todo_list_repository.dart (modified)
class TodoListRepository {
  Future<void> createTodoList(TodoList todoList) async {
    await _todoListBox.put(todoList.id, todoList);
    // Schedule notifications for items with due dates
    for (final item in todoList.items) {
      if (item.dueDate != null && !item.isCompleted) {
        await NotificationService.scheduleDueDateNotification(item);
      }
    }
  }
}
```

## References

- [flutter_local_notifications Package](https://pub.dev/packages/flutter_local_notifications)
- [flutter_local_notifications Official Documentation](https://github.com/MaikuB/flutter_local_notifications)
- [timezone Package](https://pub.dev/packages/timezone)
- [permission_handler Package](https://pub.dev/packages/permission_handler)
- [Android Exact Alarm Permissions](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms)
- [Android Doze Mode Documentation](https://developer.android.com/training/monitoring-device-state/doze-standby)
- [iOS UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [Flutter Repository Pattern Best Practices](https://codewithandrea.com/articles/flutter-repository-pattern/)
- [GeeksforGeeks: Schedule Local Notifications with Timezone](https://www.geeksforgeeks.org/flutter/flutter-schedule-local-notification-using-timezone/)

## Appendix

### Additional Notes

**Observations During Research:**

1. **Platform Fragmentation**: Android notification behavior varies significantly between manufacturers (Samsung, Xiaomi, OnePlus). Extensive real-device testing recommended.

2. **Permission UX**: Apps requesting notification permissions immediately on first launch have lower acceptance rates. Best practice: request after user creates their first todo with a due date.

3. **Android 14 Changes**: Google Play Store now restricts `USE_EXACT_ALARM` permission to specific use cases. Using `SCHEDULE_EXACT_ALARM` with runtime permission request is safer for app store approval.

4. **iOS Background Modes**: Local notifications don't require Background Modes entitlements. Only push notifications need additional configuration.

5. **Notification IDs**: Using `todoItem.id.hashCode` as notification ID ensures deterministic IDs for cancellation without storing them separately.

### Questions for Further Investigation

1. **User Preferences**: Should users be able to customize notification timing (e.g., notify 15 min, 1 hour, or 1 day before due date)?

2. **Recurring Reminders**: Should overdue tasks trigger repeated notifications until completed?

3. **Notification Actions**: Should notifications include quick actions (Complete Task, Snooze, View)?

4. **Sound Customization**: Should app provide custom notification sounds or use system defaults?

5. **Analytics**: Should app track notification effectiveness (open rate, completion after notification)?

### Related Topics Worth Exploring

1. **Phase 2 Integration**: How will local notifications integrate with Supabase cloud sync? Will server send push notifications or rely on local scheduling?

2. **Notification Grouping**: As user creates more tasks, should notifications be grouped by space or list?

3. **Smart Scheduling**: Could app analyze user behavior to determine optimal notification timing?

4. **Widget Integration**: Could due date information be displayed in home screen widgets alongside notifications?

5. **Wear OS/watchOS**: Future support for smartwatch notifications?
