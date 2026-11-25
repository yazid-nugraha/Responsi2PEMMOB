import 'package:flutter/material.dart';

class WeatherConditionInfo {
  const WeatherConditionInfo({
    required this.description,
    required this.icon,
    required this.color,
  });

  final String description;
  final IconData icon;
  final Color color;
}

class WeatherCodeHelper {
  const WeatherCodeHelper._();

  static WeatherConditionInfo getCondition(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return const WeatherConditionInfo(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFF59E0B),
        );
      case 1:
        return const WeatherConditionInfo(
          description: 'Cerah Berawan',
          icon: Icons.wb_cloudy_rounded,
          color: Color(0xFFF59E0B),
        );
      case 2:
        return const WeatherConditionInfo(
          description: 'Sebagian Berawan',
          icon: Icons.cloud_queue_rounded,
          color: Color(0xFF64748B),
        );
      case 3:
        return const WeatherConditionInfo(
          description: 'Berawan',
          icon: Icons.cloud_rounded,
          color: Color(0xFF64748B),
        );
      case 45:
      case 48:
        return const WeatherConditionInfo(
          description: 'Berkabut',
          icon: Icons.foggy,
          color: Color(0xFF94A3B8),
        );
      case 51:
      case 53:
      case 55:
        return const WeatherConditionInfo(
          description: 'Gerimis',
          icon: Icons.grain_rounded,
          color: Color(0xFF38BDF8),
        );
      case 56:
      case 57:
        return const WeatherConditionInfo(
          description: 'Gerimis Membeku',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF0EA5E9),
        );
      case 61:
      case 63:
      case 65:
        return const WeatherConditionInfo(
          description: 'Hujan',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF2563EB),
        );
      case 66:
      case 67:
        return const WeatherConditionInfo(
          description: 'Hujan Membeku',
          icon: Icons.severe_cold_rounded,
          color: Color(0xFF0284C7),
        );
      case 71:
      case 73:
      case 75:
        return const WeatherConditionInfo(
          description: 'Hujan Salju',
          icon: Icons.cloudy_snowing,
          color: Color(0xFF60A5FA),
        );
      case 77:
        return const WeatherConditionInfo(
          description: 'Butiran Salju',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF93C5FD),
        );
      case 80:
      case 81:
      case 82:
        return const WeatherConditionInfo(
          description: 'Hujan Lokal',
          icon: Icons.umbrella_rounded,
          color: Color(0xFF1D4ED8),
        );
      case 85:
      case 86:
        return const WeatherConditionInfo(
          description: 'Hujan Salju Lokal',
          icon: Icons.snowing,
          color: Color(0xFF3B82F6),
        );
      case 95:
        return const WeatherConditionInfo(
          description: 'Badai Petir',
          icon: Icons.thunderstorm_rounded,
          color: Color(0xFF7C3AED),
        );
      case 96:
      case 99:
        return const WeatherConditionInfo(
          description: 'Badai Petir dengan Hujan Es',
          icon: Icons.bolt_rounded,
          color: Color(0xFF6D28D9),
        );
      default:
        return const WeatherConditionInfo(
          description: 'Kondisi Tidak Diketahui',
          icon: Icons.help_outline_rounded,
          color: Color(0xFF64748B),
        );
    }
  }

  static String getDescription(int weatherCode) =>
      getCondition(weatherCode).description;

  static IconData getIcon(int weatherCode) => getCondition(weatherCode).icon;

  static Color getColor(int weatherCode) => getCondition(weatherCode).color;
}
