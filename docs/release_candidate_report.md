# Release Candidate Report (RC-1.2)

## Executive Summary
This release candidate strictly resolves P0 and P1 failures surfaced during RC-1.1 manual validation. We restored offline-first state machine reliability, protected history and draft records natively in Hive, explicitly removed inappropriate fallbacks across BLoC states, and established a documented migration matrix explaining the local install conflict.

## Changes
- Add/Edit flow rigorously requires full `Work` models for modification, eliminating silent fallback overwrites affecting historical records.
- Built a native Autosave protocol persisting `LabourFormModel` payloads in-flight using an auxiliary `DraftModel` and `draftBox`.
- Corrected unexpected screen state by strictly narrowing `buildWhen` logic to filter arbitrary global state emissions (`WorkActionSuccess`).
- Completed `HistoryScreen` displaying dates/sessions.
- Created `AnalyticsScreen` projecting offline statistical analysis locally.

## Technical Decisions
- Preserved Clean Architecture standards by persisting `SearchQuery` dynamically within global UI `WorkBloc` state, matching UI queries across separate screens avoiding standalone bloat.
- Re-architectured inline labour modifications mapping soft deletes (`isPresent = false`) directly to historical payloads.

## Risk Assessment
- **APK Install Continuity:** A known fail condition remains regarding APK installs over RC-1.1; documented explicit un-install/migration paths correctly due to absence of original proprietary `.jks`.

## Validation
- `edit_flow_test.dart` ensures continuity across trip persistence layers.
- Tests passing: 54 / 54. Analyzer issues effectively zero.
