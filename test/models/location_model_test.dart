import 'package:atmosweather/models/location_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationModel', () {
    test('parses valid Open-Meteo geocoding JSON correctly', () {
      final json = {
        'id': 1630328,
        'name': 'Purwokerto',
        'country': 'Indonesia',
        'admin1': 'Jawa Tengah',
        'latitude': -7.4246,
        'longitude': 109.2396,
        'timezone': 'Asia/Jakarta',
      };

      final location = LocationModel.fromJson(json);

      expect(location.id, 1630328);
      expect(location.name, 'Purwokerto');
      expect(location.country, 'Indonesia');
      expect(location.admin1, 'Jawa Tengah');
      expect(location.latitude, -7.4246);
      expect(location.longitude, 109.2396);
      expect(location.timezone, 'Asia/Jakarta');
      expect(location.subtitle, 'Jawa Tengah, Indonesia');
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'name': 'Singapore',
        'latitude': 1.2897,
        'longitude': 103.8501,
      };

      final location = LocationModel.fromJson(json);

      expect(location.id, isNull);
      expect(location.name, 'Singapore');
      expect(location.country, 'Tidak Diketahui');
      expect(location.admin1, isNull);
      expect(location.subtitle, 'Tidak Diketahui');
    });

    test('serializes and deserializes consistently via toJson/fromJson', () {
      const original = LocationModel(
        id: 1642911,
        name: 'Jakarta',
        country: 'Indonesia',
        admin1: 'DKI Jakarta',
        latitude: -6.2146,
        longitude: 106.8451,
        timezone: 'Asia/Jakarta',
      );

      final restored = LocationModel.fromJson(original.toJson());
      expect(restored, equals(original));
      expect(restored.timezone, original.timezone);
    });

    test('throws FormatException when required fields are missing', () {
      expect(
        () => LocationModel.fromJson({'name': 'Tanpa Koordinat'}),
        throwsFormatException,
      );
      expect(
        () => LocationModel.fromJson({'latitude': -7.4, 'longitude': 109.2}),
        throwsFormatException,
      );
    });
  });
}
