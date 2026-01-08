import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/sensor_data_source.dart';
import '../../data/datasources/location_data_source.dart';
import '../../data/datasources/health_data_source.dart';
import '../../data/datasources/weather_data_source.dart';
import '../../data/repositories/jump_history_repository.dart';
import '../../domain/entities/jump_data.dart';
import '../../domain/usecases/jump_analysis_engine.dart';
import '../../domain/usecases/score_calculator.dart';
import '../../core/constants/app_constants.dart';

// Providers för data sources
final sensorDataSourceProvider = Provider((ref) => SensorDataSource());
final locationDataSourceProvider = Provider((ref) => LocationDataSource());
final healthDataSourceProvider = Provider((ref) => HealthDataSource());
final weatherDataSourceProvider = Provider((ref) => WeatherDataSource());
final jumpHistoryRepositoryProvider =
    Provider((ref) => JumpHistoryRepository());

// Provider för jump analysis engine
final jumpAnalysisEngineProvider = Provider((ref) => JumpAnalysisEngine());

// State notifier för jumptracking
class JumpTrackingNotifier extends StateNotifier<JumpTrackingState> {
  final SensorDataSource _sensorDataSource;
  final LocationDataSource _locationDataSource;
  final HealthDataSource _healthDataSource;
  final WeatherDataSource _weatherDataSource;
  final JumpHistoryRepository _historyRepository;
  final JumpAnalysisEngine _analysisEngine;

  JumpTrackingNotifier({
    required SensorDataSource sensorDataSource,
    required LocationDataSource locationDataSource,
    required HealthDataSource healthDataSource,
    required WeatherDataSource weatherDataSource,
    required JumpHistoryRepository historyRepository,
    required JumpAnalysisEngine analysisEngine,
  })  : _sensorDataSource = sensorDataSource,
        _locationDataSource = locationDataSource,
        _healthDataSource = healthDataSource,
        _weatherDataSource = weatherDataSource,
        _historyRepository = historyRepository,
        _analysisEngine = analysisEngine,
        super(const JumpTrackingState.idle());

  /// Starta ett nytt hopp
  Future<void> startJump() async {
    state = const JumpTrackingState.preparing();

    try {
      print('🚀 Startar hopp...');
      
      // Begär Health-behörigheter
      print('❤️ Begär Health-behörigheter...');
      final healthPermission = await _healthDataSource.initialize();
      if (healthPermission) {
        print('✅ Health-behörigheter godkända');
      } else {
        print('⚠️ Health-behörigheter nekades - använder standardvärden för puls');
      }
      
      // Initiera sensorer och analysmotor
      print('📱 Startar sensorer...');
      await _sensorDataSource.startMonitoring();
      print('✅ Sensorer startade');
      
      print('🔍 Startar analysmotor...');
      _analysisEngine.startMonitoring();
      print('✅ Analysmotor startad');

      // Lyssna på sensordata och mata till analysmotorn
      _sensorDataSource.sensorStream.listen((reading) {
        _analysisEngine.processSensorReading(reading);
      });

      // Lyssna på analysmotor state
      _analysisEngine.stateStream.listen((analysisState) async {
        print('📊 Analysmotor state: $analysisState');
        switch (analysisState) {
          case JumpAnalysisState.ready:
            state = const JumpTrackingState.ready();
            break;
          case JumpAnalysisState.jumping:
            state = const JumpTrackingState.jumping();
            break;
          case JumpAnalysisState.analyzing:
            await _finishJump();
            break;
          case JumpAnalysisState.error:
            state =
                const JumpTrackingState.error('Något gick fel under hoppet');
            break;
          default:
            break;
        }
      });

      print('✅ Hopp redo!');
      state = const JumpTrackingState.ready();
    } catch (e, stackTrace) {
      print('❌ Fel vid start av hopp: $e');
      print('Stack trace: $stackTrace');
      state = JumpTrackingState.error('Kunde inte starta hopp: $e');
    }
  }

  /// Avsluta hopp och beräkna resultat
  Future<void> _finishJump() async {
    state = const JumpTrackingState.analyzing();

    try {
      print('🏁 Avslutar hopp...');
      
      // Stoppa sensorer
      print('⏹️ Stoppar sensorer...');
      await _sensorDataSource.stopMonitoring();
      print('✅ Sensorer stoppade');

      // Analysera hoppdatan
      print('📊 Analyserar hopp...');
      final analysisResult = _analysisEngine.analyzeJump();
      print('✅ Analys klar: Höjd=${analysisResult.height}m');

      // Hämta position
      print('📍 Hämtar position...');
      final location = await _locationDataSource.getCurrentLocation();
      print('✅ Position: ${location.latitude}, ${location.longitude}');

      // Hämta väderdata
      print('🌤️ Hämtar väderdata...');
      final weather = await _weatherDataSource.getCurrentWeather(
        location.latitude,
        location.longitude,
      );
      print('✅ Väder: ${weather.temperature}°C, ${weather.condition}');

      // Hämta pulsdata (från 30 sekunder innan till nu för att säkerställa att vi får data)
      print('❤️ Hämtar pulsdata...');
      final endTime = DateTime.now();
      final startTime = endTime.subtract(const Duration(seconds: 30));
      final pulse = await _healthDataSource.getPulseData(startTime, endTime);
      print('✅ Puls: $pulse bpm');

      // Beräkna total rotation
      final totalRotation = sqrt(
          analysisResult.rotationX * analysisResult.rotationX +
              analysisResult.rotationY * analysisResult.rotationY +
              analysisResult.rotationZ * analysisResult.rotationZ);

      // Beräkna totalpoäng
      final totalScore = ScoreCalculator.calculateTotalScore(
        height: analysisResult.height,
        stabilityScore: analysisResult.stabilityScore,
        pulse: pulse,
        rotationMagnitude: totalRotation,
      );

      // Skapa JumpData
      final jumpData = JumpData(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        fallTime: analysisResult.fallTime,
        height: analysisResult.height,
        velocity: analysisResult.velocity,
        rotationX: analysisResult.rotationX,
        rotationY: analysisResult.rotationY,
        rotationZ: analysisResult.rotationZ,
        stabilityScore: analysisResult.stabilityScore,
        location: location,
        weather: weather,
        pulse: pulse,
        totalScore: totalScore,
      );

      // Spara till historik
      print('💾 Sparar hopp...');
      await _historyRepository.saveJump(jumpData);
      print('✅ Hopp sparat!');

      // Uppdatera state med resultat
      state = JumpTrackingState.completed(jumpData);
    } catch (e, stackTrace) {
      print('❌ Fel vid analys: $e');
      print('Stack trace: $stackTrace');
      state = JumpTrackingState.error('Kunde inte analysera hopp: $e');
    }
  }

  /// Återställ till idle state
  void reset() {
    state = const JumpTrackingState.idle();
  }

  /// Simulera ett hopp för demo/test
  Future<void> simulateJump() async {
    state = const JumpTrackingState.jumping();
    
    print('🎬 Simulerar hopp...');
    
    // Vänta lite för att simulera hopptid
    await Future.delayed(const Duration(seconds: 2));
    
    await _simulateFinishJump();
  }

  /// Simulera hopp-avslut med fake data
  Future<void> _simulateFinishJump() async {
    state = const JumpTrackingState.analyzing();

    try {
      print('🎬 Skapar simulerad hoppdata...');
      
      // Stoppa sensorer om de körs
      try {
        await _sensorDataSource.stopMonitoring();
      } catch (e) {
        print('⚠️ Kunde inte stoppa sensorer: $e');
      }

      // Simulerad hoppdata
      final random = Random();
      final simulatedHeight = 3.0 + random.nextDouble() * 2.0; // 3-5 meter
      final simulatedFallTime = sqrt(2 * simulatedHeight / AppConstants.gravity);
      final simulatedVelocity = AppConstants.gravity * simulatedFallTime;

      // Hämta position med error handling
      LocationData location;
      try {
        print('📍 Hämtar position...');
        location = await _locationDataSource.getCurrentLocation();
        print('✅ Position: ${location.latitude}, ${location.longitude}');
      } catch (e) {
        print('⚠️ Kunde inte hämta position: $e. Använder standardvärden.');
        location = LocationData(
          latitude: 59.3293,
          longitude: 18.0686,
          altitude: 0.0,
        );
      }

      // Hämta väderdata med error handling
      WeatherData weather;
      try {
        print('🌤️ Hämtar väderdata...');
        weather = await _weatherDataSource.getCurrentWeather(
          location.latitude,
          location.longitude,
        );
        print('✅ Väder: ${weather.temperature}°C, ${weather.condition}');
      } catch (e) {
        print('⚠️ Kunde inte hämta väderdata: $e. Använder standardvärden.');
        weather = const WeatherData(
          temperature: 20.0,
          condition: 'Soligt',
          windSpeed: 3.5,
        );
      }

      // Simulerad pulsdata
      final basePulse = 120 + random.nextInt(40); // 120-160 bpm
      final simulatedPulse = PulseData(
        startPulse: basePulse,
        maxPulse: basePulse + 10 + random.nextInt(20),
        endPulse: basePulse + random.nextInt(10),
      );

      // Simulerad rotation
      final rotationX = random.nextDouble() * 360 - 180;
      final rotationY = random.nextDouble() * 360 - 180;
      final rotationZ = random.nextDouble() * 360 - 180;
      final totalRotation = sqrt(rotationX * rotationX + rotationY * rotationY + rotationZ * rotationZ);

      // Simulerad stabilitet
      final stabilityScore = 70 + random.nextDouble() * 25; // 70-95%

      // Beräkna totalpoäng
      final totalScore = ScoreCalculator.calculateTotalScore(
        height: simulatedHeight,
        stabilityScore: stabilityScore,
        pulse: simulatedPulse,
        rotationMagnitude: totalRotation,
      );

      // Skapa JumpData
      final jumpData = JumpData(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        fallTime: simulatedFallTime,
        height: simulatedHeight,
        velocity: simulatedVelocity,
        rotationX: rotationX,
        rotationY: rotationY,
        rotationZ: rotationZ,
        stabilityScore: stabilityScore,
        location: location,
        weather: weather,
        pulse: simulatedPulse,
        totalScore: totalScore,
      );

      // Spara till historik
      print('💾 Sparar simulerat hopp...');
      await _historyRepository.saveJump(jumpData);
      print('✅ Simulerat hopp sparat!');

      // Uppdatera state med resultat
      state = JumpTrackingState.completed(jumpData);
    } catch (e, stackTrace) {
      print('❌ Fel vid simulering: $e');
      print('Stack trace: $stackTrace');
      state = JumpTrackingState.error('Kunde inte simulera hopp: $e');
    }
  }
}

// State för jump tracking
sealed class JumpTrackingState {
  const JumpTrackingState();

  const factory JumpTrackingState.idle() = JumpTrackingIdle;
  const factory JumpTrackingState.preparing() = JumpTrackingPreparing;
  const factory JumpTrackingState.ready() = JumpTrackingReady;
  const factory JumpTrackingState.jumping() = JumpTrackingJumping;
  const factory JumpTrackingState.analyzing() = JumpTrackingAnalyzing;
  const factory JumpTrackingState.completed(JumpData jumpData) =
      JumpTrackingCompleted;
  const factory JumpTrackingState.error(String message) = JumpTrackingError;
}

class JumpTrackingIdle extends JumpTrackingState {
  const JumpTrackingIdle();
}

class JumpTrackingPreparing extends JumpTrackingState {
  const JumpTrackingPreparing();
}

class JumpTrackingReady extends JumpTrackingState {
  const JumpTrackingReady();
}

class JumpTrackingJumping extends JumpTrackingState {
  const JumpTrackingJumping();
}

class JumpTrackingAnalyzing extends JumpTrackingState {
  const JumpTrackingAnalyzing();
}

class JumpTrackingCompleted extends JumpTrackingState {
  final JumpData jumpData;
  const JumpTrackingCompleted(this.jumpData);
}

class JumpTrackingError extends JumpTrackingState {
  final String message;
  const JumpTrackingError(this.message);
}

// Provider för jump tracking notifier
final jumpTrackingProvider =
    StateNotifierProvider<JumpTrackingNotifier, JumpTrackingState>((ref) {
  return JumpTrackingNotifier(
    sensorDataSource: ref.watch(sensorDataSourceProvider),
    locationDataSource: ref.watch(locationDataSourceProvider),
    healthDataSource: ref.watch(healthDataSourceProvider),
    weatherDataSource: ref.watch(weatherDataSourceProvider),
    historyRepository: ref.watch(jumpHistoryRepositoryProvider),
    analysisEngine: ref.watch(jumpAnalysisEngineProvider),
  );
});

// Provider för historik
final jumpHistoryProvider = FutureProvider<List<JumpData>>((ref) async {
  final repository = ref.watch(jumpHistoryRepositoryProvider);
  return repository.getAllJumps();
});

// Provider för statistik
final jumpStatisticsProvider = FutureProvider((ref) async {
  final repository = ref.watch(jumpHistoryRepositoryProvider);
  return repository.getStatistics();
});
