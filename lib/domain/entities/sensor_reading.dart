import 'package:equatable/equatable.dart';

/// Entitet för realtidssensordata under hoppet
class SensorReading extends Equatable {
  final DateTime timestamp;
  final double gyroX; // grader/sekund
  final double gyroY;
  final double gyroZ;
  final double accelX; // m/s²
  final double accelY;
  final double accelZ;

  const SensorReading({
    required this.timestamp,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
  });

  /// Returnerar total gyroskopmagnitud
  double get gyroMagnitude =>
      (gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ).abs();

  /// Returnerar total accelerationsmagnitud
  double get accelMagnitude =>
      (accelX * accelX + accelY * accelY + accelZ * accelZ).abs();

  @override
  List<Object?> get props => [
        timestamp,
        gyroX,
        gyroY,
        gyroZ,
        accelX,
        accelY,
        accelZ,
      ];
}
