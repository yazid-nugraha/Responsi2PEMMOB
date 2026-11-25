import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/location_model.dart';

class GeocodingException implements Exception {
  const GeocodingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final uri = ApiConstants.buildGeocodingUri(trimmedQuery);

    try {
      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw GeocodingException(
          'Gagal mencari lokasi (kode HTTP ${response.statusCode}). Silakan coba lagi.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const GeocodingException(
          'Format respons pencarian lokasi tidak valid.',
        );
      }

      final results = decoded['results'];
      if (results == null) {
        return [];
      }
      if (results is! List) {
        throw const GeocodingException(
          'Format daftar hasil pencarian tidak valid.',
        );
      }

      final locations = <LocationModel>[];
      for (final item in results) {
        if (item is Map<String, dynamic>) {
          try {
            locations.add(LocationModel.fromJson(item));
          } on FormatException {
            // Skip malformed entry while keeping valid results.
          }
        }
      }
      return locations;
    } on TimeoutException {
      throw const GeocodingException(
        'Waktu permintaan pencarian habis. Periksa koneksi internet Anda.',
      );
    } on SocketException {
      throw const GeocodingException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const GeocodingException(
        'Gagal terhubung ke server pencarian lokasi. Periksa koneksi Anda.',
      );
    } on FormatException {
      throw const GeocodingException('Gagal membaca data lokasi dari server.');
    } on GeocodingException {
      rethrow;
    } catch (_) {
      throw const GeocodingException(
        'Terjadi kesalahan saat mencari lokasi. Silakan coba lagi.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
