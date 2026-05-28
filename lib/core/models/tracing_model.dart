class TracingModel {
  final String id;
  final String? patientId;
  final String? tracingRef;
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final DateTime? visitedAt;
  final DateTime createdAt;

  const TracingModel({
    required this.id,
    this.patientId,
    this.tracingRef,
    this.latitude,
    this.longitude,
    this.placeName,
    this.visitedAt,
    required this.createdAt,
  });

  factory TracingModel.fromJson(Map<String, dynamic> json) {
    return TracingModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String?,
      tracingRef: json['tracing_ref'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeName: json['place_name'] as String?,
      visitedAt: json['visited_at'] != null
          ? DateTime.tryParse(json['visited_at'] as String)
          : null,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'tracing_ref': tracingRef,
      'latitude': latitude,
      'longitude': longitude,
      'place_name': placeName,
      'visited_at': visitedAt?.toIso8601String(),
    };
  }
}
