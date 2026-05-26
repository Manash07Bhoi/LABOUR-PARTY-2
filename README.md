# 1. Project Overview
- **Name:** Labour Party
- **Type:** Offline-first Android application
- **Purpose:** Labour trip management and tracking.
- **Scope Boundaries:** Operates entirely locally without remote APIs, cloud backend, or internet dependencies.

# 2. Key Capabilities
- **Work management:** Organize and group specific jobs.
- **Trip tracking:** Record individual trips, drivers, and tractors.
- **Labour tracking:** Associate labour participation explicitly per trip.
- **History:** Browse structured historical records chronologically.
- **Analytics:** View computed performance and operational metrics.
- **Backup/Restore:** Export and import local datasets.
- **Draft autosave:** Capture form changes real-time preventing data loss during edits.
- **Offline operation:** 100% offline local-only operation out of the box.

# 3. Architecture
- **Clean Architecture:** Strict separation between Presentation, Domain, and Data layers.
- **BLoC:** Manages state transitions explicitly.
- **Hive:** Handles NoSQL rapid document storage.
- **Repository Pattern:** Abstracts local database interactions from business rules.
- **Local-only persistence:** Data lives uniquely on the device within Android Sandboxing.

# 4. Application Flow
- Dashboard
- Add/Edit (Work forms)
- Confirm Next Trip (Sequential trip continuation)
- Trip Details (In-depth metadata)
- History (Archive viewing)
- Analytics (KPI computations)
- Settings (Backup mechanics)

# 5. Data Model Overview
- **Work:** Top-level identifier grouping trips.
- **Trip:** Core execution event (Time, Notes, Driver, Tractor).
- **Labour:** Persistent global entities available for selection.
- **TripLabour:** Relationship mapping a specific Labour entity to a Trip.
- **Draft:** Transient storage for autosaved active edits.

# 6. Backup & Restore
- **Format:** Operates via exported `.labourbackup` files.
- **SAF Flow:** Leverages Android Storage Access Framework (Scoped Storage) to avoid broad file permissions.
- **Restore limits:** Constrained to < 25MB to prevent memory isolates from overflowing during restore parsing.
- **Migration expectations:** Users migrating between mismatched APK signatures must export `.labourbackup`, reinstall, and restore.

# 7. Release Status
- Release Candidate Approved
- Production Certification Deferred

# 8. Production Readiness Summary
The repository has undergone a strict, multi-phase audit evaluating the frontend logic bounds, database integrity constraints, and offline security scope. Please reference the [Production Readiness Report](docs/production_readiness/PRODUCTION_READINESS_REPORT.md) for detailed deliverables.

# 9. Development
- **Setup:** `flutter pub get`
- **Analyze:** `flutter analyze`
- **Test:** `flutter test`
- **Build:** `flutter build apk --release` (Requires `android/key.properties` configuration)

# 10. Maintenance Policy
**Allowed:**
- Bug fixes
- Security patches
- Database migration logic
- QA implementations

**Not Allowed:**
- Undocumented breaking changes
