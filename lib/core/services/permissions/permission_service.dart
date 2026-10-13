// TODO: Uncomment when `permission_handler` package is enabled in pubspec.yaml:
// import 'package:permission_handler/permission_handler.dart';

/// Contract for managing runtime OS permissions.
abstract interface class PermissionService {
  Future<bool> requestCameraPermission();
  Future<bool> requestPhotosPermission();
  Future<bool> requestNotificationPermission();
  Future<bool> openAppSettings();
}

/// Production implementation of [PermissionService].
class DefaultPermissionService implements PermissionService {
  @override
  Future<bool> requestCameraPermission() async {
    // TODO: Uncomment when `permission_handler` is enabled:
    // final status = await Permission.camera.request();
    // return status.isGranted;
    return true;
  }

  @override
  Future<bool> requestPhotosPermission() async {
    // TODO: Uncomment when `permission_handler` is enabled:
    // final status = await Permission.photos.request();
    // return status.isGranted;
    return true;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    // TODO: Uncomment when `permission_handler` is enabled:
    // final status = await Permission.notification.request();
    // return status.isGranted;
    return true;
  }

  @override
  Future<bool> openAppSettings() async {
    // TODO: Uncomment when `permission_handler` is enabled:
    // return openAppSettings();
    return true;
  }
}
