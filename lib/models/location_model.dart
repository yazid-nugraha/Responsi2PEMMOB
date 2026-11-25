class LocationModel {
  const LocationModel({
    this.id,
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
    this.timezone,
  });

  final int? id;
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;
  final String? timezone;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'];
    final rawLat = json['latitude'];
    final rawLon = json['longitude'];

    if (rawName is! String || rawName.trim().isEmpty) {
      throw const FormatException('Field "name" tidak valid pada data lokasi.');
    }
    if (rawLat is! num || rawLon is! num) {
      throw const FormatException(
        'Koordinat "latitude" atau "longitude" tidak valid pada data lokasi.',
      );
    }

    final rawCountry = json['country'];
    final rawAdmin1 = json['admin1'];
    final rawTimezone = json['timezone'];
    final rawId = json['id'];

    return LocationModel(
      id: rawId is num ? rawId.toInt() : null,
      name: rawName.trim(),
      country: rawCountry is String && rawCountry.trim().isNotEmpty
          ? rawCountry.trim()
          : 'Tidak Diketahui',
      admin1: rawAdmin1 is String && rawAdmin1.trim().isNotEmpty
          ? rawAdmin1.trim()
          : null,
      latitude: rawLat.toDouble(),
      longitude: rawLon.toDouble(),
      timezone: rawTimezone is String && rawTimezone.trim().isNotEmpty
          ? rawTimezone.trim()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  /// Formatted subtitle showing administrative region and country.
  String get subtitle {
    if (admin1 != null &&
        admin1!.isNotEmpty &&
        admin1!.toLowerCase() != name.toLowerCase()) {
      return '$admin1, $country';
    }
    return country;
  }

  /// Stable key used to identify duplicate locations across API and storage.
  String get uniqueKey {
    if (id != null) {
      return 'id_$id';
    }
    return '${name.toLowerCase()}_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LocationModel) return false;
    if (id != null && other.id != null) {
      return id == other.id;
    }
    return name.toLowerCase() == other.name.toLowerCase() &&
        (latitude - other.latitude).abs() < 0.01 &&
        (longitude - other.longitude).abs() < 0.01;
  }

  @override
  int get hashCode => id != null
      ? id.hashCode
      : Object.hash(
          name.toLowerCase(),
          latitude.toStringAsFixed(2),
          longitude.toStringAsFixed(2),
        );

  @override
  String toString() =>
      'LocationModel($name, $subtitle [$latitude, $longitude])';
}
