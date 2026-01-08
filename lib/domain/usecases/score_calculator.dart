import '../../core/constants/app_constants.dart';
import '../../domain/entities/jump_data.dart';

/// Beräknar totalt poäng för ett hopp baserat på flera faktorer
class ScoreCalculator {
  /// Beräkna totalt poäng (0-100)
  static double calculateTotalScore({
    required double height,
    required double stabilityScore,
    required PulseData pulse,
    required double rotationMagnitude,
  }) {
    // Höjdpoäng (0-100): Normaliserat mot 10 meter som max
    final heightScore = _normalizeHeight(height);

    // Stabilitetspoäng kommer redan som 0-100
    final stability = stabilityScore;

    // Pulspoäng (0-100): Baserat på pulsökning
    final pulseScore = _calculatePulseScore(pulse);

    // Rotationspoäng (0-100): Baserat på total rotation
    final rotationScore = _calculateRotationScore(rotationMagnitude);

    // Viktat genomsnitt
    final totalScore = (heightScore * AppConstants.heightWeight) +
        (stability * AppConstants.stabilityWeight) +
        (pulseScore * AppConstants.pulseWeight) +
        (rotationScore * AppConstants.rotationWeight);

    return totalScore.clamp(0.0, 100.0);
  }

  /// Normalisera höjd till 0-100 skala
  static double _normalizeHeight(double height) {
    // 10 meter = 100 poäng, linjär skalning
    const maxHeight = 10.0;
    return (height / maxHeight * 100.0).clamp(0.0, 100.0);
  }

  /// Beräkna pulspoäng baserat på pulsreaktion
  static double _calculatePulseScore(PulseData pulse) {
    // Högre pulsökning = mer spänning = högre poäng (upp till en viss gräns)
    final pulseIncrease = pulse.maxPulse - pulse.startPulse;

    // Optimal pulsökning är 30-60 slag/min
    if (pulseIncrease >= 30 && pulseIncrease <= 60) {
      return 100.0;
    } else if (pulseIncrease < 30) {
      // Lägre än optimalt
      return (pulseIncrease / 30.0 * 100.0).clamp(0.0, 100.0);
    } else {
      // Högre än optimalt (men inte dåligt)
      final excess = pulseIncrease - 60;
      return (100.0 - excess * 0.5).clamp(50.0, 100.0);
    }
  }

  /// Beräkna rotationspoäng
  static double _calculateRotationScore(double rotationMagnitude) {
    // Måttlig rotation är bra, för mycket eller för lite är sämre
    // Optimal rotation: 180-360 grader (en halv till hel rotation)
    const optimalRotMin = 180.0;
    const optimalRotMax = 360.0;

    if (rotationMagnitude >= optimalRotMin &&
        rotationMagnitude <= optimalRotMax) {
      return 100.0;
    } else if (rotationMagnitude < optimalRotMin) {
      return (rotationMagnitude / optimalRotMin * 100.0).clamp(0.0, 100.0);
    } else {
      // För mycket rotation - poäng minskar
      final excess = rotationMagnitude - optimalRotMax;
      return (100.0 - excess * 0.1).clamp(0.0, 100.0);
    }
  }
}
