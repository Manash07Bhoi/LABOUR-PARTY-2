# Database System

The application is powered exclusively by a local-first **Hive** NoSQL database system. It avoids asynchronous SQLite relational queries to maximize rapid UI re-rendering and synchronous behavior required by field environments.

## 1. Hive Boxes

The database is structured into isolated object stores ("boxes") mapped tightly to their respective domains.

- **`works` Box:** Contains `WorkModel`. Defines a single date and session parameter (e.g., "15 May 2026, Morning"). Acts as the parent container.
- **`trips` Box:** Contains `TripModel`. Defines an individual trip (e.g., "Trip #4") containing the Tractor mapping and Driver metadata.
- **`labours` Box:** Contains `LabourModel`. Master registry of all available employees/labours.
- **`trip_labours` Box:** Contains `TripLabourModel`. The associative bridge. Logs whether a specific Labour was present for a specific Trip.

## 2. Relationships & Integrity

Hive is inherently a key-value store, so relational mapping is handled programmatically in the Data Layer (Repositories) rather than natively by the database engine.
- `TripModel` stores a string `workId` pointing to its parent `WorkModel`.
- `TripLabourModel` stores strings for both `tripId` and `labourId`.
- **Orphan Handling:** When deleting a `Work` entry, the Repository is responsible for mapping down and sequentially deleting all `Trips`, and subsequently all `TripLabours` associated with those trips to prevent data leakage and memory buildup.

## 3. Migration Strategy

Since there is no cloud synchronization, backwards compatibility and schema evolution are handled via Hive's standard TypeAdapter mechanisms. If adding new fields, the `TypeAdapter` generator is re-run, and defaults must be mapped to avoid null reference crashes on older datasets.

## 4. JSON Backup Format

To support the military-grade offline export feature, the entire database state is serialized into a single JSON schema representing all boxes simultaneously.

```json
{
  "works": [...],
  "trips": [...],
  "labours": [...],
  "trip_labours": [...]
}
```

The data ownership belongs 100% to the user device. The restore protocol mandates loading this entire JSON file into memory, successfully mapping all keys, and only committing a full database overwrite if the parsing passes 100% of the integrity checks.
