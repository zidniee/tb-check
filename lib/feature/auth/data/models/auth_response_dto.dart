import 'user_dto.dart';

class AuthResponseDTO {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final UserDTO user;

  AuthResponseDTO({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.user,
  });

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      accessToken: (json['access_token'] ?? '') as String,
      refreshToken: (json['refresh_token'] ?? '') as String,
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 900,
      refreshExpiresIn: (json['refresh_expires_in'] as num?)?.toInt() ?? 604800,
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'refresh_expires_in': refreshExpiresIn,
      'user': user.toJson(),
    };
  }
}
