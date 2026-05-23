# Release Strategy

Releasing the application into production follows a stringent, measured strategy focused on stability, offline reliability, and binary optimization.

## 1. Build Verification

Before compiling any release binary, the codebase must clear the local validation chain. No pull request may merge without this checklist verified.

```bash
flutter pub get
flutter analyze
flutter test
```

## 2. Release Generation

The Android application (`com.roshan.labourparty`) utilizes a `minSdk` of 24.

### Generating APK for Direct Distribution
To build a highly optimized APK for direct sharing (sideloading):
```bash
flutter build apk --release
```

### Generating App Bundle for Play Store
If distribution ever shifts to the Play Store, the required format is the AppBundle:
```bash
flutter build appbundle
```

## 3. Optimizations & Constraints

- **R8 / Proguard:** Active on all release builds. Strips unused classes and ensures the dart codebase is safely minified.
- **APK Size Exception:** The validated baseline release APK size is `~52.1 MB`. This is structurally accepted because of embedded vector icon fonts (`MaterialIcons`, `CupertinoIcons`) required for a visually rich local-first experience.

## 4. Permissions

The application is engineered 100% offline. Consequently:
- **No Internet Permissions:** The production `AndroidManifest.xml` explicitly prohibits internet access, ensuring absolute peace of mind regarding data sovereignty.
- **Storage Permissions:** Required solely for exporting and importing the JSON backup files safely to the user's local filesystem.
