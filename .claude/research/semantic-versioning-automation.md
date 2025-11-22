# Research: Semantic Versioning Automation for Flutter CI/CD

## Executive Summary

This research explores practical approaches to automate semantic versioning in a Flutter mobile app without manually updating `pubspec.yaml` with every release. The goal is to keep the implementation simple and maintainable while following semantic versioning principles (MAJOR.MINOR.PATCH) based on commit messages.

**Key Findings:**
- **Conventional Commits** provide a standardized format that maps directly to semantic version bumps (feat → MINOR, fix → PATCH, BREAKING CHANGE → MAJOR)
- Multiple GitHub Actions exist to calculate next versions from commit history automatically
- **Simple bash scripts** with sed/perl can update `pubspec.yaml` dynamically in CI without Node.js dependencies
- **semantic-release ecosystem** (Node.js) offers the most comprehensive solution but adds complexity
- **GitHub run numbers** or **git commit counts** provide reliable sequential build numbers
- For Flutter apps, version format is `MAJOR.MINOR.PATCH+BUILD_NUMBER` where build number must be unique and incrementing

**Recommended Approach:** Use Conventional Commits + GitHub Action to calculate version + bash script to update pubspec.yaml. This avoids Node.js dependencies while providing full automation with minimal complexity.

## Research Scope

### What Was Researched
- Conventional Commits specification and tooling for Flutter projects
- GitHub Actions for automatic version calculation from commit messages
- Methods to programmatically update `pubspec.yaml` version field
- Build number automation strategies (sequential vs timestamp)
- Comparison of semantic-release ecosystem vs lightweight alternatives
- Integration with existing CI/CD pipeline from `.claude/research/github-actions-android-ci-cd-google-play.md`

### What Was Explicitly Excluded
- iOS versioning automation (Android-only focus)
- Complex release management workflows (staged rollouts, beta tracks)
- Changelog generation tools (focused on version bumping only)
- Manual git tagging workflows (automation focus)
- Monorepo-specific versioning strategies

### Research Methodology
- Web search for Flutter semantic versioning best practices (2025 sources prioritized)
- Analysis of GitHub Actions marketplace for version calculation tools
- Review of semantic-release ecosystem and Flutter plugins
- Evaluation of bash/perl scripting approaches for pubspec.yaml manipulation
- Analysis of current project commit message patterns
- Review of existing CI/CD configuration structure

## Current State Analysis

### Existing Implementation

**Project:** Flutter mobile app at `/apps/later_mobile/`
- **Package:** `dev.curth.later`
- **Current Version:** `1.0.0+1` (from pubspec.yaml:5)
- **CI/CD:** GitHub Actions workflows planned (from previous research)
- **No git tags:** No existing tags found (empty output from `git tag --list`)
- **No version automation:** Manual version management currently

**Recent Commit Message Patterns:**
Analysis of last 20 commits shows **partial adoption** of Conventional Commits:
- ✅ Good examples: `feat(search):`, `fix(tests):`, `fix(search):`, `docs(search):`
- ✅ Scoped commits with proper prefixes
- ❌ Some commits use `chore:` prefix
- ❌ No BREAKING CHANGE markers observed
- **Conclusion:** Team is already using Conventional Commits format with some consistency

**Gap Analysis:**
- No commit message linting or enforcement
- No automated version calculation
- No git tagging strategy
- Manual pubspec.yaml updates required
- Build number management not automated

### Industry Standards

**Conventional Commits (2025):**
- Standard format: `<type>(<scope>): <description>` with optional body and footer
- Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Version mapping: `feat` → MINOR bump, `fix` → PATCH bump, `BREAKING CHANGE` → MAJOR bump
- Widely adopted across JavaScript, Python, Go, and increasingly Flutter projects

**Flutter Version Format:**
- Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- Example: `1.2.4+5` (version 1.2.4, build 5)
- `MAJOR.MINOR.PATCH` → User-facing version (versionName on Android, CFBundleShortVersionString on iOS)
- `BUILD_NUMBER` → Internal build identifier (versionCode on Android, CFBundleVersion on iOS)
- Build number must be unique, incrementing integer for each build
- Google Play requires incrementing build numbers for each upload

**GitHub Actions Best Practices (2025):**
- Use dedicated actions for version calculation (avoid reinventing logic)
- Pin action versions for reproducibility (e.g., `@v1.2.3`)
- Store calculated version in environment variables or outputs
- Create git tags automatically after successful releases
- Use GitHub run number for build numbers (reliable, sequential, unique)

**Build Number Strategies:**
- **Sequential (Recommended):** Use GitHub Actions run number or git commit count
- **Timestamp (Not Recommended):** Can exceed Android's max integer value (2147483647)
- **Hybrid:** Semantic version from commits + sequential build number

## Technical Analysis

### Approach 1: Conventional Commits + GitHub Action + Bash Script (Recommended)

**Description:** Use Conventional Commits for commit messages, a GitHub Action to calculate the next semantic version, and a simple bash script to update `pubspec.yaml` dynamically during CI builds. No Node.js dependencies required.

**Pros:**
- ✅ Simple to implement and maintain
- ✅ No Node.js/npm dependencies in Flutter project
- ✅ Works with existing CI/CD pipeline structure
- ✅ Team already partially using Conventional Commits
- ✅ Explicit version calculation in workflow (easy to debug)
- ✅ Build number tied to GitHub run number (reliable, sequential)
- ✅ Minimal external dependencies (just one GitHub Action)

**Cons:**
- ❌ Requires enforcing Conventional Commits (need commit linting)
- ❌ Less feature-rich than semantic-release (no changelog generation, plugin ecosystem)
- ❌ Manual git tag creation in workflow (extra step)
- ❌ Bash script maintenance (though simple)

**Use Cases:**
- First-time semantic versioning setup
- Teams wanting simplicity over advanced features
- Projects without Node.js ecosystem
- When existing commit messages follow conventions

**Implementation Components:**

1. **GitHub Action for Version Calculation:**
   - **ietf-tools/semver-action** (Recommended)
   - Parses commit history from latest tag to HEAD
   - Outputs next version based on Conventional Commits
   - Lightweight, focused, well-maintained

2. **Bash Script for pubspec.yaml Update:**
   ```bash
   # Update version in pubspec.yaml
   VERSION="${{ steps.semver.outputs.nextStrict }}"
   BUILD_NUMBER="${{ github.run_number }}"

   # Replace version line in pubspec.yaml
   sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml
   ```

3. **Optional: Commit Linting (Dart-native):**
   - Use `commitlint_cli` (Dart package) + `husky` (Dart package)
   - No Node.js required
   - Validates commits locally before push

**Workflow Integration:**
```yaml
- name: Calculate Next Version
  id: semver
  uses: ietf-tools/semver-action@v1
  with:
    token: ${{ github.token }}
    branch: main

- name: Update pubspec.yaml Version
  run: |
    VERSION="${{ steps.semver.outputs.nextStrict }}"
    BUILD_NUMBER="${{ github.run_number }}"
    sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" apps/later_mobile/pubspec.yaml

- name: Build App Bundle
  run: flutter build appbundle --release
  working-directory: apps/later_mobile

- name: Create Git Tag
  run: |
    git tag v${{ steps.semver.outputs.nextStrict }}
    git push origin v${{ steps.semver.outputs.nextStrict }}
```

### Approach 2: semantic-release with semantic-release-pub Plugin

**Description:** Use the full semantic-release ecosystem with the `semantic-release-pub` plugin to automate versioning, git tagging, GitHub releases, and pubspec.yaml updates. Comprehensive but requires Node.js.

**Pros:**
- ✅ Industry-standard tooling (widely used, well-documented)
- ✅ Automatic git tagging and GitHub release creation
- ✅ Plugin ecosystem (changelog generation, Slack notifications, etc.)
- ✅ Handles version bumping, git operations, and publishing in one tool
- ✅ Supports OIDC authentication for pub.dev (though not relevant for this project)

**Cons:**
- ❌ Requires Node.js/npm in Flutter project (adds dependency complexity)
- ❌ Steeper learning curve (many configuration options)
- ❌ Overkill for simple version bumping needs
- ❌ `semantic-release-pub` plugin is less mature than core semantic-release
- ❌ Requires package.json and .releaserc configuration files

**Use Cases:**
- Teams already using Node.js tooling
- Projects publishing to pub.dev (Dart packages)
- Need for advanced features (changelog, notifications, multiple plugins)
- Multi-platform projects with shared release tooling

**Configuration Example:**
```json
// .releaserc.json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    [
      "semantic-release-pub",
      {
        "cli": "flutter",
        "publishPub": false,
        "updateBuildNumber": true
      }
    ],
    [
      "@semantic-release/git",
      {
        "assets": ["pubspec.yaml"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ],
    "@semantic-release/github"
  ]
}
```

**Workflow Integration:**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'

- name: Install semantic-release
  run: npm install -D semantic-release semantic-release-pub @semantic-release/git @semantic-release/github

- name: Run semantic-release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: npx semantic-release
```

### Approach 3: Manual Version Bumping with Flutter CLI Options

**Description:** Use Flutter's built-in `--build-name` and `--build-number` flags during build to override pubspec.yaml values without modifying the file. Keep pubspec.yaml as a template with placeholder values.

**Pros:**
- ✅ No file modification required (read-only pubspec.yaml)
- ✅ No additional dependencies or tools
- ✅ Simple to understand and implement
- ✅ Explicit version specification at build time

**Cons:**
- ❌ No automated semantic versioning (manual calculation required)
- ❌ Must pass version to every flutter build command
- ❌ Developers must manually determine version bumps
- ❌ Prone to human error (forgot to bump version)
- ❌ No commit message → version mapping
- ❌ Git tags must be created manually

**Use Cases:**
- Very small projects with infrequent releases
- Teams that prefer explicit version control
- Temporary solution before implementing automation
- When full automation is not justified

**Implementation:**
```yaml
- name: Set Version Variables
  run: |
    VERSION="1.0.0"  # Manually update this
    BUILD_NUMBER="${{ github.run_number }}"
    echo "VERSION=$VERSION" >> $GITHUB_ENV
    echo "BUILD_NUMBER=$BUILD_NUMBER" >> $GITHUB_ENV

- name: Build App Bundle
  run: |
    flutter build appbundle \
      --release \
      --build-name=${{ env.VERSION }} \
      --build-number=${{ env.BUILD_NUMBER }}
  working-directory: apps/later_mobile
```

**Note:** This approach does not automate version bumping based on commit messages, so it fails the core requirement of not manually updating versions.

### Approach 4: Fastlane with Version Plugin

**Description:** Use Fastlane's versioning plugin to manage Flutter app versions with semantic versioning support. Combines Ruby ecosystem with Flutter builds.

**Pros:**
- ✅ Integrated with Fastlane deployment pipeline (if already using)
- ✅ Simple commands: `fastlane bump_major`, `fastlane bump_minor`, `fastlane bump_patch`
- ✅ Supports build number management
- ✅ Works well with iOS + Android simultaneous releases

**Cons:**
- ❌ Requires Ruby and Fastlane setup (additional dependencies)
- ❌ Manual triggering of bump commands (not automatic from commits)
- ❌ Slower build times (Ruby overhead)
- ❌ Steeper learning curve if not already using Fastlane
- ❌ Does not parse commit messages for automatic version calculation

**Use Cases:**
- Teams already using Fastlane for deployment
- Projects requiring iOS + Android version synchronization
- Need for Fastlane's metadata management features

**Configuration Example:**
```ruby
# fastlane/Fastfile
lane :bump_version do |options|
  type = options[:type] || 'patch'  # major, minor, patch

  sh("flutter pub run flutter_version_manager bump --#{type}")

  # Update pubspec.yaml
  version = sh("grep '^version:' ../pubspec.yaml | sed 's/version: //'").strip

  git_commit(
    path: "pubspec.yaml",
    message: "chore(release): bump version to #{version}"
  )
end
```

**Limitation:** Still requires manual decision on version type (major/minor/patch), does not automate based on commit messages.

## Tools and Libraries

### Option 1: ietf-tools/semver-action (GitHub Action)

- **Purpose:** Calculate next semantic version from Conventional Commits history
- **Maturity:** Production-ready (official IETF tool, actively maintained)
- **License:** BSD 3-Clause
- **Community:** Official IETF project, well-documented
- **Integration Effort:** Low - single action step in workflow
- **Key Features:**
  - Parses commit history from latest tag to HEAD
  - Outputs next version, current version, bump type
  - Supports custom branch and tag prefix patterns
  - Follows Conventional Commits spec strictly
  - No Node.js required in project (runs in action container)

**GitHub Marketplace:** https://github.com/marketplace/actions/semver-conventional-commits

**Outputs:**
- `next`: Next version (e.g., `1.2.0`)
- `nextStrict`: Next version without `v` prefix (e.g., `1.2.0`)
- `current`: Current version from latest tag
- `bump`: Type of bump (`major`, `minor`, `patch`, `none`)

### Option 2: PaulHatch/semantic-version (GitHub Action)

- **Purpose:** Generate semantic version from git commit history
- **Maturity:** Production-ready (popular community action)
- **License:** MIT
- **Community:** Active community, 200+ stars
- **Integration Effort:** Low - single action step
- **Key Features:**
  - Conventional Commits support
  - Custom version format templates
  - Configurable bump patterns
  - Pre-release and metadata support
  - Outputs for major, minor, patch numbers

**GitHub Marketplace:** https://github.com/marketplace/actions/git-semantic-version

**Configuration Example:**
```yaml
- uses: paulhatch/semantic-version@v5.4.0
  with:
    branch: main
    tag_prefix: "v"
    major_pattern: "(MAJOR)"
    minor_pattern: "feat:"
    format: "${major}.${minor}.${patch}"
```

### Option 3: semantic-release + semantic-release-pub

- **Purpose:** Fully automated release workflow (version, changelog, git tags, GitHub releases)
- **Maturity:** semantic-release is production-ready (industry standard), semantic-release-pub is community plugin (less mature)
- **License:** MIT
- **Community:** semantic-release has 20k+ stars, semantic-release-pub is smaller community project
- **Integration Effort:** Medium - requires Node.js setup, multiple configuration files
- **Key Features:**
  - Automatic version calculation
  - Git tag creation
  - GitHub release creation
  - Changelog generation
  - Plugin ecosystem (Slack, npm, etc.)
  - Updates pubspec.yaml automatically
  - Build number management for Flutter

**Installation:**
```bash
npm install --save-dev semantic-release semantic-release-pub @semantic-release/git @semantic-release/github
```

**Configuration:** Requires `.releaserc.json` and `package.json`

### Option 4: commitlint_cli + husky (Dart packages)

- **Purpose:** Enforce Conventional Commits format via git hooks
- **Maturity:** Community packages, stable
- **License:** MIT
- **Community:** Dart-native alternatives to Node.js commitlint/husky
- **Integration Effort:** Low - add to dev_dependencies, configure git hooks
- **Key Features:**
  - Validates commit messages before commit
  - Dart-native (no Node.js required)
  - Configurable rules via YAML
  - Prevents invalid commit messages
  - Works locally and in CI

**Installation:**
```bash
dart pub add --dev commitlint_cli
dart pub add --dev husky
dart run husky install
dart run husky add .husky/commit-msg 'dart run commitlint_cli --edit $1'
```

**Configuration (commitlint.yaml):**
```yaml
include: package:commitlint_cli/commitlint.yaml

rules:
  type-enum:
    - error
    - always
    - [feat, fix, docs, style, refactor, test, chore]
  subject-empty:
    - error
    - never
```

### Option 5: Standard Bash/Sed Scripting

- **Purpose:** Programmatically update pubspec.yaml version field
- **Maturity:** Standard Unix tools (decades old, extremely stable)
- **License:** N/A (built-in tools)
- **Community:** Universal Unix/Linux knowledge
- **Integration Effort:** Very low - inline script in workflow
- **Key Features:**
  - No dependencies
  - Fast execution
  - Works in any Linux environment
  - Simple string replacement logic

**Example Script:**
```bash
# Simple version replacement
VERSION="1.2.0"
BUILD_NUMBER="42"
sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml

# With validation
if ! grep -q "version: $VERSION+$BUILD_NUMBER" pubspec.yaml; then
  echo "Error: Version update failed"
  exit 1
fi
```

**Alternative (Perl for in-place increment):**
```bash
# Increment build number in place
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml
```

## Implementation Considerations

### Technical Requirements

**Prerequisites:**
1. **Conventional Commits Adoption:** Team must follow commit message format consistently
2. **Git Tags:** At least one initial tag (e.g., `v1.0.0`) to establish baseline
3. **GitHub Actions:** Existing CI/CD pipeline (already planned from previous research)
4. **Semantic Versioning Knowledge:** Team understands MAJOR.MINOR.PATCH meanings

**Dependencies (Recommended Approach):**
- **GitHub Action:** ietf-tools/semver-action (runs in container, no project dependency)
- **Bash/Sed:** Built-in Linux tools (no installation required)
- **Optional:** commitlint_cli + husky (Dart dev dependencies for commit linting)

**Performance Implications:**
- Version calculation adds ~5-10 seconds to CI build
- Bash script execution: <1 second
- No impact on app runtime performance (build-time only)
- Negligible impact compared to Flutter build time (~5-10 minutes)

**Build Number Strategy:**
- **Source:** GitHub Actions run number (`${{ github.run_number }}`)
- **Format:** Sequential integer starting from 1
- **Persistence:** Managed by GitHub (automatically increments per workflow)
- **Uniqueness:** Guaranteed unique per repository
- **Reset Risk:** None (persists across all workflows)

### Integration Points

**Repository Structure:**
```
/Users/jonascurth/later/
├── .github/
│   └── workflows/
│       ├── pr-checks.yml          # No version changes (validation only)
│       └── deploy-internal.yml    # Version bump + tag + deploy
├── apps/later_mobile/
│   ├── pubspec.yaml               # Version field updated by CI
│   └── ...
├── commitlint.yaml                # Optional: commit message validation
└── .husky/                        # Optional: git hooks for local validation
    └── commit-msg
```

**Workflow Modifications (deploy-internal.yml):**

```yaml
name: Deploy to Play Store Internal Testing

on:
  push:
    branches: [ main ]
    paths:
      - 'apps/later_mobile/**'
      - '.github/workflows/deploy-internal.yml'

jobs:
  deploy:
    name: Build, Version, and Deploy
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for commit history analysis

      # NEW: Calculate next semantic version
      - name: Calculate Next Version
        id: semver
        uses: ietf-tools/semver-action@v1
        with:
          token: ${{ github.token }}
          branch: main

      # NEW: Update pubspec.yaml with calculated version
      - name: Update Version in pubspec.yaml
        run: |
          VERSION="${{ steps.semver.outputs.nextStrict }}"
          BUILD_NUMBER="${{ github.run_number }}"
          echo "Updating version to $VERSION+$BUILD_NUMBER"
          sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" apps/later_mobile/pubspec.yaml
          cat apps/later_mobile/pubspec.yaml | grep "^version:"

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
          cache: 'gradle'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        working-directory: apps/later_mobile
        run: flutter pub get

      - name: Run tests
        working-directory: apps/later_mobile
        run: flutter test

      - name: Decode keystore
        working-directory: apps/later_mobile
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks

      - name: Create key.properties
        working-directory: apps/later_mobile
        run: |
          cat > android/key.properties << EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=upload-keystore.jks
          EOF

      - name: Build App Bundle
        working-directory: apps/later_mobile
        run: flutter build appbundle --release

      - name: Upload to Play Store Internal Testing
        uses: r0adkll/upload-google-play@v1.1.3
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: dev.curth.later
          releaseFiles: apps/later_mobile/build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed
          inAppUpdatePriority: 2

      # NEW: Create git tag after successful deployment
      - name: Create Git Tag
        if: success()
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git tag -a v${{ steps.semver.outputs.nextStrict }} -m "Release v${{ steps.semver.outputs.nextStrict }}"
          git push origin v${{ steps.semver.outputs.nextStrict }}

      - name: Upload AAB artifact
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: release-aab-${{ github.run_number }}
          path: apps/later_mobile/build/app/outputs/bundle/release/app-release.aab
          retention-days: 30

      - name: Clean up secrets
        if: always()
        working-directory: apps/later_mobile
        run: |
          rm -f android/app/upload-keystore.jks
          rm -f android/key.properties
```

**Initial Setup Steps:**

1. **Create Initial Git Tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   This establishes the baseline version for the semver-action to calculate from.

2. **Update pubspec.yaml (One Time):**
   ```yaml
   # apps/later_mobile/pubspec.yaml
   version: 1.0.0+1  # This will be overwritten by CI
   ```
   The version in the file becomes a placeholder - CI will update it before building.

3. **Optional: Set Up Commit Linting:**
   ```bash
   cd apps/later_mobile
   dart pub add --dev commitlint_cli husky
   dart run husky install
   dart run husky add .husky/commit-msg 'dart run commitlint_cli --edit $1'
   ```
   Create `commitlint.yaml` at repository root with validation rules.

### Risks and Mitigation

| Risk | Severity | Mitigation Strategy |
|------|----------|---------------------|
| **Developers not following Conventional Commits** | High | Implement commit linting with commitlint_cli + husky to block invalid commits. Provide team training and clear examples in CONTRIBUTING.md. |
| **First-time setup without git tags** | Medium | Require creating initial v1.0.0 tag before enabling automated versioning. Document in setup guide. |
| **Version calculation fails (no matching commits)** | Low | semver-action outputs "none" for bump type. Handle in workflow with conditional logic or default to patch bump. |
| **Sed command fails on different OS (macOS vs Linux)** | Low | Use Linux-only sed syntax (`-i` without backup extension) since GitHub Actions runs Ubuntu. Test locally with Docker if needed. |
| **Build number collision (workflow reruns)** | Very Low | GitHub run number is unique per workflow execution, including reruns. No collision possible. |
| **Forgetting to push git tags** | Medium | Automate tag creation and push in workflow (shown in example). Use `if: success()` to only tag after successful deployment. |
| **Breaking commit message parsing** | Low | semver-action is robust and handles malformed commits gracefully. Falls back to patch bump or no bump. |
| **Team confusion about version meanings** | Medium | Document semantic versioning rules clearly (MAJOR = breaking, MINOR = feature, PATCH = bugfix). Provide examples in CONTRIBUTING.md. |

**Rollback Strategy:**
1. **Version Reverts:** If version is incorrect, manually create corrective commit and tag
2. **Workflow Failures:** Version is only tagged after successful deployment - no partial updates
3. **Emergency Manual Release:** Can bypass automation by manually updating pubspec.yaml and building locally
4. **Tag Cleanup:** Delete incorrect tags: `git tag -d v1.2.3 && git push origin :refs/tags/v1.2.3`

## Recommendations

### Recommended Approach: Conventional Commits + GitHub Action + Bash Script

**Reasoning:**
- ✅ **Simplicity:** Minimal dependencies (one GitHub Action, built-in bash tools)
- ✅ **Maintainability:** Easy to understand, debug, and modify
- ✅ **Team Readiness:** Project already partially uses Conventional Commits
- ✅ **No Overhead:** No Node.js, Ruby, or additional tooling required
- ✅ **Integration:** Works seamlessly with existing CI/CD plan
- ✅ **Cost-Effective:** Free GitHub Action, no paid tools
- ✅ **Flexibility:** Easy to customize bash script if needed

**Why Not semantic-release:**
- Overkill for this use case (just need version bumping, not full release management)
- Adds Node.js dependency to Flutter project (unnecessary complexity)
- Steeper learning curve for features not needed (changelog, plugins, etc.)
- semantic-release-pub plugin is less mature than alternatives

**Why Not Fastlane:**
- Project not currently using Fastlane (from previous research)
- Doesn't automatically parse commit messages (still manual version decisions)
- Adds Ruby dependency and slower build times
- Better suited when also deploying to iOS (not in current scope)

### Implementation Strategy

**Phase 1: Foundation Setup (Week 1)**

1. **Create Initial Git Tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Document Conventional Commits Guidelines:**
   Create `.github/CONTRIBUTING.md` with:
   - Commit message format: `<type>(<scope>): <description>`
   - Type definitions: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
   - Examples of good commit messages
   - Version bump mapping (feat → MINOR, fix → PATCH, BREAKING CHANGE → MAJOR)

3. **Team Training:**
   - Review Conventional Commits with team (15 minute meeting)
   - Share examples from existing good commits in project
   - Emphasize importance for automated versioning

**Phase 2: Commit Linting (Week 1-2)**

4. **Install Dart Commit Linting Tools:**
   ```bash
   cd apps/later_mobile
   dart pub add --dev commitlint_cli husky
   dart run husky install
   ```

5. **Configure Commitlint:**
   Create `commitlint.yaml` at repository root:
   ```yaml
   include: package:commitlint_cli/commitlint.yaml

   rules:
     type-enum:
       - error
       - always
       - [feat, fix, docs, style, refactor, test, chore]
     type-case:
       - error
       - always
       - lower-case
     subject-empty:
       - error
       - never
     subject-full-stop:
       - error
       - never
       - '.'
   ```

6. **Set Up Git Hook:**
   ```bash
   dart run husky add .husky/commit-msg 'dart run commitlint_cli --edit $1'
   ```

7. **Test Locally:**
   ```bash
   # Should fail
   git commit -m "bad commit message"

   # Should succeed
   git commit -m "feat: add new feature"
   ```

**Phase 3: CI/CD Integration (Week 2)**

8. **Update deploy-internal.yml Workflow:**
   Add version calculation and pubspec.yaml update steps (see full example in Integration Points section above).

9. **Test Version Calculation:**
   - Create test branch
   - Make commit with `feat: test version automation`
   - Create PR and merge to main
   - Verify workflow calculates version and updates pubspec.yaml
   - Check git tags created automatically

10. **Verify Play Store Upload:**
    - Ensure AAB uploaded to internal testing has correct version
    - Check Play Console shows new version number
    - Test installation on device

**Phase 4: Documentation and Monitoring (Week 2-3)**

11. **Update Documentation:**
    - Update `.claude/plans/` with implemented approach
    - Add versioning section to main README.md
    - Document rollback procedures

12. **Monitor First Few Releases:**
    - Watch GitHub Actions logs for version calculation
    - Verify tags created correctly
    - Check for any team confusion with commit messages

13. **Iterate Based on Feedback:**
    - Adjust commit linting rules if too strict
    - Add more examples to CONTRIBUTING.md
    - Address any edge cases discovered

### Alternative Approach: Defer Commit Linting (If Team Resistance)

If the team finds commit linting too restrictive initially, you can defer Phase 2 and implement only Phase 1 + Phase 3:

**Pros:**
- Lower friction for initial adoption
- Faster implementation (skip linting setup)
- Team can learn Conventional Commits gradually

**Cons:**
- Risk of incorrect commit messages breaking version calculation
- May lead to incorrect version bumps
- Need to fix bad commits manually (rebase/amend)

**Mitigation:**
- Rely on PR review process to catch bad commit messages
- Add commit message guidelines to PR template
- Implement linting after 2-3 successful releases when team is comfortable

### Recommended Configuration Files

**1. Initial Git Tag Command:**
```bash
# Run once before implementing automation
git tag -a v1.0.0 -m "Initial version for semantic versioning"
git push origin v1.0.0
```

**2. Commit Linting Configuration (commitlint.yaml):**
```yaml
# Repository root: /Users/jonascurth/later/commitlint.yaml

include: package:commitlint_cli/commitlint.yaml

rules:
  # Enforce type is one of the allowed values
  type-enum:
    - error
    - always
    - [feat, fix, docs, style, refactor, test, chore, perf, ci]

  # Type must be lowercase
  type-case:
    - error
    - always
    - lower-case

  # Subject cannot be empty
  subject-empty:
    - error
    - never

  # Subject cannot end with period
  subject-full-stop:
    - error
    - never
    - '.'

  # Subject must be in sentence-case (lowercase first letter)
  subject-case:
    - error
    - always
    - sentence-case

  # Header (type + subject) max length
  header-max-length:
    - warning
    - always
    - 72
```

**3. Husky Setup (if using commit linting):**
```bash
# Add to apps/later_mobile/pubspec.yaml dev_dependencies:
dev_dependencies:
  commitlint_cli: ^0.7.1
  husky: ^1.1.1

# Then run:
cd apps/later_mobile
dart pub get
dart run husky install

# Create commit-msg hook:
dart run husky add .husky/commit-msg 'dart run commitlint_cli --edit $1'
```

**4. Updated deploy-internal.yml (Key Sections):**
```yaml
# Add to beginning of job steps:
steps:
  - name: Checkout code
    uses: actions/checkout@v4
    with:
      fetch-depth: 0  # IMPORTANT: Required for full commit history

  - name: Calculate Next Version
    id: semver
    uses: ietf-tools/semver-action@v1
    with:
      token: ${{ github.token }}
      branch: main
      noVersionBumpBehavior: patch  # Default to patch if no version bump detected
      noNewCommitBehavior: current  # Keep current version if no new commits

  - name: Display Calculated Version
    run: |
      echo "Current Version: ${{ steps.semver.outputs.current }}"
      echo "Next Version: ${{ steps.semver.outputs.nextStrict }}"
      echo "Bump Type: ${{ steps.semver.outputs.bump }}"

  - name: Update Version in pubspec.yaml
    run: |
      VERSION="${{ steps.semver.outputs.nextStrict }}"
      BUILD_NUMBER="${{ github.run_number }}"

      echo "📦 Updating version to $VERSION+$BUILD_NUMBER"

      # Update version line in pubspec.yaml
      sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" apps/later_mobile/pubspec.yaml

      # Display updated version for verification
      echo "✅ Updated version:"
      grep "^version:" apps/later_mobile/pubspec.yaml

  # ... existing build and deployment steps ...

  # Add at end of job steps (before cleanup):
  - name: Create Git Tag
    if: success() && steps.semver.outputs.bump != 'none'
    run: |
      VERSION="${{ steps.semver.outputs.nextStrict }}"

      echo "🏷️  Creating git tag v$VERSION"

      git config user.name "github-actions[bot]"
      git config user.email "github-actions[bot]@users.noreply.github.com"

      git tag -a "v$VERSION" -m "Release v$VERSION - Build ${{ github.run_number }}"
      git push origin "v$VERSION"

      echo "✅ Tag v$VERSION created and pushed"

  - name: Create GitHub Release
    if: success() && steps.semver.outputs.bump != 'none'
    uses: actions/create-release@v1
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    with:
      tag_name: v${{ steps.semver.outputs.nextStrict }}
      release_name: Release v${{ steps.semver.outputs.nextStrict }}
      body: |
        ## Changes
        See commit history for details.

        **Build Number:** ${{ github.run_number }}
        **Version:** ${{ steps.semver.outputs.nextStrict }}+${{ github.run_number }}
      draft: false
      prerelease: false
```

**5. Contributing Guidelines (.github/CONTRIBUTING.md):**
```markdown
# Contributing to Later

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) for automated semantic versioning.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- **feat**: New feature (triggers MINOR version bump, e.g., 1.0.0 → 1.1.0)
- **fix**: Bug fix (triggers PATCH version bump, e.g., 1.0.0 → 1.0.1)
- **docs**: Documentation changes (no version bump)
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code refactoring (no feature or bug fix)
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (dependencies, config, etc.)
- **perf**: Performance improvements
- **ci**: CI/CD configuration changes

### Breaking Changes

To trigger a MAJOR version bump (e.g., 1.0.0 → 2.0.0):

```
feat!: change API endpoint structure

BREAKING CHANGE: The API endpoint /api/v1/items is now /api/v2/items
```

### Examples

Good commit messages:
- `feat(search): add full-text search for notes`
- `fix(auth): resolve session timeout issue`
- `docs: update installation instructions`
- `refactor(ui): simplify button component structure`
- `test(models): add tests for TodoList serialization`

Bad commit messages:
- `update stuff` (no type, unclear description)
- `Fix bug` (capitalized, not specific enough)
- `feat:add feature` (missing space after colon)
- `added new search feature` (wrong tense, no type)

### Commit Linting

Commits are automatically validated using commitlint. If your commit message doesn't follow the format, the commit will be rejected with an error message explaining the issue.

To bypass linting (not recommended):
```bash
git commit --no-verify -m "message"
```
```

## Step-by-Step Implementation Guide

### Prerequisites Verification

Before implementing automated versioning, verify the following:

✅ **Git Repository:** Project is a git repository with commit history
✅ **GitHub Actions:** Repository has Actions enabled (check Settings → Actions)
✅ **Existing CI/CD:** GitHub Actions workflows directory exists (`.github/workflows/`)
✅ **Conventional Commits:** Team understands commit message format
✅ **Semantic Versioning:** Team understands MAJOR.MINOR.PATCH meanings

### Part A: Initial Setup and Git Tagging

#### Step 1: Create Baseline Git Tag

The semver-action requires at least one existing tag to calculate the next version.

```bash
# From repository root
cd /Users/jonascurth/later

# Create initial tag (use current version from pubspec.yaml)
git tag -a v1.0.0 -m "Initial version for semantic versioning automation"

# Push tag to remote
git push origin v1.0.0

# Verify tag created
git tag --list
```

**Output:**
```
v1.0.0
```

**Important Notes:**
- This is a one-time operation
- Use the current version from `pubspec.yaml` (1.0.0+1 → v1.0.0)
- All future versions will be calculated automatically from commit messages
- The `v` prefix is conventional for version tags (semver-action expects it)

#### Step 2: Document Conventional Commits Guidelines

Create `.github/CONTRIBUTING.md` to guide developers on commit message format.

```bash
mkdir -p .github
```

Create the file with content from "Recommended Configuration Files" section above (see **5. Contributing Guidelines**).

```bash
# Review with team
cat .github/CONTRIBUTING.md
```

#### Step 3: Optional - Add Commit Message Template

Create `.gitmessage` template to help developers format commits correctly:

```bash
# Repository root: /Users/jonascurth/later/.gitmessage
cat > .gitmessage << 'EOF'
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>
#
# Type: feat, fix, docs, style, refactor, test, chore, perf, ci
# Scope: area of codebase (search, auth, ui, etc.)
# Subject: imperative mood, lowercase, no period
#
# Body: explain what and why (optional)
# Footer: BREAKING CHANGE or issue references (optional)
#
# Examples:
#   feat(search): add full-text search for notes
#   fix(auth): resolve session timeout issue
#   docs: update installation instructions
EOF

# Configure git to use template
git config commit.template .gitmessage
```

### Part B: Optional - Commit Linting Setup

This step is optional but recommended to prevent invalid commit messages from breaking version calculation.

#### Step 1: Install Dart Packages

```bash
cd apps/later_mobile

# Add commitlint and husky to dev dependencies
dart pub add --dev commitlint_cli
dart pub add --dev husky

# Install dependencies
dart pub get
```

**Expected Output:**
```
Resolving dependencies...
+ commitlint_cli 0.7.1
+ husky 1.1.1
Changed 2 dependencies!
```

#### Step 2: Initialize Husky

```bash
# Initialize git hooks directory
dart run husky install
```

**Expected Output:**
```
✔ Git hooks installed successfully
✔ .husky directory created
```

#### Step 3: Create Commitlint Configuration

From repository root (`/Users/jonascurth/later/`), create `commitlint.yaml`:

```bash
cd /Users/jonascurth/later

# Use configuration from "Recommended Configuration Files" section above
# (see **2. Commit Linting Configuration**)
```

Content:
```yaml
include: package:commitlint_cli/commitlint.yaml

rules:
  type-enum:
    - error
    - always
    - [feat, fix, docs, style, refactor, test, chore, perf, ci]

  type-case:
    - error
    - always
    - lower-case

  subject-empty:
    - error
    - never

  subject-full-stop:
    - error
    - never
    - '.'

  subject-case:
    - error
    - always
    - sentence-case

  header-max-length:
    - warning
    - always
    - 72
```

#### Step 4: Add Commit Message Hook

```bash
cd apps/later_mobile

# Add commit-msg hook to validate messages
dart run husky add .husky/commit-msg 'dart run commitlint_cli --edit $1'
```

**Expected Output:**
```
✔ Hook added: .husky/commit-msg
```

#### Step 5: Test Commit Linting Locally

```bash
# Test invalid commit message (should fail)
git commit --allow-empty -m "bad message"

# Expected error:
# ✖ subject may not be empty
# ✖ type may not be empty
```

```bash
# Test valid commit message (should succeed)
git commit --allow-empty -m "test: verify commit linting works"

# Expected:
# [main abc1234] test: verify commit linting works
```

#### Step 6: Commit Linting Setup

```bash
# Add commitlint config and husky directory to git
git add commitlint.yaml apps/later_mobile/pubspec.yaml .husky/

git commit -m "ci: add commit message linting with commitlint and husky"

git push origin main
```

### Part C: GitHub Actions Workflow Update

#### Step 1: Backup Existing Workflow

```bash
cd /Users/jonascurth/later/.github/workflows

# Create backup
cp deploy-internal.yml deploy-internal.yml.backup
```

#### Step 2: Update deploy-internal.yml

Open `.github/workflows/deploy-internal.yml` and make the following changes:

**Add to the beginning of job steps (after checkout):**

```yaml
- name: Checkout code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0  # ⬅️ IMPORTANT: Add this line (was probably missing)

# ⬇️ ADD THESE NEW STEPS:
- name: Calculate Next Version
  id: semver
  uses: ietf-tools/semver-action@v1
  with:
    token: ${{ github.token }}
    branch: main
    noVersionBumpBehavior: patch
    noNewCommitBehavior: current

- name: Display Calculated Version
  run: |
    echo "📊 Version Calculation Results:"
    echo "  Current Version: ${{ steps.semver.outputs.current }}"
    echo "  Next Version: ${{ steps.semver.outputs.nextStrict }}"
    echo "  Bump Type: ${{ steps.semver.outputs.bump }}"
    echo ""

- name: Update Version in pubspec.yaml
  run: |
    VERSION="${{ steps.semver.outputs.nextStrict }}"
    BUILD_NUMBER="${{ github.run_number }}"

    echo "📦 Updating version to $VERSION+$BUILD_NUMBER"

    sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" apps/later_mobile/pubspec.yaml

    echo "✅ Updated version:"
    grep "^version:" apps/later_mobile/pubspec.yaml
```

**Add before the cleanup step at the end:**

```yaml
- name: Create Git Tag
  if: success() && steps.semver.outputs.bump != 'none'
  run: |
    VERSION="${{ steps.semver.outputs.nextStrict }}"

    echo "🏷️  Creating git tag v$VERSION"

    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"

    git tag -a "v$VERSION" -m "Release v$VERSION - Build ${{ github.run_number }}"
    git push origin "v$VERSION"

    echo "✅ Tag v$VERSION created and pushed"

- name: Create GitHub Release
  if: success() && steps.semver.outputs.bump != 'none'
  uses: actions/create-release@v1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    tag_name: v${{ steps.semver.outputs.nextStrict }}
    release_name: Release v${{ steps.semver.outputs.nextStrict }}
    body: |
      ## Changes
      See commit history for details.

      **Build Number:** ${{ github.run_number }}
      **Version:** ${{ steps.semver.outputs.nextStrict }}+${{ github.run_number }}
    draft: false
    prerelease: false
```

**Full example workflow provided in Integration Points section above.**

#### Step 3: Commit Workflow Changes

```bash
cd /Users/jonascurth/later

git add .github/workflows/deploy-internal.yml

git commit -m "ci: add automated semantic versioning to deployment workflow"

git push origin main
```

**Note:** This push will trigger the workflow, but since there are no `feat` or `fix` commits since v1.0.0, the version will remain 1.0.0.

### Part D: Testing and Validation

#### Step 1: Create Test Feature Branch

```bash
cd /Users/jonascurth/later

git checkout -b test/version-automation
```

#### Step 2: Make Test Commit

```bash
# Make a small, safe change (add comment to pubspec.yaml)
cd apps/later_mobile

# Add a comment
echo "# Test semantic versioning automation" >> pubspec.yaml

git add pubspec.yaml

git commit -m "feat(ci): add semantic versioning automation

This enables automatic version calculation based on conventional commits.
Version numbers will be updated in pubspec.yaml during CI builds."

git push origin test/version-automation
```

#### Step 3: Create Pull Request

1. Go to GitHub repository
2. Create Pull Request from `test/version-automation` to `main`
3. Verify PR checks pass (no version changes in PR workflow)
4. Add description explaining the test
5. Merge the PR

#### Step 4: Monitor Deployment Workflow

1. Go to GitHub Actions tab
2. Click on "Deploy to Play Store Internal Testing" workflow
3. Watch the execution in real-time

**Expected output in logs:**

```
📊 Version Calculation Results:
  Current Version: 1.0.0
  Next Version: 1.1.0
  Bump Type: minor

📦 Updating version to 1.1.0+42

✅ Updated version:
version: 1.1.0+42
```

(Where `42` is the GitHub run number)

#### Step 5: Verify Version in Play Console

1. Go to https://play.google.com/console
2. Navigate to Testing → Internal testing
3. Verify new release shows **1.1.0 (42)** or similar
4. Download and install on test device
5. Check app info shows new version number

#### Step 6: Verify Git Tag Created

```bash
cd /Users/jonascurth/later

git fetch --tags

git tag --list
```

**Expected output:**
```
v1.0.0
v1.1.0
```

```bash
# View tag details
git show v1.1.0
```

**Expected output:**
```
tag v1.1.0
Tagger: github-actions[bot] <github-actions[bot]@users.noreply.github.com>
Date:   ...

Release v1.1.0 - Build 42

commit abc1234...
...
```

#### Step 7: Verify GitHub Release Created

1. Go to GitHub repository
2. Click "Releases" in right sidebar
3. Verify "Release v1.1.0" exists with:
   - Tag: v1.1.0
   - Build Number listed in description
   - Commit history link

### Part E: Team Training and Documentation

#### Step 1: Share Guidelines with Team

Send email or Slack message with:
- Link to `.github/CONTRIBUTING.md`
- Summary of commit message format
- Examples of good/bad commits
- Link to Conventional Commits spec (https://www.conventionalcommits.org/)

#### Step 2: Update Project README

Add section to main `README.md`:

```markdown
## Versioning

This project uses automated semantic versioning based on [Conventional Commits](https://www.conventionalcommits.org/).

### Commit Message Format

```
<type>(<scope>): <description>
```

**Types:**
- `feat`: New feature (bumps MINOR version)
- `fix`: Bug fix (bumps PATCH version)
- `docs`: Documentation only
- `style`, `refactor`, `test`, `chore`: No version bump

**Breaking Changes:** Add `BREAKING CHANGE:` in footer or `!` after type (bumps MAJOR version)

### Version Numbers

Versions follow the format `MAJOR.MINOR.PATCH+BUILD_NUMBER`:
- **MAJOR**: Incompatible API changes (breaking changes)
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)
- **BUILD_NUMBER**: Sequential build identifier (auto-incremented)

Versions are calculated automatically from commit messages during CI/CD deployment.

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for detailed guidelines.
```

#### Step 3: Schedule Team Training Session

Hold a 15-minute meeting to:
1. Explain semantic versioning and Conventional Commits
2. Show examples from project commits
3. Demonstrate commit linting (if implemented)
4. Answer questions
5. Share cheat sheet

#### Step 4: Monitor First Few Releases

For the next 3-5 releases:
- Review commit messages in PRs
- Provide feedback on format
- Check that versions bump correctly
- Address any confusion or issues

#### Step 5: Iterate Based on Feedback

- Adjust commitlint rules if too strict
- Add more examples to docs
- Create FAQ section for common questions

## Appendix

### A. Commit Message Type Reference

| Type | Description | Version Bump | Example |
|------|-------------|--------------|---------|
| `feat` | New feature | MINOR (1.0.0 → 1.1.0) | `feat(auth): add Google login` |
| `fix` | Bug fix | PATCH (1.0.0 → 1.0.1) | `fix(ui): resolve button alignment` |
| `docs` | Documentation | None | `docs: update README installation steps` |
| `style` | Code style (formatting) | None | `style: format with dart format` |
| `refactor` | Code refactoring | None | `refactor(api): simplify error handling` |
| `perf` | Performance improvement | PATCH | `perf(db): optimize query performance` |
| `test` | Add or update tests | None | `test(models): add TodoList serialization tests` |
| `chore` | Maintenance tasks | None | `chore: update dependencies` |
| `ci` | CI/CD changes | None | `ci: add caching to workflow` |
| `feat!` or `BREAKING CHANGE:` | Breaking change | MAJOR (1.0.0 → 2.0.0) | `feat!: change API endpoint structure` |

### B. Troubleshooting Guide

**Issue: "No tags found" error in semver-action**

**Cause:** No initial git tag exists in repository.

**Solution:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

---

**Issue: Version doesn't bump as expected**

**Cause:** Commit messages don't follow Conventional Commits format.

**Solution:**
1. Check commit messages since last tag: `git log v1.0.0..HEAD --oneline`
2. Verify at least one commit has `feat:` or `fix:` prefix
3. If needed, amend latest commit: `git commit --amend -m "feat: ..."`

---

**Issue: Commit linting blocks valid commits**

**Cause:** Rules in `commitlint.yaml` may be too strict or incorrectly configured.

**Solution:**
1. Check error message for specific rule violation
2. Review `commitlint.yaml` configuration
3. Adjust rules or fix commit message format
4. Temporary bypass: `git commit --no-verify -m "..."` (not recommended)

---

**Issue: sed command fails on macOS (local testing)**

**Cause:** macOS sed requires backup extension with `-i` flag.

**Solution:**
```bash
# macOS version
sed -i '' "s/^version: .*/version: 1.2.0+1/" pubspec.yaml

# Linux version (GitHub Actions)
sed -i "s/^version: .*/version: 1.2.0+1/" pubspec.yaml
```

**Note:** GitHub Actions uses Ubuntu Linux, so the workflow is correct. Only local testing on macOS needs adjustment.

---

**Issue: Build number doesn't increment**

**Cause:** Using wrong variable or workflow not running.

**Solution:**
1. Verify using `${{ github.run_number }}` not `${{ github.run_id }}`
2. Check workflow is triggered (not skipped by path filters)
3. View workflow logs to see actual build number used

---

**Issue: Git tag push fails with "permission denied"**

**Cause:** GitHub token doesn't have write permissions.

**Solution:**
1. Ensure workflow has `permissions: contents: write`
2. Check repository settings allow workflow write access
3. Use `GITHUB_TOKEN` secret (automatically available)

---

**Issue: "Version already exists" error in Play Console**

**Cause:** Build number collision (same version code as previous upload).

**Solution:**
1. Verify using `${{ github.run_number }}` for build number (should be unique)
2. Check previous build didn't fail and retry with same number
3. If needed, manually increment version in pubspec.yaml and rebuild

---

**Issue: Workflow runs but version stays the same (no bump)**

**Cause:** No `feat` or `fix` commits since last tag, or `noVersionBumpBehavior` configuration.

**Solution:**
1. Check commit history: `git log v1.0.0..HEAD --oneline`
2. Verify at least one commit has version-bumping prefix
3. Review semver-action `noVersionBumpBehavior` setting (set to `patch` to force patch bump if no matching commits)

### C. Semantic Versioning Decision Tree

```
                    ┌─────────────────────────────┐
                    │   Making a change?          │
                    └──────────┬──────────────────┘
                               │
                               │
                ┌──────────────┴──────────────┐
                │                             │
      ┌─────────▼─────────┐         ┌────────▼──────────┐
      │ Breaking change?  │         │ New feature?      │
      │ (API change)      │         │ (new capability)  │
      └─────────┬─────────┘         └────────┬──────────┘
                │                             │
            YES │ NO                      YES │ NO
                │                             │
      ┌─────────▼─────────┐         ┌────────▼──────────┐
      │  MAJOR version    │         │  MINOR version    │
      │  (1.0.0 → 2.0.0)  │         │  (1.0.0 → 1.1.0)  │
      │                   │         │                   │
      │  Use:             │         │  Use:             │
      │  feat!: message   │         │  feat: message    │
      │  or               │         │                   │
      │  BREAKING CHANGE  │         │                   │
      └───────────────────┘         └───────────────────┘
                                              │
                                              │
                                    ┌─────────▼─────────┐
                                    │  Bug fix?         │
                                    │  (no new features)│
                                    └─────────┬─────────┘
                                              │
                                          YES │ NO
                                              │
                                    ┌─────────▼─────────┐
                                    │  PATCH version    │
                                    │  (1.0.0 → 1.0.1)  │
                                    │                   │
                                    │  Use:             │
                                    │  fix: message     │
                                    └───────────────────┘
                                              │
                                              │
                                    ┌─────────▼─────────┐
                                    │  No version bump  │
                                    │                   │
                                    │  Use:             │
                                    │  docs:            │
                                    │  style:           │
                                    │  refactor:        │
                                    │  test:            │
                                    │  chore:           │
                                    └───────────────────┘
```

### D. Version History Example

Example showing how version numbers evolve with different commit types:

```
v1.0.0  ← Initial release
  ↓
  feat(auth): add password reset
  ↓
v1.1.0  ← New feature (MINOR bump)
  ↓
  fix(ui): correct button color
  ↓
v1.1.1  ← Bug fix (PATCH bump)
  ↓
  feat(search): add full-text search
  ↓
v1.2.0  ← New feature (MINOR bump)
  ↓
  docs: update README
  chore: update dependencies
  ↓
v1.2.0  ← No bump (non-code changes)
  ↓
  fix(db): resolve connection timeout
  ↓
v1.2.1  ← Bug fix (PATCH bump)
  ↓
  feat!: change API authentication method
  BREAKING CHANGE: OAuth2 now required
  ↓
v2.0.0  ← Breaking change (MAJOR bump)
```

### E. Quick Reference Cheat Sheet

**Commit Message Format:**
```
<type>(<scope>): <description>
```

**Common Types:**
- `feat` → New feature → Bumps MINOR
- `fix` → Bug fix → Bumps PATCH
- `feat!` or `BREAKING CHANGE` → Breaking → Bumps MAJOR

**Examples:**
```bash
# New feature
git commit -m "feat(search): add full-text search"

# Bug fix
git commit -m "fix(auth): resolve session timeout"

# Breaking change (method 1)
git commit -m "feat!(api): change endpoint structure"

# Breaking change (method 2)
git commit -m "feat(api): change endpoint structure

BREAKING CHANGE: /api/v1/items moved to /api/v2/items"

# Documentation (no version bump)
git commit -m "docs: update installation guide"
```

**Version Format:**
```
MAJOR.MINOR.PATCH+BUILD_NUMBER
   ↑     ↑     ↑        ↑
   │     │     │        └─ Sequential build ID (GitHub run number)
   │     │     └────────── Bug fixes (fix:)
   │     └──────────────── New features (feat:)
   └────────────────────── Breaking changes (feat!: or BREAKING CHANGE)
```

**Testing Locally:**
```bash
# Test commit linting
git commit --allow-empty -m "test: verify commit format"

# Bypass linting (not recommended)
git commit --no-verify -m "message"

# View recent commits
git log --oneline -10

# Check current tags
git tag --list
```

## References

1. **Conventional Commits Specification:** https://www.conventionalcommits.org/
2. **Semantic Versioning 2.0.0:** https://semver.org/
3. **ietf-tools/semver-action:** https://github.com/ietf-tools/semver-action
4. **Flutter Official Versioning Documentation:** https://docs.flutter.dev/deployment/android#versioning-the-app
5. **GitHub Actions Documentation:** https://docs.github.com/en/actions
6. **commitlint_cli (Dart package):** https://pub.dev/packages/commitlint_cli
7. **husky (Dart package):** https://pub.dev/packages/husky
8. **semantic-release-pub:** https://github.com/zeshuaro/semantic-release-pub
9. **Medium - Automating Versioning in Flutter Projects (2025):** https://medium.com/fludev/automating-versioning-and-changelog-in-flutter-projects-755274f4499b
10. **Stack Overflow - Flutter Automatic Versioning:** https://stackoverflow.com/questions/75436391/flutter-and-automatic-versioning
