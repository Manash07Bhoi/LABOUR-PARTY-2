# Architecture Document

## Overview
Labour Party strictly adheres to Clean Architecture decoupled via BLoC for state management and Hive for offline local persistence.

## Layer Division
- **Presentation:** Uses Material 3 UI with `flutter_bloc` managing `WorkBloc` and `HistoryBloc`. Strict `buildWhen` logic maintains local UI stability against unassociated global emissions.
- **Domain:** Data structures like `Work`, `Trip`, `Labour` encoded natively independent of infrastructure concerns. Data orchestration operates fully within isolated `UseCase` boundaries.
- **Data:** Direct IO access bound to `Hive`. Data hierarchies execute natively within Box boundaries leveraging UUID generation.

## Key Design Patterns
- **Soft Deletions:** Labour persistence leverages `isPresent` booleans rather than strict removals maintaining historical records.
- **Draft Redundancy:** Continuous listener pipelines cache encoded form states dynamically inside `draftBox`.
- **Search Propagation:** Global search query strings pass natively through shared State preventing standalone bloc duplications.
