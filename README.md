# Free Base

Free Base is the digital companion for the Free Base reflex-integration program. The Flutter app guides families, athletes, and
therapists through structured training phases, keeps offline progress safely encrypted, and synchronises results with Firebase so
coaches always have the latest information.

## Project Overview

### Key Features
- **Guided onboarding** with Firebase email/password authentication, secure key generation, and role selection for personal,
  parent/child, or trainer journeys.
- **Daily training companion** featuring phase-based exercise plans, timers, and offline persistence through Hive, with automatic
  background synchronisation handled by the `SyncService` once connectivity returns.
- **Calendar and “Golden Day” planning** powered by the `CalendarService` and `GoldenDayService` to monitor adherence and highlight
  milestone celebrations.
- **Questionnaire and reflex profiles** that pull structured content from local JSON assets, store state securely, and surface
  insights through the profile screens.
- **Cross-platform shell** with platform-specific assets (icons, splash screens) ready to be replaced with branded Free Base
  artwork.

### Architecture Highlights
- Flutter 3 / Dart 3 application organised under `lib/features`, using Provider for dependency injection and state management.
- Firebase Core, Authentication, and Firestore for backend services; configuration is generated via `firebase_options.dart` and
  platform-specific files created by `flutterfire configure`.
- Hive (AES encrypted via `SecureStorageService`) for offline-first storage of training sessions, questionnaires, and calendar
  events.
- Modular services (`SessionRepository`, `ExerciseRepository`, `SyncService`, `CalendarService`, `GoldenDayService`,
  `ProfileService`) that keep UI widgets declarative and easy to test.
- Localisation scaffolding (`lib/l10n/*.arb`) prepared for English and German with the shared `appName` key.

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or newer (verify with `flutter --version`).
- Dart 3 toolchain (included with Flutter).
- Firebase CLI (`npm install -g firebase-tools`) with access to a Firebase project.
- Platform SDKs for your targets (Android Studio, Xcode, Visual Studio Build Tools).

### 1. Clone & install dependencies
```bash
git clone https://github.com/<your-org>/free-base.git
cd free-base
flutter pub get
```

### 2. Configure Firebase (EU region)
1. Sign in to the Firebase console and create a **dedicated EU project** (no US resources). When enabling Firestore and Storage,
   choose `europe-west3` (Frankfurt) to keep personal data inside the EU.
2. Bind the Flutter app to that project with FlutterFire. The command below regenerates `lib/firebase_options.dart` and keeps the
   configuration scoped to Android/iOS (mobile) plus opt-in desktop/web builds:
   ```bash
   flutterfire configure \
     --project <eu-project-id> \
     --out=lib/firebase_options.dart \
     --platforms=android,ios,macos,windows,web
   ```
3. Restrict each generated API key to the package or bundle IDs defined in the platform folders. These keys are
   domain/bundle-restricted **and therefore not secrets**, but rotate them if they were ever leaked.
4. Deploy the hardened Firestore rules from `firestore.rules` with `firebase deploy --only firestore:rules`.

### 3. Environment configuration
Mobile builds rely on the generated `firebase_options.dart` file. Desktop and web builds pull their values from
`--dart-define` flags so that no unrestricted keys live in version control. Set them in your shell, CI, or editor launch
configuration.

| Key | Purpose |
| --- | --- |
| `FIREBASE_USE_GENERATED_OPTIONS` | Set to `true` for local web runs when you want to reuse the generated options. |
| `FIREBASE_PROJECT_ID` | Shared project identifier for desktop platforms. |
| `FIREBASE_WEB_*` | Web API key, app ID, auth domain, messaging sender ID, and storage bucket. |
| `FIREBASE_MACOS_*` | macOS API key, bundle ID, sender ID, and storage bucket. |
| `FIREBASE_WINDOWS_*` | Windows API key, app ID, auth domain, sender ID, and storage bucket. |

Quick start script:
```bash
./tool/run.sh
```
The script sets `FIREBASE_USE_GENERATED_OPTIONS=true` for Chrome so you can boot the app without exporting every variable
manually.

### 4. Run smoke tests
- `flutter run` (mobile/web/desktop) — verify the splash screen, login, and dashboard navigation flows.
- `flutter test` — execute unit and widget tests (including questionnaire and golden day services).
- `npm run test:rules` — executes the automated Firestore security rule suite via Jest.

### Build & Release
- Android: `flutter build apk` / `flutter build appbundle`.
- iOS: `flutter build ios --release` (requires Xcode setup and code signing).
- Web: `flutter build web` and deploy the contents of `build/web/`.
- macOS / Windows: `flutter build macos` or `flutter build windows` (make sure the generated binaries use the Free Base name).

Replace the placeholder launcher icons and splash screens with official Free Base artwork before shipping. Assets live under
`assets/images` and platform-specific resources (`android/app/src/main/res`, `ios/Runner/Assets.xcassets`, etc.).

## Privacy & Data Protection (EU)
- Store all Firebase services in an EU region and document the data flows in your privacy policy.
- Authentication credentials are handled by Firebase Auth; training data and questionnaire answers live in Firestore collections
  scoped to the user ID.
- Local Hive boxes are encrypted with an AES key stored via `SecureStorageService` and purged on sign-out.
- Update the in-app and store privacy disclosures to explain retention periods, user deletion rights, and data processing roles.

## Security Automation & Runbooks
- `SECURITY.md` describes how to rotate Firebase keys, who to contact during incidents, and how to audit recent security scans.
- Enable `git-secrets` (or run `pre-commit install`) locally to block accidental commits of credentials. CI repeats these checks
  with TruffleHog so pull requests fail if a leak is detected.
- The Jest rules tests (`npm run test:rules`) must stay green before each release to guarantee that Firestore's least-privilege
  policy remains intact.

## Maintenance & Tooling
- Generate localisation files with `flutter pub run intl_utils:generate` after editing `.arb` resources.
- Run `flutter pub run build_runner build --delete-conflicting-outputs` if you add new `freezed` or `json_serializable`
  models.
- Keep the Firebase configuration (`lib/firebase_options.dart` and platform bundles) in sync with the project when environments
  change.

## Known Issues
- Parent and trainer role flows still use placeholder screens. UX copy and dedicated dashboards will follow in future sprints.
- Exercise assets currently rely on placeholder imagery (`assets/images/placeholder.png`). Replace these with the final Free Base
  visuals during the branding pass.

