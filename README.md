# bugbear_app

A cross-platform Flutter application for logging bug reports and managing recovery tasks.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firestore Rules

Security rules for Cloud Firestore are stored in `firestore.rules`. After making changes, deploy them with other Firebase configuration using:

```bash
firebase deploy
```

## Encryption Key Lifecycle

The app encrypts all Hive boxes using a secret key. The first time the
application runs, `SecureStorageService` generates a new key using `Hive.generateSecureKey()`.
This key is persisted with `FlutterSecureStorage` so it remains available across
app restarts. On subsequent launches the stored key is loaded again and reused to
decrypt the boxes. The key only changes when the app data is cleared or the
`FlutterSecureStorage` entry is removed.
Signing out triggers `AuthService.signOut()`, which clears `SecureStorageService`
and deletes the stored encryption key so a fresh key is generated on the next
launch.

## Firebase API Key Restrictions

API keys in `lib/firebase_options.dart` should be restricted in the Google Cloud
console to prevent unauthorized use. When generating new keys, apply the
following restrictions:

1. **Android** – Restrict to the Android package name
   `com.example.bugbear_app` and add the appropriate SHA-1/SHA-256 signing
   certificate fingerprints.
2. **iOS** – Restrict to the bundle ID `com.example.bugbearRecovery`.
3. **Web** – Authorize the domains used by the web app such as
   `https://bugbear-9d720.web.app`, `https://bugbear-9d720.firebaseapp.com` and
   any local development hosts (for example `http://localhost:5000`).

After creating restricted keys, provide them as compile‑time environment
variables when building the app. The values are read using `String.fromEnvironment`
and are **not** stored in source control. Example:

```bash
flutter run \
  --dart-define=FIREBASE_PROJECT_ID=bugbear-9d720 \
  --dart-define=FIREBASE_ANDROID_API_KEY=<android-key> \
  --dart-define=FIREBASE_ANDROID_APP_ID=<android-app-id> \
  --dart-define=FIREBASE_ANDROID_MESSAGING_SENDER_ID=<android-messaging-id> \
  --dart-define=FIREBASE_ANDROID_STORAGE_BUCKET=<android-bucket> \
  --dart-define=FIREBASE_IOS_API_KEY=<ios-key> \
  --dart-define=FIREBASE_IOS_APP_ID=<ios-app-id> \
  --dart-define=FIREBASE_IOS_BUNDLE_ID=<ios-bundle-id> \
  --dart-define=FIREBASE_IOS_MESSAGING_SENDER_ID=<ios-messaging-id> \
  --dart-define=FIREBASE_IOS_STORAGE_BUCKET=<ios-bucket> \
  --dart-define=FIREBASE_MACOS_API_KEY=<macos-key> \
  --dart-define=FIREBASE_MACOS_APP_ID=<macos-app-id> \
  --dart-define=FIREBASE_MACOS_BUNDLE_ID=<macos-bundle-id> \
  --dart-define=FIREBASE_MACOS_MESSAGING_SENDER_ID=<macos-messaging-id> \
  --dart-define=FIREBASE_MACOS_STORAGE_BUCKET=<macos-bucket> \
  --dart-define=FIREBASE_WEB_API_KEY=<web-key> \
  --dart-define=FIREBASE_WEB_APP_ID=<web-app-id> \
  --dart-define=FIREBASE_WEB_AUTH_DOMAIN=<web-auth-domain> \
  --dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID=<web-messaging-id> \
  --dart-define=FIREBASE_WEB_STORAGE_BUCKET=<web-bucket> \
  --dart-define=FIREBASE_WINDOWS_API_KEY=<windows-key> \
  --dart-define=FIREBASE_WINDOWS_APP_ID=<windows-app-id> \
  --dart-define=FIREBASE_WINDOWS_AUTH_DOMAIN=<windows-auth-domain> \
  --dart-define=FIREBASE_WINDOWS_MESSAGING_SENDER_ID=<windows-messaging-id> \
  --dart-define=FIREBASE_WINDOWS_STORAGE_BUCKET=<windows-bucket>
```

Missing values for any of these variables cause `Firebase.initializeApp` to fail
during startup.

These variables can also be configured in your CI environment with the same
names when running `flutter build`.


### Using a key file for local development
Instead of supplying dozens of `--dart-define` options every time, the values can
be stored in a JSON file. Create `key_values.json` with all the required keys and
run:

```bash
flutter run --dart-define-from-file=key_values.json
```

This loads each environment variable from the JSON file so Firebase initializes
successfully.
