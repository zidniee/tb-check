import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserEmail = 'user_email';
  static const String _keyProfileData = 'profile_data';
  static const String _keyLocalAvatarPath = 'local_avatar_path';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserData({
    required String userId,
    required String role,
    String? email,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserRole, value: role);
    if (email != null && email.isNotEmpty) {
      await _storage.write(key: _keyUserEmail, value: email);
    }
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  Future<void> saveProfileData(String jsonString) async {
    await _storage.write(key: _keyProfileData, value: jsonString);
  }

  Future<String?> getProfileData() async {
    return await _storage.read(key: _keyProfileData);
  }

  Future<void> saveLocalAvatarPath(String path) async {
    await _storage.write(key: _keyLocalAvatarPath, value: path);
  }

  Future<String?> getLocalAvatarPath() async {
    return await _storage.read(key: _keyLocalAvatarPath);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
