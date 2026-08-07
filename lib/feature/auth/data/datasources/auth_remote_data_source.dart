
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/auth_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDTO> loginWithGoogle();
  Future<AuthResponseDTO> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  });
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
  });
  Future<void> verifyEmail({
    required String email,
    required String otp,
  });
  Future<void> resendOTP({
    required String email,
  });
  Future<void> forgotPassword({
    required String email,
  });
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> logout({String? refreshToken, bool allDevices = false});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.apiService,
    required this.googleSignIn,
  });

  @override
  Future<AuthResponseDTO> loginWithGoogle() async {
    await googleSignIn.initialize(
      serverClientId: AuthConstants.googleClientId,
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
    if (googleUser == null) {
      throw Exception('Google Sign-In dibatalkan oleh pengguna.');
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Gagal mendapatkan idToken dari Google.');
    }

    final response = await apiService.loginWithGoogleMobile(idToken);
    return AuthResponseDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDTO> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    final response = await apiService.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        if (deviceId != null) 'device_id': deviceId,
        if (deviceName != null) 'device_name': deviceName,
      },
    );
    return AuthResponseDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
  }) async {
    final response = await apiService.dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone_number': phoneNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    await apiService.dio.post(
      '/auth/verify-email',
      data: {
        'email': email,
        'otp': otp,
      },
    );
  }

  @override
  Future<void> resendOTP({
    required String email,
  }) async {
    await apiService.dio.post(
      '/auth/resend-verification',
      data: {
        'email': email,
      },
    );
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await apiService.dio.post(
      '/auth/forgot-password',
      data: {
        'email': email,
      },
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await apiService.dio.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  @override
  Future<void> logout({String? refreshToken, bool allDevices = false}) async {
    await apiService.dio.post(
      '/auth/logout',
      data: {
        if (refreshToken != null && refreshToken.isNotEmpty) 'refresh_token': refreshToken,
        'all_devices': allDevices,
      },
    );
  }
}
