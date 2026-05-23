# Memory Bank

**Purpose:** To preserve vital project intelligence, architectural choices, unwritten tradeoffs, and historical decisions over the lifecycle of the Labour Party application. This file acts as the permanent project memory.

## 1. Architectural Decisions & Tradeoffs

- **100% Offline-First Constraint:** The application strictly forbids remote cloud backend, APIs, or internet dependency. It is an Android-only local-first system. This decision was made to ensure reliability in construction and field sites where internet connectivity is sparse or nonexistent.
- **Hive Database:** Chose `Hive` over `SQLite` for speed, ease of object mapping, and synchronous data access, which aligns better with local-first fast-write behaviors required for constant field logging.
- **Clean Architecture & UI Isolation:** The UI must be exceptionally thin. All calculations (e.g., trip numbering logic) and orchestration are handled exclusively by BLoCs (`WorkBloc`) and pure UseCases (`CalculateNextTripNumberUseCase`). This decision protects against fragmented logic across widgets, ensuring a single source of truth for the Trip Engine.

## 2. Business Decisions & Exceptions

- **Database Data Policy:** Avoid all mock, fake, or dummy data. The database must start mostly empty, with the only exceptions being real operational defaults like 'Sand (Bali)' for Work Types, and 'Sonalika' and 'JohnDeere' for Tractor options.
- **Morning to Evening Continuity:** A core business requirement states that if an 'Evening' session is started on the same date as a 'Morning' session, the Trip Numbering Engine must calculate the total trips of the Morning session and strictly append chronologically. (e.g. Morning ends at Trip 3, Evening starts at Trip 4).
- **Historical Trip Protection:** Historical trip modifications must never disrupt existing chronologies. The system must preserve the exact chronological assignment.

## 3. UX Philosophy

- **Destructive Operation Safety:** Data deletions (trips, work) must enforce a safety flow that requires explicit user confirmation before executing. Accidental data loss is heavily mitigated.
- **Material 3 & Glassmorphism:** Implemented a dark-themed UI (Color `#0F172A`) utilizing professional, subtle glassmorphism to emulate a premium, industrial feel.
- **Visual Noise Limitations:** Excessive blur, over-animation, and low contrast designs are strictly prohibited. The focus remains on rapid readability and high field-performance usability.

## 4. Release Rules & Constraints

- **Release Candidates (RCA):** Never declare a candidate production-ready based solely on implementation claims. Production merges must only happen after explicit Release Candidate Acceptance involving measured validation of offline capabilities, architecture purity, and E2E business rule checks.
- **APK Size Exception:** R8/Proguard is enabled. The repository accepts a standard release size threshold (~52.1 MB) resulting from embedded font assets (`CupertinoIcons`, `MaterialIcons`), which aligns with acceptable boundaries for offline distributions.

## 5. Lessons Learned

- **Integration Migrations:** During RC-1, we learned that asynchronous UI futures handling data transformations caused state desyncs. The repository now firmly dictates that all integration paths and user inputs must operate via standard `DashboardLoaded` BLoC streams synchronously.

## 6. Repository Conventions

- **Source of Truth:** The `PRD.md` file (if available) or the stated business rules supersede all implementation.
- **Testing Structure:** Strict directory mapping must be maintained: `test/unit/` (usecases, repos, blocs), `test/widget/` (feature dashboards), and `test/integration/`.
