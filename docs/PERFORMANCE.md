# Performance

Labour Party relies on high-performance execution to feel like a native tool, especially on lower-end Android devices common in field deployments.

## 1. Hive Memory Management
Hive keeps data in memory for instant read access. However, large lists of lists (e.g., massive numbers of `TripLabour` associations) can bloat RAM.
- **Rule:** Lazy loading is not required at the current scale, but all mapping functions inside Repositories must avoid unnecessary deep-copy iterations.

## 2. List Views
When rendering historical trips on the `DetailsScreen`, `ListView.builder` must be used. Never use a standard `ListView` for unbounded data, as it will render all items simultaneously and crash low-memory devices.

## 3. Minification
The Android release utilizes R8 (Proguard). This strips out unutilized Dart and Flutter engine code, keeping the application payload light and the execution speed rapid.
