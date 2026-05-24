# Labour Party

> A fully offline, professional-grade Flutter application designed for local-first operational management.

Labour Party is built specifically for daily logistical tracking: recording labour work, managing driver & tractor assignments, tracking sand trips, and compiling on-device operational reports. The application utilizes a stringent offline-first architecture with no backend server, APIs, or internet reliance.

## Overview

- **Offline-First:** All data persists locally via [Hive](https://pub.dev/packages/hive).
- **Clean Architecture:** Strict boundaries separating UI, BLoC, UseCases, Repositories, and Data Sources.
- **Enterprise-Grade UI:** Incorporates Material 3, glassmorphism, and explicit state feedback mechanisms.
- **Performance Optimized:** Batch database persistence and local cache indexing ensuring $O(1)$ lookups and sub-10ms UI renders.

## Documentation

Comprehensive architecture, testing, and operational rules are maintained within the `docs/` directory:

- [Architecture Guide](docs/ARCHITECTURE.md)
- [Business Rules](docs/BUSINESS_RULES.md)
- [Backup & Restore Logic](docs/BACKUP_RESTORE.md)
- [Memory Bank & State](docs/MEMORY_BANK.md)
- [Testing Report](docs/testing_report.md)
- [Release Notes](docs/release_notes.md)
- [Merge Resolution Report](docs/merge_resolution_report.md)

## Getting Started

To run the application locally:

```bash
flutter clean
flutter pub get
flutter test
flutter run
```

### Release Builds
Release builds enforce strict signing parameters. You must supply a valid `android/key.properties` configuration referencing your keystore.

```bash
flutter build apk --release
flutter build appbundle
```
_Note: If signing variables are absent, the Gradle build will explicitly fail to prevent accidental un-signed APKs._
