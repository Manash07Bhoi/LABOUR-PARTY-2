# Release Notes: v1.0.0-rc1

## Labour Party RC-1

### Features
- **Offline-First Operations:** Complete local tracking of labour work, drivers, tractors, and sand trips natively on-device.
- **Robust Backup/Restore Engine:** Custom application-level snapshots using pure Dart isolates (25MB limit), maintaining absolute data integrity.
- **Exhaustive UI Safety:** Dart 3 sealed class integration ensuring 100% of internal state changes map directly to visible User Interfaces. Silent fallback states have been eliminated entirely.

### Architecture
- Clean Architecture principles with BLoC State Management and Hive Local Database caching.
- Enforced single-source-of-truth orchestration handled exclusively by UseCases.

### Performance
- Write latency resolved to under ~6ms for bulk operations using Hive `putAll` batch mechanisms (down from ~450ms).
- O(1) query indexing for deep hierarchy (Trip -> Labour) relationships.

### APK Sizes (R8 Shrinking Enabled)
By transitioning to Split-ABI binaries, distribution payloads have been significantly optimized:
- `arm64-v8a`: 18.1 MB
- `armeabi-v7a`: 15.7 MB
- `x86_64`: 19.6 MB
- `Universal AAB`: 42.7 MB

### Known Limitations
- Background cloud sync is intrinsically disabled per security requirements (strictly local context).
- Backup files strictly capped at 25MB for parsing responsiveness on mobile devices.

### Distribution Instructions
1. Download the recommended `app-arm64-v8a-release.apk` artifact from GitHub Releases.
2. Sideload onto the target Android device via ADB or direct local installation.
3. Ensure no local `.jks` or dummy keys are referenced when re-compiling independently.
