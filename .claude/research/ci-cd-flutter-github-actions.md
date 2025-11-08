# Research: CI/CD for Flutter App with GitHub Actions

## Executive Summary

This research document outlines the comprehensive approach to implement CI/CD for the Later Flutter mobile app using GitHub Actions. The implementation will consist of two primary workflows: (1) a **PR Validation workflow** that runs tests and builds on every pull request push, and (2) a **Release workflow** that triggers on tag pushes to create GitHub releases with signed Android APKs and auto-generated changelogs.

The project currently has no CI/CD infrastructure, no Android signing configuration, and uses `flutter_dotenv` for environment variables (Supabase URL and anon key). The implementation will require setting up Android keystore signing, configuring GitHub Secrets for sensitive credentials, creating workflow YAML files, and optionally implementing changelog generation from git commit messages.

Key findings indicate that modern Flutter CI/CD in 2025 uses `subosito/flutter-action@v2` with Java 17 (Temurin distribution), caching for pub dependencies to reduce build times, and `softprops/action-gh-release` for creating releases with asset uploads. The project's existing commit message format (e.g., "feat: Add feature", "fix: Fix bug") suggests compatibility with conventional commits, making automated changelog generation feasible.

## Research Scope

### What was researched
- Flutter GitHub Actions workflows for testing and building Android apps (2025 best practices)
- Android APK signing configuration with keystores in GitHub Actions
- Environment variable management (`.env` files) with GitHub Secrets
- Automated changelog generation from git commits
- GitHub release creation on tag push with APK upload
- Dependency caching strategies for Flutter workflows
- Required permissions for GitHub Actions tokens

### What was explicitly excluded
- iOS build and deployment workflows (not requested)
- Google Play Store automatic deployment (no Play Console listing exists)
- Internal/alpha/beta testing distribution (focus on GitHub releases)
- Advanced testing strategies (integration tests, E2E tests)
- Code coverage reporting and enforcement
- Multi-platform matrix builds (only Android APK needed)

### Research methodology used
- Analysis of current codebase structure (`apps/later_mobile/`)
- Review of existing dependencies and configuration (`pubspec.yaml`, `build.gradle.kts`)
- Web search for 2025 Flutter CI/CD best practices
- Investigation of GitHub Actions marketplace actions for Flutter
- Review of Android signing documentation and security practices
- Analysis of changelog generation tools and conventional commit standards

## Current State Analysis

### Existing Implementation

**No CI/CD Infrastructure:**
- No `.github/workflows/` directory exists
- No automated testing or building on PR or push events
- Manual build and release process

**Flutter Project Configuration:**
- **Version**: `1.0.0+1` (defined in `pubspec.yaml:5`)
- **SDK**: `^3.9.2` (Dart/Flutter SDK version)
- **Environment Variables**: Uses `flutter_dotenv` package (version `^6.0.0`)
- **Environment File**: `.env` file in project root (gitignored, with `.env.example` as template)
- **Required Secrets**: `SUPABASE_URL` and `SUPABASE_ANON_KEY`

**Android Build Configuration:**
- **Application ID**: `dev.curth.later`
- **Build Tool**: Gradle with Kotlin DSL (`.kts` files)
- **Java Compatibility**: `JavaVersion.VERSION_11` (source/target)
- **Kotlin JVM Target**: Java 11
- **Current Signing**: Debug keystore (see `android/app/build.gradle.kts:36`)
- **No Release Signing**: Comment on line 34 indicates "TODO: Add your own signing config for the release build"
- **Gitignore**: Properly configured to exclude `key.properties`, `*.keystore`, and `*.jks` files

**Test Coverage:**
- Comprehensive test suite with 200+ tests and >70% coverage (per `CLAUDE.md`)
- Tests located in `apps/later_mobile/test/`
- Uses `mockito` for mocking dependencies
- Test helpers available in `test/test_helpers.dart` for widget testing

**Git Commit Format:**
- Recent commits follow conventional commit format:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation
  - `refactor:` for refactoring
- Pull request numbers included in merge commits (e.g., `(#20)`)
- This format is ideal for automated changelog generation

### Industry Standards

**Flutter CI/CD Best Practices (2025):**

1. **Workflow Triggers:**
   - `on: [push, pull_request]` for PR validation workflows
   - `on: push: tags: ['v*']` for release workflows
   - `workflow_dispatch` for manual triggering

2. **Caching Strategy:**
   - Cache Flutter SDK and pub dependencies to reduce build times by ~20%
   - Use `subosito/flutter-action@v2` with built-in cache support
   - Cache key based on `hashFiles('**/pubspec.lock')`

3. **Environment Setup:**
   - **Java**: Version 17 with 'temurin' distribution (OpenJDK)
   - **Flutter**: Use stable channel with specific version pinning
   - **Actions versions**: Latest major versions (v3/v4) for all actions

4. **Build Artifacts:**
   - Use `actions/upload-artifact@v3` for PR builds (temporary storage)
   - Use release actions (e.g., `softprops/action-gh-release`) for tag builds

5. **Security:**
   - Store keystores as base64-encoded GitHub Secrets
   - Decode keystores at runtime in workflow
   - Never commit `key.properties`, `.jks`, or `.keystore` files
   - Use `permissions: contents: write` for release creation

6. **Testing:**
   - Run `flutter analyze` for static analysis
   - Run `flutter test` for unit/widget tests
   - Optional: `flutter format --set-exit-if-changed` for code formatting checks

**Android Signing Best Practices:**

1. **Keystore Generation:**
   - Use `keytool` command to generate `.jks` file
   - RSA algorithm with 2048-bit key size
   - 10,000-day validity period
   - Store in secure location outside repository

2. **Build Configuration:**
   - Create `key.properties` file with signing credentials (gitignored)
   - Load properties in `build.gradle.kts` using `Properties()` class
   - Define `signingConfigs { create("release") { ... } }` block
   - Reference signing config in `buildTypes { release { ... } }` block

3. **GitHub Actions Integration:**
   - Encode keystore as base64: `openssl base64 < keystore.jks | tr -d '\n'`
   - Store in GitHub Secret (e.g., `ANDROID_KEYSTORE_BASE64`)
   - Decode in workflow: `echo ${{ secrets.KEYSTORE }} | base64 -d > keystore.jks`
   - Create `key.properties` dynamically from GitHub Secrets
   - Clean up keystore file after build

**Changelog Generation Best Practices:**

1. **GitHub Native Feature:**
   - GitHub provides automatic release notes generation
   - Click "Generate release notes" when creating a release
   - Includes merged PRs, contributors, and full changelog link
   - No additional action required

2. **Conventional Commits:**
   - Commit format: `<type>(<scope>): <description>`
   - Types: feat, fix, docs, refactor, test, chore, etc.
   - Enables semantic versioning and automated changelogs

3. **Popular Actions:**
   - `requarks/changelog-action` - generates changelog from conventional commits
   - GitHub's native "Generate release notes" button
   - `softprops/action-gh-release` supports automatic body generation

## Technical Analysis

### Approach 1: Basic PR Validation Workflow

**Description**: A simple workflow that runs tests and performs a debug build on every pull request push. This provides quick feedback without the complexity of signed release builds.

**Pros:**
- Simple to implement and maintain
- Fast feedback loop for developers
- No need for signing secrets in PR workflow
- Validates code quality before merge

**Cons:**
- Does not validate release build configuration
- Does not test APK signing process
- Debug build may hide release-only issues

**Use Cases:**
- Initial CI/CD implementation
- Projects with frequent PRs needing quick validation
- When release builds are infrequent

**Implementation Example:**
```yaml
name: PR Validation

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Create .env file
        run: |
          echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" > .env
          echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env
        working-directory: apps/later_mobile

      - name: Get dependencies
        run: flutter pub get
        working-directory: apps/later_mobile

      - name: Analyze code
        run: flutter analyze
        working-directory: apps/later_mobile

      - name: Run tests
        run: flutter test
        working-directory: apps/later_mobile

      - name: Build debug APK
        run: flutter build apk --debug
        working-directory: apps/later_mobile
```

### Approach 2: Comprehensive PR Validation with Release Build

**Description**: An enhanced workflow that builds a signed release APK on every PR, ensuring the release build process is validated before merge.

**Pros:**
- Validates complete build pipeline on every PR
- Catches release-specific build issues early
- Provides release APK artifact for testing
- More confidence before merging

**Cons:**
- Slower build times (release builds take longer)
- Requires signing secrets in PR workflow (security consideration)
- Higher compute costs (GitHub Actions minutes)
- May be overkill for small changes

**Use Cases:**
- Projects with complex release build configurations
- When release-specific issues have occurred in the past
- Teams that want maximum confidence before merge

**Implementation Example:**
Same as Approach 1, but replace debug build with:
```yaml
      - name: Build release APK
        run: flutter build apk --release
        working-directory: apps/later_mobile

      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: apps/later_mobile/build/app/outputs/flutter-apk/app-release.apk
```

### Approach 3: Minimal PR Validation (Tests Only)

**Description**: Fastest workflow that only runs static analysis and tests, skipping build entirely.

**Pros:**
- Extremely fast feedback (<3 minutes typical)
- Lowest compute cost
- Sufficient for most code changes
- Encourages frequent commits

**Cons:**
- Does not validate build configuration
- May miss build-breaking changes
- No artifact for manual testing

**Use Cases:**
- High-velocity projects with frequent PRs
- When build issues are rare
- Cost-sensitive projects minimizing CI minutes

**Implementation Example:**
Same as Approach 1, but remove the build step entirely.

## Technical Analysis: Release Workflows

### Approach 1: Manual Release with GitHub UI

**Description**: Create releases manually through GitHub UI, uploading locally-built APK files.

**Pros:**
- No workflow configuration needed
- Full control over release timing and content
- Can review changelog before publishing

**Cons:**
- Manual process prone to errors
- Inconsistent release process
- Time-consuming for developers
- No automation benefits

**Use Cases:**
- Very infrequent releases
- Small teams with manual QA processes
- Not recommended for this project

### Approach 2: Tag-Triggered Release with Native Changelog

**Description**: Workflow triggers on tag push, builds signed APK, creates GitHub release using native release notes generation.

**Pros:**
- Fully automated release process
- Native GitHub changelog requires no additional action
- Simple workflow configuration
- Standard git tag workflow (`git tag v1.0.0 && git push --tags`)

**Cons:**
- Changelog format is PR-based (not commit-based)
- Less control over changelog formatting
- Requires manual "Generate release notes" click (can be automated)

**Use Cases:**
- Most projects with standard release cadence
- **Recommended for this project**

**Implementation Example:**
```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Fetch all history for changelog

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/release-keystore.jks
        working-directory: apps/later_mobile

      - name: Create key.properties
        run: |
          cat > android/key.properties << EOF
          storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=release-keystore.jks
          EOF
        working-directory: apps/later_mobile

      - name: Create .env file
        run: |
          echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" > .env
          echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env
        working-directory: apps/later_mobile

      - name: Get dependencies
        run: flutter pub get
        working-directory: apps/later_mobile

      - name: Build release APK
        run: flutter build apk --release
        working-directory: apps/later_mobile

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: apps/later_mobile/build/app/outputs/flutter-apk/app-release.apk
          generate_release_notes: true
          draft: false
          prerelease: false

      - name: Cleanup keystore
        if: always()
        run: |
          rm -f android/app/release-keystore.jks
          rm -f android/key.properties
        working-directory: apps/later_mobile
```

### Approach 3: Tag-Triggered Release with Conventional Commit Changelog

**Description**: Enhanced workflow that generates changelog from commit messages using conventional commits format.

**Pros:**
- Detailed changelog based on actual commits (not just PR titles)
- Supports semantic versioning
- More granular release notes
- Professional changelog format

**Cons:**
- Requires additional action (`requarks/changelog-action`)
- Depends on commit message discipline
- More complex workflow configuration
- May include too much detail

**Use Cases:**
- Projects following conventional commits strictly
- Teams wanting detailed changelogs
- When commit messages are more descriptive than PR titles

**Implementation Example:**
Add this step before the "Create GitHub Release" step in Approach 2:
```yaml
      - name: Generate Changelog
        id: changelog
        uses: requarks/changelog-action@v1
        with:
          token: ${{ github.token }}
          tag: ${{ github.ref_name }}

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: apps/later_mobile/build/app/outputs/flutter-apk/app-release.apk
          body: ${{ steps.changelog.outputs.changes }}
          draft: false
          prerelease: false
```

## Tools and Libraries

### Option 1: subosito/flutter-action@v2

- **Purpose**: Sets up Flutter SDK in GitHub Actions environment
- **Maturity**: Production-ready, widely adopted
- **License**: MIT License
- **Community**: 900+ stars, active maintenance
- **Integration Effort**: Low
- **Key Features**:
  - Built-in caching support for pub dependencies
  - Supports all Flutter channels (stable, beta, dev)
  - Cross-platform (Linux, macOS, Windows)
  - Version pinning support
  - Fast setup (<30 seconds with cache)

**Recommendation**: Required for Flutter CI/CD

### Option 2: actions/setup-java@v3

- **Purpose**: Sets up Java Development Kit for Android builds
- **Maturity**: Production-ready, official GitHub action
- **License**: MIT License
- **Community**: Official GitHub action, heavily used
- **Integration Effort**: Low
- **Key Features**:
  - Multiple Java distributions (Temurin, Zulu, Oracle)
  - Version caching
  - Supports Java 8-20+
  - Built-in caching for Maven/Gradle dependencies

**Recommendation**: Required for Android APK builds (use Java 17 with Temurin)

### Option 3: softprops/action-gh-release@v1

- **Purpose**: Creates GitHub releases and uploads assets
- **Maturity**: Production-ready, widely used
- **License**: MIT License
- **Community**: 3k+ stars, active development
- **Integration Effort**: Low
- **Key Features**:
  - Upload multiple files as release assets
  - Auto-generate release notes from PRs
  - Draft and prerelease support
  - Tag-based release naming
  - Body content from file or string

**Recommendation**: Recommended for release workflow (simplest and most reliable)

### Option 4: requarks/changelog-action@v1

- **Purpose**: Generates changelog from conventional commits
- **Maturity**: Production-ready
- **License**: MIT License
- **Community**: 200+ stars
- **Integration Effort**: Low
- **Key Features**:
  - Conventional commits parsing
  - Configurable changelog format
  - Supports custom commit types
  - Outputs changelog as action output variable
  - Works between any two tags

**Recommendation**: Optional, use if commit-based changelog is preferred over PR-based

### Option 5: r0adkll/sign-android-release@v1

- **Purpose**: Signs Android APK/AAB files with keystore
- **Maturity**: Production-ready
- **License**: MIT License
- **Community**: 600+ stars
- **Integration Effort**: Low
- **Key Features**:
  - Base64-encoded keystore support
  - AAB and APK signing
  - Automatic zipalign
  - Outputs signed artifact path

**Recommendation**: Alternative approach, but manual signing configuration is more flexible and transparent

### Option 6: flutter_dotenv (Existing Dependency)

- **Purpose**: Loads environment variables from `.env` files in Flutter apps
- **Maturity**: Production-ready
- **License**: MIT License
- **Community**: 500+ stars
- **Integration Effort**: Already integrated (version ^6.0.0)
- **Key Features**:
  - Load `.env` files at runtime
  - Access via `dotenv.env['KEY']`
  - Asset-based loading
  - Multiple environment file support

**Security Note**: Variables are stored in clear text in app assets and can be extracted via reverse engineering. For production apps, consider backend API key protection or obfuscation solutions like `enven` package.

## Implementation Considerations

### Technical Requirements

**Prerequisites:**
- GitHub repository with admin access
- Android keystore file (`.jks`) for release signing
- GitHub Secrets configured:
  - `ANDROID_KEYSTORE_BASE64` (base64-encoded keystore file)
  - `ANDROID_KEYSTORE_PASSWORD` (keystore password)
  - `ANDROID_KEY_PASSWORD` (key password, may be same as keystore password)
  - `ANDROID_KEY_ALIAS` (key alias name)
  - `SUPABASE_URL` (Supabase project URL)
  - `SUPABASE_ANON_KEY` (Supabase anonymous key)

**Android Signing Configuration Changes:**
- Modify `android/app/build.gradle.kts` to add release signing config
- Create `key.properties` loading logic (for local builds)
- Add CI-specific keystore path handling

**Workflow Files:**
- `.github/workflows/pr-validation.yml` (PR testing workflow)
- `.github/workflows/release.yml` (Tag-triggered release workflow)

**Performance:**
- First run: ~8-10 minutes (no cache)
- Subsequent runs: ~4-6 minutes (with cache)
- Test-only runs: ~2-3 minutes

### Integration Points

**Existing Architecture:**
- Monorepo structure: Workflows must use `working-directory: apps/later_mobile`
- Test suite: Already comprehensive, ready for CI integration
- Environment variables: `flutter_dotenv` requires `.env` file creation in workflow
- Supabase: Local development uses Supabase CLI, CI uses production secrets

**Modified Files:**
1. **`android/app/build.gradle.kts`**:
   - Add keystore properties loading at top of file
   - Add `signingConfigs { create("release") { ... } }` block
   - Update `buildTypes { release { ... } }` to use release signing config

2. **`android/key.properties`** (gitignored):
   - Create for local development only
   - Contains keystore path and credentials
   - Not committed to repository

3. **`.github/workflows/pr-validation.yml`** (new file):
   - Runs on PR and push to main
   - Creates `.env` from secrets
   - Runs tests and analysis
   - Optional: builds debug APK

4. **`.github/workflows/release.yml`** (new file):
   - Runs on tag push (`v*`)
   - Decodes keystore from secret
   - Creates `key.properties` from secrets
   - Builds signed release APK
   - Creates GitHub release with APK and changelog

**No Database Migrations Required**: CI/CD infrastructure is orthogonal to application data layer.

**No Provider Changes Required**: State management is unaffected by CI/CD.

### Risks and Mitigation

**Risk 1: Keystore Loss or Compromise**
- **Impact**: Cannot sign future releases, must create new app listing
- **Mitigation**:
  - Store keystore in multiple secure locations (1Password, encrypted backup)
  - Document recovery process
  - Use GitHub Secrets for CI access only
  - Never commit keystore to repository
  - Consider backup key strategy (Google Play supports multiple keys)

**Risk 2: GitHub Secrets Exposure**
- **Impact**: Unauthorized access to Supabase or ability to sign malicious APKs
- **Mitigation**:
  - Use principle of least privilege for repository access
  - Enable branch protection rules requiring PR reviews
  - Monitor GitHub Actions logs for unusual activity
  - Rotate secrets periodically
  - Use repository secrets (not organization secrets) for sensitive data

**Risk 3: Build Failures Breaking Release Process**
- **Impact**: Unable to create releases, delays in shipping
- **Mitigation**:
  - Implement comprehensive PR validation workflow
  - Require tests to pass before merge
  - Test release workflow in separate repository first
  - Document manual release process as fallback
  - Use draft releases for testing before going public

**Risk 4: .env Variables Exposed in App Assets**
- **Impact**: Supabase anonymous key visible to attackers
- **Mitigation**:
  - Supabase RLS (Row Level Security) already in place protects data
  - Anonymous key is designed to be client-side (expected exposure)
  - Consider rate limiting and API abuse detection in Supabase
  - For future: consider moving sensitive operations to backend API
  - Document security model in README

**Risk 5: Monorepo Working Directory Issues**
- **Impact**: Workflows fail due to incorrect paths
- **Mitigation**:
  - Use `working-directory: apps/later_mobile` in all Flutter steps
  - Test workflows thoroughly before relying on them
  - Use absolute paths for keystore and properties files
  - Document directory structure in workflow comments

**Risk 6: Java/Flutter Version Incompatibility**
- **Impact**: Builds fail due to version mismatches
- **Mitigation**:
  - Pin Flutter SDK version in workflow (or use stable channel)
  - Use Java 17 (recommended for Flutter 3.x)
  - Document version requirements in README
  - Test locally with same versions before pushing
  - Consider adding version check step in workflow

## Recommendations

### Recommended Approach

**For PR Validation: Approach 1 (Basic PR Validation Workflow)**
- Run `flutter analyze` and `flutter test` on every PR push
- Build debug APK to validate build configuration
- Create `.env` file from GitHub Secrets
- Use caching to keep builds fast (~4-6 minutes)
- **Rationale**: Balances speed and confidence, sufficient for most PRs

**For Releases: Approach 2 (Tag-Triggered Release with Native Changelog)**
- Trigger on `v*` tag push (e.g., `v1.0.1`)
- Build signed release APK with keystore from secrets
- Create GitHub release using `softprops/action-gh-release`
- Use `generate_release_notes: true` for automatic changelog
- **Rationale**: Fully automated, simple, leverages GitHub native features

**Alternative if Commit-Based Changelog Preferred:**
- Use Approach 3 with `requarks/changelog-action`
- Requires strict conventional commit discipline
- Provides more detailed changelogs
- Adds complexity for marginal benefit given existing PR-based workflow

### Phased Implementation Strategy

**Phase 1: Android Signing Setup (Prerequisites)**
1. Generate Android keystore using `keytool` command
2. Test keystore locally by building release APK
3. Encode keystore as base64: `openssl base64 < keystore.jks | tr -d '\n'`
4. Store keystore and credentials securely (1Password, etc.)
5. Configure GitHub Secrets in repository settings
6. Update `android/app/build.gradle.kts` with signing configuration
7. Create `android/key.properties` for local development (gitignored)
8. Test local release build: `flutter build apk --release`
9. Verify APK installs and runs correctly

**Phase 2: PR Validation Workflow (Foundation)**
1. Create `.github/workflows/` directory
2. Create `pr-validation.yml` workflow file
3. Configure triggers: `on: [pull_request, push]` for main branch
4. Add secrets for `SUPABASE_URL` and `SUPABASE_ANON_KEY`
5. Test workflow by creating a test PR
6. Verify tests run and pass
7. Add branch protection rule requiring checks to pass

**Phase 3: Release Workflow (Automation)**
1. Create `release.yml` workflow file
2. Configure tag trigger: `on: push: tags: ['v*']`
3. Add keystore decoding and `key.properties` creation steps
4. Test workflow by pushing a test tag (e.g., `v0.0.1-test`)
5. Verify APK builds, signs, and uploads to release
6. Delete test release and tag after verification
7. Document release process in README

**Phase 4: Documentation and Process (Polish)**
1. Update README with CI/CD documentation
2. Document release process: versioning, tagging, changelog
3. Create `CONTRIBUTING.md` with PR guidelines
4. Add badge to README showing workflow status
5. Train team on new release process
6. Establish branching strategy (feature branches, main branch protection)

**Estimated Timeline:**
- Phase 1: 2-3 hours (keystore setup and local testing)
- Phase 2: 1-2 hours (PR workflow creation and testing)
- Phase 3: 1-2 hours (release workflow creation and testing)
- Phase 4: 1 hour (documentation)
- **Total: 5-8 hours** for complete implementation

## References

### Official Documentation
- [Flutter: Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [GitHub Actions: Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions: Permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs)
- [GitHub: Automatically generated release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes)

### GitHub Actions Marketplace
- [subosito/flutter-action](https://github.com/marketplace/actions/flutter-action)
- [actions/setup-java](https://github.com/marketplace/actions/setup-java-jdk)
- [softprops/action-gh-release](https://github.com/marketplace/actions/gh-release)
- [requarks/changelog-action](https://github.com/marketplace/actions/changelog-action)

### Articles and Guides
- [Flutter CI/CD using GitHub Actions - LogRocket](https://blog.logrocket.com/flutter-ci-cd-using-github-actions/)
- [How to build and sign Flutter Android app using GitHub Actions - Damien Aicheh](https://damienaicheh.github.io/flutter/github/actions/2021/04/29/build-sign-flutter-android-github-actions-en.html)
- [How to Automate Flutter Testing and Builds with GitHub Actions - freeCodeCamp](https://www.freecodecamp.org/news/how-to-automate-flutter-testing-and-builds-with-github-actions-for-android-and-ios/)

### Stack Overflow & Community
- [Flutter & Github Actions: Signed APK - Medium](https://medium.com/@danieln.llewellyn/flutter-github-actions-for-a-signed-apk-fcdf9878f660)
- [Add artifact from github actions to releases - Stack Overflow](https://stackoverflow.com/questions/65325879/add-artifact-from-github-actions-to-releases)
- [How to store Android Keystore safely on GitHub Actions - Medium](https://stefma.medium.com/how-to-store-a-android-keystore-safely-on-github-actions-f0cef9413784)

### Code Examples
- [Flutter Production GitHub Action Gist](https://gist.github.com/yarabramasta/aaef958d688672396c77b8b15b9160a2)
- [Android-Github-Actions Workflow Examples](https://github.com/wajahatkarim3/Android-Github-Actions)

## Appendix

### Additional Notes

**Supabase Local Development Consideration:**
The project uses Supabase CLI for local development (`supabase start`), but CI/CD workflows will use production Supabase instance. Ensure production instance is properly configured with:
- RLS policies matching local development
- Database migrations applied
- Authentication enabled

**Test Suite Compatibility:**
Current test suite may need updates to work with CI environment:
- Tests using Supabase may need mocking (already uses `mockito`)
- Widget tests must use `testApp()` helper from `test/test_helpers.dart`
- Integration tests not currently in scope for CI (can be added later)

**Future Enhancements:**
- **Code Coverage Reporting**: Add `flutter test --coverage` and upload to Codecov
- **Fastlane Integration**: For more complex build configurations
- **Google Play Deployment**: Automate upload to Play Console when listing is created
- **Multi-Flavor Builds**: Production, staging, development flavors
- **iOS Workflow**: TestFlight and App Store deployment
- **Performance Monitoring**: Add workflow to check APK size and performance metrics

**Cost Considerations:**
- GitHub Actions free tier: 2,000 minutes/month for private repos
- Estimated usage: ~6 min/PR + ~10 min/release
- Example: 20 PRs + 2 releases/month = ~140 minutes (~7% of free tier)
- Public repos: unlimited minutes

### Questions for Further Investigation

1. **Versioning Strategy**: Should version be auto-incremented from git tags, or manually managed in `pubspec.yaml`?
2. **Release Cadence**: How often will releases be created? (Daily, weekly, per feature?)
3. **Pre-release Testing**: Should APKs be distributed to testers before creating public release?
4. **Supabase Production Instance**: Is production Supabase project already set up with correct credentials?
5. **Code Signing Certificate**: Do we want to use Google Play App Signing (managed keys) or upload keys?

### Related Topics Worth Exploring

- **Semantic Versioning**: Automating version bumps based on commit types
- **Beta Testing Distribution**: Firebase App Distribution or Google Play Internal Testing
- **APK Optimization**: Splitting by ABI, minification, obfuscation
- **Security Scanning**: Adding SAST tools (e.g., Snyk, SonarCloud) to workflow
- **Monitoring**: Sentry or Firebase Crashlytics integration for production crash reporting
