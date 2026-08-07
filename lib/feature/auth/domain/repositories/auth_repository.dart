import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/auth_response_dto.dart';

abstract class AuthRepository {
  Future<Either<ApiException, AuthResponseDTO>> loginWithGoogle();

  Future<Either<ApiException, AuthResponseDTO>> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  });

  Future<Either<ApiException, Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
  });

  Future<Either<ApiException, void>> verifyEmail({
    required String email,
    required String otp,
  });

  Future<Either<ApiException, void>> resendOTP({
    required String email,
  });

  Future<Either<ApiException, void>> forgotPassword({
    required String email,
  });

  Future<Either<ApiException, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<ApiException, void>> logout({bool allDevices = false});
}
