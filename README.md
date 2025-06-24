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

