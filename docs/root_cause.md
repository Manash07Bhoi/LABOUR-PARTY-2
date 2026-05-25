# Root Cause Document - RC-1.2 Enhancements

## 1. Dashboard Unexpected State
**Root Cause:** `DetailsScreen` and `TripDetailsScreen` used exhaustive Dart `switch` statements over `WorkState` without filtering irrelevant global events. When `WorkBloc` emitted `WorkActionSuccess` (e.g., after saving a trip), these screens fell into their fallback "Unexpected state" UI.
**Fix:** Implemented `buildWhen` logic in `BlocBuilder` to ensure screens only rebuild for states they actually care about, ignoring asynchronous global state pollution.

## 2. Trip Details Edit Flow
**Root Cause:** The `TripDetailsScreen` navigated to `/add-edit-work` passing the `Trip` but failing to provide the associated `Work` and `Labour` instances. Without `editingWork`, `AddEditWorkScreen` erroneously fell back to `DateTime.now()` as the new date, thereby corrupting date/session isolation and duplicating historical trips.
**Fix:** Modified `TripDetailsScreen` to extract the `Work` object and existing labours from `TripDetailsLoaded` state and pass them strictly. The `AddEditWorkScreen` now explicitly throws an error if a trip edit is attempted without a valid original `Work` object.

## 3. Labour Persistence
**Root Cause:** Inline editing features (toggles, remove) were missing from the UI in `TripDetailsScreen`. Additionally, `AddEditWorkScreen` did not transmit hard/soft-delete instructions to the database when updating an existing trip.
**Fix:** Implemented full inline controls in `TripDetailsScreen` including a hard-delete action protected by a Snackbar `Undo`. Refactored `SaveFullWorkTripEvent` to fetch existing labours and perform a soft-delete (`isPresent = false`) on any labour omitted in the new payload.

## 4. Date Isolation & Local Storage
**Root Cause:** The absence of a `HistoryScreen` meant old data was unreachable, presenting the illusion of data loss. Furthermore, edits without the parent `Work` object shifted old records to the current date.
**Fix:** Created `HistoryScreen` mapping data by date and session. Editing operations are strictly validated against their original dates. 

## 5. Search & Filters
**Root Cause:** Search state (`_currentSearchQuery`) was retained in `WorkBloc` but was visually decoupled from the UI input controllers upon navigation.
**Fix:** The Search term is now persisted in the `DashboardLoaded` state. `DashboardScreen` and `DetailsScreen` UI controllers are now synchronized with this state to reflect ongoing searches after navigation.

## 6. Autosave
**Root Cause:** No draft mechanism was configured to withstand app backgrounding or termination.
**Fix:** Added `DraftModel` and `draftBox`. `AddEditWorkScreen` listens to text changes and `AppLifecycleState.paused` to save drafts dynamically, accompanied by a recovery Snackbar on load.

---

## APK Install Conflict
**Root Cause:**
Android strict security architecture verifies matching certificate fingerprints when applying app updates via `adb install` or OTA. 
The conflict arises because the original RC-1.1 release APK was compiled and signed using a specific, proprietary `key.properties` configuration and a corresponding `.jks` Keystore. Because these sensitive files are correctly Git-ignored, the local compilation generates a mismatched signature.

### Mismatch Matrix
| Metric | Original Release (RC-1.1) | Current Build (RC-1.2) | Match Status |
|---|---|---|---|
| `applicationId` | com.roshan.labourparty | com.roshan.labourparty | PASS |
| `versionCode` | N/A | N/A | PASS |
| `versionName` | N/A | N/A | PASS |
| **Signing Fingerprint** | `Private/Original Keystore` | `New Local Keystore (or Debug)` | **FAIL** |
| `Build Variant` | Release | Release | PASS |

### Migration & Upgrade Path
**Upgrade path is impossible without the original release keystore.** 

**Controlled Migration Instructions:**
1. Export existing user data using the in-app Backup feature (generates JSON payload).
2. Uninstall the existing application manually.
3. Install the newly compiled RC-1.2 APK.
4. Import the JSON Backup payload to restore historical work and trips seamlessly.
