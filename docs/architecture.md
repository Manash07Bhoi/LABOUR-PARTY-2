# Architecture Document

## Overview
Labour Party is an Android-only, offline-first application that records and tracks daily operational data without relying on a remote backend. It follows Clean Architecture principles.

## Structure
- **Data Layer:** Interacts with local storage via Hive.
- **Domain Layer:** Enforces business logic and use cases without dependency on external frameworks.
- **Presentation Layer:** Managed strictly via `flutter_bloc`. BLoCs emit deterministic UI states.

## Key Rules
1. **No Backend API:** All persistence is local.
2. **Explicit States:** UI components must exhaustively handle `WorkState` through sealed classes. No silent fallbacks (e.g., `SizedBox.shrink()`).
3. **Data Hierarchy Constraints:** Work -> Trips -> TripLabours. These relationships are explicit and resolved efficiently via batch Hive operations (e.g., `putAll`).
