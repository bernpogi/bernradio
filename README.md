# BERN – Off-Grid Radio

A Flutter app for talking, texting and sending SOS over a LoRa mesh when there is
no cell signal and no internet. The phone connects to a pocket LoRa radio over
Bluetooth; every radio relays messages for the others. An optional SMS gateway
node forwards messages to normal phones once it has signal.

**Platform:** Android 7.0 (API 24) and newer. iOS later.

## Setting up on a new machine

1. Clone and enter the repo:
   ```
   git clone https://github.com/bernpogi/bernradio.git
   cd bernradio
   ```
2. Generate the rest of the Flutter project **inside this folder**. Existing files
   are kept. The names must match `android/app/build.gradle.kts`:
   ```
   flutter create --org com.theprojectnoah --project-name bern_offgrid_radio --platforms android .
   ```
3. Fonts are bundled, not downloaded, because the app must work offline. Download these
   from fonts.google.com into `assets/fonts/`:
   - `BarlowCondensed-SemiBold.ttf`, `BarlowCondensed-Bold.ttf`
   - `IBMPlexSans-Regular.ttf`, `IBMPlexSans-Medium.ttf`, `IBMPlexSans-SemiBold.ttf`
   - `IBMPlexMono-Medium.ttf`
4. Create the map asset folder: `mkdir -p assets/map`
5. Install packages and check the code:
   ```
   flutter pub get
   flutter analyze
   ```
6. After the first successful `pub get`, run `flutter pub outdated` and pin the
   package versions in `pubspec.yaml` (they are currently left open).

## Android version compatibility

| Android | API | What the app does |
|---|---|---|
| 7.0 – 11 | 24–30 | Asks for **location** to scan for the radio, and checks the Location switch is on |
| 12+ | 31+ | Asks for **Nearby devices** (Bluetooth) only |
| 13+ | 33+ | Also asks for **notification** permission |
| 14+ | 34+ | Uses typed foreground service permissions to stay connected with the screen off |

## Progress

### Done
| # | File | Purpose |
|---|---|---|
| 1 | `pubspec.yaml` | Packages and bundled fonts |
| 2 | `android/app/src/main/AndroidManifest.xml` | Permissions per Android version |
| 3 | `android/app/build.gradle.kts` (+ `proguard-rules.pro`) | minSdk 24, latest targetSdk, shrunk release builds |
| 4 | `lib/services/permissions_service.dart` | Version-aware permission requests |

### Next: front-end
5. `lib/theme/app_theme.dart`: orange theme and fonts from the design
6. `lib/main.dart`: app entry, routes
7. Fake radio layer: demo data so screens work without a radio
8. Screens: Welcome → Pair → Join channel → Channel, Nodes, Map, SOS, Device,
   SMS compose, Gateway

### Backend (needs owner approval before starting)
- Real Bluetooth link to the LoRa radio and the message format
- Local storage of messages and settings
- Background service that keeps the radio connected
- SMS gateway logic and voice burst compression

## Notes
- **SMS gateway mode** needs SEND_SMS, which Google Play restricts. It will ship as a
  separate build installed outside the Play Store. That's why SMS permissions are not in the
  main manifest.
- **LoRa frequency band:** check NTC rules for the Philippines before buying or
  deploying radios.
- **Release signing:** create an upload keystore and `android/key.properties`
  (already git-ignored) before publishing.
