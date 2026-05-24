# Hotfix RC-1.2 Root Cause Audit

## P0 — Trip Details Screen Read-Only
- **Issue:** Trip Details screen is read-only. Cannot edit trip, add labour, toggle attendance correctly, or delete labours.
- **Root Cause:** `TripDetailsScreen` UI is purely presentation-focused. It contains no interactive actions in the AppBar (Edit Trip missing) or in the Body (Add Labour missing). Toggle and delete buttons aren't wired to `SaveFullWorkTripEvent`.
- **Affected Layers:** `trip_details_screen.dart`.
- **Fix Strategy:** Add Action buttons. Upon click, update `TripDetailsLoaded` state locally and trigger `saveTripLabours` logic through the BLoC immediately to sync storage.

## P0 — Dashboard Error Fallback
- **Issue:** Dashboard displays "Unexpected state in Dashboard".
- **Root Cause:** Dashboard `BlocBuilder` exhaustive switch resolves `TripDetailsLoaded` (and potentially other transient states) to a text placeholder instead of handling recovery or ignoring them.
- **Affected Layers:** `dashboard_screen.dart`.
- **Fix Strategy:** Remove "Unexpected state" entirely. Make `WorkActionSuccess` trigger a silent reload, and `TripDetailsLoaded` reload or fallback gracefully.

## P0 — Search System Nonfunctional
- **Issue:** Search works only on one screen and filters nothing globally.
- **Root Cause:** Global state lacks search query propagation. `DetailsScreen` implements local filtering, but it isn't robust across work type, date, or trip number.
- **Affected Layers:** `dashboard_screen.dart`, `details_screen.dart`, `work_bloc.dart`.
- **Fix Strategy:** Elevate search query to `WorkBloc` state or `DashboardLoaded` state to persist it across tabs. Ensure case-insensitive `.contains` runs across all properties.

## P0 — Filters Nonfunctional
- **Issue:** Filter buttons do nothing.
- **Root Cause:** OnPressed actions are `() {}` (empty). No filter state model exists.
- **Affected Layers:** `details_screen.dart`.
- **Fix Strategy:** Introduce filter parameters (date range, session, work type) to `WorkBloc` to apply server-side/client-side data projection.

## P0 — Local Storage + Date Isolation
- **Issue:** Adding next-day work resets data or shows old date.
- **Root Cause:** Currently, the system uses a shared Work ID.
- **Affected Layers:** `work_bloc.dart`, `work_local_data_source.dart`.
- **Fix Strategy:** Ensure deterministic isolated key derivation `work_{date}_{session}` is rigorously enforced on creation. Maintain history indexes by date.

## P0 — Auto Save
- **Issue:** Draft autosave missing.
- **Root Cause:** Not implemented in `AddEditWorkScreen`.
- **Affected Layers:** `AddEditWorkScreen`.
- **Fix Strategy:** Attach debounced listeners to `TextEditingController`s to sync a draft to local storage or memory cache.
