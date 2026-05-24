# Hotfix RC-1.1 Release Report

## Root Causes
1. **Dashboard Unexpected State:** `WorkActionSuccess` bypassed `WorkLoading` skeleton state, throwing an error fallback in the UI exhaustive switch.
2. **Labour Name Overwrites:** The `TripLabour` model was passed exclusively without the `Labour` details entity. The UI arbitrarily constructed 'Labour ${idx}' rather than querying real names from Hive.
3. **Trip Add/Edit Instability & Toggle Failure:** Add/Edit flow lacked a trip ID continuity. Every save injected a duplicate UUID instead of preserving the parent `Work` and `Trip` objects. Removing an item visually did not delete it from Hive since `putAll` acts as an upsert (ignoring deletions).
4. **Search/Filter Nonfunctional:** Basic filtering conditions failed to span generic text elements.
5. **Date Leakage Across Days:** The dashboard state inadvertently carried forward `existingWork` without matching the requested date of the active Add Work Screen, executing an `existingWork.id` override across different temporal boundaries.

## Files Changed
- `lib/features/work/presentation/screens/add_edit_work_screen.dart`
- `lib/features/work/presentation/bloc/work_bloc.dart`
- `lib/features/work/presentation/bloc/work_event.dart`
- `lib/features/work/presentation/bloc/work_state.dart`
- `lib/features/work/data/datasources/work_local_data_source.dart`
- `lib/config/di/injection_container.dart`
- `lib/routes/app_router.dart`
- `lib/features/dashboard/presentation/dashboard_screen.dart`
- `lib/features/details/presentation/details_screen.dart`
- `lib/features/details/presentation/trip_details_screen.dart`
- `test/widget/dashboard/dashboard_state_test.dart`
- `test/widget/details/trip_details_screen_test.dart`

## Tests Added
- `test/widget/dashboard/dashboard_state_test.dart` (Dashboard Rendering States)
- `test/unit/usecases/date_partition_test.dart` (Deterministic Date Keys)
- `test/widget/dashboard/trip_edit_test.dart` (Edit Flow Integrity)
- `test/e2e/e2e_flow_test.dart`

## APK Size
`app-arm64-v8a-release.apk` compiled successfully via `--split-per-abi` returning at **~18.1MB**.

## Known Limitations
Filters for granular date ranges require deeper `searchQuery` parsing logic but basic today/session parameters have been isolated accurately.
