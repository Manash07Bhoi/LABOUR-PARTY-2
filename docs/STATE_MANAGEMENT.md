# State Management

Labour Party uses **Flutter BLoC (Business Logic Component)** as its exclusive state management solution.

## 1. Principles

- **No `setState` for Data:** UI widgets must never use `setState` to manage or alter business data. `setState` is strictly reserved for ephemeral, superficial UI animations (e.g., expanding a generic visual container).
- **Synchronous Resolution:** All UI intents are resolved via pure BLoC Events. Wait times, database calls, and error handling are orchestrated entirely inside the BLoC structure.

## 2. Event-Driven Architecture

Widgets dispatch `Events`. The BLoC processes the Event by executing `UseCases`, and then yields a new immutable `State`.

*Example Flow in WorkBloc:*
1. **Event:** `AddQuickTripEvent` is dispatched by the Dashboard.
2. **Action:** The BLoC emits `WorkLoading()`.
3. **Logic:** BLoC queries `calculateNextTripNumber` UseCase.
4. **State:** BLoC yields a refreshed `DashboardLoaded()` state.

## 3. UI Re-Rendering Rules

- Views must utilize `BlocBuilder` to construct their interfaces based heavily on the state types (`WorkLoading`, `WorkEmpty`, `DashboardLoaded`).
- Views must utilize `BlocListener` for executing side-effects like Navigation or showing a `SnackBar`.
- **Never Mix:** Do not attempt to query Hive directly inside a UI build method. This violates the state architecture and causes desyncs.
