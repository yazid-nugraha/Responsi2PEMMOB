import '../../models/location_model.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'Atmos Weather';
  static const int maxSearchHistory = 10;
  static const Duration searchDebounceDuration = Duration(milliseconds: 450);

  static const String favoritesStorageKey = 'atmos_favorite_locations';
  static const String searchHistoryStorageKey = 'atmos_search_history';
  static const String lastLocationStorageKey = 'atmos_last_selected_location';

  /// Default initial location when the user launches the app for the first time.
  /// Weather data is always fetched live from the Open-Meteo API.
  static const LocationModel defaultLocation = LocationModel(
    id: 1630328,
    name: 'Purwokerto',
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
    latitude: -7.4246,
    longitude: 109.2396,
    timezone: 'Asia/Jakarta',
  );
}
