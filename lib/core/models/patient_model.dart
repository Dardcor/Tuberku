class PatientModel {
  final String id;
  final String? profileId;
  final String? fullName;
  final String? nik;
  final String? phone;
  final String? facilityName;
  final String? district;
  final String? activationCode;
  final String? address;
  final double? domicileLat;
  final double? domicileLng;
  final DateTime? diagnosisDate;
  final String? tbType;
  final String? zone;
  final bool isActive;
  final bool gpsConsent;
  final DateTime createdAt;

  const PatientModel({
    required this.id,
    this.profileId,
    this.fullName,
    this.nik,
    this.phone,
    this.facilityName,
    this.district,
    this.activationCode,
    this.address,
    this.domicileLat,
    this.domicileLng,
    this.diagnosisDate,
    this.tbType,
    this.zone,
    this.isActive = true,
    this.gpsConsent = false,
    required this.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String?,
      fullName: json['full_name'] as String?,
      nik: json['nik'] as String?,
      phone: json['phone'] as String?,
      facilityName: json['facility_name'] as String?,
      district: json['district'] as String?,
      activationCode: json['activation_code'] as String?,
      address: json['address'] as String?,
      domicileLat: (json['domicile_lat'] as num?)?.toDouble(),
      domicileLng: (json['domicile_lng'] as num?)?.toDouble(),
      diagnosisDate: json['diagnosis_date'] != null
          ? DateTime.parse(json['diagnosis_date'] as String)
          : null,
      tbType: json['tb_type'] as String?,
      zone: json['zone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      gpsConsent: json['gps_consent'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'full_name': fullName,
      'nik': nik,
      'phone': phone,
      'facility_name': facilityName,
      'district': district,
      'activation_code': activationCode,
      'address': address,
      'domicile_lat': domicileLat,
      'domicile_lng': domicileLng,
      'diagnosis_date': diagnosisDate?.toIso8601String(),
      'tb_type': tbType,
      'zone': zone,
      'is_active': isActive,
      'gps_consent': gpsConsent,
    };
  }
}
