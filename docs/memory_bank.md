# 1. Project Identity
- Labour Party is an offline-first, Android-only Flutter application designed strictly for tracking work, trips, and labour without internet or cloud backend dependency.

# 2. Architecture Decisions
- Built upon Clean Architecture, enforcing the `UI -> BLoC -> UseCase -> Repository -> Datasource` pipeline.
- State management leverages Dart 3 sealed classes in BLoC for exhaustive matching.
- Hive handles local NoSQL storage.

# 3. Domain Rules
- The PRD.md file is the absolute source of truth.
- Business calculations (Trip Numbering, Date Isolations, Session splits) run entirely within BLoCs and UseCases.
- Analytics compute aggregates dynamically from local Repositories without caching stale representations.

# 4. Critical Data Rules
- No dummy, fake, or mock data is allowed in the production database flow.
- Modifying historical records (`edit_flow`) must explicitly preserve the original date, session, and `workId`.
- Backup/restore operations must parse data entirely in-memory using isolates (`compute`) prior to destructive wipes. Maximum allowed backup size is 25MB.

# 5. Navigation Rules
- Navigation logic and UI feedback (Snackbars) are strictly treated as side-effects, triggering from `BlocListener` only.
- Buttons dispatch events, but they do not execute routes directly.

# 6. Release Decisions
- Refer to the [Release Notes](release_notes.md) for incremental structural decisions.
- Current Status: Release Candidate Approved.
- Current Status: Production Certification Deferred.
- Releases require active `android/key.properties`; no dummy credentials are to be stored in git.

# 7. Known Risks
- Refer to the [Rollback Plan](production_readiness/rollback_plan.md) for details on schema corruption handling.
- `state.extra` casting errors cause recoverable UI crashes but do not introduce database corruption.
- Migration versioning handles additive models natively but struggles with destructive field modifications.

# 8. Migration Rules
- Destructive operations demand the SAF export flow via `.labourbackup`.
- Direct file access is bypassed using Storage Access Framework to maintain scoped storage compliance.

# 9. Testing Rules
- Unit tests for UseCases isolate logic via local spy verification, rejecting deep mock frameworks where possible.
- Widget tests utilize `pumpAndSettle` constraints prior to size assertions.

# 10. Maintenance Constraints
- Dead code removal must rely explicitly on `flutter analyze` evidence.
- No untested or undocumented breaking changes.
