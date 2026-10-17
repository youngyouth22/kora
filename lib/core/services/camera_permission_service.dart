import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

/// Contract for requesting, inspecting, and managing camera permissions.
abstract class CameraPermissionService {
  /// Prompts the user or checks if camera access is permitted.
  ///
  /// Returns `true` if camera access is granted, `false` otherwise.
  Future<bool> requestCameraPermission();

  /// Checks whether camera permission is currently granted.
  Future<bool> isPermissionGranted();

  /// Checks whether camera access has been permanently denied by the user.
  Future<bool> isPermanentlyDenied();

  /// Opens the device settings screen for Kora so the user can enable access.
  Future<bool> openSettings();
}

/// Production implementation backed by the native permission_handler package.
class DefaultCameraPermissionService implements CameraPermissionService {
  /// Creates a [DefaultCameraPermissionService].
  const DefaultCameraPermissionService();

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> isPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> isPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  @override
  Future<bool> openSettings() async {
    return openAppSettings();
  }
}
