import 'dart:convert';

import 'package:atmosweather/services/geocoding_service.dart';
import 'package:atmosweather/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GeocodingService (Mock HTTP)', () {
    test('returns parsed locations on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.queryParameters['name'], 'Purwokerto');
        expect(request.url.queryParameters['language'], 'id');

        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 1630328,
                'name': 'Purwokerto',
                'country': 'Indonesia',
                'admin1': 'Jawa Tengah',
                'latitude': -7.4246,
                'longitude': 109.2396,
                'timezone': 'Asia/Jakarta',
              },
            ],
          }),
          200,
        );
      });

      final service = GeocodingService(client: mockClient);
      final results = await service.searchLocations('Purwokerto');

      expect(results, hasLength(1));
      expect(results.first.name, 'Purwokerto');
      expect(results.first.admin1, 'Jawa Tengah');
    });

    test('returns empty list when API omits results key', () async {
      final mockClient = MockClient((_) async => http.Response('{}', 200));
      final service = GeocodingService(client: mockClient);

      final results = await service.searchLocations('KotaTidakAdaXYZ');
      expect(results, isEmpty);
    });

    test('throws GeocodingException on HTTP error', () async {
      final mockClient = MockClient((_) async => http.Response('Error', 500));
      final service = GeocodingService(client: mockClient);

      expect(
        () => service.searchLocations('Jakarta'),
        throwsA(isA<GeocodingException>()),
      );
    });
  });

  group('WeatherService (Mock HTTP)', () {
    test('returns WeatherResponseModel on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.queryParameters['forecast_days'], '7');
        expect(request.url.queryParameters['timezone'], 'auto');

        return http.Response(
          jsonEncode({
            'latitude': -7.4246,
            'longitude': 109.2396,
            'timezone': 'Asia/Jakarta',
            'current': {
              'time': '2026-11-25T13:00',
              'temperature_2m': 28.5,
              'relative_humidity_2m': 76,
              'apparent_temperature': 32.0,
              'precipitation': 0.0,
              'weather_code': 1,
              'wind_speed_10m': 9.4,
            },
            'daily': {
              'time': ['2026-11-25', '2026-11-26'],
              'temperature_2m_max': [31.0, 30.5],
              'temperature_2m_min': [23.0, 22.5],
              'precipitation_probability_max': [40, 60],
              'weather_code': [1, 61],
            },
          }),
          200,
        );
      });

      final service = WeatherService(client: mockClient);
      final weather = await service.fetchWeather(
        latitude: -7.4246,
        longitude: 109.2396,
      );

      expect(weather.current.temperature, 28.5);
      expect(weather.daily, hasLength(2));
      expect(weather.todayPrecipitationProbabilityMax, 40);
    });

    test('throws WeatherServiceException on HTTP error', () async {
      final mockClient = MockClient((_) async => http.Response('Error', 503));
      final service = WeatherService(client: mockClient);

      expect(
        () => service.fetchWeather(latitude: -7.4, longitude: 109.2),
        throwsA(isA<WeatherServiceException>()),
      );
    });
  });
}
