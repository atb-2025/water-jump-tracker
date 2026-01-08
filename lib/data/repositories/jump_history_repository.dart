import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/jump_data.dart';
import '../models/jump_data_model.dart';

/// Repository för lokal lagring av hopphistorik med Hive
class JumpHistoryRepository {
  Box<JumpDataModel>? _box;

  /// Initialisera Hive och öppna box
  Future<void> initialize() async {
    // Hive.initFlutter() anropas redan i main.dart

    // Registrera adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(JumpDataModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LocationDataModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WeatherDataModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PulseDataModelAdapter());
    }

    _box = await Hive.openBox<JumpDataModel>(AppConstants.jumpHistoryBox);
  }

  /// Spara ett hopp
  Future<void> saveJump(JumpData jump) async {
    if (_box == null) await initialize();
    final model = JumpDataModel.fromEntity(jump);
    await _box!.put(jump.id, model);
  }

  /// Hämta alla hopp (sorterade efter datum, nyast först)
  Future<List<JumpData>> getAllJumps() async {
    if (_box == null) await initialize();
    final models = _box!.values.toList();
    models.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return models.map((m) => m.toEntity()).toList();
  }

  /// Hämta ett specifikt hopp
  Future<JumpData?> getJump(String id) async {
    if (_box == null) await initialize();
    final model = _box!.get(id);
    return model?.toEntity();
  }

  /// Ta bort ett hopp
  Future<void> deleteJump(String id) async {
    if (_box == null) await initialize();
    await _box!.delete(id);
  }

  /// Rensa all historik
  Future<void> clearHistory() async {
    if (_box == null) await initialize();
    await _box!.clear();
  }

  /// Hämta statistik
  Future<JumpStatistics> getStatistics() async {
    final jumps = await getAllJumps();

    if (jumps.isEmpty) {
      return const JumpStatistics(
        totalJumps: 0,
        averageHeight: 0.0,
        maxHeight: 0.0,
        averageScore: 0.0,
        bestScore: 0.0,
      );
    }

    final totalJumps = jumps.length;
    final averageHeight =
        jumps.map((j) => j.height).reduce((a, b) => a + b) / totalJumps;
    final maxHeight =
        jumps.map((j) => j.height).reduce((a, b) => a > b ? a : b);
    final averageScore =
        jumps.map((j) => j.totalScore).reduce((a, b) => a + b) / totalJumps;
    final bestScore =
        jumps.map((j) => j.totalScore).reduce((a, b) => a > b ? a : b);

    return JumpStatistics(
      totalJumps: totalJumps,
      averageHeight: averageHeight,
      maxHeight: maxHeight,
      averageScore: averageScore,
      bestScore: bestScore,
    );
  }
}

/// Statistik för hopp
class JumpStatistics {
  final int totalJumps;
  final double averageHeight;
  final double maxHeight;
  final double averageScore;
  final double bestScore;

  const JumpStatistics({
    required this.totalJumps,
    required this.averageHeight,
    required this.maxHeight,
    required this.averageScore,
    required this.bestScore,
  });
}
