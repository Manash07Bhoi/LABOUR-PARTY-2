# Offline Strategy

Labour Party is not an "offline-capable" app; it is an **Offline-First and Offline-Only** application.

## 1. Zero Cloud Dependency
There are no REST API calls, no Firebase SDKs, no GraphQL queries, and no socket connections. The app operates entirely inside the sandbox of the user's Android device.

## 2. Fast-Write Operations
Because there are no network latencies to mask, data writes to the Hive database must be exceptionally fast to prevent UI stuttering. All data mutations happen synchronously.

## 3. Data Sovereignty
The user maintains absolute control over their data. The application does not transmit analytics, crash logs, or telemetry, ensuring zero data leakage.

## 4. Portability via JSON
The only external data interaction occurs when a user initiates a Manual Backup. The system serializes the Hive boxes into a `backup.json` file and writes it to the local Downloads folder using native Android Intent routing via the `file_picker` package, maintaining the offline barrier.
