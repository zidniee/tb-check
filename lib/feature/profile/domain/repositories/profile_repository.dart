import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';

abstract class ProfileRepository {
  Future<Either<ApiException, dynamic>> getMyProfile(); // returns PatientProfileDTO or DoctorProfileDTO
  Future<Either<ApiException, void>> updatePatientProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String birthDate,
    required String address,
    required String nik,
    required String kkNumber,
    bool bcgVaccinated,
    File? avatarFile,
  });
  Future<Either<ApiException, void>> updateDoctorProfile({
    required String fullName,
    required String phone,
    required String specialization,
    required String strNumber,
    File? avatarFile,
  });
  Future<Either<ApiException, void>> updateLocation({
    required double latitude,
    required double longitude,
  });
  Future<Either<ApiException, String>> uploadAvatar(File file);
}
