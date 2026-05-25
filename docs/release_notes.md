# Release Notes - RC-1.2

## Executive Summary
This release completes the stabilization of RC-1.2. The core focus was resolving structural bugs from the previous candidate related to data integrity, offline continuity, and application state behavior during navigation and editing.

## Changes
- **Dashboard Stability**: Removed "Unexpected State" fallbacks across the main screens. State updates now explicitly filter unrelated BLoC emissions using strictly bound `buildWhen` logic.
- **Date Integrity**: Implemented hard validations to block `AddEditWorkScreen` from defaulting to `DateTime.now()` on historical trip edits, successfully resolving cross-day data pollution.
- **Labour Persistence**: Expanded inline editing controls inside `TripDetailsScreen`, supporting attendance toggles, soft-deletes (`isPresent = false`), and hard removal paired with an `Undo` Snackbar.
- **Draft Autosave**: Integrated `draftBox` via Hive. Unsaved edits to trips dynamically cache during background operations and text field updates, triggering a restoration banner upon application resume. Successful saves correctly wipe the draft entries.
- **History & Analytics**: Shipped fully operational `HistoryScreen` displaying collapsible trip segments by date and session. Delivered an `AnalyticsScreen` projecting offline KPIs and Data Tables synthesized locally from the history cache.
- **Search Propagation**: Global search strings persist intelligently via native State syncing preventing standalone `SearchBloc` memory bloat.

## Technical Decisions
- **Soft Deletions**: Decided to utilize `isPresent = false` for labour attendance logic during edit events to preserve structural associations in Hive rather than destructive queries.
- **Aggregated Offline Rendering**: Analytics metrics construct entirely from locally cached historical segments without triggering nested or duplicate `Hive` queries.

## Risk Assessment
- **APK Continuity Conflict**: Updating from RC-1.1 will fail natively via Android's package manager due to misaligned `.jks` Keystore fingerprints absent from the repository.

## Migration Path
Administrators performing the upgrade must utilize the in-app backup/restore functionality:
1. Export current production data.
2. Uninstall RC-1.1 natively.
3. Install RC-1.2.
4. Import data.

## Final Status
RC-1.2 structural and architectural defects are fully resolved. Automated coverage validates data continuity successfully. Ready for final manual validation and deployment.
