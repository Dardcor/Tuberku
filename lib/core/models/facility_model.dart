class FacilityModel {
  final String id;
  final String name;
  final String type;
  final String? address;
  final double latitude;
  final double longitude;
  final String? phone;
  final Map<String, dynamic>? openingHours;
  final DateTime? updatedAt;
  double? distanceKm;

  FacilityModel({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.openingHours,
    this.updatedAt,
    this.distanceKm,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      phone: json['phone'] as String?,
      openingHours: json['opening_hours'] as Map<String, dynamic>?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  String get formattedDistance {
    if (distanceKm == null) return '-';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toInt()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }
}
