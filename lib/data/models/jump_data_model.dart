import 'package:hive/hive.dart';
import '../../domain/entities/jump_data.dart';

part 'jump_data_model.g.dart';

/// Hive-modell för att spara JumpData lokalt
@HiveType(typeId: 0)
class JumpDataModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final double fallTime;

  @HiveField(3)
  final double height;

  @HiveField(4)
  final double velocity;

  @HiveField(5)
  final double rotationX;

  @HiveField(6)
  final double rotationY;

  @HiveField(7)
  final double rotationZ;

  @HiveField(8)
  final double stabilityScore;

  @HiveField(9)
  final LocationDataModel location;

  @HiveField(10)
  final WeatherDataModel weather;

  @HiveField(11)
  final PulseDataModel pulse;

  @HiveField(12)
  final double totalScore;

  JumpDataModel({
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

  /// Konvertera från entitet till modell
  factory JumpDataModel.fromEntity(JumpData entity) {
    return JumpDataModel(
      id: entity.id,
      timestamp: entity.timestamp,
      fallTime: entity.fallTime,
      height: entity.height,
      velocity: entity.velocity,
      rotationX: entity.rotationX,
      rotationY: entity.rotationY,
      rotationZ: entity.rotationZ,
      stabilityScore: entity.stabilityScore,
      location: LocationDataModel.fromEntity(entity.location),
      weather: WeatherDataModel.fromEntity(entity.weather),
      pulse: PulseDataModel.fromEntity(entity.pulse),
      totalScore: entity.totalScore,
    );
  }

  /// Konvertera från modell till entitet
  JumpData toEntity() {
    return JumpData(
      id: id,
      timestamp: timestamp,
      fallTime: fallTime,
      height: height,
      velocity: velocity,
      rotationX: rotationX,
      rotationY: rotationY,
      rotationZ: rotationZ,
      stabilityScore: stabilityScore,
      location: location.toEntity(),
      weather: weather.toEntity(),
      pulse: pulse.toEntity(),
      totalScore: totalScore,
    );
  }
}

@HiveType(typeId: 1)
class LocationDataModel {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double altitude;

  LocationDataModel({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  factory LocationDataModel.fromEntity(LocationData entity) {
    return LocationDataModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      altitude: entity.altitude,
    );
  }

  LocationData toEntity() {
    return LocationData(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
    );
  }
}

@HiveType(typeId: 2)
class WeatherDataModel {
  @HiveField(0)
  final double temperature;

  @HiveField(1)
  final String condition;

  @HiveField(2)
  final double windSpeed;

  WeatherDataModel({
    required this.temperature,
    required this.condition,
    required this.windSpeed,
  });

  factory WeatherDataModel.fromEntity(WeatherData entity) {
    return WeatherDataModel(
      temperature: entity.temperature,
      condition: entity.condition,
      windSpeed: entity.windSpeed,
    );
  }

  WeatherData toEntity() {
    return WeatherData(
      temperature: temperature,
      condition: condition,
      windSpeed: windSpeed,
    );
  }
}

@HiveType(typeId: 3)
class PulseDataModel {
  @HiveField(0)
  final int startPulse;

  @HiveField(1)
  final int maxPulse;

  @HiveField(2)
  final int endPulse;

  PulseDataModel({
    required this.startPulse,
    required this.maxPulse,
    required this.endPulse,
  });

  factory PulseDataModel.fromEntity(PulseData entity) {
    return PulseDataModel(
      startPulse: entity.startPulse,
      maxPulse: entity.maxPulse,
      endPulse: entity.endPulse,
    );
  }

  PulseData toEntity() {
    return PulseData(
      startPulse: startPulse,
      maxPulse: maxPulse,
      endPulse: endPulse,
    );
  }
}
