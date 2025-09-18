# Security Runbook

## Secrets Policy
- Firebase API keys, App IDs, and sender IDs stored in `lib/firebase_options.dart` are domain/bundle restricted and may live in
the repository.
- All other credentials (service accounts, refresh tokens, `.env` files) must remain outside git. Store them in the secrets
manager that matches your deployment stack.
- Local builds rely on `--dart-define` values or platform keystores. Never commit generated `google-services.json` or
`GoogleService-Info.plist` files.

## Key Rotation Checklist
1. Identify the affected API key in the Firebase console.
2. Create a new key scoped to the correct package IDs / SHA fingerprints.
3. Update CI and local `.env` files with the replacement value.
4. Disable the previous key once the new key is confirmed in use.
5. Smoke test sign-in, Firestore access, and Storage uploads.
6. Record the incident in this repository's security log or ticketing system.

## Firestore Rules & Testing
- Rules are defined in `firestore.rules` and enforced via the Jest suite (`npm run test:rules`).
- Before each release, run the emulator tests locally and confirm CI is green.
- When changing the data model, add a failing test first so the new access rule is enforced intentionally.

## Secret Scanning
- Install [`git-secrets`](https://github.com/awslabs/git-secrets) or `pre-commit` with the provided configuration to block
  high-risk commits.
- GitHub Actions re-runs TruffleHog scans for every branch and pull request. Follow up on any finding immediately and rotate
  the impacted key via the checklist above.

## Incident Contacts
- Engineering lead: <engineering-lead@example.com>
- Security officer: <security@example.com>
- On-call rotation: #security-oncall (Slack / Teams)
