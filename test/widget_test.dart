import 'dart:convert';

import 'package:atmosweather/app.dart';
import 'package:atmosweather/services/geocoding_service.dart';
import 'package:atmosweather/services/local_storage_service.dart';
import 'package:atmosweather/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'AtmosWeatherApp renders weather data and navigates across tabs',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockClient = MockClient((request) async {
        if (request.url.host == 'api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'latitude': -7.4246,
              'longitude': 109.2396,
              'timezone': 'Asia/Jakarta',
              'current': {
                'time': '2026-11-25T13:00',
                'temperature_2m': 29.0,
                'relative_humidity_2m': 75,
                'apparent_temperature': 32.5,
                'precipitation': 0.0,
                'weather_code': 1,
                'wind_speed_10m': 10.2,
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
                'temperature_2m_max': [
                  31.0,
                  30.0,
                  29.5,
                  31.2,
                  32.0,
                  30.4,
                  29.9,
                ],
                'temperature_2m_min': [
                  23.0,
                  22.8,
                  22.5,
                  23.1,
                  23.4,
                  22.9,
                  22.7,
                ],
                'precipitation_probability_max': [45, 60, 75, 30, 20, 50, 40],
                'weather_code': [1, 61, 80, 0, 2, 3, 95],
              },
            }),
            200,
          );
        }
        return http.Response(jsonEncode({'results': []}), 200);
      });

      await tester.pumpWidget(
        AtmosWeatherApp(
          weatherService: WeatherService(client: mockClient),
          geocodingService: GeocodingService(client: mockClient),
          localStorageService: LocalStorageService(preferences: prefs),
        ),
      );

      await tester.pumpAndSettle();

      // Home screen displays location and fetched temperature.
      expect(find.text('Atmos Weather'), findsOneWidget);
      expect(find.text('Purwokerto'), findsOneWidget);
      expect(find.text('29°C'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Prakiraan 7 Hari'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Prakiraan 7 Hari'), findsOneWidget);

      // Navigate to Search tab.
      await tester.tap(find.text('Cari'));
      await tester.pumpAndSettle();
      expect(find.text('Cari Lokasi'), findsOneWidget);

      // Navigate to Favorites tab (empty state initially).
      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();
      expect(find.text('Belum Ada Lokasi Favorit'), findsOneWidget);

      // Navigate back to Home and tap favorite button.
      await tester.tap(find.text('Cuaca'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Simpan ke favorit'));
      await tester.pumpAndSettle();

      // Verify favorite now appears in Favorites tab.
      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();
      expect(find.text('Purwokerto'), findsWidgets);
    },
  );
}
