import 'package:atmosweather/core/constants/app_constants.dart';
import 'package:atmosweather/models/location_model.dart';
import 'package:atmosweather/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const purwokerto = LocationModel(
    id: 1630328,
    name: 'Purwokerto',
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
    latitude: -7.4246,
    longitude: 109.2396,
  );

  const jakarta = LocationModel(
    id: 1642911,
    name: 'Jakarta',
    country: 'Indonesia',
    admin1: 'DKI Jakarta',
    latitude: -6.2146,
    longitude: 106.8451,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService - Favorites', () {
    test('saves and restores favorite locations', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(preferences: prefs);

      await storage.saveFavorites([purwokerto, jakarta]);
      final restored = await storage.getFavorites();

      expect(restored, hasLength(2));
      expect(restored.first, equals(purwokerto));
      expect(restored.last, equals(jakarta));
    });

    test('handles corrupted favorites JSON safely', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.favoritesStorageKey: '{corrupted json!!!',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(preferences: prefs);

      final restored = await storage.getFavorites();
      expect(restored, isEmpty);
    });
  });

  group('LocalStorageService - Search History & Last Location', () {
    test(
      'keeps newest search at top, prevents duplicates, and caps at 10',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorageService(preferences: prefs);

        for (var i = 1; i <= 12; i++) {
          await storage.addSearchHistory(
            LocationModel(
              id: i,
              name: 'Kota $i',
              country: 'Indonesia',
              latitude: -7.0 + i * 0.1,
              longitude: 109.0 + i * 0.1,
            ),
          );
        }

        var history = await storage.getSearchHistory();
        expect(history, hasLength(AppConstants.maxSearchHistory));
        expect(history.first.name, 'Kota 12');

        // Re-adding an existing city should move it to top without duplicating.
        await storage.addSearchHistory(history.last);
        history = await storage.getSearchHistory();
        expect(history, hasLength(AppConstants.maxSearchHistory));
        expect(history.first.name, 'Kota 3');
      },
    );

    test('saves and restores last selected location', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(preferences: prefs);

      await storage.saveLastSelectedLocation(jakarta);
      final restored = await storage.getLastSelectedLocation();

      expect(restored, equals(jakarta));
    });

    test('clears search history', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(preferences: prefs);

      await storage.addSearchHistory(purwokerto);
      expect(await storage.getSearchHistory(), hasLength(1));

      await storage.clearSearchHistory();
      expect(await storage.getSearchHistory(), isEmpty);
    });
  });
}
