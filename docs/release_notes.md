# Release Notes - RC-1.3 (Final Candidate)

## Executive Summary
This release completes the final stabilization of RC-1.3. It focuses on resolving final UX regressions and offline safety protocols, particularly concerning sequential trip appending and scoped storage backup restrictions.

## Changes
- **Confirm Next Trip Flow**: Introduced `ConfirmNextTripScreen` isolating sequential trip creations from deep-edits. Deep clones the last trip's configuration but safely isolates metadata, actively preventing duplicate writes or state bleeding.
- **Trip Metadata Expansion**: Upgraded the core `Trip` domain schema and `TripModel` to include: `Place`, `WorkType`, `Notes`, `Status`, and timestamp telemetry (`updatedAt`). Fully preserves backwards compatibility with default values for legacy DB entries.
- **Trip Details Expansion**: Expanded `TripDetailsScreen` UI architecture mapping the newly introduced fields inline while retaining a calculated-only `Duration` string. Handles empty inputs gracefully displaying 'Not specified'.
- **Safe Storage Backups**: Migrated offline exports off native direct directory writes, replacing them with Scoped Storage / SAF-compatible `saveFile` prompts natively handling extensions (`.labourbackup`) cleanly across Android 11+.
- **Validated Restorations**: Implemented file-picker `FileType.any` with robust manual `.labourbackup` validation logic filtering corrupted files safely via dialog feedback before destructive Hive wipes.

## Technical Decisions
- **Next Trip Deep Cloning**: `ConfirmNextTripScreen` physically deep-copies `TripLabour` associations instead of referencing old pointers ensuring complete independence of new entries natively via Dart memory models.
- **Migration Schema Fallbacks**: Legacy `TripModel` records automatically hydrate default fields using `@HiveField` defaults. This prevents destructive wipe behaviors during database upgrades directly supporting continuity.
- **Target Platform Build Output**: APK bloat reduced via explicitly targeting `android-arm64`, dropping APK payload footprint drastically.

## Risk Assessment
- **APK Continuity Conflict**: Updating from RC-1.1 / RC-1.2 continues to fail cleanly due to misaligned `.jks` Keystore fingerprints absent from the repository. Adhere to documented data migration patterns.

## Migration Path
Administrators performing the upgrade must utilize the in-app backup/restore functionality:
1. Export current production data via Settings -> Backup.
2. Uninstall RC-1.2 natively.
3. Install RC-1.3 release.
4. Import `.labourbackup` data successfully safely reloading UI layers.

## Final Status
RC-1.3 offline workflows, domain constraints, UI validations, and migration protocols are comprehensively locked and tested natively without exceptions. Approved for release generation.
