# example_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## White-label client builds

This app is built once per client, with that client's config baked in at
build time. Client definitions live in `/configs/<client_id>/` at the repo
root (`config.json` + `icon.png`).

To build for a client locally, run from the repo root:

```
dart tool/apply_client.dart <client_id>
cd apps/example_app
flutter pub get
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
flutter build apk      # or: flutter build ipa ...
```

`tool/apply_client.dart` overwrites the following files in this app with
that client's values. They're committed with harmless placeholder defaults
(so a fresh checkout still builds/runs) — don't hand-edit them with
client-specific values on `main`, and don't worry about the `git status`
diff they leave behind after a local run:

- `config/config_app.json` — theme + backend/feature flags, read at runtime
- `android/client.properties` — Android `applicationId` + app name
- `ios/Flutter/Client.xcconfig` — iOS bundle id + app name
- `ios/ExportOptions.plist` — iOS export signing options
- `flutter_launcher_icons.yaml` — generated launcher icon config

To add a new client, add `configs/<client_id>/config.json` and
`configs/<client_id>/icon.png` — no code or CI changes needed. Trigger the
`Build Client` GitHub Actions workflow (`workflow_dispatch`) with that
`client_id` to get downloadable Android/iOS build artifacts.

iOS builds in CI require a one-time Apple Developer Portal setup (wildcard
App ID + ad-hoc provisioning profile with test device UDIDs registered)
and its secrets (`IOS_CERT_P12_BASE64`, `IOS_CERT_PASSWORD`,
`IOS_PROVISION_PROFILE_BASE64`, `IOS_PROFILE_NAME`, `IOS_TEAM_ID`) —
see `.github/workflows/build-client.yml`.
