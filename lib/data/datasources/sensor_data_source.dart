import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/entities/sensor_reading.dart';

/// Data source för gyroskop och accelerometer
class SensorDataSource {
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  final StreamController<SensorReading> _sensorController =
      StreamController<SensorReading>.broadcast();

  GyroscopeEvent? _lastGyro;
  AccelerometerEvent? _lastAccel;

  /// Stream av kombinerade sensoravläsningar
  Stream<SensorReading> get sensorStream => _sensorController.stream;

  /// Starta sensorövervakning
  Future<void> startMonitoring() async {
    _gyroSubscription = gyroscopeEventStream().listen((event) {
      _lastGyro = event;
      _emitCombinedReading();
    });

    _accelSubscription = accelerometerEventStream().listen((event) {
      _lastAccel = event;
      _emitCombinedReading();
    });
  }

  /// Stoppa sensorövervakning
  Future<void> stopMonitoring() async {
    await _gyroSubscription?.cancel();
    await _accelSubscription?.cancel();
    _gyroSubscription = null;
    _accelSubscription = null;
  }

  /// Kombinera gyroskop och accelerometer till en läsning
  void _emitCombinedReading() {
    if (_lastGyro != null && _lastAccel != null) {
      final reading = SensorReading(
        timestamp: DateTime.now(),
        gyroX: _lastGyro!.x,
        gyroY: _lastGyro!.y,
        gyroZ: _lastGyro!.z,
        accelX: _lastAccel!.x,
        accelY: _lastAccel!.y,
        accelZ: _lastAccel!.z,
      );
      _sensorController.add(reading);
    }
  }

  /// Rensa resurser
  void dispose() {
    stopMonitoring();
    _sensorController.close();
  }
}
