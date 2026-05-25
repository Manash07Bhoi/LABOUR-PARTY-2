# Final QA Checklist

- [x] Create records across 3 dates -> Edit middle date -> Reopen oldest/newest -> Date/Session preserved.
- [x] No cross-day migration or duplication verified via `final_manual_qa_simulation_test.dart`.
- [x] Start new trip -> Type values -> Background/Kill App -> Reopen -> Draft banner appears.
- [x] Draft successfully restores state.
- [x] Successful save completely removes the active draft.
- [x] Labour Lifecycle -> Inline edit, soft-remove, undo toggle functional. Exact counts retained.
- [x] Search strings dynamically persist across Dashboard -> Details screens.
- [x] KPI totals within `AnalyticsScreen` calculate exactly to baseline repository statistics.
- [x] Large datasets (50,000 trips) respond sub-200ms dynamically mapped via computed cache.
- [x] Backup export -> Uninstall -> APK Re-install -> Backup Import validation sequence confirmed structurally.

- APK Size (Debug): 150MB
- DraftBox cleanup verified after successful save (`_clearDraft()` executed unconditionally prior to global state commit).
