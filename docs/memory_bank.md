# Memory Bank

## Project Directives
1. **User Request Supremacy:** The PRD is the absolute source of truth.
2. **Offline-First:** No remote capabilities.
3. **UI Logic & BLoC:** Exhaustive state tracking is enforced using Dart 3 sealed classes to eliminate unreachable and silent states. Unhandled states throw visible UI elements instead of silent widgets.
4. **Data Integrity via Backup & Restore:** Strict validations apply to JSON `.labourbackup` files. Operations are handled entirely in memory (`compute`) before safely wiping old datasets to prevent loss.

## Known Adjustments
- Performance improvements utilizing local `putAll` have successfully reduced write latency from ~450ms down to ~6ms for high load scenarios.
- BLoC UI logic has been upgraded to explicit fallback reporting across `DashboardScreen`, `DetailsScreen`, and `TripDetailsScreen`.
