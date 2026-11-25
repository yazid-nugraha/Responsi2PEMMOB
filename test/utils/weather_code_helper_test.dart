import 'package:atmosweather/core/utils/weather_code_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherCodeHelper', () {
    test('maps all required WMO codes to Indonesian descriptions', () {
      expect(WeatherCodeHelper.getDescription(0), 'Cerah');
      expect(WeatherCodeHelper.getDescription(1), 'Cerah Berawan');
      expect(WeatherCodeHelper.getDescription(2), 'Sebagian Berawan');
      expect(WeatherCodeHelper.getDescription(3), 'Berawan');
      expect(WeatherCodeHelper.getDescription(45), 'Berkabut');
      expect(WeatherCodeHelper.getDescription(48), 'Berkabut');
      expect(WeatherCodeHelper.getDescription(51), 'Gerimis');
      expect(WeatherCodeHelper.getDescription(53), 'Gerimis');
      expect(WeatherCodeHelper.getDescription(55), 'Gerimis');
      expect(WeatherCodeHelper.getDescription(56), 'Gerimis Membeku');
      expect(WeatherCodeHelper.getDescription(57), 'Gerimis Membeku');
      expect(WeatherCodeHelper.getDescription(61), 'Hujan');
      expect(WeatherCodeHelper.getDescription(63), 'Hujan');
      expect(WeatherCodeHelper.getDescription(65), 'Hujan');
      expect(WeatherCodeHelper.getDescription(66), 'Hujan Membeku');
      expect(WeatherCodeHelper.getDescription(67), 'Hujan Membeku');
      expect(WeatherCodeHelper.getDescription(71), 'Hujan Salju');
      expect(WeatherCodeHelper.getDescription(73), 'Hujan Salju');
      expect(WeatherCodeHelper.getDescription(75), 'Hujan Salju');
      expect(WeatherCodeHelper.getDescription(77), 'Butiran Salju');
      expect(WeatherCodeHelper.getDescription(80), 'Hujan Lokal');
      expect(WeatherCodeHelper.getDescription(81), 'Hujan Lokal');
      expect(WeatherCodeHelper.getDescription(82), 'Hujan Lokal');
      expect(WeatherCodeHelper.getDescription(85), 'Hujan Salju Lokal');
      expect(WeatherCodeHelper.getDescription(86), 'Hujan Salju Lokal');
      expect(WeatherCodeHelper.getDescription(95), 'Badai Petir');
      expect(
        WeatherCodeHelper.getDescription(96),
        'Badai Petir dengan Hujan Es',
      );
      expect(
        WeatherCodeHelper.getDescription(99),
        'Badai Petir dengan Hujan Es',
      );
    });

    test('returns fallback condition for unknown weather code', () {
      final fallback = WeatherCodeHelper.getCondition(999);
      expect(fallback.description, 'Kondisi Tidak Diketahui');
      expect(fallback.icon, Icons.help_outline_rounded);
    });
  });
}
