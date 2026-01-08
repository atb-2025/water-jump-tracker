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
      // Initiera sensorer och analysmotor
      await _sensorDataSource.startMonitoring();
      _analysisEngine.startMonitoring();

      // Lyssna på sensordata och mata till analysmotorn
      _sensorDataSource.sensorStream.listen((reading) {
        _analysisEngine.processSensorReading(reading);
      });

      // Lyssna på analysmotor state
      _analysisEngine.stateStream.listen((analysisState) async {
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

      state = const JumpTrackingState.ready();
    } catch (e) {
      state = JumpTrackingState.error('Kunde inte starta hopp: $e');
    }
  }

  /// Avsluta hopp och beräkna resultat
  Future<void> _finishJump() async {
    state = const JumpTrackingState.analyzing();

    try {
      // Stoppa sensorer
      await _sensorDataSource.stopMonitoring();

      // Analysera hoppdatan
      final analysisResult = _analysisEngine.analyzeJump();

      // Hämta position
      final location = await _locationDataSource.getCurrentLocation();

      // Hämta väderdata
      final weather = await _weatherDataSource.getCurrentWeather(
        location.latitude,
        location.longitude,
      );

      // Hämta pulsdata (från 5 sekunder innan till nu)
      final endTime = DateTime.now();
      final startTime = endTime.subtract(const Duration(seconds: 5));
      final pulse = await _healthDataSource.getPulseData(startTime, endTime);

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
      await _historyRepository.saveJump(jumpData);

      // Uppdatera state med resultat
      state = JumpTrackingState.completed(jumpData);
    } catch (e) {
      state = JumpTrackingState.error('Kunde inte analysera hopp: $e');
    }
  }

  /// Återställ till idle state
  void reset() {
    state = const JumpTrackingState.idle();
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
