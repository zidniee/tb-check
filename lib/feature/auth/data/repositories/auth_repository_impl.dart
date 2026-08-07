import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    SecureStorageService? storageService,
  }) : storageService = storageService ?? SecureStorageService();

  @override
  Future<Either<ApiException, AuthResponseDTO>> loginWithGoogle() async {
    try {
      final response = await remoteDataSource.loginWithGoogle();
      await storageService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await storageService.saveUserData(
        userId: response.user.userId,
        role: response.user.role,
        email: response.user.email,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, AuthResponseDTO>> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      await storageService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await storageService.saveUserData(
        userId: response.user.userId,
        role: response.user.role,
        email: response.user.email,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
  }) async {
    try {
      final res = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phoneNumber: phoneNumber,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      await remoteDataSource.verifyEmail(email: email, otp: otp);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> resendOTP({
    required String email,
  }) async {
    try {
      await remoteDataSource.resendOTP(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> logout({bool allDevices = false}) async {
    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await remoteDataSource.logout(refreshToken: refreshToken, allDevices: allDevices);
        } catch (_) {
          // Swallow API logout error so local logout always completes
        }
      }
      await storageService.clearAll();
      return const Right(null);
    } catch (e) {
      await storageService.clearAll();
      return const Right(null);
    }
  }
}
