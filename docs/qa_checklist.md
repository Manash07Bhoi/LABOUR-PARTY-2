# Manual QA Checklist: Hotfix RC-1.2

## 1. Dashboard Validation
- [ ] Open App. Verify `WorkLoading` skeleton appears briefly.
- [ ] Ensure `DashboardLoaded` displays current trips.
- [ ] Ensure "Unexpected state in Dashboard" does not appear under any circumstances.
- [ ] Trigger an empty state (no trips). Verify `WorkEmpty` renders.

## 2. Trip Details Management
- [ ] Tap a trip in Dashboard to open `TripDetailsScreen`.
- [ ] Tap "Add Labour" in AppBar. Add "Rahul". Ensure Rahul appears instantly.
- [ ] Tap "Edit" (pencil) to edit a labour name.
- [ ] Toggle "Working" switch. Return to dashboard, reopen trip, verify toggle state is preserved.
- [ ] Tap "Remove" (minus) button. Verify labour is permanently deleted.

## 3. Search System
- [ ] Type a driver name in the dashboard search bar.
- [ ] Verify list instantly filters.
- [ ] Navigate to "History" tab. Verify search query remains active and filters historical data.
- [ ] Clear search bar. Verify full list restores.

## 4. Filters Validation
- [ ] Open filter menu. Select a date range. Verify trips update.
- [ ] Select "Morning" session. Verify trips update.
- [ ] Clear filters. Verify full list restores.

## 5. Local Storage + Date Isolation
- [ ] Add a trip for "Today".
- [ ] Change date in Add Work to "Tomorrow". Add a trip.
- [ ] Return to Dashboard. Check Today's trips (should be 1).
- [ ] Check Tomorrow's trips (should be 1).
- [ ] Close app completely, reopen. Verify data persists correctly.

## 6. Auto Save Drafts
- [ ] Open Add Trip. Type "John" as driver.
- [ ] Do not click save. Force close the app.
- [ ] Open app, click Add Trip. Verify "John" is pre-filled.

## 7. History & Analytics Screens
- [ ] Navigate to History tab. Verify trips are grouped logically by date.
- [ ] Navigate to Analytics tab. Verify total trips and total labour count accurately reflect database values.
