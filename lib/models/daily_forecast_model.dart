class DailyForecastModel {
  const DailyForecastModel({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });

  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final int weatherCode;

  static List<DailyForecastModel> fromDailyJson(Map<String, dynamic> json) {
    final times = json['time'];
    final maxTemps = json['temperature_2m_max'];
    final minTemps = json['temperature_2m_min'];
    final precipProbs = json['precipitation_probability_max'];
    final weatherCodes = json['weather_code'];

    if (times is! List ||
        maxTemps is! List ||
        minTemps is! List ||
        weatherCodes is! List) {
      throw const FormatException(
        'Data prakiraan harian tidak lengkap atau tidak valid.',
      );
    }

    final count = [
      times.length,
      maxTemps.length,
      minTemps.length,
      weatherCodes.length,
    ].reduce((a, b) => a < b ? a : b);

    final forecasts = <DailyForecastModel>[];
    for (var i = 0; i < count; i++) {
      final rawDate = times[i];
      final rawMax = maxTemps[i];
      final rawMin = minTemps[i];
      final rawCode = weatherCodes[i];
      final rawProb = precipProbs is List && i < precipProbs.length
          ? precipProbs[i]
          : 0;

      if (rawDate is! String ||
          rawMax is! num ||
          rawMin is! num ||
          rawCode is! num) {
        continue;
      }

      final parsedDate = DateTime.tryParse(rawDate);
      if (parsedDate == null) continue;

      forecasts.add(
        DailyForecastModel(
          date: parsedDate,
          temperatureMax: rawMax.toDouble(),
          temperatureMin: rawMin.toDouble(),
          precipitationProbabilityMax: rawProb is num ? rawProb.round() : 0,
          weatherCode: rawCode.toInt(),
        ),
      );
    }

    if (forecasts.isEmpty) {
      throw const FormatException('Prakiraan cuaca 7 hari tidak tersedia.');
    }

    return forecasts;
  }
}
