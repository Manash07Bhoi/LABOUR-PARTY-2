# Production Rollback Plan

## Context
Labour Party operates purely as an offline Android application without central database dependencies. Because there is no network syncing, standard backend rollbacks or database script downs are fundamentally unviable. All rollback strategies mandate physical device intervention from the user.

## Scenario 1: Critical UI/Logic Regression (No Schema Corruption)
If a released application variant introduces a blocking UI failure or UseCase degradation:
1. **Developer Action**: Revert the local branch to the previous stable release candidate commit hash. Update the `pubspec.yaml` `versionCode` +1 and deploy an emergency patch APK to users.
2. **User Action**: Install over the current installation.
3. **Data Impact**: Because the Hive models did not shift destructively, the previous code bindings will safely query the underlying application cache directory intact.

## Scenario 2: Hive Schema Corruption (Catastrophic Failure)
If an update deploys mismatched Hive property keys enforcing Type read-length mismatched crashes:
1. **Stop Condition**: Do not attempt a blind sequential update. Hive will permanently flag the database cache as corrupted unrecoverably.
2. **Developer Action**: Immediate publication pause. Ensure the stable previous APK is distributed.
3. **User Action**:
   - The user **must** uninstall the corrupted version (this natively burns the corrupted Hive tables mapped to local app storage).
   - The user re-installs the prior stable release APK.
   - The user manually uploads their last verified `.labourbackup` file using the Settings > Restore functionality.
4. **Data Impact**: Data accumulated between the last valid manual `.labourbackup` and the exact point of catastrophic upgrade is permanently lost.

## Safeguards Implemented
To mitigate Scenario 2 impacts, backup workflows dynamically write strictly into Android's independent user-selectable filesystem partitions, effectively disconnecting data lifetimes from the native internal app uninstallation routines.
