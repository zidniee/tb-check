class HospitalDTO {
  final String hospitalId;
  final String hospitalName;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String? website;
  final String? logoUrl;
  final bool isActive;

  HospitalDTO({
    required this.hospitalId,
    required this.hospitalName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    this.website,
    this.logoUrl,
    required this.isActive,
  });

  factory HospitalDTO.fromJson(Map<String, dynamic> json) {
    return HospitalDTO(
      hospitalId: (json['hospital_id'] ?? '') as String,
      hospitalName: (json['hospital_name'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: (json['phone'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospital_id': hospitalId,
      'hospital_name': hospitalName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_url': logoUrl,
      'is_active': isActive,
    };
  }
}
