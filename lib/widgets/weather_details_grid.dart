import 'package:flutter/material.dart';

import '../models/current_weather_model.dart';
import '../models/daily_forecast_model.dart';

class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({
    super.key,
    required this.currentWeather,
    required this.todayPrecipitationProbabilityMax,
    this.todayForecast,
  });

  final CurrentWeatherModel currentWeather;
  final int todayPrecipitationProbabilityMax;
  final DailyForecastModel? todayForecast;

  @override
  Widget build(BuildContext context) {
    final items = <_WeatherDetailItem>[
      _WeatherDetailItem(
        icon: Icons.thermostat_rounded,
        label: 'Terasa Seperti',
        value: '${currentWeather.apparentTemperature.toStringAsFixed(1)}°C',
      ),
      _WeatherDetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Kelembapan',
        value: '${currentWeather.relativeHumidity}%',
      ),
      _WeatherDetailItem(
        icon: Icons.air_rounded,
        label: 'Kecepatan Angin',
        value: '${currentWeather.windSpeed.toStringAsFixed(1)} km/h',
      ),
      _WeatherDetailItem(
        icon: Icons.grain_rounded,
        label: 'Presipitasi',
        value: '${currentWeather.precipitation.toStringAsFixed(1)} mm',
      ),
      _WeatherDetailItem(
        icon: Icons.umbrella_rounded,
        label: 'Peluang Hujan Maks.',
        value: '$todayPrecipitationProbabilityMax%',
      ),
      if (todayForecast != null)
        _WeatherDetailItem(
          icon: Icons.device_thermostat_rounded,
          label: 'Suhu Hari Ini',
          value:
              '${todayForecast!.temperatureMax.round()}° / ${todayForecast!.temperatureMin.round()}°',
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
        final spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _WeatherDetailTile(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _WeatherDetailItem {
  const _WeatherDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _WeatherDetailTile extends StatelessWidget {
  const _WeatherDetailTile({required this.item});

  final _WeatherDetailItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
