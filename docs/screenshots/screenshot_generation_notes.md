# Screenshot Generation Notes

## Playwright Execution
Screenshots were captured using a headless Chromium Playwright instance running against a local Flutter web-server build (`flutter build web --profile`).

## Environment Configuration
- **Viewport**: Emulated Android generic sizing (412x915).
- **Execution Script**: Stored temporarily in `/home/jules/verification/verify_screens.py`.
- **Test Hook**: A temporary test hook (`lib/main_screenshots.dart`) was created to launch the app, initialize the local Hive database, clear all boxes, and seed deterministic logic boundaries (e.g. Work bounds on `2024-10-15`, Driver limits, etc.). This ensures that subsequent screenshot captures are completely immune to time-shift regressions or empty states.

## Capture Path Matrix
The Playwright script sequentially orchestrated cursor click events bypassing missing widget ID binds by utilizing strict positional rendering bounds:
- **Dashboard**: Default render.
- **Trip Details**: Bound to offset mapping `(200, 200)` simulating a click into the first Active Trip.
- **Confirm Next Trip**: Bound to offset mapping `(350, 850)` simulating a Floating Action Button hit from the `Trip Details` frame.
- **Add / Edit Work**: Bound to dashboard `Add Work` Floating Action Button mapping.
- **Navigation Shell Maps**: Executed sequentially across `History`, `Analytics`, and `Settings`.
- **Search Boundaries**: Simulated click into the Dashboard AppBar explicitly dropping the native web keyboard into frame bounds.

## Limitations
Because this repository is strictly an Android-first architecture utilizing native Material constraints, rendering via `flutter build web` triggers `CanvasKit` overhead. Static timing pauses (`time.sleep()`) were actively enforced during script execution instead of explicit `waitForSelector` DOM polls due to Flutter's native web Canvas implementation stripping traditional HTML hierarchies.
