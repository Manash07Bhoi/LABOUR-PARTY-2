# Documentation Index

Welcome to the Labour Party project documentation. This system has been structured to provide a self-contained, easily navigable knowledge base for long-term maintainability.

## 📌 Core Documentation

- **[Product Overview](PRODUCT_OVERVIEW.md)**: A high-level breakdown of the application, the problems it solves, and its core features.
- **[Architecture](ARCHITECTURE.md)**: Details on the Clean Architecture pattern, data flow, BLoC management, and UseCases.
- **[Business Rules](BUSINESS_RULES.md)**: The absolute source of truth regarding trip chronologies, data exceptions, and operational constraints.
- **[Database](DATABASE.md)**: Hive implementation strategies, relational mapping logic, and backup JSON structures.
- **[Design System](DESIGN_SYSTEM.md)**: The Material 3 constraints, color maps, typography, and glassmorphism standards.

## 🚀 Engineering & Maintenance

- **[Testing](TESTING.md)**: Strategies, directory boundaries, E2E checks, and validation parameters.
- **[Release](RELEASE.md)**: Deployment steps, APK constraints, and security permissions (zero internet).
- **[State Management](STATE_MANAGEMENT.md)**: Specific rules governing the application's implementation of Flutter BLoC.
- **[Offline Strategy](OFFLINE_STRATEGY.md)**: Deep dive into the 100% offline-first mechanics.
- **[Trip Engine](TRIP_ENGINE.md)**: Technical breakdown of the `CalculateNextTripNumberUseCase`.
- **[Performance](PERFORMANCE.md)**: R8/Proguard rules, list view optimizations, and memory management.
- **[Backup & Restore](BACKUP_RESTORE.md)**: Safely managing physical device JSON snapshots.
- **[Navigation Flow](NAVIGATION_FLOW.md)**: Routing map and screen-to-screen user journeys.

## 📜 History & Future

- **[Memory Bank](MEMORY_BANK.md)**: Crucial file detailing unwritten tradeoffs, historical decisions, and architectural exceptions.
- **[Future Roadmap](FUTURE_ROADMAP.md)**: Potential feature ideas scoped strictly for reference.
- **[Known Limitations](KNOWN_LIMITATIONS.md)**: Documented bounds and acceptable constraints of the current implementation.
- **[Changelog](CHANGELOG.md)**: Historical tracking of major version releases.
- **[Contributing](CONTRIBUTING.md)**: Guidelines for writing code, pushing branches, and running the RC-1 validation pipeline.
