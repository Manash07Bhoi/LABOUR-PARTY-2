# Release Notes - RC-1.3

## Executive Summary
This iteration addresses stabilization parameters and strict offline governance. It handles sequential trip logic flows, expands metadata structures, and enforces rigorous backup size validation limits for Android Scoped Storage integration.

## Changes
- **Confirm Next Trip Flow**: Introduced `ConfirmNextTripScreen` isolating sequential trip creations from deep edits. Deep clones the last trip's configuration but safely isolates metadata, actively preventing duplicate writes or state bleeding.
- **Trip Metadata Expansion**: Upgraded the core `Trip` domain schema and `TripModel` to include: `Place`, `WorkType`, `Notes`, `Status`, and timestamp telemetry (`updatedAt`). Preserves backwards compatibility with default values for legacy database entries.
- **Trip Details Expansion**: Expanded `TripDetailsScreen` UI architecture mapping the newly introduced fields inline while retaining a calculated-only `Duration` string. Handles empty inputs gracefully by displaying 'Not specified'.
- **Safe Storage Backups**: Migrated offline exports off native direct directory writes, replacing them with Scoped Storage / SAF-compatible `saveFile` prompts natively handling extensions (`.labourbackup`) cleanly across Android 11+.
- **Restoration Validation**: Implemented file-picker `FileType.any` with robust manual `.labourbackup` validation logic, filtering files larger than 25MB before executing destructive Hive wipes.

## Technical Decisions
- **Next Trip Deep Cloning**: `ConfirmNextTripScreen` physically deep-copies `TripLabour` associations instead of referencing old pointers, ensuring independence of new entries natively via Dart memory models.
- **Migration Schema Fallbacks**: Legacy `TripModel` records automatically hydrate default fields using `@HiveField` defaults. This prevents destructive wipe behaviors during database upgrades directly supporting continuity.
- **Target Platform Build Output**: APK bloat reduced via explicitly targeting `android-arm64`, dropping APK payload footprint drastically.

## Risk Assessment
- **APK Continuity Conflict**: Updating from RC-1.1 / RC-1.2 continues to fail cleanly due to misaligned `.jks` Keystore fingerprints absent from the repository. Adhere to documented data migration patterns.

## Migration Path
Administrators performing the upgrade must utilize the in-app backup/restore functionality:
1. Export current data via Settings -> Backup.
2. Uninstall RC-1.2 natively.
3. Install RC-1.3 release.
4. Import `.labourbackup` data successfully.

## Final Status
Release Candidate.
Conditionally approved.
Pending physical validation.
