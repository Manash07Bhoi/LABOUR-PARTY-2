# Business Rules

This document serves as the absolute source of truth regarding the core behavior and domain rules of the Labour Party application. Implementation must never deviate from these rules.

## 1. Work Session & Continuity Rules

- **Morning → Evening Continuity:**
  If a 'Morning' session exists on a specific date, and an 'Evening' session is initiated on the exact same date, the 'Evening' session trips **must not start at Trip #1**. They must continue chronologically from the end of the 'Morning' session.
  *Example:* Morning ends at Trip 3. Evening begins at Trip 4.

- **Isolated Dates:**
  Trip chronologies reset to Trip #1 at the beginning of each new date (midnight crossover).

- **Isolated Sessions:**
  If an 'Evening' session is initiated but a 'Morning' session never occurred on that date, the 'Evening' session begins natively at Trip #1.

## 2. Trip Numbering Constraints

- **Single Source of Truth Calculation:** The application exclusively relies on the `CalculateNextTripNumberUseCase` to determine the next safe trip.
- **Middle Trip Deletion:** If a user deletes a middle trip (e.g., Deletes Trip 2 from sequence 1, 2, 3), the sequence retains its maximum bounds. The subsequent trip added will be Trip 4, maintaining chronological progression instead of backfilling Trip 2.
- **Historical Edit Protection:** Modifying the contents of a historical trip (e.g., updating the tractor name) must retain the original Trip Number constraint.

## 3. Auto-Copy Capabilities

- **Rapid Logging:** If a work session already contains a trip, creating a new "Quick Trip" must automatically fetch the **last trip** logged and copy its exact configurations (Tractor assigned, Driver Name, and the complete List of active Labours).
- **Session Auto-Copy Crossing:** If creating the first trip of an 'Evening' session, the system must search the prior 'Morning' session, find the last trip recorded in that session, and copy those parameters to prime the Evening session seamlessly.

## 4. UI/UX Rules & Validation

- **Destructive Behavior Restrictions:** Any operation that deletes data (e.g., deleting a Trip, deleting a Work Day) must present a modal or alert dialog requiring explicit user confirmation before executing.
- **Mandatory Fields:** When creating a trip from scratch, fields for Tractor Name and Driver Name must pass local validation before the BLoC is permitted to emit the save state.
- **Data Reality Validation:** No dummy or fake data is allowed. Operations use explicitly real options. Defaults are permitted (e.g., "Sand (Bali)") but must reflect a legitimate use case.

## 5. Backup & Restoration Behavior

- **Safety Overwrite Protocol:** When restoring from a backup JSON file, the entire JSON payload must be loaded into memory, fully parsed, and successfully instantiated *before* any wipe or overwrite commands are dispatched to the Hive database. This guarantees a broken backup file cannot corrupt an active operational database.
