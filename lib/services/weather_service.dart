import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/weather_response_model.dart';

class WeatherServiceException implements Exception {
  const WeatherServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherResponseModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = ApiConstants.buildForecastUri(
      latitude: latitude,
      longitude: longitude,
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw WeatherServiceException(
          'Gagal memuat data cuaca (kode HTTP ${response.statusCode}). Silakan coba lagi.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherServiceException(
          'Format respons cuaca dari server tidak valid.',
        );
      }

      return WeatherResponseModel.fromJson(decoded);
    } on TimeoutException {
      throw const WeatherServiceException(
        'Waktu permintaan cuaca habis. Periksa koneksi internet Anda.',
      );
    } on SocketException {
      throw const WeatherServiceException(
        'Tidak ada koneksi internet. Pastikan perangkat terhubung ke jaringan.',
      );
    } on http.ClientException {
      throw const WeatherServiceException(
        'Gagal terhubung ke server Open-Meteo. Periksa koneksi internet Anda.',
      );
    } on FormatException catch (e) {
      throw WeatherServiceException(
        'Data cuaca tidak dapat diproses: ${e.message}',
      );
    } on WeatherServiceException {
      rethrow;
    } catch (_) {
      throw const WeatherServiceException(
        'Terjadi kesalahan yang tidak terduga saat memuat data cuaca.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
