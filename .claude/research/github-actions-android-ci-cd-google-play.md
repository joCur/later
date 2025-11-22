# Research: GitHub Actions CI/CD Pipeline for Flutter Android with Google Play Internal Testing

## Executive Summary

This research covers the complete setup for creating a GitHub Actions CI/CD pipeline for a Flutter Android app that builds and tests on pull requests, then automatically publishes to Google Play Console internal testing track after merge. The pipeline requires configuring app signing with a keystore, setting up a Google Cloud service account for Play Store API access, and creating GitHub workflows for both PR validation and deployment.

**Key Findings:**
- Google Play now **requires Android App Bundle (AAB)** format for all new apps (mandatory since August 2021)
- GitHub Actions can fully automate build, test, signing, and deployment using marketplace actions like `r0adkll/upload-google-play`
- App signing requires generating a keystore, storing it as a base64-encoded GitHub secret, and configuring Gradle
- Google Play Console setup is a multi-step process requiring a $25 one-time developer account fee, app creation, content declarations, and initial manual upload
- Service account JSON credentials enable automated deployments without manual intervention
- **New developer accounts** created after November 13, 2023 must complete closed testing with at least 12 testers for 14 days before production access

## Research Scope

### What Was Researched
- GitHub Actions workflow configuration for Flutter Android apps
- Google Play Console first-time setup requirements and process
- App signing configuration with keystores for release builds
- Service account setup for Google Play Developer API access
- Internal testing track setup and tester management
- Best practices for secrets management in GitHub Actions
- AAB vs APK format requirements and differences
- Fastlane as an alternative automation tool

### What Was Explicitly Excluded
- iOS deployment workflows
- Firebase App Distribution as an alternative to Play Store
- Manual deployment processes
- Alternative CI/CD platforms (CircleCI, GitLab CI, etc.)
- Play Store production release workflows (focus is internal testing only)

### Research Methodology
- Web search for official documentation (Flutter, Google Play Console, GitHub Actions)
- Review of recent tutorials and guides (2025 sources prioritized)
- Analysis of GitHub marketplace actions for Play Store publishing
- Code review of current project structure and configuration

## Current State Analysis

### Existing Implementation

**Project:** Flutter mobile app at `/apps/later_mobile/`
- **Package:** `dev.curth.later`
- **Version:** 1.0.0+1 (from pubspec.yaml)
- **Build System:** Gradle with Kotlin DSL (build.gradle.kts)
- **Current Signing:** Using debug signing config (line 36 of build.gradle.kts: `signingConfig = signingConfigs.getByName("debug")`)
- **Java Version:** 11 (source and target compatibility)
- **CI/CD:** No existing GitHub Actions workflows found

**Critical Gap:** The app currently uses debug signing for release builds (TODO comment on line 34-35). This must be replaced with proper release signing before publishing to Play Store.

### Industry Standards

**GitHub Actions for Flutter (2025):**
- Standard workflow structure: `.github/workflows/*.yml`
- Java 17 via Temurin distribution (required for modern Android builds)
- Flutter SDK via `subosito/flutter-action@v2` with version pinning
- Caching enabled for Flutter SDK and Gradle to improve build times
- Code coverage enforcement (90%+ in some implementations)
- Artifact upload for APKs/AABs for manual inspection

**Google Play Publishing:**
- AAB format required for all new apps (mandatory since August 2021)
- Internal testing track allows up to 100 testers without full review process
- Service accounts with Play Developer API access enable automated publishing
- Row-level security: Service account JSON stored as GitHub secret
- Release tracks: internal → alpha → beta → production

**App Signing Best Practices:**
- Keystore stored as base64-encoded GitHub secret (not committed to repo)
- key.properties file generated dynamically in CI environment
- Play App Signing recommended for key management
- Minimum keystore validity: 10,000 days (27+ years)
- RSA key algorithm with 2048-bit key size

## Technical Analysis

### Approach 1: Direct GitHub Actions with Marketplace Action

**Description:** Use GitHub Actions workflows with the `r0adkll/upload-google-play` marketplace action to handle building, testing, and publishing without additional tools like Fastlane.

**Pros:**
- Simpler setup with fewer dependencies
- Direct integration with GitHub ecosystem
- Faster CI builds (no Fastlane/Ruby overhead)
- Easier to understand and maintain for teams unfamiliar with Fastlane
- Active marketplace action with good documentation

**Cons:**
- Less flexibility for complex release workflows
- Limited to GitHub Actions platform
- Manual configuration for each step (no Fastlane lanes)
- Less feature-rich than Fastlane for metadata management

**Use Cases:**
- First-time CI/CD setup for smaller teams
- Projects without existing Fastlane configuration
- When simplicity and maintainability are priorities
- GitHub-exclusive projects

**Code Example:**
```yaml
- name: Upload to Play Store Internal Testing
  uses: r0adkll/upload-google-play@v1
  with:
    serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
    packageName: dev.curth.later
    releaseFiles: build/app/outputs/bundle/release/app-release.aab
    track: internal
    status: completed
```

### Approach 2: GitHub Actions with Fastlane

**Description:** Combine GitHub Actions for CI orchestration with Fastlane lanes for build and deployment logic, providing a more structured and portable automation framework.

**Pros:**
- Industry-standard tool with extensive features
- Portable across CI platforms (GitHub Actions, CircleCI, GitLab, etc.)
- Rich ecosystem for metadata management, screenshots, beta management
- Powerful DSL for complex release workflows
- Official Flutter support

**Cons:**
- Additional dependency (Ruby, Fastlane)
- Steeper learning curve
- Slower setup and execution time
- More configuration files to maintain (Fastfile, Appfile)
- Requires initial manual APK upload to Play Console for supply initialization

**Use Cases:**
- Teams already using Fastlane for iOS
- Complex release workflows with multiple tracks/stages
- Need for automated metadata and screenshot management
- Multi-platform projects requiring consistent deployment logic

**Code Example:**
```ruby
# fastlane/Fastfile
lane :deploy_internal do
  gradle(task: "bundle", build_type: "Release")
  upload_to_play_store(
    track: 'internal',
    aab: '../build/app/outputs/bundle/release/app-release.aab',
    skip_upload_metadata: true,
    skip_upload_images: true,
    skip_upload_screenshots: true
  )
end
```

### Approach 3: Gradle Play Publisher Plugin

**Description:** Use the official Gradle Play Publisher plugin to handle Play Store uploads directly from Gradle tasks, integrated into GitHub Actions workflows.

**Pros:**
- Native Gradle integration
- No additional tooling required (pure Gradle)
- Type-safe Kotlin/Groovy DSL
- Supports metadata and APK/AAB uploads
- Good for Gradle-centric workflows

**Cons:**
- Less popular than Fastlane or marketplace actions
- Requires more Gradle configuration knowledge
- Less documentation and community support
- Harder to debug than dedicated CI/CD tools
- Configuration mixed with build logic

**Use Cases:**
- Teams with deep Gradle expertise
- Projects with complex Gradle build configurations
- When minimizing external dependencies is critical
- Android-only projects with no iOS component

**Code Example:**
```kotlin
// build.gradle.kts
plugins {
    id("com.github.triplet.play") version "3.8.6"
}

play {
    serviceAccountCredentials.set(file("../service-account.json"))
    track.set("internal")
    defaultToAppBundles.set(true)
}
```

## Tools and Libraries

### Option 1: r0adkll/upload-google-play (GitHub Action)

- **Purpose:** Upload Android APK/AAB to Google Play Console via GitHub Actions
- **Maturity:** Production-ready (widely used in community)
- **License:** Apache 2.0
- **Community:** Active with regular updates
- **Integration Effort:** Low - simple workflow configuration
- **Key Features:**
  - Supports all release tracks (internal, alpha, beta, production)
  - Service account JSON authentication
  - Release status control (draft, completed, inProgress)
  - Version code/name specification
  - Release notes support

**GitHub Marketplace:** https://github.com/marketplace/actions/upload-android-release-to-play-store

### Option 2: subosito/flutter-action (GitHub Action)

- **Purpose:** Install and cache Flutter SDK in GitHub Actions
- **Maturity:** Production-ready (official community action)
- **License:** MIT
- **Community:** Very active, 1000+ stars on GitHub
- **Integration Effort:** Low - single action call
- **Key Features:**
  - Version pinning for consistent builds
  - SDK caching for faster workflows
  - Cross-platform support (macOS, Linux, Windows)
  - Channel selection (stable, beta, dev)

**GitHub Marketplace:** https://github.com/marketplace/actions/flutter-action

### Option 3: Fastlane

- **Purpose:** Automation tool for building and releasing iOS and Android apps
- **Maturity:** Production-ready (industry standard since 2014)
- **License:** MIT
- **Community:** Very large (38k+ GitHub stars), active maintenance
- **Integration Effort:** Medium - requires Ruby, Fastlane setup, and lane configuration
- **Key Features:**
  - Cross-platform (iOS + Android)
  - Metadata and screenshot management
  - Multiple deployment targets (Play Store, TestFlight, Firebase, etc.)
  - Rich plugin ecosystem
  - Official Flutter support

**Installation:** `brew install fastlane`
**Docs:** https://docs.fastlane.tools/

### Option 4: actions/setup-java (GitHub Action)

- **Purpose:** Set up Java environment for Android builds
- **Maturity:** Production-ready (official GitHub action)
- **License:** MIT
- **Community:** Official GitHub support
- **Integration Effort:** Low - single action call
- **Key Features:**
  - Multiple JDK distributions (Temurin, Zulu, Adopt, etc.)
  - Version caching
  - Matrix builds support
  - Environment variable configuration

**Recommendation:** Use Temurin distribution with Java 17 for modern Android builds.

## Implementation Considerations

### Technical Requirements

**Prerequisites:**
1. **Google Play Developer Account** - $25 one-time registration fee
2. **Java Development Kit (JDK)** - Version 11+ (17 recommended for 2025)
3. **Keystore File** - Generated using `keytool` command
4. **Google Cloud Service Account** - For Play Developer API access
5. **GitHub Repository Secrets** - For storing sensitive credentials
6. **Initial Manual Upload** - At least one APK/AAB uploaded manually to Play Console

**Dependencies:**
- Flutter SDK: ^3.9.2 (from pubspec.yaml)
- Gradle: 8.x (from project)
- GitHub Actions: Free for public repos, included in paid plans for private repos
- Google Play Developer API: Enabled in Google Cloud Console

**Performance Implications:**
- CI build time: ~5-10 minutes for Flutter Android build with tests
- Caching can reduce subsequent builds to ~2-5 minutes
- Play Store review for internal testing: Usually instant (no review required)
- First-time account review: Can take several days for new developers

### Integration Points

**Repository Structure:**
```
/Users/jonascurth/later/
├── .github/
│   └── workflows/
│       ├── pr-checks.yml          # PR build and test
│       └── deploy-internal.yml    # Deploy after merge
├── apps/later_mobile/
│   ├── android/
│   │   ├── app/
│   │   │   ├── build.gradle.kts   # Configure signing
│   │   │   └── src/
│   │   └── key.properties         # Generated in CI (not committed)
│   └── pubspec.yaml
└── README.md
```

**Build Configuration Changes:**

1. **android/app/build.gradle.kts** - Add release signing configuration:
```kotlin
// Load keystore properties
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties['keyAlias']
                keyPassword = keystoreProperties['keyPassword']
                storeFile = file(keystoreProperties['storeFile'])
                storePassword = keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release  // Replace debug signing
        }
    }
}
```

2. **android/.gitignore** - Ensure key.properties is ignored:
```
key.properties
*.keystore
*.jks
```

**GitHub Secrets Configuration:**

Required secrets (Settings → Secrets and variables → Actions):
- `KEYSTORE_BASE64` - Base64-encoded keystore file
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_ALIAS` - Key alias from keystore
- `KEY_PASSWORD` - Key password
- `SERVICE_ACCOUNT_JSON` - Google Play service account JSON credentials

**API Changes Needed:**
- No application code changes required
- Configuration-only changes

**Database Impacts:**
- No database changes required

### Risks and Mitigation

| Risk | Severity | Mitigation Strategy |
|------|----------|---------------------|
| **Keystore loss** | Critical | Store keystore backup in secure location (password manager, encrypted storage). Enable Play App Signing for Google-managed keys. |
| **Service account compromise** | High | Rotate service account keys regularly. Use least-privilege permissions (only Play Developer API access). Monitor API usage. |
| **Build failures blocking releases** | Medium | Implement comprehensive test suite. Use PR checks to catch issues early. Have manual deployment fallback. |
| **Play Store review rejection** | Medium | Follow Play Store policies. Test thoroughly in internal track. Complete all required declarations. |
| **GitHub Actions quota exceeded** | Low | Use caching to reduce build times. Monitor usage in Settings → Billing. Upgrade to paid plan if needed. |
| **New account testing requirements** | Medium | Plan for 14-day closed testing period with 12+ testers if account created after Nov 2023. |
| **Version code conflicts** | Low | Use automated version code generation based on CI build number or timestamp. |
| **AAB compatibility issues** | Low | Test AAB thoroughly in internal testing before wider release. Verify Play Store generates APKs correctly. |

**Rollback Strategy:**
1. Keep previous keystore and credentials backed up
2. Maintain manual deployment capability (don't rely solely on automation)
3. Use Play Console's rollback feature if a release has critical issues
4. Internal testing track allows quick iteration without affecting production users

## Recommendations

### Recommended Approach: Direct GitHub Actions with Marketplace Actions

**Reasoning:**
- **Simplicity:** Easier to set up and maintain for first-time CI/CD implementation
- **Performance:** Faster builds without Fastlane overhead
- **Cost-Effective:** No additional tooling or learning curve
- **Sufficient Features:** Marketplace actions provide all required functionality for this use case
- **GitHub-Native:** Better integration with GitHub ecosystem (secrets, artifacts, etc.)

**Implementation Strategy:**

**Phase 1: Local Setup (Prerequisites)**
1. Generate release keystore using `keytool`
2. Convert keystore to base64 and store in GitHub secrets
3. Update `android/app/build.gradle.kts` with release signing config
4. Test local release build: `flutter build appbundle --release`

**Phase 2: Google Play Console Setup**
1. Create Google Play Developer account ($25 fee)
2. Create app in Play Console with app details and content declarations
3. Build and manually upload first AAB to internal testing track
4. Create internal testing email list with initial testers
5. Create Google Cloud service account with Play Developer API access
6. Download service account JSON and add to GitHub secrets

**Phase 3: GitHub Actions Workflows**
1. Create `.github/workflows/pr-checks.yml` for PR validation:
   - Checkout code
   - Setup Java 17 and Flutter
   - Run `flutter pub get`
   - Run `flutter analyze` (linting)
   - Run `flutter test` (unit and widget tests)
   - Build AAB (validation only, not deployed)
2. Create `.github/workflows/deploy-internal.yml` for post-merge deployment:
   - Trigger on push to `main` branch
   - Build signed AAB with release keystore
   - Upload to Play Store internal testing track using `r0adkll/upload-google-play`

**Phase 4: Testing and Validation**
1. Create test PR to validate PR checks workflow
2. Merge PR to trigger deployment workflow
3. Verify AAB appears in Play Console internal testing
4. Test installation via internal testing link
5. Monitor GitHub Actions logs for any issues

### Alternative Approach: GitHub Actions with Fastlane (If Complexity Grows)

**When to Consider:**
- Adding iOS deployment to the pipeline
- Need for automated metadata/screenshot management
- Complex release workflows with multiple stages
- Team has existing Fastlane expertise

**Migration Path:**
1. Install Fastlane: `brew install fastlane`
2. Initialize Fastlane in `android/` directory: `fastlane init`
3. Create Fastfile with deployment lanes
4. Update GitHub Actions to call Fastlane lanes instead of direct actions
5. Migrate secrets to Fastlane configuration

### Recommended Configuration Files

**1. PR Checks Workflow (`.github/workflows/pr-checks.yml`):**
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
          flutter-version: '3.24.5'  # Pin to specific version
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build APK (validation)
        run: flutter build apk --release
```

**2. Deployment Workflow (`.github/workflows/deploy-internal.yml`):**
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
    name: Build and Deploy to Internal Testing
    runs-on: ubuntu-latest
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

      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks

      - name: Create key.properties
        run: |
          cat > android/key.properties << EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=upload-keystore.jks
          EOF

      - name: Build App Bundle
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

      - name: Upload AAB artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release-aab
          path: apps/later_mobile/build/app/outputs/bundle/release/app-release.aab
          retention-days: 30
```

## Step-by-Step Implementation Guide

### Part A: Google Play Console Setup (First-Time Developer)

#### Step 1: Create Developer Account

1. Go to https://play.google.com/console
2. Sign in with your Google Account
3. Accept the Google Play Developer Distribution Agreement
4. Pay the $25 one-time registration fee
5. Choose account type: **Personal** or **Organization**
6. Complete identity verification (required for new accounts)
7. Enable two-step verification on your Google Account

**Note for Personal Accounts Created After November 13, 2023:**
You must complete a closed testing phase with at least 12 internal testers for a minimum of 14 days before you can access the Production tab.

#### Step 2: Create Your App

1. In Play Console, select **Home** → **Create app**
2. Fill in required information:
   - **Default language:** English (United States)
   - **App name:** Later (or your app name)
   - **App or game:** App
3. Acknowledge declarations:
   - ✓ Developer Program Policies
   - ✓ US export laws
4. Accept Play App Signing Terms of Service
5. Click **Create app**

#### Step 3: Complete App Dashboard Requirements

The dashboard will show required tasks. Complete each section:

**3.1 Store Listing**
- **App name:** Later (max 50 characters)
- **Short description:** Brief description (max 80 characters)
- **Full description:** Detailed app description (max 4000 characters)
- **App icon:** 512 x 512 PNG (32-bit, with alpha)
- **Feature graphic:** 1024 x 500 JPG or 24-bit PNG (no alpha)
- **Screenshots:** At least 2 phone screenshots (min dimensions)
- **App category:** Choose appropriate category (e.g., Productivity)

**3.2 Privacy Policy**
- **Privacy policy URL:** Required - host your privacy policy online
- Tip: Use services like app-privacy-policy-generator.firebaseapp.com

**3.3 App Content Declarations**
- **Content rating:** Complete IARC questionnaire
- **Target audience:** Select age groups
- **News app:** Declare if app is news-related
- **COVID-19 contact tracing/status:** Declare if applicable
- **Ads:** Declare if app contains ads (including third-party SDKs)
- **Data safety:** Complete data collection and sharing declarations

**3.4 App Access**
- If app requires login, provide demo account credentials
- Or select "All functionality is available without special access"

#### Step 4: Set Up Internal Testing Track

1. Go to **Testing** → **Internal testing**
2. Click **Create new release**
3. **App signing:** Enroll in Play App Signing (recommended)
   - Google manages your app signing key
   - You upload with an upload key
   - Provides key security and recovery options
4. Build your first release:
   ```bash
   cd apps/later_mobile
   flutter build appbundle --release
   ```
5. Upload the AAB manually (required for first release):
   - Drag `build/app/outputs/bundle/release/app-release.aab` to upload area
   - Or click **Browse files** to select it
6. Fill in release details:
   - **Release name:** 1.0.0 (1) - Internal Beta
   - **Release notes:** What's new in this version
7. Click **Save** (do not release yet)

#### Step 5: Create Internal Testing Email List

1. In **Internal testing**, go to **Testers** tab
2. Click **Create email list**
3. Enter list name: "Internal Testers"
4. Add email addresses (separated by commas or one per line):
   - Must be Google accounts (@gmail.com or Google Workspace)
   - Maximum 100 testers for internal testing
   - Alternatively, upload a CSV file
5. Click **Save**
6. Select the email list in the "Testers" section
7. Copy the **opt-in URL** - share this with your testers

**Important Notes:**
- Play Console does NOT automatically email testers
- You must manually share the opt-in URL
- After first release, it may take a few hours for the test link to be available

#### Step 6: Complete and Publish Internal Release

1. Go back to **Internal testing** → **Releases**
2. Click **Review release**
3. Verify all information is correct
4. Click **Start rollout to Internal testing**
5. Confirm rollout

**Review Time:** Internal testing releases are usually available within minutes (no formal review).

### Part B: Google Cloud Service Account Setup

#### Step 1: Enable Google Play Developer API

1. Go to https://console.cloud.google.com/
2. Create a new project or select existing project
3. In the search bar, search for "Google Play Android Developer API"
4. Click **Enable** (if not already enabled)

#### Step 2: Create Service Account

1. In Google Cloud Console, go to **IAM & Admin** → **Service Accounts**
2. Click **+ CREATE SERVICE ACCOUNT**
3. Fill in details:
   - **Service account name:** github-actions-play-deploy
   - **Service account ID:** github-actions-play-deploy (auto-generated)
   - **Description:** Service account for GitHub Actions to deploy to Play Store
4. Click **Create and continue**
5. Skip granting access to project (click **Continue**)
6. Click **Done**

#### Step 3: Generate Service Account Key

1. In the service accounts list, click on the newly created account
2. Go to **Keys** tab
3. Click **Add Key** → **Create new key**
4. Select **JSON** format
5. Click **Create**
6. Save the downloaded JSON file securely (you'll need it for GitHub secrets)

**Security Warning:** This JSON file provides full access to your Play Developer account. Never commit it to version control!

#### Step 4: Grant Service Account Access in Play Console

1. Go to https://play.google.com/console
2. Navigate to **Setup** → **API access**
3. Under **Service accounts**, you should see your new service account listed
4. If not listed, click **Link existing service account** and follow the prompts
5. Click **Grant access** next to your service account
6. Configure permissions:
   - **Account permissions:** None (or minimal)
   - **App permissions:** Select your app ("Later")
   - **Releases:** Select **Release manager** or **Admin** (required for publishing)
   - **Store presence:** Can leave as "View only" unless updating metadata
7. Click **Invite user**
8. Confirm by clicking **Apply**

**Note:** It may take a few minutes for permissions to propagate.

#### Step 5: Verify API Access (Optional but Recommended)

Test the service account using Google's APIs Explorer:
1. Go to https://developers.google.com/android-publisher/api-ref/rest
2. Try calling `edits.insert` with your package name
3. Use OAuth 2.0 Playground with the service account credentials

### Part C: Keystore Generation and Configuration

#### Step 1: Generate Release Keystore

Run the following command (adjust path for your OS):

**macOS/Linux:**
```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

**Windows (PowerShell):**
```powershell
keytool -genkey -v `
  -keystore $env:USERPROFILE\upload-keystore.jks `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias upload
```

You'll be prompted to enter:
- Keystore password (choose a strong password)
- Key password (can be same as keystore password)
- Name, organizational unit, organization, city, state, country code

**Important:**
- Store passwords securely in a password manager
- Back up the keystore file in a secure location
- Never commit the keystore to version control
- Validity: 10,000 days = ~27 years (Play Store requires min 2033 expiry)

#### Step 2: Convert Keystore to Base64

**macOS/Linux:**
```bash
base64 -i ~/upload-keystore.jks | pbcopy
# Or save to file:
base64 -i ~/upload-keystore.jks > ~/keystore-base64.txt
```

**Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\upload-keystore.jks")) | Set-Clipboard
# Or save to file:
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\upload-keystore.jks")) | Out-File -FilePath "$env:USERPROFILE\keystore-base64.txt"
```

The base64 string is now copied to clipboard (or saved to file).

#### Step 3: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each of the following:

| Secret Name | Value | Example |
|------------|-------|---------|
| `KEYSTORE_BASE64` | Base64-encoded keystore from Step 2 | `MIIKWwIBAzCCC...` (very long string) |
| `KEYSTORE_PASSWORD` | Keystore password from Step 1 | `MyStr0ngP@ssw0rd` |
| `KEY_ALIAS` | Key alias from Step 1 | `upload` |
| `KEY_PASSWORD` | Key password from Step 1 | `MyStr0ngP@ssw0rd` |
| `SERVICE_ACCOUNT_JSON` | Full contents of service account JSON file | `{"type": "service_account",...}` |

**Verification:**
- All 5 secrets should be listed in the repository secrets
- Secret values are encrypted and hidden after creation

#### Step 4: Update Build Configuration

Edit `apps/later_mobile/android/app/build.gradle.kts`:

**Add before the `android` block:**
```kotlin
// Load keystore properties if they exist
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

**Update the `android` block to add signing configuration:**
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

    // Add signing configurations
    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties['keyAlias']
                keyPassword = keystoreProperties['keyPassword']
                storeFile = file(keystoreProperties['storeFile'])
                storePassword = keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            // Remove debug signing, use release signing config
            signingConfig = signingConfigs.release
        }
    }
}

flutter {
    source = "../.."
}
```

**Update `apps/later_mobile/android/.gitignore`:**
```
# Add these lines if not already present
key.properties
*.keystore
*.jks
```

#### Step 5: Test Local Build (Optional)

To test the signing configuration locally:

1. Create `android/key.properties`:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```

2. Build the release bundle:
   ```bash
   cd apps/later_mobile
   flutter build appbundle --release
   ```

3. Verify the AAB is signed:
   ```bash
   # Check the AAB file was created
   ls -lh build/app/outputs/bundle/release/app-release.aab
   ```

4. **Delete `key.properties` after testing** (never commit this file!)

### Part D: GitHub Actions Workflow Setup

#### Step 1: Create Workflow Directory

```bash
cd /Users/jonascurth/later
mkdir -p .github/workflows
```

#### Step 2: Create PR Checks Workflow

Create `.github/workflows/pr-checks.yml`:

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
          flutter-version: '3.24.5'  # Match your project version
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

**Key Points:**
- Runs on every PR to `main` branch
- Only triggers if files in `apps/later_mobile/` change
- Builds APK for validation (not deployed)
- Uploads APK as artifact for manual testing
- 30-minute timeout to prevent hanging builds

#### Step 3: Create Deployment Workflow

Create `.github/workflows/deploy-internal.yml`:

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
    name: Build and Deploy to Internal Testing
    runs-on: ubuntu-latest
    timeout-minutes: 45

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

      - name: Run tests
        run: flutter test

      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}

      - name: Create key.properties
        run: |
          cat > android/key.properties << EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=upload-keystore.jks
          EOF

      - name: Build App Bundle
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

      - name: Upload AAB artifact
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: release-aab-${{ github.run_number }}
          path: apps/later_mobile/build/app/outputs/bundle/release/app-release.aab
          retention-days: 30

      - name: Clean up secrets
        if: always()
        run: |
          rm -f android/app/upload-keystore.jks
          rm -f android/key.properties
```

**Key Points:**
- Runs on push to `main` branch (after PR merge)
- Only triggers if files in `apps/later_mobile/` change
- Decodes keystore from base64 secret
- Creates temporary `key.properties` for Gradle
- Builds signed AAB
- Uploads to internal testing track automatically
- Cleans up secrets after build
- 45-minute timeout for build + upload

#### Step 4: Commit and Push Workflows

```bash
git add .github/workflows/
git commit -m "feat: Add GitHub Actions CI/CD for Android

- PR checks: build, analyze, and test
- Deployment: auto-publish to Play Store internal testing after merge"
git push origin main
```

This will trigger the deployment workflow immediately. Monitor progress in the **Actions** tab.

### Part E: Testing and Validation

#### Step 1: Test PR Workflow

1. Create a test branch:
   ```bash
   git checkout -b test/ci-pipeline
   ```

2. Make a trivial change (e.g., add comment to `pubspec.yaml`):
   ```yaml
   # Test CI/CD pipeline
   name: later_mobile
   ```

3. Commit and push:
   ```bash
   git add .
   git commit -m "test: Validate CI/CD pipeline"
   git push origin test/ci-pipeline
   ```

4. Create a pull request on GitHub

5. Monitor the PR checks:
   - Go to the PR page
   - Check the **Checks** tab
   - Verify "PR Checks - Build and Test" runs successfully
   - Review build logs if failures occur

6. Download the APK artifact:
   - Go to workflow run details
   - Scroll to **Artifacts** section
   - Download `pr-apk-XXX` file
   - Install on Android device for manual testing

#### Step 2: Test Deployment Workflow

1. Merge the PR to `main`

2. Monitor the deployment workflow:
   - Go to **Actions** tab in repository
   - Click on "Deploy to Play Store Internal Testing" workflow
   - Watch the build and upload steps

3. Verify upload to Play Console:
   - Go to https://play.google.com/console
   - Navigate to **Testing** → **Internal testing**
   - Verify new release appears with correct version
   - Check release notes and version number

4. Test installation via internal testing:
   - Share the opt-in URL with a test device
   - Opt in to internal testing
   - Install the app from Play Store
   - Verify app launches and functions correctly

#### Step 3: Monitor for Issues

**Common Issues and Solutions:**

| Issue | Cause | Solution |
|-------|-------|----------|
| "Error signing APK" | Invalid keystore or passwords | Verify GitHub secrets are correct, regenerate keystore if needed |
| "Service account authentication failed" | Invalid service account JSON or permissions | Re-download JSON, verify Play Console permissions |
| "Version code already exists" | Duplicate version code | Increment version in `pubspec.yaml` |
| "Tests failed" | Code issues | Fix failing tests, ensure all tests pass locally first |
| "Upload timeout" | Large AAB or slow network | Increase workflow timeout, optimize AAB size |
| "Keystore not found" | Base64 decoding failed | Verify base64 encoding is correct, no whitespace |

**Debugging Steps:**
1. Check workflow logs in GitHub Actions (click on failed step)
2. Enable debug logging: Settings → Secrets → Add `ACTIONS_STEP_DEBUG` = `true`
3. Test locally: Build release bundle and verify signing
4. Verify secrets: Check all 5 required secrets are set correctly
5. Check Play Console: Ensure service account has correct permissions

## Version Management Strategy

### Automatic Version Code Generation

To avoid version conflicts in CI/CD, implement automatic version code generation based on build number:

**Option 1: Use GitHub Run Number**

Update `pubspec.yaml`:
```yaml
version: 1.0.0+$BUILD_NUMBER
```

Update workflow to set BUILD_NUMBER:
```yaml
- name: Set build number
  run: |
    BUILD_NUMBER=${{ github.run_number }}
    echo "BUILD_NUMBER=$BUILD_NUMBER" >> $GITHUB_ENV
    sed -i "s/\$BUILD_NUMBER/$BUILD_NUMBER/g" pubspec.yaml
```

**Option 2: Use Timestamp**

Generate version code from timestamp:
```yaml
- name: Generate version code
  run: |
    VERSION_CODE=$(date +%s)
    echo "VERSION_CODE=$VERSION_CODE" >> $GITHUB_ENV
    sed -i "s/version: \(.*\)+.*/version: \1+$VERSION_CODE/" pubspec.yaml
```

**Recommendation:** Use GitHub run number for easier tracking and sequential version codes.

## Appendix

### A. Required GitHub Secrets Summary

| Secret Name | Description | How to Obtain |
|------------|-------------|---------------|
| `KEYSTORE_BASE64` | Base64-encoded upload keystore | Generate keystore, then: `base64 -i upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Password for the keystore | Set when generating keystore with `keytool` |
| `KEY_ALIAS` | Alias of the key in keystore | Set when generating keystore (typically "upload") |
| `KEY_PASSWORD` | Password for the specific key | Set when generating keystore (can match keystore password) |
| `SERVICE_ACCOUNT_JSON` | Google Play service account credentials | Google Cloud Console → Service Accounts → Create Key → JSON |

### B. Google Play Console Navigation Reference

Common tasks and where to find them:

- **Create app:** Home → Create app
- **Internal testing:** Testing → Internal testing
- **Add testers:** Testing → Internal testing → Testers tab
- **View releases:** Testing → Internal testing → Releases tab
- **API access:** Setup → API access
- **App content:** Policy → App content
- **Store listing:** Grow → Store presence → Main store listing
- **App signing:** Release → Setup → App signing

### C. Useful Commands Reference

**Flutter:**
```bash
# Build release AAB
flutter build appbundle --release

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean build
flutter clean

# Get dependencies
flutter pub get
```

**Keystore:**
```bash
# Generate keystore (macOS/Linux)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# List keystore contents
keytool -list -v -keystore upload-keystore.jks

# Convert to base64 (macOS/Linux)
base64 -i upload-keystore.jks | pbcopy

# Convert to base64 (Windows PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
```

**Git:**
```bash
# Create workflow directory
mkdir -p .github/workflows

# Commit workflows
git add .github/workflows/
git commit -m "feat: Add CI/CD workflows"
git push origin main
```

### D. Troubleshooting Guide

**Issue: "Build fails with 'Execution failed for task :app:signReleaseBundle'"**

**Cause:** Missing or incorrect keystore configuration.

**Solution:**
1. Verify all keystore secrets are set in GitHub
2. Check base64 encoding has no whitespace/newlines
3. Verify key.properties is created correctly in workflow
4. Test local build with key.properties

---

**Issue: "Service account does not have access to the app"**

**Cause:** Service account not granted permissions in Play Console.

**Solution:**
1. Go to Play Console → Setup → API access
2. Find your service account
3. Grant access to the app with "Release manager" or higher role
4. Wait 5-10 minutes for permissions to propagate

---

**Issue: "Version code 1 has already been used"**

**Cause:** Same version code used for multiple releases.

**Solution:**
1. Increment version in `pubspec.yaml`: `version: 1.0.0+2`
2. Implement automatic version code generation (see Version Management Strategy)
3. Commit and push change

---

**Issue: "Workflow runs but never publishes to Play Store"**

**Cause:** Workflow might be skipped due to path filters.

**Solution:**
1. Check workflow logs to see if it ran
2. Verify changes are in `apps/later_mobile/` directory
3. Temporarily remove `paths:` filter to test
4. Check service account JSON is valid

---

**Issue: "App bundle is too large (over 150MB)"**

**Cause:** Large assets or dependencies.

**Solution:**
1. Enable R8/ProGuard shrinking in `build.gradle.kts`
2. Optimize assets (compress images, remove unused files)
3. Use app bundle (AAB) instead of APK for optimized delivery
4. Consider Android App Bundle with Play Asset Delivery for large apps

---

**Issue: "Tests pass locally but fail in CI"**

**Cause:** Environment differences or missing dependencies.

**Solution:**
1. Check Java version matches (use Java 17 in both)
2. Verify Flutter version matches in workflow
3. Check for missing environment variables or secrets
4. Run `flutter clean` locally and rebuild to ensure clean state

### E. Next Steps After Implementation

**Immediate Tasks:**
1. ✅ Set up Google Play Developer account
2. ✅ Create app in Play Console
3. ✅ Generate keystore and configure GitHub secrets
4. ✅ Create service account and configure API access
5. ✅ Implement GitHub Actions workflows
6. ✅ Test PR checks workflow
7. ✅ Test deployment workflow
8. ✅ Verify app appears in internal testing

**Short-term Enhancements:**
1. Add automated version code generation
2. Implement release notes generation from git commits
3. Add Slack/email notifications for deployment success/failure
4. Create separate workflow for manual production releases
5. Add code coverage reporting
6. Implement automated screenshot generation for Play Store

**Long-term Considerations:**
1. Migrate from internal testing → closed testing → open testing → production
2. Set up alpha/beta tracks for staged rollouts
3. Implement automated metadata management (store listing, screenshots)
4. Add iOS deployment pipeline (TestFlight)
5. Integrate with Firebase for crash reporting and analytics
6. Set up monitoring and alerting for production releases
7. Implement automated rollback strategy for failed releases

### F. Additional Resources

**Official Documentation:**
- Flutter deployment: https://docs.flutter.dev/deployment/android
- GitHub Actions: https://docs.github.com/en/actions
- Google Play Console: https://support.google.com/googleplay/android-developer
- Play Developer API: https://developers.google.com/android-publisher/api-ref/rest
- Fastlane for Flutter: https://docs.fastlane.tools/getting-started/cross-platform/flutter/

**Community Resources:**
- Flutter CI/CD examples: https://github.com/flutter/flutter/wiki/Continuous-Integration
- r0adkll/upload-google-play action: https://github.com/r0adkll/upload-google-play
- Flutter community on Discord: https://discord.gg/flutter
- Android developer community: https://developer.android.com/community

**Tools:**
- Keystore Explorer (GUI for keystore management): https://keystore-explorer.org/
- Privacy Policy Generator: https://app-privacy-policy-generator.firebaseapp.com/
- App Icon Generator: https://appicon.co/
- Screenshot Generator: https://www.appmockup.com/

## References

1. Flutter Official Documentation - Build and release an Android app: https://docs.flutter.dev/deployment/android
2. GitHub Actions Documentation: https://docs.github.com/en/actions
3. Google Play Console Help - Create and set up your app: https://support.google.com/googleplay/android-developer/answer/9859152
4. Google Play Developer API Reference: https://developers.google.com/android-publisher/api-ref/rest
5. Medium - Deploying Android Apps to Play Store Internal Testing with GitHub Actions and Fastlane: https://apexive.com/post/deploying-android-apps-to-play-store-internal-testing-with-github-actions-and-fastlane
6. FreeCodeCamp - How to Automate Flutter Testing and Builds with GitHub Actions: https://www.freecodecamp.org/news/how-to-automate-flutter-testing-and-builds-with-github-actions-for-android-and-ios/
7. GitHub Marketplace - Upload Android Release to Play Store: https://github.com/marketplace/actions/upload-android-release-to-play-store
8. Fastlane Documentation - Flutter: https://docs.fastlane.tools/getting-started/cross-platform/flutter/
9. LogRocket Blog - Flutter CI/CD using GitHub Actions: https://blog.logrocket.com/flutter-ci-cd-using-github-actions/
10. Medium - Automating Success: GitHub Actions Workflow for Android App Deployment: https://medium.com/@vontonnie/automating-success-github-actions-workflow-for-android-app-deployment-908095d53b97
