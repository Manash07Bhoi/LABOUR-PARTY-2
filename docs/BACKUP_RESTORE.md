# Backup & Restore Protocol

The Backup and Restore system is the only way data moves in and out of the application. It is highly structured to prevent data corruption.

## 1. Export Protocol
1. User taps "Backup Database".
2. The application serializes all Hive boxes (`works`, `trips`, `labours`, `trip_labours`) into a massive dictionary.
3. It writes this payload to `labour_party_backup_YYYYMMDD.json`.
4. It prompts the OS to save this file securely to the local Downloads directory.

## 2. Restore Protocol (Safe Overwrite)
1. User taps "Restore Database".
2. The OS file picker allows the user to select a JSON file.
3. **CRITICAL:** The application reads the JSON file *into memory*.
4. It attempts to parse and map all fields to the Data Models.
5. If the parsing fails (e.g., missing keys, corrupted JSON), the operation immediately aborts, and the existing database is left completely untouched.
6. If the parsing is 100% successful, the application triggers `clear()` on all Hive boxes, wiping the current database.
7. It then synchronously injects the in-memory models into the empty Hive boxes.

This atomic-style transaction ensures no user ever loses their active data due to a corrupted backup file.
