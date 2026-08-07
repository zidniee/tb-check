import '../../../../core/config/env_config.dart';

class DoctorProfileDTO {
  final String doctorId;
  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final String specialization;
  final String strNumber;
  final String profilePictureUrl;
  final bool isActive;

  DoctorProfileDTO({
    required this.doctorId,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.specialization,
    required this.strNumber,
    required this.profilePictureUrl,
    required this.isActive,
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

  factory DoctorProfileDTO.fromJson(Map<String, dynamic> json) {
    final rawUrl = (json['profile_picture_url'] ?? '') as String;
    return DoctorProfileDTO(
      doctorId: (json['doctor_id'] ?? '') as String,
      userId: (json['user_id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      specialization: (json['specialization'] ?? '') as String,
      strNumber: (json['str_number'] ?? '') as String,
      profilePictureUrl: _normalizeUrl(rawUrl),
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'specialization': specialization,
      'str_number': strNumber,
      'profile_picture_url': profilePictureUrl,
      'is_active': isActive,
    };
  }
}
