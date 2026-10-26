import 'package:permission_handler/permission_handler.dart';

/// Contract for requesting, inspecting, and managing push/local notification permissions.
abstract class NotificationPermissionService {
  /// Prompts the user or checks if notification access is permitted.
  ///
  /// Returns `true` if notification access is granted, `false` otherwise.
  Future<bool> requestNotificationPermission();

  /// Checks whether notification permission is currently granted.
  Future<bool> isPermissionGranted();

  /// Checks whether notification permission has been permanently denied.
  Future<bool> isPermanentlyDenied();

  /// Opens the device settings screen for Kora so the user can enable access.
  Future<bool> openSettings();
}

/// Production implementation backed by the native permission_handler package.
class DefaultNotificationPermissionService
    implements NotificationPermissionService {
  /// Creates a [DefaultNotificationPermissionService].
  const DefaultNotificationPermissionService();

  @override
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  @override
  Future<bool> isPermanentlyDenied() async {
    final status = await Permission.notification.status;
    return status.isPermanentlyDenied;
  }

  @override
  Future<bool> openSettings() async {
    return openAppSettings();
  }
}
