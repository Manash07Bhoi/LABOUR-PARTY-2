# Migration Notes: v1.0.1-hotfix-rc1 to RC-1.2

## Schema Safety
The local Hive schema remains completely backward-compatible.
- `TripLabourModel` instances generated before the `DeleteTripLabour` patch will be natively absorbed and purged of orphans during their next save lifecycle.
- `WorkModel` IDs historically generated using generic UUIDs will remain intact. All *new* records will inherit the strict `work_${date}_${session}` ID formulation to enforce date partitioning automatically.

## Feature Additions
The `HistoryScreen` and `AnalyticsScreen` heavily leverage the existing `WorkBloc` data flow. No new Hive boxes or architectural dependencies were introduced.
