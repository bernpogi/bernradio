// BERN – Off-Grid Radio · Permissions
//
// Asks for the right permissions based on the phone's Android version.
// Screens call this; it never talks to the radio itself.
//
//   Android 7.0 – 11 (API 24–30)  Bluetooth scanning needs LOCATION permission,
//                                 and the phone's Location switch must be ON.
//   Android 12+    (API 31+)      Bluetooth uses "Nearby devices"
//                                 (BLUETOOTH_SCAN + BLUETOOTH_CONNECT). No location needed.
//   Android 13+    (API 33+)      Notifications must be requested at runtime.
//
// Legacy BLUETOOTH / BLUETOOTH_ADMIN (API ≤ 30) are granted at install time
// from AndroidManifest.xml, so they are never requested here.

import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// What happened when we asked.
enum PermissionOutcome {
  /// Everything needed was allowed.
  granted,

  /// The user tapped "Don't allow". We can ask again later.
  denied,

  /// The user chose "Don't ask again" (or denied twice). Only the
  /// app's system settings page can change it now.
  permanentlyDenied,

  /// Android 7–11 only: permission is fine, but the phone's Location
  /// switch is off, so Bluetooth scanning will find nothing.
  locationServiceOff,
}

/// Plain-language text the screens show before asking.
class PermissionRationale {
  final String title;
  final String body;
  const PermissionRationale(this.title, this.body);
}

class PermissionsService {
  PermissionsService._();
  static final PermissionsService instance = PermissionsService._();

  int? _sdkInt;

  // Android version helpers

  /// Android API level (e.g. 24 = Android 7.0, 31 = Android 12).
  /// Returns 0 when not running on Android.
  Future<int> androidSdk() async {
    if (_sdkInt != null) return _sdkInt!;
    if (!Platform.isAndroid) return _sdkInt = 0;
    final info = await DeviceInfoPlugin().androidInfo;
    return _sdkInt = info.version.sdkInt;
  }

  /// True on Android 12+, which uses "Nearby devices" for Bluetooth.
  Future<bool> usesNearbyDevices() async => (await androidSdk()) >= 31;

  /// True on Android 13+, where notifications need a runtime prompt.
  Future<bool> needsNotificationPrompt() async => (await androidSdk()) >= 33;

  // Radio (Bluetooth) access

  /// The exact permissions needed to find and connect to the LoRa radio
  /// on this phone's Android version.
  Future<List<Permission>> _radioPermissions() async {
    if (!Platform.isAndroid) return [Permission.bluetooth]; // iOS, later
    if (await usesNearbyDevices()) {
      return [Permission.bluetoothScan, Permission.bluetoothConnect];
    }
    return [Permission.locationWhenInUse];
  }

  /// Text for the screen shown before the Bluetooth prompt.
  Future<PermissionRationale> radioRationale() async {
    if (await usesNearbyDevices()) {
      return const PermissionRationale(
        'Allow Nearby devices',
        'BERN uses Bluetooth to talk to your pocket radio. '
            'Tap "Allow" on the next screen.',
      );
    }
    return const PermissionRationale(
      'Allow location to find your radio',
      'On this Android version, phones need location permission to scan '
          'for Bluetooth devices. BERN does not track you with it. '
          'Please also keep Location switched on while pairing.',
    );
  }

  /// Is everything needed to reach the radio already allowed?
  Future<bool> hasRadioAccess() async {
    for (final p in await _radioPermissions()) {
      if (!await p.isGranted) return false;
    }
    if (!await usesNearbyDevices() && Platform.isAndroid) {
      return await _locationServiceOn();
    }
    return true;
  }

  /// Ask for radio access. On Android 7–11 this also checks that the
  /// Location switch is on, because BLE scans silently return nothing otherwise.
  Future<PermissionOutcome> requestRadio() async {
    final outcome = await _requestAll(await _radioPermissions());
    if (outcome != PermissionOutcome.granted) return outcome;

    if (Platform.isAndroid && !await usesNearbyDevices()) {
      if (!await _locationServiceOn()) return PermissionOutcome.locationServiceOff;
    }
    return PermissionOutcome.granted;
  }

  // Other permissions, asked only when the feature is first used

  /// Map, location sharing and SOS coordinates.
  Future<PermissionOutcome> requestLocation() =>
      _requestAll([Permission.locationWhenInUse]);

  /// Alerts for incoming messages and SOS. Older Android allows by default.
  Future<PermissionOutcome> requestNotifications() async {
    if (Platform.isAndroid && !await needsNotificationPrompt()) {
      return PermissionOutcome.granted;
    }
    return _requestAll([Permission.notification]);
  }

  /// Voice bursts (Hold to Talk).
  Future<PermissionOutcome> requestMicrophone() =>
      _requestAll([Permission.microphone]);

  /// Scanning a channel QR code.
  Future<PermissionOutcome> requestCamera() => _requestAll([Permission.camera]);

  /// Opens this app's page in system settings, for permanently denied cases.
  Future<bool> openSettings() => openAppSettings();

  // Internals

  Future<PermissionOutcome> _requestAll(List<Permission> permissions) async {
    // Skip the system dialog if everything is already granted.
    final missing = <Permission>[];
    for (final p in permissions) {
      if (!await p.isGranted) missing.add(p);
    }
    if (missing.isEmpty) return PermissionOutcome.granted;

    final results = await missing.request();

    if (results.values.any((s) => s.isPermanentlyDenied || s.isRestricted)) {
      return PermissionOutcome.permanentlyDenied;
    }
    if (results.values.every((s) => s.isGranted || s.isLimited)) {
      return PermissionOutcome.granted;
    }
    return PermissionOutcome.denied;
  }

  Future<bool> _locationServiceOn() async =>
      (await Permission.location.serviceStatus) == ServiceStatus.enabled;
}
