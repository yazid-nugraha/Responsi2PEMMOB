import 'package:atmosweather/models/weather_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherResponseModel', () {
    test('parses valid Open-Meteo forecast JSON correctly', () {
      final json = {
        'latitude': -7.4246,
        'longitude': 109.2396,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-25T13:00',
          'temperature_2m': 29.4,
          'relative_humidity_2m': 74,
          'apparent_temperature': 33.1,
          'precipitation': 0.2,
          'weather_code': 2,
          'wind_speed_10m': 11.5,
        },
        'daily': {
          'time': [
            '2026-11-25',
            '2026-11-26',
            '2026-11-27',
            '2026-11-28',
            '2026-11-29',
            '2026-11-30',
            '2026-12-01',
          ],
          'temperature_2m_max': [31.2, 30.8, 29.5, 31.0, 32.1, 30.0, 29.8],
          'temperature_2m_min': [23.4, 23.0, 22.8, 23.1, 23.5, 22.9, 22.7],
          'precipitation_probability_max': [65, 80, 90, 45, 30, 70, 55],
          'weather_code': [2, 61, 80, 1, 0, 95, 3],
        },
      };

      final response = WeatherResponseModel.fromJson(json);

      expect(response.latitude, -7.4246);
      expect(response.longitude, 109.2396);
      expect(response.timezone, 'Asia/Jakarta');

      expect(response.current.temperature, 29.4);
      expect(response.current.relativeHumidity, 74);
      expect(response.current.apparentTemperature, 33.1);
      expect(response.current.precipitation, 0.2);
      expect(response.current.weatherCode, 2);
      expect(response.current.windSpeed, 11.5);

      expect(response.daily, hasLength(7));
      expect(response.todayPrecipitationProbabilityMax, 65);
      expect(response.daily.first.temperatureMax, 31.2);
      expect(response.daily.first.temperatureMin, 23.4);
      expect(response.daily.last.weatherCode, 3);
    });

    test('throws FormatException when current or daily section is missing', () {
      expect(
        () => WeatherResponseModel.fromJson({
          'latitude': -7.4,
          'longitude': 109.2,
        }),
        throwsFormatException,
      );
    });
  });
}
