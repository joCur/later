# CI/CD Automation with Google Play Store Deployment and Semantic Versioning

## Objective and Scope

Implement a complete CI/CD pipeline for the Later Flutter mobile app that:
- **Validates** all pull requests with automated build and test checks
- **Automatically deploys** to Google Play Store Internal Testing after merge to main
- **Manages versions** automatically using Conventional Commits (no manual pubspec.yaml updates)
- **Injects Supabase environment variables** securely during the build process
- **Guides you through** first-time Google Play Console setup with step-by-step instructions

**Scope**: Android-only deployment to Google Play Store Internal Testing track. iOS deployment is explicitly excluded.

## Technical Approach and Reasoning

### Architecture Overview

**Workflow Strategy:**
- **PR Workflow** (`pr-checks.yml`): Runs on every pull request to validate code quality, tests, and build integrity without deploying
- **Deployment Workflow** (`deploy-internal.yml`): Runs on merge to `main` branch, calculates semantic version, builds signed AAB, and deploys to Play Store

**Semantic Versioning:**
- Use **ietf-tools/semver-action** to calculate versions from Conventional Commits (no Node.js dependencies)
- Version format: `MAJOR.MINOR.PATCH+BUILD_NUMBER` where build number is GitHub run number
- Git tags created automatically after successful deployments
- Initial baseline tag (`v1.0.0`) required before automation starts

**Environment Variables:**
- Supabase credentials (API URL, anon key) stored as GitHub secrets
- Injected into Flutter build via `--dart-define` flags
- No hardcoded credentials in codebase or version control

**Signing Strategy:**
- Generate release keystore once, encode as base64, store in GitHub secrets
- Keystore decoded dynamically during CI builds
- Temporary `key.properties` file created in CI, never committed
- Play App Signing enabled in Play Console for Google-managed key security

**Testing Strategy:**
- All tests must pass in PR workflow before merge allowed
- Deployment workflow runs tests again as safety check before publishing
- Test failures block deployment automatically

### Why This Approach

1. **Simple over Complex**: Using GitHub Actions marketplace actions instead of Fastlane avoids Ruby dependencies and complexity
2. **No Manual Version Updates**: Conventional Commits + semver-action eliminates manual pubspec.yaml edits
3. **Security-First**: All secrets in GitHub Secrets, no credentials in code, RLS policies in Supabase
4. **Fail-Fast**: PR checks catch issues early before merge, preventing broken deployments
5. **Audit Trail**: Git tags + GitHub Releases provide complete version history

## Implementation Phases

### Phase 1: Google Play Console First-Time Setup

**Prerequisites**: Google Play Developer account ($25 one-time fee), app not yet published

- [x] Task 1.1: Create Google Play Developer account
  - Navigate to https://play.google.com/console
  - Sign in with your Google Account (use account that will manage the app)
  - Accept the Google Play Developer Distribution Agreement
  - Pay the $25 one-time registration fee
  - Choose account type: **Personal** (unless you have a business entity)
  - Complete identity verification if prompted (required for new accounts)
  - Enable two-step verification on your Google Account (required for security)
  - **Note**: If your account was created after November 13, 2023, you must complete 14 days of closed testing with 12+ testers before accessing Production tab

- [x] Task 1.2: Create app in Play Console
  - In Play Console, select **Home** → **Create app**
  - Fill in required information:
    - **Default language**: English (United States)
    - **App name**: Later (or your preferred app name)
    - **App or game**: App
    - **Free or Paid**: Free
  - Acknowledge declarations:
    - ✓ Developer Program Policies compliance
    - ✓ US export laws compliance
  - Accept Play App Signing Terms of Service
  - Click **Create app**
  - Note the **Package name** displayed (should be `dev.curth.later` from your Flutter app)

- [x] Task 1.3: Complete app dashboard requirements
  - Navigate to **Dashboard** to see required tasks checklist
  - **Store Listing** section:
    - **App name**: Later (max 50 characters)
    - **Short description**: Brief app description (max 80 characters, e.g., "Flexible task and note organizer without rigid structures")
    - **Full description**: Detailed app description (max 4000 characters) - describe Later's features, spaces, notes, todo lists, etc.
    - **App icon**: 512 x 512 PNG (32-bit with alpha) - create from your app's launcher icon
    - **Feature graphic**: 1024 x 500 JPG or 24-bit PNG - create marketing banner image
    - **Screenshots**: Upload at least 2 phone screenshots (minimum dimensions: 320px on shorter side) - take screenshots of home screen, note detail, etc.
    - **App category**: Choose **Productivity**
    - **Contact email**: Your support email address
  - **Privacy Policy** section:
    - **Privacy policy URL**: Required - create and host privacy policy (can use https://app-privacy-policy-generator.firebaseapp.com/)
    - Enter the URL in Play Console
  - **App Content Declarations** (complete all required questionnaires):
    - **Content rating**: Complete IARC questionnaire (answer questions about app content)
    - **Target audience**: Select age groups (e.g., 13+, 18+, or All Ages)
    - **News app**: Select "No" (Later is not a news app)
    - **COVID-19 contact tracing/status**: Select "No" (not applicable)
    - **Ads**: Select "No" if Later doesn't show ads, "Yes" if using ad SDKs
    - **Data safety**: Complete data collection questionnaire (Later collects email, notes, tasks - all stored in Supabase with RLS)
  - **App access** section:
    - If Later requires login, provide demo account credentials for Google's testing
    - Or select "All functionality is available without special access" if you'll create test accounts later
  - Save all sections and verify dashboard shows no blocking issues

- [x] Task 1.4: Set up Internal Testing track
  - Navigate to **Testing** → **Internal testing**
  - Click **Create new release**
  - **App signing** section:
    - Select **"Continue"** to enroll in Play App Signing (strongly recommended)
    - Google will manage your app signing key (provides key security and recovery)
    - You'll upload builds with an upload key (generated in Phase 2)
  - Do **NOT** upload AAB yet (will be done after CI/CD setup)
  - Save as draft

- [x] Task 1.5: Create internal testing email list
  - Still in **Internal testing** section, go to **Testers** tab
  - Click **Create email list**
  - **List name**: "Internal Testers" or "Development Team"
  - **Add email addresses**: Enter Google accounts for testing (comma-separated or one per line)
    - Must be valid Google accounts (@gmail.com or Google Workspace)
    - Maximum 100 testers for internal testing
    - Add yourself and any team members who will test
  - Click **Save changes**
  - Select the newly created email list in the "Testers" section
  - **Copy the opt-in URL** displayed - you'll share this with testers after first release

### Phase 2: Google Cloud Service Account Setup

**Prerequisites**: Google Cloud account (same as Play Console account)

- [x] Task 2.1: Enable Google Play Developer API
  - Navigate to https://console.cloud.google.com/
  - Create a new project or select existing project (name it "Later CI/CD" or similar)
  - In the search bar at top, search for **"Google Play Android Developer API"**
  - Click on the API result
  - Click **Enable** button (if not already enabled)
  - Wait for API to be enabled (takes ~30 seconds)

- [ ] Task 2.2: Create service account for CI/CD
  - In Google Cloud Console, navigate to **IAM & Admin** → **Service Accounts** (use left sidebar)
  - Click **+ CREATE SERVICE ACCOUNT** button at top
  - **Service account details**:
    - **Service account name**: `github-actions-play-deploy`
    - **Service account ID**: `github-actions-play-deploy` (auto-generated from name)
    - **Description**: "Service account for GitHub Actions to deploy Later app to Play Store"
  - Click **Create and continue**
  - **Grant access to project** (step 2): Skip this - click **Continue** (no project-level permissions needed)
  - **Grant users access to this service account** (step 3): Skip this - click **Done**
  - Service account is now created and listed

- [x] Task 2.3: Generate service account JSON key
  - In the service accounts list, find `github-actions-play-deploy@[PROJECT-ID].iam.gserviceaccount.com`
  - Click on the service account email to open details
  - Navigate to **Keys** tab
  - Click **Add Key** → **Create new key**
  - Select **JSON** format
  - Click **Create**
  - JSON file will download automatically (e.g., `later-ci-cd-abc123-456def.json`)
  - **IMPORTANT**: Save this file securely - it provides full API access
  - **NEVER** commit this file to version control
  - Keep file for Phase 3 (adding to GitHub secrets)

- [x] Task 2.4: Grant service account access in Play Console
  - Go back to https://play.google.com/console
  - Navigate to **Setup** → **API access** (in left sidebar under your app)
  - Under **Service accounts** section, look for your service account listed
  - If not automatically listed, click **Link existing service account**, follow prompts, and link the service account created in step 2.2
  - Once listed, click **Grant access** button next to `github-actions-play-deploy@...`
  - **Configure permissions**:
    - **Account permissions**: Select **"View app information and download bulk reports (read-only)"**
    - **App permissions**: Select your app **"Later"** from dropdown
    - **Release management**: Select **"Release manager"** (required for publishing releases)
    - **Store presence**: Select **"View only"** (sufficient for deployments)
  - Click **Invite user**
  - Confirm by clicking **Send invite** or **Apply**
  - Wait 5-10 minutes for permissions to propagate

### Phase 3: App Signing Keystore Setup

**Prerequisites**: Java Development Kit (JDK) installed (comes with Android Studio or install via `brew install openjdk@17`)

- [x] Task 3.1: Generate release keystore
  - Open terminal and navigate to a secure location (NOT inside your git repository)
  - Run the following command (macOS/Linux):
    ```bash
    keytool -genkey -v \
      -keystore ~/later-upload-keystore.jks \
      -keyalg RSA \
      -keysize 2048 \
      -validity 10000 \
      -alias upload
    ```
  - For Windows (PowerShell):
    ```powershell
    keytool -genkey -v `
      -keystore $env:USERPROFILE\later-upload-keystore.jks `
      -storetype JKS `
      -keyalg RSA `
      -keysize 2048 `
      -validity 10000 `
      -alias upload
    ```
  - You'll be prompted to enter:
    - **Keystore password**: Choose a strong password (at least 12 characters, mix of letters/numbers/symbols) - save this in password manager
    - **Key password**: Can be same as keystore password for simplicity - save this in password manager
    - **Name and organizational information**: Enter your name, organization (can use "Later" or personal name), city, state, country code
  - After completion, verify file exists: `ls ~/later-upload-keystore.jks` (macOS/Linux) or `dir $env:USERPROFILE\later-upload-keystore.jks` (Windows)
  - **IMPORTANT**: Back up this keystore file in a secure location (encrypted cloud storage, password manager with file attachments, etc.)
  - **NEVER** lose this keystore - losing it means you cannot update your published app

- [x] Task 3.2: Convert keystore to base64 for GitHub secrets
  - macOS/Linux:
    ```bash
    base64 -i ~/later-upload-keystore.jks | pbcopy
    ```
    (This copies the base64 string to clipboard)
  - Alternative to save to file:
    ```bash
    base64 -i ~/later-upload-keystore.jks > ~/keystore-base64.txt
    ```
  - Windows (PowerShell):
    ```powershell
    [Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\later-upload-keystore.jks")) | Set-Clipboard
    ```
  - Alternative to save to file:
    ```powershell
    [Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\later-upload-keystore.jks")) | Out-File -FilePath "$env:USERPROFILE\keystore-base64.txt"
    ```
  - The base64 string is now in clipboard (or saved to file) - keep this for next task

- [x] Task 3.3: Configure GitHub secrets
  - Navigate to your GitHub repository: https://github.com/[YOUR-USERNAME]/later
  - Go to **Settings** → **Secrets and variables** → **Actions**
  - Click **New repository secret** button
  - Add the following secrets one by one:

    **Secret 1: KEYSTORE_BASE64**
    - Name: `KEYSTORE_BASE64`
    - Value: Paste the base64 string from Task 3.2 (entire string, no line breaks)
    - Click **Add secret**

    **Secret 2: KEYSTORE_PASSWORD**
    - Name: `KEYSTORE_PASSWORD`
    - Value: The keystore password you entered in Task 3.1
    - Click **Add secret**

    **Secret 3: KEY_ALIAS**
    - Name: `KEY_ALIAS`
    - Value: `upload` (the alias used in Task 3.1)
    - Click **Add secret**

    **Secret 4: KEY_PASSWORD**
    - Name: `KEY_PASSWORD`
    - Value: The key password you entered in Task 3.1 (same as keystore password if you made them identical)
    - Click **Add secret**

    **Secret 5: SERVICE_ACCOUNT_JSON**
    - Name: `SERVICE_ACCOUNT_JSON`
    - Value: Open the JSON file downloaded in Phase 2 Task 2.3, copy **entire contents** (from `{` to `}` including all nested properties)
    - Click **Add secret**

    **Secret 6: SUPABASE_URL**
    - Name: `SUPABASE_URL`
    - Value: Your Supabase project URL (e.g., `https://xxxxx.supabase.co`)
    - Find in Supabase Dashboard → Settings → API → Project URL
    - Click **Add secret**

    **Secret 7: SUPABASE_ANON_KEY**
    - Name: `SUPABASE_ANON_KEY`
    - Value: Your Supabase anon/public key
    - Find in Supabase Dashboard → Settings → API → Project API keys → `anon` `public`
    - Click **Add secret**

  - Verify all 7 secrets are listed in repository secrets (values will be hidden)

- [x] Task 3.4: Update Android build configuration for release signing
  - Open `apps/later_mobile/android/app/build.gradle.kts` in your editor
  - Find the section near the top (before `android {` block) and add this code:
    ```kotlin
    // Load keystore properties if they exist (for CI/CD signing)
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = java.util.Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
    }
    ```
  - Find the `android {` block and add the `signingConfigs` section inside it (before `buildTypes`):
    ```kotlin
    android {
        namespace = "dev.curth.later"
        compileSdk = flutter.compileSdkVersion
        ndkVersion = flutter.ndkVersion

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }

        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_11.toString()
        }

        defaultConfig {
            applicationId = "dev.curth.later"
            minSdk = flutter.minSdkVersion
            targetSdk = flutter.targetSdkVersion
            versionCode = flutter.versionCode
            versionName = flutter.versionName
        }

        // Add this signingConfigs block
        signingConfigs {
            create("release") {
                if (keystorePropertiesFile.exists()) {
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    storeFile = file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                }
            }
        }

        buildTypes {
            release {
                // Replace the existing signingConfig line (currently using debug)
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
    ```
  - Update `apps/later_mobile/android/.gitignore` to ensure keystore files are never committed:
    ```
    # Add these lines if not already present
    key.properties
    *.keystore
    *.jks
    ```
  - Save all files
  - Commit changes:
    ```bash
    git add apps/later_mobile/android/app/build.gradle.kts apps/later_mobile/android/.gitignore
    git commit -m "ci: configure release signing for Play Store deployment"
    git push origin main
    ```

### Phase 4: Semantic Versioning Setup

**Prerequisites**: Git repository with commit history

**Important Note**: This project uses **squash merging** for pull requests. This means individual commit messages in feature branches don't matter for versioning - only the **PR title** (which becomes the squash commit message) triggers version bumps. This simplifies the workflow significantly.

- [ ] Task 4.1: Create initial git tag for version baseline
  - Ensure you're on `main` branch and it's up to date:
    ```bash
    git checkout main
    git pull origin main
    ```
  - Create initial version tag (use current version from `pubspec.yaml`, which is 1.0.0+1):
    ```bash
    git tag -a v1.0.0 -m "Initial version for semantic versioning automation"
    ```
  - Push tag to GitHub:
    ```bash
    git push origin v1.0.0
    ```
  - Verify tag was created:
    ```bash
    git tag --list
    ```
    (Should show `v1.0.0`)

- [x] Task 4.2: Configure GitHub repository for squash merge
  - Navigate to your GitHub repository settings: https://github.com/[YOUR-USERNAME]/later/settings
  - Scroll to **"Pull Requests"** section
  - **Enable** "Allow squash merging" checkbox (if not already enabled)
  - **Disable** "Allow merge commits" (optional, but recommended to enforce squash merge)
  - **Disable** "Allow rebase merging" (optional, but recommended to enforce squash merge)
  - Under **"Allow squash merging"**, select:
    - Default commit message: **"Pull request title"**
    - This ensures the PR title becomes the commit message on main (critical for semantic versioning)
  - Click **"Save changes"** at the bottom

- [ ] Task 4.3: Document PR title guidelines for team
  - Create `.github/CONTRIBUTING.md` with PR title format guidelines:
    ```bash
    mkdir -p .github
    ```
  - Create the file with this content (save to `.github/CONTRIBUTING.md`):
    ```markdown
    # Contributing to Later

    ## Pull Request Guidelines

    We use **squash merging** for all pull requests and follow [Conventional Commits](https://www.conventionalcommits.org/) for automated semantic versioning.

    ### Important: PR Title Format

    **Your PR title determines the version bump** - it becomes the commit message on `main` after squash merge.

    Individual commits in your feature branch can use any format - only the PR title matters.

    ### PR Title Format

    ```
    <type>(<scope>): <description>
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

    To trigger a MAJOR version bump (e.g., 1.0.0 → 2.0.0), add `!` after the type:

    ```
    feat!: change API endpoint structure
    ```

    Or include `BREAKING CHANGE:` in the PR description.

    ### Examples

    **Good PR titles:**
    - `feat(notes): add full-text search for notes`
    - `fix(auth): resolve session timeout issue`
    - `docs: update installation instructions`
    - `refactor(ui): simplify button component structure`
    - `test(models): add tests for TodoList serialization`
    - `feat!: migrate to new authentication system` (MAJOR bump)

    **Bad PR titles:**
    - `Update stuff` (no type, unclear description)
    - `Fix bug` (not lowercase, not specific enough)
    - `feat:add feature` (missing space after colon)
    - `Added new search feature` (wrong tense, no type)

    ### Version Mapping

    - `feat:` in PR title → Bump MINOR version (1.0.0 → 1.1.0)
    - `fix:` in PR title → Bump PATCH version (1.0.0 → 1.0.1)
    - `feat!:` or `BREAKING CHANGE:` → Bump MAJOR version (1.0.0 → 2.0.0)
    - Other types (`docs:`, `chore:`, etc.) → No version bump

    ### Workflow

    1. Create feature branch with any commit style you prefer
    2. Open PR with conventional commit format in **title**
    3. PR checks run automatically (build, test, analyze)
    4. After approval, merge with **squash merge**
    5. PR title becomes commit on `main`
    6. Deployment workflow automatically calculates version and publishes to Play Store
    ```
  - Commit the guidelines:
    ```bash
    git add .github/CONTRIBUTING.md
    git commit -m "docs: add PR title guidelines for semantic versioning with squash merge"
    git push origin feat/ci-cd-play-store-automation
    ```

- [ ] Task 4.4: (Optional) Create PR template with title reminder
  - Create `.github/pull_request_template.md` to remind developers about PR title format:
    ```bash
    cd .github
    ```
  - Create the file with this content:
    ```markdown
    ## Description
    <!-- Describe your changes in detail -->

    ## Type of Change
    <!-- Check the one that applies -->
    - [ ] `feat`: New feature (MINOR version bump)
    - [ ] `fix`: Bug fix (PATCH version bump)
    - [ ] `docs`: Documentation only
    - [ ] `style`: Code style/formatting
    - [ ] `refactor`: Code refactoring
    - [ ] `test`: Adding/updating tests
    - [ ] `chore`: Maintenance tasks
    - [ ] `perf`: Performance improvement
    - [ ] `ci`: CI/CD changes

    ## Breaking Changes
    - [ ] This PR includes breaking changes (add `!` to PR title for MAJOR version bump)

    ## PR Title Format Reminder
    **Important**: Your PR title must follow Conventional Commits format:
    ```
    <type>(<scope>): <description>
    ```

    Example: `feat(notes): add full-text search`

    The PR title becomes the commit message after squash merge and determines the version bump.

    ## Testing
    <!-- Describe how you tested these changes -->

    ## Checklist
    - [ ] Code follows project style guidelines
    - [ ] Tests pass locally
    - [ ] PR title follows conventional commit format
    - [ ] Documentation updated (if needed)
    ```
  - Commit the PR template:
    ```bash
    git add .github/pull_request_template.md
    git commit -m "docs: add PR template with conventional commit reminder"
    git push origin feat/ci-cd-play-store-automation
    ```

### Phase 5: GitHub Actions Workflow Implementation

**Prerequisites**: GitHub repository, all secrets configured (Phase 3)

- [ ] Task 5.1: Create GitHub Actions workflow directory
  - From repository root:
    ```bash
    cd /Users/jonascurth/later
    mkdir -p .github/workflows
    ```

- [ ] Task 5.2: Create PR checks workflow
  - Create `.github/workflows/pr-checks.yml` with this content:
    ```yaml
    name: PR Checks - Build and Test

    on:
      pull_request:
        branches: [ main ]
        paths:
          - 'apps/later_mobile/**'
          - '.github/workflows/pr-checks.yml'

    jobs:
      test:
        name: Build and Test Flutter App
        runs-on: ubuntu-latest
        timeout-minutes: 30

        defaults:
          run:
            working-directory: apps/later_mobile

        steps:
          - name: Checkout code
            uses: actions/checkout@v4

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
            run: flutter pub get

          - name: Analyze code
            run: flutter analyze

          - name: Run tests
            run: flutter test

          - name: Build APK (validation only)
            run: flutter build apk --release --no-shrink

          - name: Upload APK artifact
            uses: actions/upload-artifact@v4
            if: success()
            with:
              name: pr-apk-${{ github.event.pull_request.number }}
              path: apps/later_mobile/build/app/outputs/flutter-apk/app-release.apk
              retention-days: 7
    ```
  - This workflow:
    - Runs on every PR to `main` branch
    - Only triggers if files in `apps/later_mobile/` change
    - Validates code with `flutter analyze`
    - Runs all tests with `flutter test`
    - Builds APK to verify build succeeds (not deployed)
    - Uploads APK as artifact for manual testing if needed

- [ ] Task 5.3: Create deployment workflow with semantic versioning and Supabase env vars
  - Create `.github/workflows/deploy-internal.yml` with this content:
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
        timeout-minutes: 45

        defaults:
          run:
            working-directory: apps/later_mobile

        steps:
          - name: Checkout code
            uses: actions/checkout@v4
            with:
              fetch-depth: 0  # Required for commit history analysis

          # Calculate next semantic version from conventional commits
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

          # Update pubspec.yaml with calculated version
          - name: Update Version in pubspec.yaml
            run: |
              VERSION="${{ steps.semver.outputs.nextStrict }}"
              BUILD_NUMBER="${{ github.run_number }}"

              echo "📦 Updating version to $VERSION+$BUILD_NUMBER"

              sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml

              echo "✅ Updated version:"
              grep "^version:" pubspec.yaml

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
            run: flutter pub get

          - name: Run tests
            run: flutter test

          # Decode keystore from base64 secret
          - name: Decode keystore
            run: |
              echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks

          # Create key.properties file for Gradle signing
          - name: Create key.properties
            run: |
              cat > android/key.properties << EOF
              storePassword=${{ secrets.KEYSTORE_PASSWORD }}
              keyPassword=${{ secrets.KEY_PASSWORD }}
              keyAlias=${{ secrets.KEY_ALIAS }}
              storeFile=upload-keystore.jks
              EOF

          # Build signed AAB with Supabase environment variables injected
          - name: Build App Bundle
            run: |
              flutter build appbundle \
                --release \
                --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
                --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}

          # Upload to Play Store Internal Testing track
          - name: Upload to Play Store Internal Testing
            uses: r0adkll/upload-google-play@v1.1.3
            with:
              serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
              packageName: dev.curth.later
              releaseFiles: apps/later_mobile/build/app/outputs/bundle/release/app-release.aab
              track: internal
              status: completed
              inAppUpdatePriority: 2

          # Create git tag after successful deployment
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

          # Create GitHub Release
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

          # Upload AAB artifact for archival
          - name: Upload AAB artifact
            uses: actions/upload-artifact@v4
            if: always()
            with:
              name: release-aab-${{ github.run_number }}
              path: apps/later_mobile/build/app/outputs/bundle/release/app-release.aab
              retention-days: 30

          # Clean up secrets from filesystem
          - name: Clean up secrets
            if: always()
            run: |
              rm -f android/app/upload-keystore.jks
              rm -f android/key.properties
    ```
  - This workflow:
    - Runs on merge to `main` branch
    - Calculates semantic version from commit messages
    - Updates `pubspec.yaml` with new version + build number
    - Injects Supabase environment variables via `--dart-define` flags
    - Builds signed AAB with release keystore
    - Uploads to Google Play Store Internal Testing track
    - Creates git tag for the release
    - Creates GitHub Release with version notes
    - Cleans up secrets after build

- [ ] Task 5.4: Update Flutter app to read Supabase env vars from dart-define
  - The app needs to read Supabase credentials from `--dart-define` values instead of hardcoded constants
  - Open `apps/later_mobile/lib/core/config/supabase_config.dart` (or wherever Supabase is initialized)
  - Update to use compile-time environment variables:
    ```dart
    class SupabaseConfig {
      // Read from --dart-define flags (provided by CI/CD)
      static const String supabaseUrl = String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '', // Empty default - will use local dev values if not set
      );

      static const String supabaseAnonKey = String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '', // Empty default - will use local dev values if not set
      );

      // For local development, use Supabase local dev server values
      static String getUrl() {
        if (supabaseUrl.isNotEmpty) {
          return supabaseUrl; // Use CI/CD provided value
        }
        // Fallback to local dev server (from `supabase status`)
        return 'http://127.0.0.1:54321'; // Or your local Supabase URL
      }

      static String getAnonKey() {
        if (supabaseAnonKey.isNotEmpty) {
          return supabaseAnonKey; // Use CI/CD provided value
        }
        // Fallback to local dev server anon key
        return 'your-local-dev-anon-key-here'; // Get from `supabase status`
      }
    }
    ```
  - Update Supabase initialization to use these values:
    ```dart
    await Supabase.initialize(
      url: SupabaseConfig.getUrl(),
      anonKey: SupabaseConfig.getAnonKey(),
    );
    ```
  - Commit changes:
    ```bash
    git add apps/later_mobile/lib/core/config/supabase_config.dart
    git commit -m "feat(ci): read Supabase credentials from dart-define environment variables"
    git push origin main
    ```

- [ ] Task 5.5: Commit and push workflows
  - From repository root:
    ```bash
    git add .github/workflows/
    git commit -m "ci: add GitHub Actions workflows for PR checks and Play Store deployment

    - PR checks: build, analyze, and test on every pull request
    - Deployment: semantic versioning + auto-publish to Play Store internal testing after merge
    - Supabase environment variables injected securely via GitHub secrets"
    git push origin main
    ```
  - This push will trigger the deployment workflow immediately (since it modifies files in workflow paths)
  - Monitor progress in GitHub Actions tab: https://github.com/[YOUR-USERNAME]/later/actions

### Phase 6: First Manual Upload to Play Store (Required)

**Prerequisites**: Play Console setup complete (Phase 1), keystore generated (Phase 3), workflows created (Phase 5)

**Important**: Google Play Console requires at least one manual APK/AAB upload before API access works. This is a one-time requirement.

- [ ] Task 6.1: Build first release AAB locally
  - Navigate to Flutter app directory:
    ```bash
    cd apps/later_mobile
    ```
  - Create temporary `key.properties` file for local signing:
    ```bash
    cat > android/key.properties << EOF
    storePassword=YOUR_KEYSTORE_PASSWORD
    keyPassword=YOUR_KEY_PASSWORD
    keyAlias=upload
    storeFile=$HOME/later-upload-keystore.jks
    EOF
    ```
    (Replace `YOUR_KEYSTORE_PASSWORD` and `YOUR_KEY_PASSWORD` with actual values from Phase 3 Task 3.1)
  - Build signed release AAB:
    ```bash
    flutter build appbundle --release \
      --dart-define=SUPABASE_URL=$SUPABASE_URL \
      --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
    ```
    (Replace `$SUPABASE_URL` and `$SUPABASE_ANON_KEY` with your actual Supabase values from GitHub secrets)
  - Verify AAB was created:
    ```bash
    ls -lh build/app/outputs/bundle/release/app-release.aab
    ```
    (Should show file size, e.g., ~50-100MB depending on app size)
  - **Delete the key.properties file immediately** (never commit this):
    ```bash
    rm android/key.properties
    ```

- [ ] Task 6.2: Upload first release to Play Console manually
  - Go to https://play.google.com/console
  - Navigate to your app → **Testing** → **Internal testing**
  - Click **Create new release** (or edit draft release from Phase 1 Task 1.4)
  - In the **App bundles** section, click **Upload** button
  - Select the AAB file from `apps/later_mobile/build/app/outputs/bundle/release/app-release.aab`
  - Wait for upload and processing (may take 1-2 minutes)
  - Once processed, fill in release details:
    - **Release name**: 1.0.0 (1) - Internal Beta
    - **Release notes** (English - United States): "Initial internal testing release. Features: Spaces, Notes, Todo Lists, Custom Lists with Supabase cloud sync."
  - Click **Save**
  - Click **Review release**
  - Verify all information is correct (version code, release notes, etc.)
  - Click **Start rollout to Internal testing**
  - Confirm the rollout
  - Wait for release to be published (usually instant for internal testing)

- [ ] Task 6.3: Verify first release is live
  - Go to **Testing** → **Internal testing** → **Releases** tab
  - Verify release shows as "Available" status
  - Copy the **opt-in URL** from the Testers tab
  - Open the opt-in URL on an Android device (or share with testers)
  - Opt in to internal testing
  - Open Google Play Store on the device
  - Search for "Later" or navigate via the testing link
  - Install the app
  - Launch the app and verify it works (test login, create space, create note, etc.)
  - Verify Supabase connection works (data syncs to cloud)

- [ ] Task 6.4: Test CI/CD pipeline with a pull request
  - Create a test branch:
    ```bash
    git checkout -b test/ci-cd-pipeline
    ```
  - Make a small change (e.g., add comment to a file):
    ```bash
    cd apps/later_mobile
    echo "# Test CI/CD pipeline" >> pubspec.yaml
    git add pubspec.yaml
    ```
  - Commit with any message (individual commits don't matter with squash merge):
    ```bash
    git commit -m "test pipeline automation"
    git push origin test/ci-cd-pipeline
    ```
  - Create pull request on GitHub:
    - Navigate to repository: https://github.com/[YOUR-USERNAME]/later
    - Click "Compare & pull request" for the pushed branch
    - **IMPORTANT: Set PR title with conventional commit format** (this becomes the squash commit):
      - Title: `feat(ci): test automated deployment pipeline`
    - Description:
      ```
      Testing the complete CI/CD pipeline including:
      - Semantic version calculation from PR title
      - Automated AAB build with Supabase env vars
      - Play Store internal testing deployment
      ```
    - Click "Create pull request"
  - Verify PR checks run successfully:
    - Go to **Checks** tab in the PR
    - Wait for "PR Checks - Build and Test" workflow to complete
    - Verify all steps succeed (green checkmarks)
    - If failures occur, review logs and fix issues
  - Merge the PR with squash merge:
    - Click "Squash and merge" button (NOT "Merge pull request")
    - Verify the commit message shows: `feat(ci): test automated deployment pipeline`
    - Click "Confirm squash and merge"
  - Monitor deployment workflow:
    - Go to **Actions** tab
    - Click on "Deploy to Play Store Internal Testing" workflow run
    - Watch the steps execute:
      - Version calculation (should show 1.1.0 since v1.0.0 + feat: in PR title)
      - pubspec.yaml update
      - Build
      - Upload to Play Store
      - Git tag creation
      - GitHub Release creation
  - Verify deployment succeeded:
    - Check workflow shows all green checkmarks
    - Go to Play Console → Internal testing
    - Verify new release appears with version 1.1.0 (build number 2 or similar)
    - Check GitHub Releases page for new v1.1.0 release
    - Run `git fetch --tags && git tag --list` to verify v1.1.0 tag exists

## Dependencies and Prerequisites

**External Accounts & Services:**
- Google Play Developer account ($25 one-time fee)
- Google Cloud account (same as Play account)
- GitHub repository with Actions enabled
- Supabase project with cloud database (existing)

**Development Tools:**
- Flutter SDK 3.24.5 or higher
- Java Development Kit (JDK) 17
- Git with command-line access
- Android device or emulator for testing

**Required Access:**
- Repository admin access (to configure GitHub secrets)
- Play Console admin access (to create app and configure API)
- Google Cloud admin access (to create service accounts)

**Knowledge Requirements:**
- Basic understanding of Conventional Commits format (documented in Phase 4)
- Familiarity with Git branching and pull requests
- Ability to follow terminal commands for keystore generation

## Challenges and Considerations

**Challenge 1: First-Time Play Console Setup Complexity**
- **Issue**: Play Console has many required steps (store listing, content declarations, privacy policy, etc.) that must be completed before first release
- **Mitigation**: Detailed step-by-step guidance in Phase 1 with all required fields listed. Allow 1-2 hours for initial setup.
- **Fallback**: If blocked on any declaration (e.g., content rating questionnaire), can save as draft and complete later. Only required fields must be done before first upload.

**Challenge 2: Service Account Permissions Propagation Delay**
- **Issue**: After granting service account access in Play Console, permissions may take 5-10 minutes to propagate. CI/CD uploads may fail during this window.
- **Mitigation**: Phase 2 Task 2.4 includes explicit wait instruction. If first automated upload fails with permission error, wait 10 minutes and retry (re-run GitHub Actions workflow).
- **Verification**: Test service account access manually using Google's APIs Explorer before relying on automation.

**Challenge 3: Keystore Management and Security**
- **Issue**: Losing the upload keystore means inability to update the published app. Keystore compromise allows malicious actors to publish fake updates.
- **Mitigation**:
  - Back up keystore in multiple secure locations (encrypted cloud storage, password manager)
  - Store keystore password in password manager (never hardcode or commit)
  - Use Play App Signing (Phase 1 Task 1.4) so Google manages final signing key (recovery possible)
  - Rotate service account keys every 90 days
- **Monitoring**: Set calendar reminder to verify keystore backup exists and is accessible quarterly

**Challenge 4: PR Title Format Enforcement**
- **Issue**: Team members may forget to use Conventional Commits format in PR titles. Invalid PR titles break semantic versioning.
- **Mitigation**:
  - Configure GitHub to use squash merge only (Phase 4 Task 4.2) - simplifies workflow
  - Comprehensive documentation in `.github/CONTRIBUTING.md` (Phase 4 Task 4.3) explains PR title importance
  - Optional PR template (Phase 4 Task 4.4) reminds developers of format requirements
  - Version calculation falls back to `patch` bump if no matching commits (via `noVersionBumpBehavior` in workflow)
  - Individual commits in feature branches can use any format - only PR title matters
- **Training**: Share CONTRIBUTING.md with team before enabling automation. Review PR titles in code reviews before merging.

**Challenge 5: Supabase Environment Variables Management**
- **Issue**: Hardcoded Supabase credentials in code are security risk. CI/CD must inject credentials without exposing them in logs.
- **Mitigation**:
  - Use `--dart-define` flags to inject credentials at build time (Phase 5 Task 5.4)
  - Store credentials as GitHub secrets (never in code or public logs)
  - Use `String.fromEnvironment()` with empty defaults (falls back to local dev values for development)
  - Local development uses `supabase start` which provides isolated credentials
- **Verification**: After implementation, search codebase for hardcoded Supabase URLs/keys and remove them

**Challenge 6: Build Failures After Merge**
- **Issue**: If deployment workflow fails after merge to `main`, the commit is already in main branch but app is not deployed.
- **Mitigation**:
  - PR checks run same tests as deployment (catch issues before merge)
  - Deployment workflow includes test step as safety check
  - If deployment fails, manually fix issue and re-run workflow (GitHub Actions allows manual re-runs)
  - Git tags only created after successful deployment (version number not "lost" on failure)
- **Rollback**: If deployed version has critical bug, use Play Console's "Stop rollout" button to halt distribution, then push hotfix commit (`fix:` prefix) to trigger new deployment

**Challenge 7: New Account Testing Requirements (Post-Nov 2023 Accounts)**
- **Issue**: Google Play accounts created after November 13, 2023 require 14 days of closed testing with 12+ testers before production access.
- **Mitigation**:
  - Use internal testing track indefinitely (no reviewer approval, up to 100 testers)
  - If production release needed, plan 14-day testing period in advance
  - Recruit 12 testers from team/friends/family (must be Google accounts)
- **Timeline**: Factor this into launch planning if production release is goal

**Challenge 8: Version Code Conflicts**
- **Issue**: Google Play requires unique, incrementing version codes. Workflow reruns or parallel builds could cause conflicts.
- **Mitigation**:
  - Use `github.run_number` for build number (unique per workflow execution, including reruns)
  - GitHub run number never decreases, always increments
  - Each deployment gets unique version code automatically
- **Edge Case**: If workflow is deleted and recreated, run number resets. Solution: Manually bump version in pubspec.yaml once before automation.

**Challenge 9: AAB Size Limits**
- **Issue**: Google Play has 150MB limit for AABs. Large Flutter apps with assets may exceed this.
- **Mitigation**:
  - Enable R8 code shrinking (already enabled with `--release` flag)
  - Optimize assets (compress images, remove unused files)
  - Use Play Asset Delivery for large assets (future enhancement)
- **Monitoring**: Check AAB size in workflow logs. If approaching 100MB, investigate asset optimization.

**Challenge 10: Testing in CI Environment**
- **Issue**: Some tests may behave differently in CI (no display, different environment variables, etc.)
- **Mitigation**:
  - Use `flutter test` in headless mode (works in CI)
  - Mock Supabase calls in unit tests (don't rely on network)
  - If integration tests needed, consider Supabase local development server in CI (future enhancement)
- **Current State**: Existing test suite is primarily unit tests, should work in CI without modification

## Success Criteria

After completing all phases, the following should be true:

✅ **Google Play Console is fully configured:**
- App created with package name `dev.curth.later`
- All required declarations completed (store listing, privacy policy, content rating, etc.)
- Internal testing track set up with tester email list
- At least one manual AAB uploaded successfully
- Service account has API access with Release Manager permissions

✅ **GitHub repository has all required secrets:**
- `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` (signing)
- `SERVICE_ACCOUNT_JSON` (Play Store API)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` (environment variables)

✅ **CI/CD workflows are operational:**
- PR checks run on every pull request (build, analyze, test)
- Deployment workflow runs on merge to `main`
- Semantic version calculated from commit messages
- `pubspec.yaml` updated automatically (no manual edits needed)
- Supabase env vars injected via `--dart-define`
- Signed AAB uploaded to Play Store Internal Testing
- Git tags and GitHub Releases created automatically

✅ **First automated deployment succeeds:**
- Commit with `feat:` prefix triggers MINOR version bump
- Workflow completes without errors
- New version appears in Play Console internal testing
- Git tag created (e.g., `v1.1.0`)
- GitHub Release created with version notes
- App installs and runs correctly from Play Store testing link

✅ **Documentation is complete:**
- `.github/CONTRIBUTING.md` explains Conventional Commits format
- Team members understand commit message requirements
- Optional: Commit linting prevents invalid commits locally

✅ **Security best practices followed:**
- No credentials committed to version control
- Keystore backed up in secure location
- Service account JSON stored only in GitHub secrets
- `key.properties` and keystore files in `.gitignore`

## Post-Implementation Next Steps

After completing this plan and verifying the CI/CD pipeline works, consider these enhancements:

1. **Closed Testing Track**: Promote from internal testing to closed testing with wider tester group (prepares for production)
2. **Release Notes Automation**: Generate release notes from commit messages using GitHub Actions (e.g., with `github-changelog-generator`)
3. **Slack Notifications**: Add Slack webhook to notify team of successful deployments
4. **Rollback Strategy**: Document process for rolling back bad releases (Play Console rollback feature + git revert)
5. **iOS Deployment**: Extend pipeline to include TestFlight deployment for iOS (similar setup with App Store Connect)
6. **Monitoring and Alerts**: Set up monitoring for CI/CD workflow failures (GitHub Actions notifications, email alerts)
7. **Production Release Process**: Define criteria and approval workflow for promoting from internal testing to production
8. **Manual Release Workflow**: Create separate workflow for manual production releases with approval gates
9. **Beta Track**: Add beta testing track for wider audience before production
10. **Code Coverage Enforcement**: Add code coverage reporting to PR checks (fail if coverage drops below threshold)
