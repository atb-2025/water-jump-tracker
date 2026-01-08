import 'package:equatable/equatable.dart';

/// Entitet som representerar ett komplett vattenhopp med alla mätningar
class JumpData extends Equatable {
  final String id;
  final DateTime timestamp;
  final double fallTime; // sekunder
  final double height; // meter
  final double velocity; // m/s
  final double rotationX; // grader
  final double rotationY; // grader
  final double rotationZ; // grader
  final double stabilityScore; // 0-100
  final LocationData location;
  final WeatherData weather;
  final PulseData pulse;
  final double totalScore; // 0-100

  const JumpData({
    required this.id,
    required this.timestamp,
    required this.fallTime,
    required this.height,
    required this.velocity,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
    required this.stabilityScore,
    required this.location,
    required this.weather,
    required this.pulse,
    required this.totalScore,
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        fallTime,
        height,
        velocity,
        rotationX,
        rotationY,
        rotationZ,
        stabilityScore,
        location,
        weather,
        pulse,
        totalScore,
      ];
}

/// Entitet för platsdata
class LocationData extends Equatable {
  final double latitude;
  final double longitude;
  final double altitude; // höjd över havet

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  @override
  List<Object?> get props => [latitude, longitude, altitude];
}

/// Entitet för väderdata
class WeatherData extends Equatable {
  final double temperature; // Celsius
  final String condition; // t.ex. "Sunny", "Cloudy"
  final double windSpeed; // m/s

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.windSpeed,
  });

  @override
  List<Object?> get props => [temperature, condition, windSpeed];
}

/// Entitet för pulsdata
class PulseData extends Equatable {
  final int startPulse; // slag/min
  final int maxPulse; // slag/min
  final int endPulse; // slag/min

  const PulseData({
    required this.startPulse,
    required this.maxPulse,
    required this.endPulse,
  });

  @override
  List<Object?> get props => [startPulse, maxPulse, endPulse];
}
