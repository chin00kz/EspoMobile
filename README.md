# ESM Mobile

ESM Mobile is a Flutter app that loads the FedEx ESM website inside a native mobile shell using an in-app WebView.

## What This App Is

- A lightweight mobile wrapper around: https://www.espocrm.com/
- Built for Android first (currently validated on a real Android device)
- Includes native pull-to-refresh and web back navigation handling

## Tech Stack

- Framework: Flutter (Dart)
- WebView engine: flutter_inappwebview
- Icon generation: flutter_launcher_icons
- Targets configured in project: Android, iOS, Web, Windows, macOS, Linux
- Production validation done: Android

## Current Features

- Loads the FedEx ESM site in-app
- Native WebView scrolling (vertical + horizontal)
- Native pull-to-refresh (via InAppWebView pull-to-refresh controller)
- Back behavior:
	- Android back button navigates WebView history first
	- If no history, app can exit
- Loading state UI:
	- Center spinner while loading
	- Top linear progress bar
- Custom app name: ESM Mobile
- Custom launcher icon generated from source asset

## Important Files

- App entry and WebView implementation: lib/main.dart
- Android app label and icon binding: android/app/src/main/AndroidManifest.xml
- iOS app display name: ios/Runner/Info.plist
- Web app name metadata: web/manifest.json
- Icon source image: assets/app_icon/fedex_logo.png
- Build dependencies and tooling config: pubspec.yaml

## How To Run

### Debug build (Android)

1. Connect Android device with USB debugging enabled
2. Run:

```bash
flutter pub get
flutter run -d <device-id>
```

### Release build (Android)

Use this for production-style testing:

```bash
flutter run --release -d <device-id>
```

### Build APK (release)

```bash
flutter build apk --release
```

Output:

- build/app/outputs/flutter-apk/app-release.apk

## Production Notes

- Debug banner is disabled in MaterialApp (`debugShowCheckedModeBanner: false`)
- Release install was validated on device (`flutter run --release`)
- For real world testing, device can be unplugged after install

## App Icon Workflow

The app icon is generated from:

- assets/app_icon/fedex_logo.png

Regenerate icons after updating source image:

```bash
dart run flutter_launcher_icons
```

Launcher icon config is in pubspec.yaml under `flutter_launcher_icons`.

## Bugs Found And Fixes Applied

1. Initial WebView app started from broken/placeholder template
- Symptom: default starter app and invalid scaffold behavior
- Fix: replaced template with dedicated WebView screen

2. Status bar overlap
- Symptom: website content clashed with top system status area
- Fix: wrapped body with SafeArea

3. Pull-to-refresh attempts broke scrolling
- Symptom: vertical/horizontal web scrolling got blocked or jittery
- Root cause: overlay gesture detectors/list wrappers intercepting WebView input
- Fix: removed custom gesture interception and migrated to flutter_inappwebview native pull-to-refresh

4. Deprecated back-navigation API warning
- Symptom: `WillPopScope` deprecation warning
- Fix: switched to `PopScope`

5. JavaScript scroll check compile error during earlier implementation
- Symptom: using `runJavaScript` where a result was expected
- Fix: corrected to `runJavaScriptReturningResult` (later custom refresh path removed)

6. Control overlay UX conflicts
- Symptom: floating controls blocked site taps in some areas
- Fix: simplified to one low-opacity back button placed bottom-right

7. Launcher icon not visibly updating on phone immediately
- Symptom: old icon still appeared after generation
- Fix: regenerated icons and reinstalled app; note that launcher cache/uninstall-reinstall may be required

8. ADB/session instability during runs
- Symptom: intermittent "Lost connection to device"
- Fix: rerun/install and continue testing from installed app; release install confirmed

## Known Limitations / Notes

- iOS support is coded, but iOS build/test requires a Mac with Xcode and CocoaPods
- Android log may show platform warnings unrelated to app correctness

## Suggested Next Improvements

1. Add Android release signing (`key.properties` + signing config) for distributable builds
2. Add a simple offline/error screen for network failures
3. Add analytics/crash logging for production observability
4. Add CI build pipeline (debug + release checks)
