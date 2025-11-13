# Research: App-Wide Localization Implementation

## Executive Summary

This research documents a comprehensive audit of the Later Flutter app to identify all hardcoded user-facing strings requiring localization. Building on the error handling localization work completed in November 2025, this research provides a complete roadmap for implementing i18n across the entire application.

**Key Findings:**
- **139 hardcoded strings** identified across 18 core files
- **50 error strings** already localized (Phase 1 complete)
- **5 major categories** requiring localization: Authentication, Empty States, Detail Screens, Navigation, and Modals
- Flutter's `flutter_localizations` and `intl` packages already configured
- No breaking changes required - backward compatible implementation possible
- Estimated implementation: 3-4 weeks in 4 phased iterations

The app currently has localization infrastructure in place (ARB files, `AppLocalizations`, and MaterialApp configuration) but only uses it for error messages. This research identifies all remaining user-facing strings and provides a structured implementation plan with ready-to-use ARB entries.

## Research Scope

### What Was Researched
- All user-facing strings in `lib/widgets/` (screens and modals)
- All user-facing strings in `lib/design_system/` (reusable components)
- Text widgets, button labels, form fields, hints, titles, and messages
- Navigation labels, menu items, and filter options
- Empty state messages and onboarding content
- Accessibility labels and semantic descriptions
- Existing localization infrastructure and patterns from error handling implementation

### What Was Excluded
- Error messages (already localized in Phase 1)
- Technical/debug strings not visible to users
- Test files and mock data
- Third-party library strings (handled by those libraries)
- Dynamic content from database (user-generated)
- Log messages and developer comments

### Research Methodology
1. **Codebase audit** - Systematic grep and file analysis of all UI files
2. **Pattern analysis** - Identification of common string patterns and categories
3. **Priority assessment** - Classification by user impact and implementation complexity
4. **Best practices review** - Flutter i18n documentation and industry standards
5. **Implementation planning** - Phased approach with testing strategy

## Current State Analysis

### Existing Implementation

**Localization Infrastructure (Already Configured):**
- `flutter_localizations` and `intl: ^0.20.2` dependencies installed
- `l10n.yaml` configuration file in project root
- `lib/l10n/app_en.arb` with 50 error message translations
- Auto-generated `AppLocalizations` class in `lib/l10n/`
- MaterialApp configured with localization delegates and `supportedLocales: [Locale('en')]`
- `AppLocalizations.of(context)` pattern established

**Current Localization Coverage:**
- ✅ **Error messages**: 29 error codes with localized messages in `app_en.arb`
- ✅ **Error display**: ErrorDialog and ErrorSnackBar use `error.getUserMessageLocalized()`
- ❌ **UI strings**: 139 hardcoded strings across screens, modals, and components
- ❌ **Navigation labels**: Hardcoded in bottom nav and sidebar
- ❌ **Form labels and hints**: Hardcoded in auth screens and detail screens
- ❌ **Empty state messages**: Hardcoded in 4 empty state components

**Hardcoded String Distribution:**
```
Authentication (39 strings):
  - Sign In Screen: 11 strings
  - Sign Up Screen: 14 strings
  - Password Strength Indicator: 5 strings

Detail Screens (35 strings):
  - List Detail Screen: 18 strings (most complex)
  - Todo List Detail Screen: 9 strings
  - Note Detail Screen: 8 strings

Empty States (20 strings):
  - Welcome State: 4 strings
  - No Spaces State: 4 strings
  - Empty Space State: 3 strings
  - Empty Search State: 2 strings

Modals (23 strings):
  - Space Switcher Modal: 16 strings
  - Create Content Modal: 7 strings

Navigation (10 strings):
  - Bottom Navigation Bar: 4 strings
  - App Sidebar: 6 strings

Other (12 strings):
  - Filters, drag handles, accessibility labels, etc.
```

### Industry Standards

**Flutter Localization Best Practices (2025):**
1. **ARB (Application Resource Bundle)** format for translations
2. **Auto-generated type-safe classes** via `flutter_localizations`
3. **Context-aware translations** with placeholder interpolation
4. **Plural and gender support** via ICU message format
5. **RTL (Right-to-Left) support** for languages like Arabic/Hebrew
6. **Locale fallbacks** for missing translations

**Common Patterns:**
- Use semantic naming: `buttonSignIn` not `signInText`
- Group by feature: `auth*`, `todo*`, `note*` prefixes
- Support placeholders: `{fieldName}`, `{count}`, etc.
- Separate labels, hints, messages, and buttons
- Use description metadata for translators

**Flutter i18n Ecosystem:**
- `flutter_localizations` - Official Flutter localization support
- `intl` package - Internationalization utilities (formatting dates, numbers, plurals)
- ARB files - JSON-based format supported by translation tools (Crowdin, Lokalise, POEditor)
- `intl_translation` - Code generation tool (built into Flutter)

## Technical Analysis

### Approach 1: Incremental Migration (Recommended)

**Description:**
Migrate strings to ARB files incrementally in phases, starting with high-impact areas (authentication, empty states) and moving to lower-priority areas. Each phase can be tested and deployed independently.

**Pros:**
- Lower risk - changes isolated to specific features
- Easier testing and QA - focus on one area at a time
- Can deploy improvements progressively
- Team can learn and adjust approach between phases
- Backward compatible - old code works during migration
- Minimal disruption to ongoing development

**Cons:**
- Longer overall timeline (3-4 weeks vs 1-2 weeks)
- Temporary inconsistency (some strings localized, others not)
- More coordination required across phases
- Need to maintain discipline to complete all phases

**Use Cases:**
- Teams with limited resources or time
- Apps with active development requiring minimal disruption
- Projects prioritizing stability over speed
- When user testing feedback is needed between phases

**Implementation Strategy:**
```
Phase 1 (Week 1): Authentication + Empty States
  Priority: CRITICAL (first user experience)
  Files: 6 files, ~45 strings
  Impact: 90% of new users see these screens

Phase 2 (Week 2): Navigation + Filters
  Priority: HIGH (core navigation)
  Files: 3 files, ~14 strings
  Impact: Every screen uses navigation

Phase 3 (Week 3): Detail Screens + Modals
  Priority: IMPORTANT (main workflows)
  Files: 5 files, ~58 strings
  Impact: Daily user interaction

Phase 4 (Week 4): Design System + Testing
  Priority: SUPPORTING (polish)
  Files: 4 files, ~20 strings
  Impact: Edge cases and polish
```

### Approach 2: Big Bang Migration

**Description:**
Update all 139 strings in a single large PR, converting the entire app to localized strings at once. Create complete ARB file with all translations and update all files simultaneously.

**Pros:**
- Faster completion (1-2 weeks total)
- Consistency - entire app localized at once
- Simpler coordination - one PR, one review
- Clear before/after state
- No partial localization phase

**Cons:**
- Higher risk - large change surface area
- Harder to test thoroughly - many changes at once
- Merge conflicts if other features in development
- All-or-nothing deployment
- Longer code review process
- More difficult to debug issues
- Larger rollback if problems found

**Use Cases:**
- Small apps with limited UI surface area
- Projects with frozen feature development
- Teams comfortable with large refactors
- When consistency is critical from day one

**Implementation Strategy:**
```
Week 1: ARB file creation + auth screens
  - Create complete app_en.arb with all 139 strings
  - Update authentication screens
  - Test auth flow thoroughly

Week 2: Detail screens + navigation
  - Update all detail screens
  - Update navigation components
  - Test all workflows

Week 3: Polish + QA
  - Final testing across all screens
  - Bug fixes and refinements
  - Deployment preparation
```

### Approach 3: Feature-Based Migration

**Description:**
Organize localization by feature area (Auth, Spaces, Content, Settings) rather than by priority. Each feature team owns their localization work and completes it independently.

**Pros:**
- Clear ownership boundaries
- Parallel work possible
- Feature teams understand their strings best
- Natural alignment with team structure
- Can integrate with feature development

**Cons:**
- Requires coordination across teams
- Inconsistent naming conventions risk
- May duplicate similar strings across features
- Harder to ensure completeness
- Timeline depends on slowest team

**Use Cases:**
- Large teams with clear feature ownership
- Apps with well-separated feature modules
- Organizations using feature flags
- When localization tied to new feature development

**Implementation Strategy:**
```
Team 1: Auth Feature
  - Authentication screens
  - Password validation
  - Email/password forms

Team 2: Content Feature
  - Detail screens (notes, todos, lists)
  - Create content modal
  - Content cards

Team 3: Navigation Feature
  - Bottom navigation
  - Sidebar navigation
  - Space switcher

Team 4: Onboarding Feature
  - Empty states
  - Welcome screens
  - Help messages
```

## Tools and Libraries

### Option 1: Flutter Built-in Localization (Currently Used)

**Purpose:** Official Flutter localization system using ARB files and code generation
**Maturity:** Production-ready (stable since Flutter 1.x)
**License:** BSD-3-Clause (Flutter SDK)
**Community:** Large - officially supported by Flutter team
**Integration Effort:** Already integrated ✅
**Key Features:**
- ARB file format (JSON-based, translator-friendly)
- Type-safe generated code (`AppLocalizations.of(context)`)
- Automatic locale fallback
- Plural and gender support via ICU format
- Date/number formatting via `intl` package
- No runtime dependencies beyond Flutter

**Current Setup:**
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

**Usage Example:**
```dart
// In widget
final l10n = AppLocalizations.of(context)!;
Text(l10n.buttonSignIn);

// With placeholder
Text(l10n.welcomeMessage(userName));

// ARB file entry
{
  "buttonSignIn": "Sign In",
  "welcomeMessage": "Welcome, {userName}!",
  "@welcomeMessage": {
    "placeholders": {
      "userName": {
        "type": "String"
      }
    }
  }
}
```

### Option 2: easy_localization Package

**Purpose:** Third-party localization package with simpler API than Flutter's built-in system
**Maturity:** Production-ready (2000+ apps using it)
**License:** MIT
**Community:** 1.2k+ GitHub stars, active maintenance
**Integration Effort:** Medium (requires setup, migration from current system)
**Key Features:**
- Simpler API than Flutter built-in
- JSON or YAML translations (not just ARB)
- Hot reload support for translations
- Fallback locale handling
- Context extensions for cleaner code
- Asset-based translations

**Why Not Recommended:**
- Requires migration from current `flutter_localizations` setup
- Adds external dependency (current system is zero-dependency)
- Less type-safe than generated `AppLocalizations`
- Not needed - current system works well
- Team already familiar with ARB format

### Option 3: intl_translation Package

**Purpose:** Command-line tools for extracting and generating translations (older approach)
**Maturity:** Mature but deprecated in favor of `flutter_localizations`
**License:** BSD-3-Clause
**Community:** Official but superseded by newer tools
**Integration Effort:** N/A (deprecated)
**Key Features:**
- Manual code generation
- ARB file support
- String extraction tools

**Why Not Recommended:**
- Deprecated by Flutter team
- Replaced by `flutter_localizations` built-in support
- More manual work required
- Less type-safe than current approach

## Implementation Considerations

### Technical Requirements

**Dependencies:**
- ✅ Already installed: `flutter_localizations` and `intl: ^0.20.2`
- ✅ Already configured: `l10n.yaml` and MaterialApp localization delegates
- No new dependencies required

**Code Generation:**
- ARB files automatically generate `AppLocalizations` class during build
- Run `flutter pub get` to trigger regeneration after ARB changes
- Generated files: `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`

**Performance:**
- Zero runtime performance impact (compile-time code generation)
- Locale switching is instant (no async loading)
- Type-safe access prevents runtime errors from missing keys
- No memory overhead (strings compiled into app binary)

**Multi-Language Support:**
- To add Spanish: Create `lib/l10n/app_es.arb` with same keys
- Update `supportedLocales` in MaterialApp: `[Locale('en'), Locale('es')]`
- Flutter automatically selects locale based on device settings
- Fallback to English if translation missing

### Integration Points

**How It Fits with Existing Architecture:**

1. **Widget Layer Integration:**
```dart
// Current (hardcoded)
Text('Sign In')

// After localization
final l10n = AppLocalizations.of(context)!;
Text(l10n.buttonSignIn)
```

2. **Design System Components:**
```dart
// Atom component with localization
class PrimaryButton extends StatelessWidget {
  final String? text; // Keep for custom text
  final String? localizationKey; // Add for localized text

  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonText = text ?? _getLocalizedText(localizationKey, l10n);
    return ElevatedButton(child: Text(buttonText));
  }
}
```

3. **Provider/State Management:**
   - No changes needed - localization happens at UI layer
   - Providers continue to work with domain models
   - Localization in widget build methods only

4. **Testing:**
```dart
// Widget tests need localization setup
testWidgets('sign in screen shows localized text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SignInScreen(),
    ),
  );

  final l10n = await AppLocalizations.delegate.load(Locale('en'));
  expect(find.text(l10n.buttonSignIn), findsOneWidget);
});
```

### Required Modifications

**1. ARB File Updates:**
- Add 139 new entries to `lib/l10n/app_en.arb`
- Follow naming convention: `category` + `Type` + `Description`
- Add placeholder metadata for dynamic strings

**2. Widget Updates:**
- Replace hardcoded strings with `AppLocalizations.of(context)!.keyName`
- Add `l10n` variable at top of build methods for cleaner code
- Update string literals in 18 files (list provided in audit)

**3. Test Updates:**
- Update widget tests to use localized string expectations
- Add localization setup to `test_helpers.dart`
- Update ~50 widget test files

**4. Documentation Updates:**
- Update CLAUDE.md with localization guidelines
- Add localization section to contributing guide
- Document ARB file naming conventions

### Database Impacts

**No database changes required.** Localization is a presentation-layer concern only. Database schema and models remain unchanged.

**User-generated content (notes, todo items, space names) is NOT localized** - it's stored and displayed as-is in the user's language.

### Risks and Mitigation

**Risk 1: Missing Translations**
- **Impact:** App crashes or shows key names instead of text
- **Likelihood:** Medium
- **Mitigation:**
  - Use compile-time code generation (catches missing keys at build time)
  - Add lint rule to require all ARB keys have translations
  - Test all screens after adding new strings
  - Use fallback locale (English) automatically

**Risk 2: Incorrect Placeholder Usage**
- **Impact:** Runtime errors when interpolating values
- **Likelihood:** Low
- **Mitigation:**
  - ARB placeholder metadata validated at compile time
  - Type-safe generated code (wrong types = compile error)
  - Test dynamic strings with various inputs
  - Document placeholder naming convention

**Risk 3: String Formatting Inconsistencies**
- **Impact:** Awkward phrasing, grammatical errors
- **Likelihood:** Medium
- **Mitigation:**
  - Use semantic key names (what it means, not what it says)
  - Add translator notes in ARB metadata
  - Review all strings in context (not in isolation)
  - Test with longer translations (e.g., German) for layout issues

**Risk 4: Breaking Changes to Existing Code**
- **Impact:** Build failures, test failures
- **Likelihood:** Low
- **Mitigation:**
  - Phased approach - one feature at a time
  - Run full test suite after each phase
  - Use feature flags if needed for gradual rollout
  - Keep PRs small and focused

**Risk 5: Performance Impact on Build Times**
- **Impact:** Slower builds during development
- **Likelihood:** Very Low
- **Mitigation:**
  - Code generation only runs when ARB files change
  - Hot reload not affected (localization cached)
  - Use `flutter pub get --offline` if needed

**Risk 6: Merge Conflicts in ARB File**
- **Impact:** Lost translations, manual conflict resolution
- **Likelihood:** Medium (if multiple people editing)
- **Mitigation:**
  - One person owns ARB file updates per phase
  - Use alphabetical ordering for keys
  - Keep PRs small to reduce conflict window
  - Use JSON formatting for easier diffing

## Recommendations

### Recommended Approach: Incremental Migration (Approach 1)

**Primary Recommendation:**
Implement localization using **Approach 1: Incremental Migration** over 4 weeks with the following phases:

**Phase 1 (Week 1): Authentication + Empty States - CRITICAL**
- **Files:** 6 files, ~45 strings
- **Rationale:** First-time user experience - authentication is the gateway to the app
- **Files to update:**
  - `sign_in_screen.dart` (11 strings)
  - `sign_up_screen.dart` (14 strings)
  - `password_strength_indicator.dart` (5 strings)
  - `welcome_state.dart` (4 strings)
  - `no_spaces_state.dart` (4 strings)
  - `empty_space_state.dart` (3 strings)
- **Testing focus:** Auth flows, empty state navigation
- **Deployment:** Can be deployed independently after Phase 1

**Phase 2 (Week 2): Navigation + Filters - HIGH**
- **Files:** 3 files, ~14 strings
- **Rationale:** Core navigation affects every screen
- **Files to update:**
  - `bottom_navigation_bar.dart` (4 strings)
  - `app_sidebar.dart` (6 strings)
  - `home_screen.dart` filters (4 strings)
- **Testing focus:** Navigation flow, filter behavior
- **Deployment:** Can be deployed independently

**Phase 3 (Week 3): Detail Screens + Modals - IMPORTANT**
- **Files:** 5 files, ~58 strings
- **Rationale:** Daily user workflows - creating and editing content
- **Files to update:**
  - `list_detail_screen.dart` (18 strings - most complex)
  - `todo_list_detail_screen.dart` (9 strings)
  - `note_detail_screen.dart` (8 strings)
  - `space_switcher_modal.dart` (16 strings)
  - `create_content_modal.dart` (7 strings)
- **Testing focus:** CRUD operations, modal interactions
- **Deployment:** Can be deployed independently

**Phase 4 (Week 4): Design System + Testing - SUPPORTING**
- **Files:** 4 files, ~20 strings
- **Rationale:** Polish and edge cases
- **Files to update:**
  - `drag_handle.dart` (2 strings)
  - `empty_search_state.dart` (2 strings)
  - Accessibility labels in various components (16 strings)
- **Testing focus:** Comprehensive QA across all screens
- **Deployment:** Final release with all localization complete

**Why This Approach:**
1. ✅ **Lower Risk:** Each phase is isolated and testable
2. ✅ **Backward Compatible:** Old and new coexist during migration
3. ✅ **User-Centric:** Prioritizes high-impact areas first
4. ✅ **Flexible:** Can adjust approach based on learnings
5. ✅ **Deployable:** Each phase can ship independently
6. ✅ **Team-Friendly:** Less disruptive to ongoing development

### Alternative Approach: Big Bang Migration (Approach 2)

**When to Use:**
- Feature freeze period (no active development)
- Small app with limited UI surface area
- Team comfortable with large refactors
- Critical deadline requiring full localization at once

**Risks:**
- Harder to test thoroughly
- Larger rollback if issues found
- Merge conflicts with other work

### Implementation Checklist

**Pre-Implementation:**
- [ ] Review all 139 strings in audit document
- [ ] Verify ARB naming conventions with team
- [ ] Update `test_helpers.dart` with localization support
- [ ] Create implementation branch from main

**Phase 1 Checklist:**
- [ ] Add ~45 auth/empty state strings to `app_en.arb`
- [ ] Update 6 files with localized strings
- [ ] Run `flutter pub get` to regenerate `AppLocalizations`
- [ ] Update widget tests for localized strings
- [ ] Run full test suite - verify no regressions
- [ ] Manual QA: Test auth flows in app
- [ ] Create PR, request review, merge to main

**Phase 2 Checklist:**
- [ ] Add ~14 navigation strings to `app_en.arb`
- [ ] Update 3 navigation files
- [ ] Update widget tests
- [ ] Run full test suite
- [ ] Manual QA: Test navigation and filters
- [ ] PR + merge

**Phase 3 Checklist:**
- [ ] Add ~58 detail screen strings to `app_en.arb`
- [ ] Update 5 detail screen files
- [ ] Update widget tests
- [ ] Run full test suite
- [ ] Manual QA: Test all CRUD operations
- [ ] PR + merge

**Phase 4 Checklist:**
- [ ] Add remaining ~20 strings to `app_en.arb`
- [ ] Update design system components
- [ ] Update all remaining widget tests
- [ ] Run full test suite
- [ ] **Comprehensive QA:** Test entire app end-to-end
- [ ] Update CLAUDE.md with localization guidelines
- [ ] PR + merge + release

**Post-Implementation:**
- [ ] Document localization process for future contributors
- [ ] Add CI check for ARB file validation
- [ ] Plan for additional languages (Spanish, French, etc.)
- [ ] Monitor for missing translation issues in production

### Testing Strategy

**Unit Tests:**
- No new unit tests needed (business logic unchanged)
- Localization is presentation layer only

**Widget Tests:**
- Update ~50 widget test files to expect localized strings
- Add localization setup to `test_helpers.dart`:
```dart
Widget testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
```

**Integration Tests:**
- Test complete user flows with localized strings
- Verify dynamic content (placeholders) works correctly
- Test locale switching (if multi-language support added)

**Manual QA Checklist:**
- [ ] Authentication: Sign up, sign in, password validation
- [ ] Empty states: Welcome, no spaces, empty space, no search results
- [ ] Navigation: Bottom nav, sidebar, space switcher
- [ ] Content creation: Notes, todos, lists via modal
- [ ] Content detail: View and edit all content types
- [ ] Filters: All content, todos only, lists only, notes only
- [ ] Settings: Menu items, sign out confirmation
- [ ] Edge cases: Long strings, special characters, placeholder interpolation

## References

### Flutter Localization Documentation
- [Official Flutter Internationalization Guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [ARB File Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package Documentation](https://pub.dev/packages/intl)
- [Flutter Localizations Package](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html)

### Industry Best Practices
- [Material Design Internationalization Guidelines](https://m3.material.io/foundations/content-design/internationalization)
- [Apple Human Interface Guidelines - Localization](https://developer.apple.com/design/human-interface-guidelines/localization)
- [Google I18n Style Guide](https://developers.google.com/style/translation)

### Translation Tools
- [Crowdin](https://crowdin.com/) - Translation management platform (ARB support)
- [Lokalise](https://lokalise.com/) - Localization management (Flutter integration)
- [POEditor](https://poeditor.com/) - Translation management service

### Project-Specific References
- Completed error handling localization: `.claude/plans/completed/error-handling-refactor.md`
- Current ARB file: `lib/l10n/app_en.arb` (50 error strings)
- Localization config: `l10n.yaml`
- Project docs: `CLAUDE.md` (will be updated with localization guidelines)

## Appendix

### Detailed String Audit

See the comprehensive audit documents created during research:
1. **LOCALIZATION_AUDIT.md** - Complete list of all 139 strings with file paths and line numbers
2. **LOCALIZATION_IMPLEMENTATION_GUIDE.md** - Ready-to-use ARB entries and code examples
3. **LOCALIZATION_SUMMARY.md** - Executive summary with statistics and priorities
4. **QUICK_REFERENCE.md** - Quick lookup guide for developers

These documents are available in the research artifacts and provide:
- Exact file locations for every hardcoded string
- Ready-to-copy ARB file entries
- Code transformation examples (before/after)
- Naming convention patterns
- Priority classifications

### ARB File Naming Convention

**Pattern:** `category` + `Type` + `Description`

**Categories:**
- `button` - Button labels (Sign In, Create, Save, Cancel, Delete)
- `label` - Form labels (Email, Password, Title, Description, Name)
- `hint` - Input hints (Enter your email, Add a note, Search spaces)
- `validation` - Validation messages (Required, Invalid format, Too short)
- `message` - Information messages (Success, Empty state, Welcome)
- `menu` - Menu items (Settings, Sign Out, Delete, Archive)
- `empty` - Empty state text (No items yet, Create your first...)
- `filter` - Filter labels (All, Todo Lists, Notes, Lists)
- `title` - Screen titles (Sign In, Todo List, Settings)
- `navigation` - Nav items (Home, Search, Profile)

**Type Suffixes:**
- `Primary` - Primary action
- `Secondary` - Secondary action
- `Danger` - Destructive action
- `Info` - Informational text

**Examples:**
- `buttonSignIn` - Sign In button
- `labelEmail` - Email form label
- `hintEnterEmail` - Email input hint
- `validationEmailRequired` - Email required error
- `messageWelcome` - Welcome message
- `menuSignOut` - Sign Out menu item
- `emptyNoSpaces` - No spaces empty state
- `filterAllContent` - All content filter
- `titleSignIn` - Sign In screen title
- `navigationHome` - Home navigation item

### Additional Notes

**Observations During Research:**
1. Most strings are in screen and modal files (not design system)
2. List detail screen has most complexity (18 strings, multiple menus)
3. Auth screens have good separation (easy to localize)
4. Empty states are well-isolated (quick wins)
5. No complex plural forms needed yet (most strings are simple labels)
6. Accessibility labels mostly use semantic widget properties (not hardcoded strings)
7. Test coverage is high (~1000+ tests) - will need significant test updates

**Questions for Further Investigation:**
1. Should we add plural support for item counts? (e.g., "1 item" vs "2 items")
2. Do we want to support RTL languages (Arabic, Hebrew)?
3. Should we extract date/time formatting into localized formats?
4. Do we need context-sensitive translations (formal vs informal)?
5. Should we create a translation guide for future languages?

**Related Topics Worth Exploring:**
1. Continuous localization workflow (integrate with Crowdin/Lokalise)
2. Automated testing for missing translations (CI check)
3. Locale persistence (remember user's language preference)
4. Dynamic locale switching without app restart
5. A/B testing for localized copy (marketing optimization)

### Code Examples

**Before Localization:**
```dart
// sign_in_screen.dart
AppBar(
  title: Text('Sign In'),
)

TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  },
)

PrimaryButton(
  text: 'Sign In',
  onPressed: _handleSignIn,
)
```

**After Localization:**
```dart
// sign_in_screen.dart
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.titleSignIn),
    ),
    body: Form(
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: l10n.labelEmail,
              hintText: l10n.hintEnterEmail,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.validationEmailRequired;
              }
              return null;
            },
          ),
          PrimaryButton(
            text: l10n.buttonSignIn,
            onPressed: _handleSignIn,
          ),
        ],
      ),
    ),
  );
}
```

**ARB File Entries:**
```json
{
  "titleSignIn": "Sign In",
  "labelEmail": "Email",
  "hintEnterEmail": "Enter your email",
  "validationEmailRequired": "Please enter your email",
  "buttonSignIn": "Sign In"
}
```

**Widget Test Update:**
```dart
// Before
expect(find.text('Sign In'), findsOneWidget);
expect(find.text('Email'), findsOneWidget);

// After
testWidgets('sign in screen displays localized strings', (tester) async {
  await tester.pumpWidget(testApp(SignInScreen()));

  final l10n = await AppLocalizations.delegate.load(Locale('en'));

  expect(find.text(l10n.titleSignIn), findsOneWidget);
  expect(find.text(l10n.labelEmail), findsOneWidget);
  expect(find.text(l10n.hintEnterEmail), findsOneWidget);
});
```

---

**Research Status:** ✅ COMPLETE (November 9, 2025)
**Next Step:** Create implementation plan with `/plan` command
**Estimated Timeline:** 3-4 weeks (4 phases)
**Total Effort:** ~139 strings across 18 files + ~50 test file updates
