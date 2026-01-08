import 'dart:async';
import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/sensor_reading.dart';

/// Analysmotor för att detektera och analysera vattenhopp
class JumpAnalysisEngine {
  // State
  bool _isMonitoring = false;
  bool _jumpDetected = false;
  DateTime? _jumpStartTime;
  DateTime? _jumpEndTime;

  // Sensordata
  final List<SensorReading> _sensorReadings = [];

  // Stream controllers
  final StreamController<JumpAnalysisState> _stateController =
      StreamController<JumpAnalysisState>.broadcast();

  Stream<JumpAnalysisState> get stateStream => _stateController.stream;

  /// Starta övervakning av sensordata
  void startMonitoring() {
    _isMonitoring = true;
    _jumpDetected = false;
    _jumpStartTime = null;
    _jumpEndTime = null;
    _sensorReadings.clear();
    _emitState(JumpAnalysisState.ready);
  }

  /// Stoppa övervakning
  void stopMonitoring() {
    _isMonitoring = false;
    _emitState(JumpAnalysisState.idle);
  }

  /// Bearbeta ny sensoravläsning
  void processSensorReading(SensorReading reading) {
    if (!_isMonitoring) return;

    _sensorReadings.add(reading);

    // Detektera fallstart
    if (!_jumpDetected && _detectFallStart(reading)) {
      _jumpDetected = true;
      _jumpStartTime = reading.timestamp;
      _emitState(JumpAnalysisState.jumping);
    }

    // Detektera vattenimpact
    if (_jumpDetected &&
        _jumpStartTime != null &&
        _detectWaterImpact(reading)) {
      _jumpEndTime = reading.timestamp;
      _isMonitoring = false;
      _emitState(JumpAnalysisState.analyzing);
    }

    // Säkerhetskontroll: Om hoppet tar för lång tid, avbryt
    if (_jumpDetected &&
        _jumpStartTime != null &&
        DateTime.now().difference(_jumpStartTime!).inMilliseconds >
            AppConstants.maxJumpDuration) {
      _resetState();
      _emitState(JumpAnalysisState.error);
    }
  }

  /// Analysera hoppdatan och beräkna resultat
  JumpAnalysisResult analyzeJump() {
    if (_jumpStartTime == null || _jumpEndTime == null) {
      throw Exception('Hoppdata är inkomplett');
    }

    // Beräkna falltid
    final fallTime =
        _jumpEndTime!.difference(_jumpStartTime!).inMilliseconds / 1000.0;

    if (fallTime < AppConstants.minJumpDuration / 1000.0) {
      throw Exception('Falltiden är för kort för att vara ett giltigt hopp');
    }

    // Beräkna höjd: h = 0.5 * g * t²
    final height = 0.5 * AppConstants.gravity * fallTime * fallTime;

    // Beräkna hastighet: v = g * t
    final velocity = AppConstants.gravity * fallTime;

    // Analysera rotation
    final rotation = _analyzeRotation();

    // Beräkna stabilitet
    final stabilityScore = _calculateStabilityScore();

    return JumpAnalysisResult(
      fallTime: fallTime,
      height: height,
      velocity: velocity,
      rotationX: rotation['x']!,
      rotationY: rotation['y']!,
      rotationZ: rotation['z']!,
      stabilityScore: stabilityScore,
    );
  }

  /// Detektera fallstart baserat på gyroskopdata
  bool _detectFallStart(SensorReading reading) {
    // Om gyroskopets totala rotation överstiger tröskelvärdet
    final gyroMag = sqrt(reading.gyroX * reading.gyroX +
        reading.gyroY * reading.gyroY +
        reading.gyroZ * reading.gyroZ);

    return gyroMag > AppConstants.fallDetectionThreshold;
  }

  /// Detektera vattenimpact baserat på accelerometerdata
  bool _detectWaterImpact(SensorReading reading) {
    // Stark acceleration i vertikal riktning indikerar vattenimpact
    final accelMag = sqrt(reading.accelX * reading.accelX +
        reading.accelY * reading.accelY +
        reading.accelZ * reading.accelZ);

    return accelMag > AppConstants.waterImpactThreshold;
  }

  /// Analysera rotation under hoppet
  Map<String, double> _analyzeRotation() {
    if (_sensorReadings.isEmpty) {
      return {'x': 0.0, 'y': 0.0, 'z': 0.0};
    }

    // Integrera gyroskopdata för att få total rotation
    double totalRotX = 0.0;
    double totalRotY = 0.0;
    double totalRotZ = 0.0;

    for (int i = 1; i < _sensorReadings.length; i++) {
      final dt = _sensorReadings[i]
              .timestamp
              .difference(_sensorReadings[i - 1].timestamp)
              .inMilliseconds /
          1000.0;

      totalRotX += _sensorReadings[i].gyroX * dt;
      totalRotY += _sensorReadings[i].gyroY * dt;
      totalRotZ += _sensorReadings[i].gyroZ * dt;
    }

    return {
      'x': totalRotX.abs(),
      'y': totalRotY.abs(),
      'z': totalRotZ.abs(),
    };
  }

  /// Beräkna stabilitetspoäng baserat på variationer i sensordata
  double _calculateStabilityScore() {
    if (_sensorReadings.isEmpty) return 0.0;

    // Beräkna standardavvikelse för gyroskopdata
    final gyroValues = _sensorReadings
        .map((r) =>
            sqrt(r.gyroX * r.gyroX + r.gyroY * r.gyroY + r.gyroZ * r.gyroZ))
        .toList();

    final mean = gyroValues.reduce((a, b) => a + b) / gyroValues.length;
    final variance =
        gyroValues.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
            gyroValues.length;
    final stdDev = sqrt(variance);

    // Lägre standardavvikelse = högre stabilitet
    // Normalisera till 0-100 skala
    final stability = max(0.0, 100.0 - (stdDev * 2));

    return stability.clamp(0.0, 100.0);
  }

  /// Återställ state
  void _resetState() {
    _jumpDetected = false;
    _jumpStartTime = null;
    _jumpEndTime = null;
    _sensorReadings.clear();
  }

  /// Emittera state
  void _emitState(JumpAnalysisState state) {
    _stateController.add(state);
  }

  /// Rensa resurser
  void dispose() {
    _stateController.close();
  }
}

/// State för jump analysis
enum JumpAnalysisState {
  idle, // Ingen aktivitet
  ready, // Redo att detektera hopp
  jumping, // Hopp detekterat, pågående
  analyzing, // Analyserar hoppdatan
  error, // Fel uppstod
}

/// Resultat från hoppanalys
class JumpAnalysisResult {
  final double fallTime;
  final double height;
  final double velocity;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double stabilityScore;

  const JumpAnalysisResult({
    required this.fallTime,
    required this.height,
    required this.velocity,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
    required this.stabilityScore,
  });
}
