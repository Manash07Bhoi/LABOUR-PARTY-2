# Deployment Checklist

## Pre-Release Validations
- [x] Codebase passes `flutter analyze` with 0 unresolved code health warnings or dead code branches.
- [x] 100% of defined `flutter test` cases pass locally on CI.
- [x] Android `AndroidManifest.xml` limits network permissions enforcing offline-first mandates.
- [x] Proguard rules/Minification are actively registered in `android/app/build.gradle.kts`.

## Release Environment Configuration
- [ ] Valid `android/key.properties` generated dynamically holding Keystore variables (do not commit to Git).
- [ ] Flutter version locked to `^3.11.0`.
- [ ] Version variables updated logically within `pubspec.yaml` representing correct release code semantics.

## Manual Sanity Walkthrough (Device QA)
- [ ] Install APK onto a physical Android device.
- [ ] Perform a manual Backup Export (`.labourbackup`) and execute a test Restore cycle.
- [ ] Trigger an intentional Route Casting Error to ensure it recovers predictably on standard physical devices.
- [ ] Force Application kill in the device background to confirm fast startup timings (`~40ms`) without data-load latency jitter.
- [ ] Compare memory allocation (`RSS`) against the benchmark `800MB` metrics for legacy offline datasets.
