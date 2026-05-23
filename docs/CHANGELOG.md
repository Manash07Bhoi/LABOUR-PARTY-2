# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - RC-1 Release Candidate

### Added
- Complete Offline-First Hive Database integration.
- `CalculateNextTripNumberUseCase` protecting trip chronologies.
- Dashboard, Details, and Settings Screens.
- Material 3 Dark Theme with glassmorphism components.
- JSON Backup and Restore engine with safe-overwrite protocols.
- BLoC architectural refactor bridging UI and Domain logic securely.

### Fixed
- Addressed UI desyncs by routing all operations entirely through the `WorkBloc`.
- Stabilized Trip Continuity so Evening sessions accurately append to Morning sessions.
