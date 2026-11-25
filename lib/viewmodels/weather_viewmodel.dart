import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/current_weather_model.dart';
import '../models/daily_forecast_model.dart';
import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_service.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    required this._weatherService,
    required this._localStorageService,
  });

  final WeatherService _weatherService;
  final LocalStorageService _localStorageService;

  LocationModel? _selectedLocation;
  CurrentWeatherModel? _currentWeather;
  List<DailyForecastModel> _dailyForecast = const [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  int _requestVersion = 0;

  LocationModel? get selectedLocation => _selectedLocation;
  CurrentWeatherModel? get currentWeather => _currentWeather;
  UnmodifiableListView<DailyForecastModel> get dailyForecast =>
      UnmodifiableListView(_dailyForecast);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  bool get hasWeatherData => _currentWeather != null;

  int get todayPrecipitationProbabilityMax => _dailyForecast.isNotEmpty
      ? _dailyForecast.first.precipitationProbabilityMax
      : 0;

  Future<void> initialize() async {
    final savedLocation = await _localStorageService.getLastSelectedLocation();
    final initialLocation = savedLocation ?? AppConstants.defaultLocation;
    _selectedLocation = initialLocation;
    await loadWeather(initialLocation);
  }

  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _errorMessage = null;
    notifyListeners();

    await _localStorageService.saveLastSelectedLocation(location);
    await loadWeather(location);
  }

  Future<void> loadWeather(LocationModel location) async {
    final currentVersion = ++_requestVersion;
    _selectedLocation = location;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _weatherService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      // Ignore stale response if a newer location request was started.
      if (currentVersion != _requestVersion) return;

      _currentWeather = response.current;
      _dailyForecast = response.daily;
      _lastUpdated = DateTime.now();
      _errorMessage = null;
    } on WeatherServiceException catch (e) {
      if (currentVersion != _requestVersion) return;
      _errorMessage = e.message;
    } catch (_) {
      if (currentVersion != _requestVersion) return;
      _errorMessage = 'Gagal memuat informasi cuaca. Silakan coba lagi.';
    } finally {
      if (currentVersion == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshWeather() async {
    final target = _selectedLocation ?? AppConstants.defaultLocation;
    await loadWeather(target);
  }
}
