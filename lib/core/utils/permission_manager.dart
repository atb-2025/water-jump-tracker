import 'package:permission_handler/permission_handler.dart';

/// Hanterare för applikationsbehörigheter
class PermissionManager {
  /// Kontrollera och begär alla nödvändiga behörigheter
  Future<PermissionStatus> requestAllPermissions() async {
    final permissions = [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.sensors,
      Permission.activityRecognition,
    ];

    // Begär alla behörigheter samtidigt
    final statuses = await permissions.request();

    // Returnera den mest restriktiva statusen
    if (statuses.values.any((status) => status.isDenied)) {
      return PermissionStatus.denied;
    }
    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      return PermissionStatus.permanentlyDenied;
    }

    return PermissionStatus.granted;
  }

  /// Kontrollera om platsbehörigheter är givna
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Kontrollera om sensorbehörigheter är givna
  Future<bool> hasSensorPermission() async {
    if (await Permission.sensors.isGranted) {
      return true;
    }
    // På vissa Android-versioner behövs activity recognition för sensorer
    return await Permission.activityRecognition.isGranted;
  }

  /// Begär specifik behörighet
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  /// Öppna appinställningar om behörigheter är permanent nekade
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Kontrollera om alla kritiska behörigheter är givna
  Future<bool> hasAllRequiredPermissions() async {
    final location = await hasLocationPermission();
    final sensors = await hasSensorPermission();

    return location && sensors;
  }
}
