# Hotfix Root Cause Audit

## P0-001: Dashboard Unexpected State
- **Severity**: P0
- **Reproduction**: Trigger a `SaveFullWorkTripEvent`. Observe the dashboard screen immediately after saving.
- **Expected**: Dashboard shows loading skeleton, then transitions to DashboardLoaded displaying the trips.
- **Actual**: Screen briefly flashes "Unexpected state in Dashboard".
- **Root Cause**: `WorkBloc` emits `WorkActionSuccess()` and immediately dispatches `LoadDashboardDataEvent`. The `DashboardScreen` UI's `BlocBuilder` evaluates `WorkActionSuccess` and hits the exhaustive `switch` block. Since `WorkActionSuccess` is mapped to the "Unexpected State" fallback in the UI, it renders an error before the dashboard finishes loading.
- **Affected Layers**: `work_bloc.dart`, `dashboard_screen.dart`, `details_screen.dart`, `trip_details_screen.dart`
- **Risk**: Low risk to data, high risk to UX.
- **Fix Strategy**: In `dashboard_screen.dart`, map `WorkActionSuccess` to `_buildSkeleton()` instead of the error state, as it implies a data refresh is imminent. Alternatively, avoid mapping it to an error in all screens.

## P0-002: Labour Name Overwrite
- **Severity**: P0
- **Reproduction**: Click "Add Labour" in `AddEditWorkScreen`, type "Rahul", and save the trip. Open Trip Details.
- **Expected**: Trip details shows "Rahul".
- **Actual**: Trip details shows "Labour 1".
- **Root Cause**: `AddEditWorkScreen` creates a `TripLabour` object internally when adding a labour but drops the name string because `TripLabour` does not have a `name` field. The actual `Labour` entity (which contains the name) is never instantiated or dispatched to `WorkBloc`. `TripDetailsScreen` iterates through `TripLabour` lists and hardcodes `'Labour ${entry.key + 1}'` because no `Labour` entity lookup exists.
- **Affected Layers**: `AddEditWorkScreen`, `WorkBloc`, `TripDetailsScreen`, `SaveFullWorkTripEvent`.
- **Risk**: Critical data integrity failure. Names are permanently lost.
- **Fix Strategy**:
  1. Add `String name` to `TripLabour` UI state or create a separate DTO for the form.
  2. Pass `List<Labour>` to `SaveFullWorkTripEvent`.
  3. `WorkBloc` must call `saveLabour` repository method for each new labour.
  4. `TripDetailsScreen` must query `Labour` entities by `labourId` to render real names.

## P0-003: Trip Add/Edit Instability
- **Severity**: P0
- **Reproduction**: In `AddEditWorkScreen`, toggle "Working" to false. Observe UI.
- **Expected**: Toggle works, absence is persisted.
- **Actual**: `setState` updates state locally, but logic might fail to apply UI visual changes. Edit mode completely drops prior values or corrupts states.
- **Root Cause**: The form is creating a new `Work` and new `TripId` even during edits. The `existingWork = state.currentWork;` logic creates duplicate entries instead of updating the specific `tripId`.
- **Affected Layers**: `AddEditWorkScreen`, `work_bloc.dart`.
- **Fix Strategy**: Differentiate strictly between Create and Edit modes. Pass existing `tripId` into the event. Ensure `context.pop()` occurs strictly via `BlocListener`.

## P0-004 & P0-005: Search & Filter Nonfunctional
- **Severity**: P0
- **Reproduction**: Type into the dashboard search bar.
- **Expected**: List of trips filters instantly.
- **Actual**: Search returns no results or breaks.
- **Root Cause**: In `DashboardScreen`, the `searchQuery` state might not be adequately mapped against all fields (driver, tractor, workType) or is swallowing states.
- **Affected Layers**: `dashboard_screen.dart`, `details_screen.dart`.
- **Fix Strategy**: Ensure robust case-insensitive `.contains()` queries across all searchable text fields in the BLoC or UI layer.

## P0-006: Date Leakage Across Days (CRITICAL)
- **Severity**: P0 (Data Corruption)
- **Reproduction**: Open app on 24 May. Change date to 25 May in `AddEditWorkScreen`. Save Trip 1.
- **Expected**: 25 May has 1 trip. 24 May remains unchanged.
- **Actual**: 25 May overwrites 24 May's `Work` entity due to reused `workId`.
- **Root Cause**: `AddEditWorkScreen` reads `final workId = existingWork?.id ?? _uuid.v4();` from the `DashboardLoaded` state. Since the dashboard loaded 24 May, `existingWork` is 24 May. Saving a trip for 25 May reuses the 24 May `workId`, executing a Hive overwrite (`workBox.put(work.id, work)`) which forces the old work entry to adopt the new date, thereby corrupting the database.
- **Affected Layers**: `AddEditWorkScreen`, `work_bloc.dart`.
- **Fix Strategy**: Do NOT rely blindly on `state.currentWork?.id`. Generate a deterministic ID based on `date_session`, or perform a repository lookup for `getWorkByDateAndSession(newDate, newSession)` before executing a save operation.

## P0-008 & P0-009: Add/Edit Trip Flow (Attendance Toggle & Negative Button Failure)
- **Severity**: P0
- **Reproduction**: Edit an existing trip. Click the minus button next to a labour. Save. Re-open the trip details. Alternatively, toggle a labour to "Not working" (absent) and save.
- **Expected**: Labour is removed entirely from the trip (if negative button was pressed) or marked absent (if toggled).
- **Actual**: Removed labours reappear. Toggle states might not apply correctly due to duplication.
- **Root Cause**:
  1. Negative Button: The `AddEditWorkScreen` removes the labour locally from `_currentLabours` (`_currentLabours.removeAt(idx)`). When `SaveFullWorkTripEvent` passes the remaining list to `work_bloc.dart`, it calls `saveTripLabours` via `putAll`. Hive's `putAll` acts as an *upsert*. It adds/updates the 2 remaining labours but never executes `delete()` for the one that was removed. Thus, the database retains all 3.
  2. The `SaveFullWorkTripEvent` implementation creates duplicate records by not explicitly syncing the exact `tripLabours` state (deleting orphans).
- **Affected Layers**: `AddEditWorkScreen`, `work_local_data_source.dart`, `work_bloc.dart`.
- **Fix Strategy**:
  1. When saving an edited trip, the BLoC or Repository must delete old `TripLabour` entries associated with the `tripId` before `putAll` executes, ensuring the database strictly mirrors the newly submitted list.
  2. Implement proper cleanup in `saveTripLabours` or introduce `updateTripLabours` UseCase.

## P0-010: Stale Dashboard Refresh
- **Severity**: P0
- **Reproduction**: Delete a trip or save an edit.
- **Expected**: Dashboard reflects changes immediately.
- **Actual**: Dashboard displays stale trips.
- **Root Cause**: Caching or missing state invalidation. In `_onDeleteTrip` and `_onSaveFullWorkTrip`, the event dispatches `LoadDashboardDataEvent` but might not clear local properties correctly.
- **Affected Layers**: `work_bloc.dart`.
- **Fix Strategy**: Validate `add(LoadDashboardDataEvent(...))` resolves after Hive transactions finalize, and clear local state correctly during `WorkLoading`.

## P0-007: Trip Details State Errors
- **Severity**: P0
- **Reproduction**: Click a trip to open details.
- **Expected**: TripDetailsScreen displays cleanly.
- **Actual**: Shows "Unexpected state" or throws errors because it might be receiving `DashboardLoaded` state instead of `TripDetailsLoaded`.
- **Root Cause**: BLoC instances are shared across screens without scoping. `TripDetailsScreen` listens to the global `WorkBloc`. If the global `WorkBloc` is currently in `DashboardLoaded` (from a background refresh or prior screen), the exhaustive switch statement in `TripDetailsScreen` falls into the generic error fallback: `WorkEmpty() || DashboardLoaded() || WorkActionSuccess() => const Center(...)`.
- **Affected Layers**: `trip_details_screen.dart`.
- **Fix Strategy**: `TripDetailsScreen` should quietly ignore or render a skeleton for states that don't belong to it, or the BLoC should emit `TripDetailsLoaded` cleanly and persist it. Better yet, `TripDetailsScreen` should tolerate `DashboardLoaded` by rendering a skeleton while waiting for `TripDetailsLoaded`.
