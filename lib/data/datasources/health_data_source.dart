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
      print('🔍 Kollar om Health är tillgängligt...');
      
      // Kolla om appen har tillgång till Health
      bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);
      print('📊 Nuvarande behörigheter: $hasPermissions');
      
      if (hasPermissions == true) {
        print('✅ Health-behörigheter redan godkända');
        return true;
      }
      
      // Begär behörigheter
      print('📝 Begär Health-behörigheter från användaren...');
      final granted = await _health.requestAuthorization(types, permissions: permissions);
      print('📊 Resultat av behörighetsförfrågan: $granted');
      
      return granted;
    } catch (e) {
      print('❌ Fel vid Health-initialisering: $e');
      return false;
    }
  }

  /// Hämta pulsdata för ett tidsintervall
  Future<PulseData> getPulseData(DateTime startTime, DateTime endTime) async {
    try {
      print('❤️‍🔥 Hämtar senaste pulsen från Health...');
      
      final types = [HealthDataType.HEART_RATE];

      // Hämta senaste pulsmätningen (sök bakåt 5 minuter)
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      
      final healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: fiveMinutesAgo,
        endTime: now,
      );

      print('📊 Antal pulsmätningar hämtade: ${healthData.length}');

      if (healthData.isEmpty) {
        print('⚠️ Ingen pulsdata hittades i Health-appen');
        print('💡 Kontrollera att din Apple Watch synkroniserar data');
        return const PulseData(
          startPulse: 70,
          maxPulse: 70,
          endPulse: 70,
        );
      }

      // Sortera och ta den senaste mätningen
      final sortedData = healthData.toList()
        ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));

      // Ta den senaste pulsmätningen
      final latestData = sortedData.first;
      final numericValue = latestData.value as NumericHealthValue;
      final latestPulse = numericValue.numericValue.toInt();
      
      print('💓 Senaste pulsen: $latestPulse bpm (mätt ${latestData.dateFrom})');
      print('✅ Använder denna puls för alla värden');

      // Använd samma puls för alla värden
      return PulseData(
        startPulse: latestPulse,
        maxPulse: latestPulse,
        endPulse: latestPulse,
      );
    } catch (e, stackTrace) {
      print('❌ Fel vid hämtning av pulsdata: $e');
      print('Stack trace: $stackTrace');
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
