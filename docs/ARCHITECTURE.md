# Architecture

The Labour Party application relies on strict **Clean Architecture** combined with **Flutter BLoC** and the **Hive** NoSQL database to ensure the system is heavily isolated, scalable, and fully offline capable.

## 1. Core Principles

- **Separation of Concerns:** UI widgets do not modify state. BLoCs do not fetch data directly from databases.
- **Dependency Inversion:** Outer layers (UI, Data sources) depend on inner layers (Domain).
- **Single Source of Truth:** Business logic strictly resides within the Domain layer via UseCases.

## 2. Layer Definitions

### Presentation Layer
Houses pure Flutter UI Widgets and BLoCs.
- **Widgets:** Responsible only for observing state (via `BlocBuilder` and `BlocConsumer`) and emitting events. Examples include `DashboardScreen`, `AddEditWorkScreen`. They must have a thin footprint and contain zero state manipulation.
- **State Management (BLoC):** Maps UI events to UseCases and emits new immutable states. Example: `WorkBloc`.

### Domain Layer (The Core)
Contains the pure business logic isolated from external packages (no Flutter dependencies allowed).
- **Entities:** Immutable representations of the core data objects. Examples: `Work`, `Trip`, `TripLabour`, `Labour`.
- **UseCases:** Specific actions representing single business requirements. Examples: `CalculateNextTripNumberUseCase`, `SaveTripUseCase`.
- **Repository Interfaces:** Abstract contracts defining data operations required by UseCases.

### Data Layer
Implements the interfaces from the Domain layer.
- **Repositories:** `WorkRepositoryImpl` maps domain entities to data models and acts as the bridge.
- **Data Sources:** `WorkLocalDataSource` implements raw database interactions.
- **Models:** Hive-specific mappings (e.g., `WorkModel`, `TripModel`) equipped with TypeAdapters.

## 3. Data Flow

1. User interacts with a UI widget (e.g., taps "Add Trip").
2. The UI widget dispatches an Event to the BLoC (e.g., `AddQuickTripEvent`).
3. The BLoC executes the appropriate Domain UseCase (e.g., `calculateNextTripNumber`).
4. The UseCase interacts with the Repository Interface.
5. The Repository Interface implementation queries the Local Data Source (Hive).
6. Hive reads/writes the `Model` and returns it to the Repository.
7. The Repository parses the `Model` back into a pure `Entity` and returns it.
8. The BLoC emits a new State (e.g., `DashboardLoaded`).
9. The UI rebuilds to reflect the new state.

## 4. Dependency Graph & Injection

Dependencies are resolved using `get_it`. The dependency injection container (`sl`) follows a bottom-up graph registration:

1. **External Packages:** `Hive` initializations.
2. **Data Sources:** `WorkLocalDataSource`.
3. **Repositories:** `WorkRepositoryImpl`.
4. **UseCases:** `CalculateNextTripNumberUseCase`.
5. **BLoCs:** `WorkBloc`.

## 5. Routing

Routing is handled via standard Flutter navigation maps to minimize external package overhead, operating synchronously to ensure screens boot safely initialized.
