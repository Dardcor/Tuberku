<<<<<<< HEAD
=======
<<<<<<< HEAD
class UserModel {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String phone;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.role,
    required this.fullName,
    this.email = '',
    required this.phone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
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
    };
  }
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
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
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
