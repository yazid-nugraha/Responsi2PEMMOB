import 'current_weather_model.dart';
import 'daily_forecast_model.dart';

class WeatherResponseModel {
  const WeatherResponseModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeatherModel current;
  final List<DailyForecastModel> daily;

  int get todayPrecipitationProbabilityMax =>
      daily.isNotEmpty ? daily.first.precipitationProbabilityMax : 0;

  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    final rawLat = json['latitude'];
    final rawLon = json['longitude'];
    final rawTimezone = json['timezone'];
    final rawCurrent = json['current'];
    final rawDaily = json['daily'];

    if (rawLat is! num || rawLon is! num) {
      throw const FormatException('Koordinat pada respons cuaca tidak valid.');
    }
    if (rawCurrent is! Map<String, dynamic>) {
      throw const FormatException(
        'Bagian "current" tidak ditemukan pada respons cuaca.',
      );
    }
    if (rawDaily is! Map<String, dynamic>) {
      throw const FormatException(
        'Bagian "daily" tidak ditemukan pada respons cuaca.',
      );
    }

    return WeatherResponseModel(
      latitude: rawLat.toDouble(),
      longitude: rawLon.toDouble(),
      timezone: rawTimezone is String && rawTimezone.isNotEmpty
          ? rawTimezone
          : 'UTC',
      current: CurrentWeatherModel.fromJson(rawCurrent),
      daily: DailyForecastModel.fromDailyJson(rawDaily),
    );
  }
}
