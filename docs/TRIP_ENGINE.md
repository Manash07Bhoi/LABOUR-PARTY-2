# Trip Engine

The Trip Engine is the core logical heartbeat of the application, encapsulated primarily inside the `CalculateNextTripNumberUseCase`.

## The Problem
When a user adds a trip, what number should it be?
- If it's the first trip of the day, it's `1`.
- If they are in an Evening session, but there was a Morning session, it must continue from the Morning count.
- If they delete a middle trip (e.g. Trip 2), the next trip shouldn't fill the gap; it should continue from the maximum known trip to preserve chronology (e.g., jump to 4).

## Implementation Rules
The `CalculateNextTripNumberUseCase` implements a fail-safe scan:
1. It requests all `Work` entities for a specific date.
2. It aggregates every `Trip` belonging to those `Work` entities.
3. It maps out the `tripNumber` integers.
4. It finds the maximum integer currently existing.
5. It returns `Max + 1`.
6. If no trips exist, it safely defaults to returning `1`.

This simple, deterministic rule ensures chronologies never overlap or conflict, regardless of how many historical edits the user makes.
