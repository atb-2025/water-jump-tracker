import 'package:geolocator/geolocator.dart';
import '../../domain/entities/jump_data.dart';

/// Data source för GPS-position
class LocationDataSource {
  /// Hämta aktuell position
  Future<LocationData> getCurrentLocation() async {
    // Kontrollera behörigheter
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Platstjänster är inaktiverade');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Platsbehörigheter nekades');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Platsbehörigheter är permanent nekade');
    }

    // Hämta position med hög noggrannhet
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    );

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
    );
  }

  /// Kontrollera om platsbehörigheter är givna
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Begär platsbehörigheter
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
