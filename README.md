# bugbear_recovery

A new Flutter project.

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

## Firebase API Key Restrictions

API keys in `lib/firebase_options.dart` should be restricted in the Google Cloud
console to prevent unauthorized use. When generating new keys, apply the
following restrictions:

1. **Android** – Restrict to the Android package name
   `com.example.bugbear_recovery` and add the appropriate SHA-1/SHA-256 signing
   certificate fingerprints.
2. **iOS** – Restrict to the bundle ID `com.example.bugbearRecovery`.
3. **Web** – Authorize the domains used by the web app such as
   `https://bugbear-9d720.web.app`, `https://bugbear-9d720.firebaseapp.com` and
   any local development hosts (for example `http://localhost:5000`).

After creating restricted keys, replace the values in
`lib/firebase_options.dart` with the new keys.

