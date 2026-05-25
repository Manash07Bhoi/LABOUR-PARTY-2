# Labour Party

Labour Party is an offline-first labour trip management application built for Android. 

## Features
- **Offline First**: All data is stored locally using Hive. No cloud dependency.
- **Trip Management**: Add, edit, and manage trips, drivers, tractors, and work assignments.
- **Labour Tracking**: Track labour participation per trip inline with soft-delete controls.
- **Autosave & Drafts**: Crash resilience using real-time autosave.
- **History & Analytics**: View historical trips organized by date and session. Aggregated KPI metrics provided seamlessly.

## Architecture
Built using Flutter with strict Clean Architecture constraints:
- `Presentation Layer` (Bloc & Widgets)
- `Domain Layer` (Entities & UseCases)
- `Data Layer` (Hive Local Datasource & Repositories)

## Installation
For RC-1.2 Migration:
Due to local compilation signing changes:
1. Export your data via Settings -> Backup.
2. Uninstall any existing RC-1.1 version.
3. Install the RC-1.2 APK.
4. Import your backup payload.
