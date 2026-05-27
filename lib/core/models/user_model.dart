class UserModel {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String phone;
  final String? facilityName;
  final String? nip;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.role,
    required this.fullName,
    this.email = '',
    required this.phone,
    this.facilityName,
    this.nip,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      facilityName: json['facility_name']?.toString(),
      nip: json['nip']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'facility_name': facilityName,
      'nip': nip,
    };
  }
}
