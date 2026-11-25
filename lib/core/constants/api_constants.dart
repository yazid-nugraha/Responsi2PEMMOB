class ApiConstants {
  const ApiConstants._();

  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  static const Duration requestTimeout = Duration(seconds: 15);
  static const int searchResultCount = 10;
  static const String searchLanguage = 'id';
  static const String responseFormat = 'json';
  static const int forecastDays = 7;

  static const String currentWeatherVariables =
      'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m';

  static const String dailyWeatherVariables =
      'temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code';

  static Uri buildGeocodingUri(String query) {
    return Uri.parse(geocodingBaseUrl).replace(
      queryParameters: {
        'name': query.trim(),
        'count': searchResultCount.toString(),
        'language': searchLanguage,
        'format': responseFormat,
      },
    );
  }

  static Uri buildForecastUri({
    required double latitude,
    required double longitude,
  }) {
    return Uri.parse(weatherBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': currentWeatherVariables,
        'daily': dailyWeatherVariables,
        'timezone': 'auto',
        'forecast_days': forecastDays.toString(),
      },
    );
  }
}
