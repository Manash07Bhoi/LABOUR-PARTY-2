# Testing Strategy

The repository utilizes an intensive, multi-layered testing strategy separated strictly by directories to guarantee stability, business rule execution, and UI safety before any production merge.

## 1. Directory Structure

- `test/unit/`: Testing of `UseCases`, `Repositories`, and `BLoCs`. Focuses on isolated business logic.
- `test/widget/`: Verifies isolated UI components (`DashboardScreen`, `TripDetailsScreen`) asserting that they correctly render specific BLoC state streams and never house their own business logic.
- `test/integration/`: End-to-End data flow testing, verifying the interconnected layers (e.g., verifying Morning to Evening trip sequence continuity using Repositories and BLoCs concurrently).
- `test/helpers/`: Mock definitions (e.g., `MockWorkRepository`) to ensure deterministic boundaries.

## 2. Core Execution Commands

Run the entire suite natively:
```bash
flutter test
```

## 3. Critical Validation Scenarios

The testing structure heavily targets the following deterministic scenarios to guarantee application safety:

### Trip Continuity Validation
- `E2E - Scenario C: Morning -> Evening continuity`: Proves that creating a trip in an Evening session perfectly bridges from the previous Morning session's trip count.
- `Trip Numbering - Delete Middle Trip Preserves Safe Chronology`: Ensures deleting a middle trip doesn't regress the maximum sequence identifier.

### Architecture Isolation Validation
- Validates that UI interactions (e.g. `SaveFullWorkTripEvent`) route completely through the `CalculateNextTripNumberUseCase` without executing local fallbacks or duplicate calculations inside UI boundaries.

## 4. Release Candidate Acceptance Checklist

Before generating the Release APK, the following checks must pass locally:
1. `flutter analyze` reports 0 issues.
2. `flutter test` reports 100% passing tests (currently 8/8 validated).
3. The offline JSON export/import works on a physical device.
4. An APK builds via `flutter build apk --release`.
