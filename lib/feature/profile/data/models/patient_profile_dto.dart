import '../../../../core/config/env_config.dart';

class PatientProfileDTO {
  final String patientId;
  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final String gender;
  final String birthDate;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool bcgVaccinated;
  final String profilePictureUrl;
  final String nik;
  final String kkNumber;

  PatientProfileDTO({
    required this.patientId,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.address,
    this.latitude,
    this.longitude,
    required this.bcgVaccinated,
    required this.profilePictureUrl,
    required this.nik,
    required this.kkNumber,
  });

  static String _normalizeUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';
    var url = rawUrl;
    if (url.contains('pub-3f528f2c58b34e29ac9a1571c4b14c82.r2.dev')) {
      url = url.replaceAll('pub-3f528f2c58b34e29ac9a1571c4b14c82.r2.dev', 'r2.dev.solusikode.my.id');
    }
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = EnvConfig.apiBaseUrl.endsWith('/')
        ? EnvConfig.apiBaseUrl.substring(0, EnvConfig.apiBaseUrl.length - 1)
        : EnvConfig.apiBaseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }

  factory PatientProfileDTO.fromJson(Map<String, dynamic> json) {
    final rawUrl = (json['profile_picture_url'] ?? '') as String;
    return PatientProfileDTO(
      patientId: (json['patient_id'] ?? '') as String,
      userId: (json['user_id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      gender: (json['gender'] ?? 'L') as String,
      birthDate: (json['birth_date'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bcgVaccinated: (json['bcg_vaccinated'] as bool?) ?? false,
      profilePictureUrl: _normalizeUrl(rawUrl),
      nik: (json['nik'] ?? '') as String,
      kkNumber: (json['kk_number'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'bcg_vaccinated': bcgVaccinated,
      'profile_picture_url': profilePictureUrl,
      'nik': nik,
      'kk_number': kkNumber,
    };
  }
}
