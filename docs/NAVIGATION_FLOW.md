# Navigation Flow

The application utilizes simple, stack-based routing.

## Screen Map
1. **DashboardScreen (Home)**
   - Displays current session data.
   - Core interaction hub for quick actions (Add Quick Trip, Remove Last Trip).
   - Routes to `SettingsScreen`, `DetailsScreen`, `AddEditWorkScreen`.

2. **DetailsScreen**
   - Renders historical dates.
   - Clicking a specific trip routes to `TripDetailsScreen`.

3. **TripDetailsScreen**
   - Read-only display of granular labour attendance for a specific trip.

4. **AddEditWorkScreen**
   - A modal-like form for manually inputting full trip details from scratch or editing a historical trip.

5. **SettingsScreen**
   - Access to Theme info, Database Management (Wipe, Backup, Restore).
