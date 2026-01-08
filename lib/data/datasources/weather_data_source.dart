import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/jump_data.dart';

/// Data source för väderdata från Open-Meteo API
class WeatherDataSource {
  final Dio _dio;

  WeatherDataSource({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConstants.weatherApiBaseUrl));

  /// Hämta aktuellt väder för en position
  Future<WeatherData> getCurrentWeather(
      double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': 'temperature_2m,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final current = data['current'];

        return WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          condition: _weatherCodeToCondition(current['weather_code'] as int),
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        );
      } else {
        throw Exception('Kunde inte hämta väderdata');
      }
    } catch (e) {
      // Vid fel, returnera standardvärden
      return const WeatherData(
        temperature: 20.0,
        condition: 'Okänt',
        windSpeed: 0.0,
      );
    }
  }

  /// Konvertera WMO-väderkod till läsbar beskrivning
  String _weatherCodeToCondition(int code) {
    switch (code) {
      case 0:
        return 'Klart';
      case 1:
      case 2:
      case 3:
        return 'Lätt molnigt';
      case 45:
      case 48:
        return 'Dimma';
      case 51:
      case 53:
      case 55:
        return 'Duggregn';
      case 61:
      case 63:
      case 65:
        return 'Regn';
      case 71:
      case 73:
      case 75:
        return 'Snö';
      case 80:
      case 81:
      case 82:
        return 'Regnskurar';
      case 95:
      case 96:
      case 99:
        return 'Åska';
      default:
        return 'Okänt';
    }
  }
}
