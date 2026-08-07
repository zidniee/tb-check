import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/doctor_profile_dto.dart';
import '../models/patient_profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, dynamic>> getMyProfile() async {
    try {
      final json = await remoteDataSource.getMyProfile();
      if (json.containsKey('patient_id')) {
        return Right(PatientProfileDTO.fromJson(json));
      } else if (json.containsKey('doctor_id')) {
        return Right(DoctorProfileDTO.fromJson(json));
      }
      return Right(PatientProfileDTO.fromJson(json));
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updatePatientProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String birthDate,
    required String address,
    required String nik,
    required String kkNumber,
    bool bcgVaccinated = false,
    File? avatarFile,
  }) async {
    try {
      await remoteDataSource.updatePatientProfile(
        fullName: fullName,
        phone: phone,
        gender: gender,
        birthDate: birthDate,
        address: address,
        nik: nik,
        kkNumber: kkNumber,
        bcgVaccinated: bcgVaccinated,
        avatarFile: avatarFile,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateDoctorProfile({
    required String fullName,
    required String phone,
    required String specialization,
    required String strNumber,
    File? avatarFile,
  }) async {
    try {
      await remoteDataSource.updateDoctorProfile(
        fullName: fullName,
        phone: phone,
        specialization: specialization,
        strNumber: strNumber,
        avatarFile: avatarFile,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await remoteDataSource.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> uploadAvatar(File file) async {
    try {
      final url = await remoteDataSource.uploadAvatar(file);
      return Right(url);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
