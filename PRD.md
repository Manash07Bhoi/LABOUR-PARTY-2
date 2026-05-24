Labour Party — Product Requirements Document (PRD v2)
Version: RC-1.1 Recovery
Status: Active Specification (authoritative)
Platform: Android
Architecture: Clean Architecture + BLoC + Hive
Mode: Offline Only

1. Product Goal
Labour Party is an offline-first labour trip management application.
Purpose: Track daily work trips, labour participation, drivers, tractors, sessions, and historical records with strict data integrity.
Non-goals: No login, No internet, No cloud sync, No multi-user, No analytics, No external backend.

2. Core Concepts
Work: Top-level work record. Date, Session, Work Type, Place. One Work contains many Trips.
Trip: Single transportation cycle. Trip number, Tractor, Driver, Time. One Trip contains many Labour entries.
Labour: Actual worker. Name, isWorking. Must NEVER become "Labour 1" unless typed.

3. Entity Rules
Work: Required: id date session workType createdAt. Optional: place.
Trip: Required: tripId tripNumber driverName tractor createdAt. Rules: Trip number immutable after save.
Labour: Required: labourId tripId name isWorking. Rules: name persists exactly.

4. Global State Machine
WorkInitial: Application started. Allowed: LoadDashboard LoadTrip LoadDetails. Forbidden: Save Delete.
WorkLoading: Show Skeleton. Forbidden: Unexpected State UI.
DashboardLoaded: Show Dashboard (date session trips counts).
WorkEmpty: Show Empty dashboard.
WorkError: Show Retry.
WorkActionSuccess: Trigger Refresh. Never render dashboard directly.
TripDetailsLoaded: Display Trip details only.

5. Dashboard Logic
On Open: IF app opened THEN emit WorkLoading. IF no records THEN WorkEmpty ELSE DashboardLoaded.
Forbidden: Never display: Unexpected state in Dashboard.

6. Add Trip Logic
Save Button: IF workType empty -> error, ELSE IF driver empty -> error, ELSE IF no labour exists -> error, ELSE Save.
After Save: emit WorkActionSuccess reload dashboard.

7. Labour Logic
Add Labour: Input Rahul -> Save Rahul -> Display Rahul. Never: Labour 1.
Toggle: TRUE: Working, FALSE: Not working this trip. Persist.
Edit: Preserve name attendance.

8. Trip Number Logic
IF first trip -> Trip #1, IF next trip -> previous+1, IF edit -> preserve, IF delete -> preserve history, IF next date -> reset, IF next session -> reset.

9. Date Isolation
Partition: Date + Session. No crossover.

10. Search
Fields: driver tractor work trip date.
Behavior: Case insensitive. Live update. No results: No matching trips.

11. Filter
Options: Today Morning Evening Date Range Reset.

12. Details Screen
Display: Trip, Driver, Time, Labours.

13. Backup
Export: JSON (25MB limit). Restore: Validate, Rollback on failure.

14. Error Rules
Never: Crash, Silent fail, Blank screen, Unexpected state.
Always: Error UI, Retry, Recovery.

15. Edge Cases
Save empty -> Reject. Delete current trip -> Refresh. Edit yesterday -> Preserve history. Restore invalid -> Reject. Search empty -> Reset.

18. Navigation & Route Rules
Dashboard → Add Trip: push AddEditWorkScreen(mode=create). After save: pop refresh dashboard show success.
Dashboard → Details: push DetailsScreen(date, session).
Details → Trip Details: push TripDetailsScreen(tripId).
Forbidden: Never duplicate push, stale route, context.pop before save.

19. Edit Preservation Rules
Edit Trip: Preserve id tripNumber createdAt date session. Editable: driver tractor labours place. IF save edit THEN update only. Never delete + recreate.

20. Hive Storage Rules
Boxes: worksBox tripBox tripLabourBox settingsBox.
Keys: Work: date_session_workId. Trip: date_session_tripNumber. Labour: tripId_labourId. Never scan entire DB.

21. Refresh / Cache Rules
Save: clear temporary state reload repository emit DashboardLoaded.
Edit: invalidate cache. Delete: recalculate.

22. Data Consistency Rules
Validation: Trip Must belong to ONE date ONE session ONE work. Labour Must belong to ONE trip. Reject orphan records.

23. UI Conditions
Dashboard: Loading -> Skeleton -> Loaded -> Empty -> Retry. Never: Unexpected State.

24. Empty States
Dashboard: No trips yet. Search: No matching result. Details: No trips found. Trip: No labour assigned.

31. State Ownership Rules
UI Layer: Render only, Dispatch events only. Never calculate/mutate.
Bloc Layer: state transitions, validation, coordination.
UseCase: business rules, trip numbering, date partition.
Repository: read/write abstraction.
Datasource: Hive only.

32. Event → State Matrix
LoadDashboardEvent -> WorkLoading -> DashboardLoaded OR WorkEmpty OR WorkError.
SaveFullWorkTripEvent -> WorkLoading -> WorkActionSuccess -> DashboardLoaded.
DeleteTripEvent -> WorkLoading -> DashboardLoaded.

33. Recovery Rules
If save fails: rollback. If restore fails: restore snapshot. If crash: recover last stable state. If corruption: show repair action.

36. Session Rules
Morning: 00:00–11:59. Evening: 12:00–23:59. Changing session: Must NOT move old trips.
