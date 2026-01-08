import 'package:health/health.dart';
import '../../domain/entities/jump_data.dart';

/// Data source för hälsodata (puls)
class HealthDataSource {
  final Health _health = Health();

  /// Initialisera och begär behörigheter
  Future<bool> initialize() async {
    final types = [
      HealthDataType.HEART_RATE,
    ];

    final permissions = [
      HealthDataAccess.READ,
    ];

    try {
      final granted =
          await _health.requestAuthorization(types, permissions: permissions);
      return granted;
    } catch (e) {
      return false;
    }
  }

  /// Hämta pulsdata för ett tidsintervall
  Future<PulseData> getPulseData(DateTime startTime, DateTime endTime) async {
    try {
      final types = [HealthDataType.HEART_RATE];

      // Hämta pulsmätningar under tidsintervallet
      final healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );

      if (healthData.isEmpty) {
        // Om ingen data finns, använd standardvärden
        return const PulseData(
          startPulse: 70,
          maxPulse: 70,
          endPulse: 70,
        );
      }

      // Sortera efter tidsstämpel
      final sortedData = healthData.toList()
        ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

      // Extrahera pulsvärden
      final pulseValues =
          sortedData.map((d) => (d.value as num).toInt()).toList();

      final startPulse = pulseValues.first;
      final maxPulse = pulseValues.reduce((a, b) => a > b ? a : b);
      final endPulse = pulseValues.last;

      return PulseData(
        startPulse: startPulse,
        maxPulse: maxPulse,
        endPulse: endPulse,
      );
    } catch (e) {
      // Vid fel, returnera standardvärden
      return const PulseData(
        startPulse: 70,
        maxPulse: 70,
        endPulse: 70,
      );
    }
  }

  /// Kontrollera om hälsobehörigheter är givna
  Future<bool> hasPermission() async {
    final types = [HealthDataType.HEART_RATE];
    try {
      final granted = await _health.hasPermissions(types);
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }
}
