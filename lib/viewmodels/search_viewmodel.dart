import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/location_model.dart';
import '../services/geocoding_service.dart';
import '../services/local_storage_service.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required this._geocodingService,
    required this._localStorageService,
  });

  final GeocodingService _geocodingService;
  final LocalStorageService _localStorageService;

  String _searchQuery = '';
  List<LocationModel> _searchResults = const [];
  List<LocationModel> _searchHistory = const [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  int _searchVersion = 0;

  String get searchQuery => _searchQuery;
  UnmodifiableListView<LocationModel> get searchResults =>
      UnmodifiableListView(_searchResults);
  UnmodifiableListView<LocationModel> get searchHistory =>
      UnmodifiableListView(_searchHistory);
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;

  Future<void> loadSearchHistory() async {
    _searchHistory = await _localStorageService.getSearchHistory();
    notifyListeners();
  }

  void onQueryChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchVersion++;
      _searchResults = const [];
      _errorMessage = null;
      _isSearching = false;
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _errorMessage = null;
    notifyListeners();

    _debounceTimer = Timer(AppConstants.searchDebounceDuration, () {
      searchLocations(trimmed);
    });
  }

  Future<void> searchLocations(String query) async {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    _searchQuery = query;

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    final currentVersion = ++_searchVersion;
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _geocodingService.searchLocations(trimmed);

      // Prevent stale API responses from overwriting newer queries.
      if (currentVersion != _searchVersion) return;

      _searchResults = results;
      _hasSearched = true;
      _errorMessage = null;
    } on GeocodingException catch (e) {
      if (currentVersion != _searchVersion) return;
      _searchResults = const [];
      _hasSearched = true;
      _errorMessage = e.message;
    } catch (_) {
      if (currentVersion != _searchVersion) return;
      _searchResults = const [];
      _hasSearched = true;
      _errorMessage = 'Gagal mencari lokasi. Silakan coba lagi.';
    } finally {
      if (currentVersion == _searchVersion) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _searchVersion++;
    _searchQuery = '';
    _searchResults = const [];
    _isSearching = false;
    _hasSearched = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addToHistory(LocationModel location) async {
    _searchHistory = await _localStorageService.addSearchHistory(location);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _localStorageService.clearSearchHistory();
    _searchHistory = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
