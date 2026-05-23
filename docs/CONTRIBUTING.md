# Contributing Guidelines

Thank you for contributing to Labour Party! We strictly enforce enterprise-grade engineering practices.

## 1. Branch Naming
- `feature/name-of-feature`
- `fix/name-of-bug`

## 2. Commit Messages
- Use clear, imperative messages.
- E.g., `Implement CalculateNextTripNumberUseCase for robust continuity`

## 3. Architectural Rules
- All new business logic must be placed inside a pure `UseCase` in the Domain layer.
- Never place logic or database querying inside UI Widgets.
- Always use the `AppTheme` constants for colors and styling. Do not hardcode HEX values in UI files.

## 4. Pre-Commit Checklist
Before submitting a pull request, you **must** ensure the following commands pass successfully:

```bash
flutter analyze
flutter test
flutter build apk --release
```

Pull requests will be rejected if E2E integration tests fail or if architectural boundaries are violated.
