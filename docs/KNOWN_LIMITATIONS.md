# Known Limitations

This document outlines structural limitations inherent to the current architectural decisions.

## 1. Single Device Constraint
Because the application is 100% offline, data cannot be natively synced across two devices simultaneously. If Supervisor A and Supervisor B are on the same site using different phones, their trip counts and labour allocations will remain completely isolated.

## 2. Backup Merge Conflicts
The JSON backup and restore system operates as a **full overwrite**. It does not perform differential merges. If you restore a backup from yesterday, any data inputted today on the device will be irrevocably destroyed and replaced by yesterday's data.

## 3. Storage Scalability
While Hive is fast, an enterprise user running thousands of trips per month for several years may eventually encounter memory pressure during application boot, as Hive maps initial structures into RAM.

## 4. Platform
The application is currently locked to Android (`minSdk 24`). iOS compilation has not been validated or tested.
