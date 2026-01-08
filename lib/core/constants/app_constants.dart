/// Applikationskonstanter för Water Jump Tracker
class AppConstants {
  // Fysikaliska konstanter
  static const double gravity = 9.82; // m/s² (gravitationskonstant)

  // Sensortröskvärden
  static const double fallDetectionThreshold = 30.0; // grader/sekund
  static const double waterImpactThreshold = 15.0; // m/s² (acceleration)

  // Tidsgränser
  static const int sensorSamplingRate = 100; // Hz
  static const int maxJumpDuration = 10000; // millisekunder
  static const int minJumpDuration = 500; // millisekunder

  // Poängberäkning vikter
  static const double heightWeight = 0.35;
  static const double stabilityWeight = 0.30;
  static const double pulseWeight = 0.20;
  static const double rotationWeight = 0.15;

  // API
  static const String weatherApiBaseUrl = 'https://api.open-meteo.com/v1';

  // GPS-inställningar
  static const double locationAccuracy = 10.0; // meter
  static const int locationTimeout = 30; // sekunder

  // Hive box-namn
  static const String jumpHistoryBox = 'jump_history';
  static const String settingsBox = 'settings';
}
