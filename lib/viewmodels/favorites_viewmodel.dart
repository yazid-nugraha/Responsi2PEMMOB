import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/local_storage_service.dart';

class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({required this._localStorageService});

  final LocalStorageService _localStorageService;

  List<LocationModel> _favoriteLocations = const [];
  bool _isLoading = false;

  UnmodifiableListView<LocationModel> get favoriteLocations =>
      UnmodifiableListView(_favoriteLocations);
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteLocations = await _localStorageService.getFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(LocationModel location) {
    return _favoriteLocations.contains(location);
  }

  Future<bool> addFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      return false;
    }

    _favoriteLocations = [location, ..._favoriteLocations];
    notifyListeners();

    await _localStorageService.saveFavorites(_favoriteLocations);
    return true;
  }

  Future<bool> removeFavorite(LocationModel location) async {
    if (!isFavorite(location)) {
      return false;
    }

    _favoriteLocations = _favoriteLocations
        .where((item) => item != location)
        .toList();
    notifyListeners();

    await _localStorageService.saveFavorites(_favoriteLocations);
    return true;
  }

  /// Toggles favorite status and returns `true` if now favorited, `false` if removed.
  Future<bool> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      await removeFavorite(location);
      return false;
    } else {
      await addFavorite(location);
      return true;
    }
  }
}
