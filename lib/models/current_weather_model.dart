class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.time,
  });

  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final DateTime time;

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    final temp = json['temperature_2m'];
    final humidity = json['relative_humidity_2m'];
    final feelsLike = json['apparent_temperature'];
    final precip = json['precipitation'];
    final code = json['weather_code'];
    final wind = json['wind_speed_10m'];
    final rawTime = json['time'];

    if (temp is! num ||
        humidity is! num ||
        feelsLike is! num ||
        precip is! num ||
        code is! num ||
        wind is! num) {
      throw const FormatException(
        'Data cuaca saat ini tidak lengkap atau tidak valid.',
      );
    }

    final parsedTime = rawTime is String
        ? DateTime.tryParse(rawTime) ?? DateTime.now()
        : DateTime.now();

    return CurrentWeatherModel(
      temperature: temp.toDouble(),
      relativeHumidity: humidity.round(),
      apparentTemperature: feelsLike.toDouble(),
      precipitation: precip.toDouble(),
      weatherCode: code.toInt(),
      windSpeed: wind.toDouble(),
      time: parsedTime,
    );
  }
}
