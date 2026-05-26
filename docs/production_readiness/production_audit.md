# Phase 0: Inventory Audit

## 1. Screen Inventory
- DashboardScreen (`lib/features/dashboard/presentation/dashboard_screen.dart`)
- SplashScreen (`lib/features/dashboard/presentation/splash_screen.dart`)
- DetailsScreen (`lib/features/details/presentation/details_screen.dart`)
- TripDetailsScreen (`lib/features/details/presentation/trip_details_screen.dart`)
- HistoryScreen (`lib/features/history/presentation/history_screen.dart`)
- AnalyticsScreen (`lib/features/analytics/presentation/analytics_screen.dart`)
- SettingsScreen (`lib/features/settings/presentation/settings_screen.dart`)
- AddEditWorkScreen (`lib/features/work/presentation/screens/add_edit_work_screen.dart`)
- ConfirmNextTripScreen (`lib/features/work/presentation/screens/confirm_next_trip_screen.dart`)
- MainLayout (`lib/shared/main_layout.dart`)

## 2. Route Inventory
From `lib/routes/app_router.dart`:
- `/splash` -> SplashScreen
- Shell Routes (Wrapped with MainLayout):
  - `/dashboard` -> DashboardScreen
  - `/details` -> DetailsScreen
  - `/settings` -> SettingsScreen
  - `/history` -> HistoryScreen
  - `/analytics` -> AnalyticsScreen
- `/trip-details` -> TripDetailsScreen (expects `Trip` extra)
- `/add-edit-work` -> AddEditWorkScreen (expects optional `Map` extra with `isNew`)
- `/confirm-next-trip` -> ConfirmNextTripScreen (expects `Map` extra)

## 3. Feature Inventory
- **Dashboard**: Main landing, splash, work list
- **Work (Core)**: Add/Edit works, confirm next trip, handle Drafts
- **Trip**: Sub-entity of Work, details, Add/Edit logic
- **History**: Display past records
- **Analytics**: Key Performance Indicators and tables
- **Settings**: Backup/Restore, general app configurations
- **Data & Domain**: Clean Architecture setup (UseCases, Repositories, DataSources)

## 4. Database Schema Inventory (Hive Boxes)
From `lib/core/database/hive_setup.dart`:
- `work_box` -> `WorkModel`
- `trip_box` -> `TripModel`
- `labour_box` -> `LabourModel`
- `trip_labour_box` -> `TripLabourModel`
- `draft_box` -> `DraftModel`

## 5. Dependency Audit
- **SDK**: Flutter (`^3.11.0`)
- **Core Packages**: `flutter_bloc` (^9.1.1), `go_router` (^17.2.3), `get_it` (^9.2.1), `dartz` (^0.10.1), `equatable` (^2.0.8)
- **Local Storage**: `hive` (^2.2.3), `hive_flutter` (^1.1.0)
- **UI/UX**: `cupertino_icons` (^1.0.8), `flutter_animate` (^4.5.2), `glassmorphism_ui` (^0.3.0), `google_fonts` (^8.1.0), `flutter_screenutil` (^5.9.3)
- **Utils**: `intl` (^0.20.2), `uuid` (^4.5.3), `path_provider` (^2.1.5), `file_picker` (^8.0.0)
- **Dev Dependencies**: `flutter_test`, `flutter_lints` (^6.0.0), `build_runner` (^2.4.13), `hive_generator` (^2.0.1), `mocktail` (^1.0.5)

## 6. Test Coverage Map
Overall coverage rate from `lcov`: 28.1% (428 of 1522 lines)

| File | Lines | Covered | Uncovered | Risk Level |
| --- | --- | --- | --- | --- |
| `AddEditWorkScreen` (`lib/features/work/presentation/screens/add_edit_work_screen.dart`) | 271 | 0 | 271 | High |
| `ConfirmNextTripScreen` (`lib/features/work/presentation/screens/confirm_next_trip_screen.dart`) | 111 | 0 | 111 | High |
| `DashboardScreen` (`lib/features/dashboard/presentation/dashboard_screen.dart`) | 207 | 30 | 177 | High |
| `HistoryScreen` (`lib/features/history/presentation/history_screen.dart`) | Not listed | N/A | N/A | High |
| `AnalyticsScreen` (`lib/features/analytics/presentation/analytics_screen.dart`) | Not listed | N/A | N/A | High |

*(Note: Files missing from the detailed line coverage report indicate 0 execution during tests natively or issues with `flutter test --coverage` capturing `go_router` shell routes.)*
