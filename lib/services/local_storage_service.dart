import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/location_model.dart';

class LocalStorageService {
  LocalStorageService({this._preferences});

  SharedPreferences? _preferences;

  Future<SharedPreferences?> _getPreferences() async {
    if (_preferences != null) {
      return _preferences;
    }
    try {
      _preferences = await SharedPreferences.getInstance();
      return _preferences;
    } catch (_) {
      return null;
    }
  }

  Future<List<LocationModel>> getFavorites() async {
    return _readLocationList(AppConstants.favoritesStorageKey);
  }

  Future<bool> saveFavorites(List<LocationModel> locations) async {
    return _writeLocationList(AppConstants.favoritesStorageKey, locations);
  }

  Future<List<LocationModel>> getSearchHistory() async {
    return _readLocationList(AppConstants.searchHistoryStorageKey);
  }

  Future<bool> saveSearchHistory(List<LocationModel> history) async {
    final trimmed = history.take(AppConstants.maxSearchHistory).toList();
    return _writeLocationList(AppConstants.searchHistoryStorageKey, trimmed);
  }

  Future<List<LocationModel>> addSearchHistory(LocationModel location) async {
    final current = await getSearchHistory();
    final updated = <LocationModel>[
      location,
      ...current.where((item) => item != location),
    ].take(AppConstants.maxSearchHistory).toList();

    await saveSearchHistory(updated);
    return updated;
  }

  Future<bool> clearSearchHistory() async {
    final prefs = await _getPreferences();
    if (prefs == null) return false;
    try {
      return await prefs.remove(AppConstants.searchHistoryStorageKey);
    } catch (_) {
      return false;
    }
  }

  Future<LocationModel?> getLastSelectedLocation() async {
    final prefs = await _getPreferences();
    if (prefs == null) return null;

    final raw = prefs.getString(AppConstants.lastLocationStorageKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return LocationModel.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveLastSelectedLocation(LocationModel location) async {
    final prefs = await _getPreferences();
    if (prefs == null) return false;

    try {
      final encoded = jsonEncode(location.toJson());
      return await prefs.setString(
        AppConstants.lastLocationStorageKey,
        encoded,
      );
    } catch (_) {
      return false;
    }
  }

  Future<List<LocationModel>> _readLocationList(String key) async {
    final prefs = await _getPreferences();
    if (prefs == null) return [];

    final raw = prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final items = <LocationModel>[];
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          try {
            final location = LocationModel.fromJson(entry);
            if (!items.contains(location)) {
              items.add(location);
            }
          } on FormatException {
            // Safely ignore corrupted individual entries.
          }
        }
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<bool> _writeLocationList(
    String key,
    List<LocationModel> locations,
  ) async {
    final prefs = await _getPreferences();
    if (prefs == null) return false;

    try {
      final encoded = jsonEncode(locations.map((e) => e.toJson()).toList());
      return await prefs.setString(key, encoded);
    } catch (_) {
      return false;
    }
  }
}
