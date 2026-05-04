class ZoneModel {
  final String name;
  final String level;
  final int caseCount;
  final double? latitude;
  final double? longitude;

  const ZoneModel({
    required this.name,
    required this.level,
    required this.caseCount,
    this.latitude,
    this.longitude,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? 'hijau',
      caseCount: json['case_count'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
