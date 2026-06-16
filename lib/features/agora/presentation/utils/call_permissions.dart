import 'package:permission_handler/permission_handler.dart';

import '../models/call_route_args.dart';

/// Requests mic/camera permissions on **iOS and Android** before joining a channel.
class CallPermissions {
  CallPermissions._();

  static Future<String?> requestForMode(CallMode mode) async {
    final micError = await _request(Permission.microphone, 'Microphone');
    if (micError != null) return micError;

    if (mode == CallMode.audio) return null;

    final cameraError = await _request(Permission.camera, 'Camera');
    if (cameraError != null) return cameraError;

    return null;
  }

  static Future<String?> _request(
    Permission permission,
    String label,
  ) async {
    var status = await permission.status;

    if (status.isGranted) return null;

    if (status.isPermanentlyDenied || status.isRestricted) {
      return '$label access is blocked. Open Settings to allow it for calls.';
    }

    status = await permission.request();

    if (status.isGranted) return null;

    if (status.isPermanentlyDenied || status.isRestricted) {
      return '$label access is blocked. Open Settings to allow it for calls.';
    }

    return '$label permission is required for calls.';
  }

  /// Opens system settings (iOS Settings app / Android app details).
  static Future<bool> openSettings() => openAppSettings();
}
