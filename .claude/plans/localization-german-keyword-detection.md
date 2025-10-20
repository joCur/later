# Localization and German Keyword Detection Implementation Plan

## Objective and Scope

Implement Flutter's official localization system with support for English and German languages, including multilingual keyword detection for the item type detector. This will enable the Later Mobile app to automatically detect tasks, lists, and notes in both languages with culturally appropriate keyword matching.

**Scope:**
- Set up official Flutter localization infrastructure (`intl` + `flutter_localizations`)
- Create English and German ARB files for UI strings
- Implement hybrid keyword detection system with synonym support
- Refactor `ItemTypeDetector` to support multiple languages
- Establish translation workflow and testing framework

**Out of Scope:**
- Additional languages beyond English and German (Phase 1)
- Downloadable language packs
- Advanced NLP/ML-based detection
- Translation management platform integration

## Technical Approach and Reasoning

**Chosen Approach: Official Flutter Localization + Hybrid Keyword Strategy**

1. **Flutter's `intl` + `flutter_localizations`:**
   - Type-safe, compile-time checked translations
   - Official support with long-term stability
   - Excellent performance (build-time generation)
   - Already have `intl: ^0.19.0` in dependencies

2. **Hybrid Keyword Detection:**
   - ARB files for UI strings (type-safe)
   - Separate JSON files for keyword dictionaries with synonyms
   - Abstraction layer (`KeywordProvider`) for flexibility
   - Language-specific customization without tight coupling

3. **Why Not Alternatives:**
   - `easy_localization`: Lacks type safety, not future-proof
   - `slang`: Smaller community, less documentation
   - Full NLP: Overkill for keyword matching, performance overhead

## Implementation Phases

### Phase 1: Core Localization Infrastructure

**Goal: Set up Flutter localization framework with English as baseline**

- [ ] Task 1.1: Add dependencies and configuration
  - Add `flutter_localizations` to `pubspec.yaml` dependencies section (already have `intl: ^0.19.0`)
  - Add `generate: true` under `flutter:` section in `pubspec.yaml`
  - Create `l10n.yaml` in project root with configuration:
    ```yaml
    arb-dir: lib/l10n
    template-arb-file: app_en.arb
    output-localization-file: app_localizations.dart
    ```

- [ ] Task 1.2: Create directory structure and initial ARB files
  - Create `lib/l10n/` directory
  - Create `lib/l10n/app_en.arb` with initial English translations
  - Include all existing UI strings from the app (screens, buttons, labels)
  - Add metadata for each entry with descriptions
  - Run `flutter pub get` to trigger code generation
  - Verify generated files appear in `.dart_tool/flutter_gen/gen_l10n/`

- [ ] Task 1.3: Configure MaterialApp for localization
  - Import generated localizations in `main.dart`: `import 'package:flutter_gen/gen_l10n/app_localizations.dart';`
  - Add `localizationsDelegates: AppLocalizations.localizationsDelegates` to MaterialApp
  - Add `supportedLocales: AppLocalizations.supportedLocales` to MaterialApp
  - Remove any hardcoded locale settings
  - Test that app builds successfully

- [ ] Task 1.4: Create test to verify localization setup
  - Create `test/core/localization/localization_setup_test.dart`
  - Test that English locale loads correctly
  - Verify all required localizations are accessible
  - Test MaterialApp configuration

### Phase 2: Keyword Detection Abstraction Layer

**Goal: Refactor ItemTypeDetector to support multiple languages**

- [ ] Task 2.1: Design and implement KeywordProvider interface
  - Create `lib/core/localization/keyword_provider.dart`
  - Define abstract class `KeywordProvider` with methods:
    - `List<String> getActionVerbs()`
    - `List<String> getTimeIndicators()`
    - `List<String> getPriorityIndicators()`
    - `List<String> getListKeywords()`
    - `bool containsActionVerb(String word)`
    - `bool containsTimeIndicator(String word)`
    - `bool containsPriorityIndicator(String word)`
    - `bool containsListKeyword(String word)`
  - Add documentation explaining the interface purpose

- [ ] Task 2.2: Create JSON-based keyword provider implementation
  - Create `lib/core/localization/json_keyword_provider.dart`
  - Implement `JsonKeywordProvider` class extending `KeywordProvider`
  - Add constructor accepting `Locale` parameter
  - Implement asynchronous keyword loading from JSON files
  - Use Sets for O(1) lookup performance
  - Implement case-insensitive matching
  - Add error handling for missing files or malformed JSON
  - Cache loaded keywords to avoid repeated file reads

- [ ] Task 2.3: Create keyword JSON structure
  - Create `lib/l10n/keywords_en.json` with structure:
    ```json
    {
      "actionVerbs": {
        "purchase": ["buy", "purchase", "get", "acquire", "order"],
        "communicate": ["call", "phone", "contact", "ring", "reach out"],
        "transmit": ["send", "email", "mail", "forward", "deliver"],
        ...
      },
      "timeIndicators": {
        "today": ["today", "tonight", "this evening", "tonite"],
        "tomorrow": ["tomorrow", "tmrw", "next day"],
        ...
      },
      "priorityIndicators": ["urgent", "asap", "important", "critical", ...],
      "listKeywords": ["list", "items", "things to", "todo", ...]
    }
    ```
  - Extract all existing keywords from `item_type_detector.dart`
  - Add synonyms and colloquialisms for each keyword
  - Include common abbreviations and variations

- [ ] Task 2.4: Refactor ItemTypeDetector to use KeywordProvider
  - Modify `lib/core/utils/item_type_detector.dart`
  - Add `KeywordProvider` as a required parameter to constructor
  - Replace all hardcoded keyword lists with provider method calls
  - Update `detectType()` method to use provider's contains methods
  - Maintain existing scoring algorithms and confidence calculations
  - Update `_hasActionVerb()`, `_hasTimeIndicator()`, etc. to use provider
  - Keep date extraction and list parsing logic unchanged initially

- [ ] Task 2.5: Create factory for easy instantiation
  - Create `lib/core/localization/keyword_provider_factory.dart`
  - Implement singleton pattern for keyword providers per locale
  - Add `KeywordProviderFactory.forLocale(Locale locale)` method
  - Cache providers to avoid repeated JSON loading
  - Preload English provider at app startup

- [ ] Task 2.6: Update existing tests
  - Update all tests in `test/core/utils/item_type_detector_test.dart`
  - Create mock `KeywordProvider` for testing
  - Ensure all existing tests pass with new architecture
  - Add parameterized tests to run same tests with different providers

### Phase 3: German Language Support

**Goal: Add complete German translation with keyword detection**

- [ ] Task 3.1: Create German ARB file
  - Create `lib/l10n/app_de.arb`
  - Translate all strings from `app_en.arb` to German
  - Ensure grammatical correctness and cultural appropriateness
  - Add metadata and descriptions in German
  - Consider formal vs. informal address ("Sie" vs. "du")
  - Run `flutter pub get` to generate German localizations
  - Verify German locale appears in supported locales

- [ ] Task 3.2: Research German task management keywords
  - Research common German action verbs for tasks
  - Identify German time indicators and their variations
  - Research German priority indicators
  - Consult German productivity apps for keyword inspiration
  - Consider Austrian and Swiss German variations where relevant
  - Document findings with cultural notes

- [ ] Task 3.3: Create German keyword dictionary
  - Create `lib/l10n/keywords_de.json`
  - Populate with German equivalents of all English keywords
  - Add German-specific synonyms and colloquialisms:
    ```json
    {
      "actionVerbs": {
        "purchase": ["kaufen", "besorgen", "holen", "erwerben", "bestellen"],
        "communicate": ["anrufen", "telefonieren", "kontaktieren", "erreichen"],
        "transmit": ["senden", "schicken", "mailen", "zusenden", "verschicken"],
        ...
      },
      "timeIndicators": {
        "today": ["heute", "heute abend"],
        "tomorrow": ["morgen"],
        "thisWeek": ["diese woche", "bis freitag", "vor dem wochenende"],
        ...
      },
      ...
    }
    ```
  - Include compound nouns common in German
  - Add formal and informal variations where applicable

- [ ] Task 3.4: Implement locale detection and selection
  - Add device locale detection in `main.dart`
  - Create language selection UI component: `lib/widgets/settings/language_selector.dart`
  - Store user's language preference using shared_preferences
  - Add language option to settings screen
  - Implement MaterialApp locale override based on user preference
  - Add visual indicators (flags or language codes) for available languages

- [ ] Task 3.5: Update ItemsProvider to use locale-specific detection
  - Modify `lib/providers/items_provider.dart`
  - Access current locale from context or app state
  - Initialize `ItemTypeDetector` with appropriate `KeywordProvider`
  - Ensure detection happens with user's selected language
  - Update detection when user changes language

- [ ] Task 3.6: Create comprehensive German tests
  - Create `test/core/localization/german_keyword_detection_test.dart`
  - Test German keyword matching for all categories
  - Test German item type detection end-to-end
  - Include edge cases: compound words, umlauts, eszett (ß)
  - Test mixed-language content handling
  - Verify confidence scores are reasonable for German

### Phase 4: Testing and Optimization

**Goal: Ensure quality, performance, and user experience**

- [ ] Task 4.1: Create integration tests for localization
  - Create `test/integration/localization_integration_test.dart`
  - Test language switching flow
  - Verify UI updates when language changes
  - Test that detection uses correct language
  - Test persistence of language preference
  - Test fallback to English when translation missing

- [ ] Task 4.2: Performance testing and optimization
  - Profile keyword lookup performance for both languages
  - Measure memory usage of keyword dictionaries
  - Implement lazy loading if needed
  - Add benchmarks: `test/performance/keyword_detection_benchmark.dart`
  - Ensure detection latency < 50ms
  - Optimize Set operations if bottlenecks found

- [ ] Task 4.3: Add keyword coverage analytics
  - Implement detection confidence logging (dev mode only)
  - Track which keywords are matched most frequently
  - Identify detection failures (low confidence scores)
  - Create analytics helper: `lib/core/utils/detection_analytics.dart`
  - Use findings to improve keyword dictionaries

- [ ] Task 4.4: User testing with German speakers
  - Conduct user testing sessions with native German speakers
  - Test various task creation scenarios
  - Gather feedback on detection accuracy
  - Identify missed keywords or false positives
  - Document cultural differences in task phrasing
  - Iterate on keyword dictionary based on feedback

- [ ] Task 4.5: Documentation and developer guidelines
  - Create translation guidelines: `.claude/docs/translation-guidelines.md`
  - Document keyword research methodology
  - Create guide for adding new languages
  - Document testing procedures for new languages
  - Add inline code documentation
  - Update README with localization information

### Phase 5: Polish and Future-Proofing

**Goal: Finalize implementation and prepare for expansion**

- [ ] Task 5.1: Implement graceful fallbacks
  - Add fallback to English for missing translations
  - Handle malformed keyword JSON files gracefully
  - Provide user-friendly error messages
  - Log localization errors for debugging
  - Test app behavior with corrupted language files

- [ ] Task 5.2: Add keyword dictionary validation
  - Create validation script: `scripts/validate_keywords.dart`
  - Check for empty keyword lists
  - Verify JSON structure consistency across languages
  - Identify duplicate keywords
  - Run validation in CI/CD pipeline
  - Generate validation report

- [ ] Task 5.3: Create language expansion template
  - Document process for adding new languages
  - Create ARB template file
  - Create keyword JSON template
  - Provide checklist for new language integration
  - Include testing requirements
  - Save to `.claude/docs/new-language-template.md`

- [ ] Task 5.4: Implement user feedback mechanism
  - Add "Report incorrect detection" option in UI
  - Log misdetections with context
  - Create feedback collection system
  - Store feedback for analysis
  - Plan quarterly review of feedback data

- [ ] Task 5.5: Final QA and release preparation
  - Run full test suite for both languages
  - Perform manual testing on iOS and Android
  - Test with different device locales
  - Verify app store descriptions mention German support
  - Update changelog
  - Create migration notes if needed

## Dependencies and Prerequisites

**Dependencies:**
- `flutter_localizations: sdk: flutter` (new)
- `intl: ^0.19.0` (already in project)
- `shared_preferences: ^2.2.0` (for language preference storage)

**Assets:**
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_de.arb` - German translations
- `lib/l10n/keywords_en.json` - English keyword dictionary
- `lib/l10n/keywords_de.json` - German keyword dictionary

**Prerequisites:**
- Existing `ItemTypeDetector` remains functional throughout refactoring
- Access to native German speakers for validation
- No breaking changes to existing item detection API
- Maintain backward compatibility with existing items in database

**External Resources:**
- German task management keyword research
- German localization best practices
- Native German speaker for translation validation

## Challenges and Considerations

**Challenge 1: German Compound Words**
- German frequently combines words into compounds (e.g., "Wochenendeinkauf")
- Solution: Include common compounds in keyword dictionary
- Consider substring matching for unknown compounds
- Test extensively with real-world German input

**Challenge 2: Formal vs. Informal German**
- German has formal (Sie) and informal (du) forms
- Considerations: Decide on app voice and be consistent
- Include both forms in keywords if users might use either
- Document decision in translation guidelines

**Challenge 3: Regional Variations**
- German varies between Germany, Austria, and Switzerland
- Solution: Start with standard German (Hochdeutsch)
- Note regional variations for future expansion
- Consider user feedback from different regions

**Challenge 4: Translation Quality**
- Poor translations reduce detection accuracy
- Solution: Work with native German speakers
- Implement review process for translations
- Create clear context in ARB descriptions
- Test with German users early and often

**Challenge 5: Date and Time Parsing**
- German date formats differ from English (DD.MM.YYYY vs. MM/DD/YYYY)
- Time expressions may be structured differently
- Solution: Update date extraction logic to be locale-aware
- Use `intl` package's date formatting capabilities
- Add comprehensive date parsing tests for German

**Challenge 6: Performance with Multiple Languages**
- Loading multiple keyword dictionaries increases memory
- Solution: Lazy load only active language
- Cache parsed JSON to avoid repeated parsing
- Profile and optimize if needed
- Set performance budgets (< 50ms detection time)

**Challenge 7: Testing Complexity**
- Must test both languages thoroughly
- Solution: Create parameterized tests
- Use test fixtures for each language
- Implement automated test generation for keywords
- Set up CI to run all language tests

**Challenge 8: Maintaining Keyword Parity**
- English and German dictionaries may drift out of sync
- Solution: Create validation script
- Document keyword addition process
- Review both languages when adding keywords
- Consider tooling to flag inconsistencies

**Challenge 9: Mixed-Language Content**
- Users might mix English and German
- Solution: Consider detecting multiple languages (future)
- For now, detect based on app language setting
- Document this limitation
- Gather data on mixed-language usage

**Challenge 10: Cultural Differences in Task Management**
- Germans may structure tasks differently than English speakers
- Solution: Research German productivity culture
- Adjust scoring weights if needed per language
- Allow language-specific detection rules
- Validate with German users

## Success Criteria

- [ ] App supports English and German languages with runtime switching
- [ ] All UI strings are properly localized
- [ ] Item type detection works accurately in both languages (>80% confidence)
- [ ] No performance degradation (detection < 50ms)
- [ ] All tests pass for both languages
- [ ] Documentation complete for future language additions
- [ ] Native German speakers validate translations and detection
- [ ] Code is maintainable and follows Flutter best practices
