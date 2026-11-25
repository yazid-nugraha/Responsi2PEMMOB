import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static const List<String> _indonesianDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _indonesianMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _indonesianShortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Formats a date as Indonesian full date, e.g. "Rabu, 25 November 2026".
  static String formatFullDate(DateTime date) {
    final dayName = _indonesianDays[date.weekday - 1];
    final monthName = _indonesianMonths[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  /// Formats a forecast date as "Hari Ini", "Besok", or Indonesian weekday name.
  static String formatForecastDay(DateTime date, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Hari Ini';
    }
    if (difference == 1) {
      return 'Besok';
    }
    return _indonesianDays[date.weekday - 1];
  }

  /// Formats a date as short Indonesian day & month, e.g. "25 Nov".
  static String formatShortDate(DateTime date) {
    final shortMonth = _indonesianShortMonths[date.month - 1];
    return '${date.day} $shortMonth';
  }

  /// Formats time in 24-hour format using intl, e.g. "14:30".
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
