import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getMyProfile();
  Future<void> updatePatientProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String birthDate,
    required String address,
    required String nik,
    required String kkNumber,
    bool bcgVaccinated = false,
    File? avatarFile,
  });
  Future<void> updateDoctorProfile({
    required String fullName,
    required String phone,
    required String specialization,
    required String strNumber,
    File? avatarFile,
  });
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  });
  Future<String> uploadAvatar(File file);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await apiService.dio.get('/api/v1/profile');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> updatePatientProfile({
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
    final formDataMap = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
      'address': address,
      'nik': nik,
      'kk_number': kkNumber,
      'bcg_vaccinated': bcgVaccinated,
    };

    if (avatarFile != null) {
      formDataMap['file'] = await MultipartFile.fromFile(
        avatarFile.path,
        filename: avatarFile.path.split(RegExp(r'[/\\]')).last,
      );
    }

    final formData = FormData.fromMap(formDataMap);
    await apiService.dio.put('/api/v1/profile/patient', data: formData);
  }

  @override
  Future<void> updateDoctorProfile({
    required String fullName,
    required String phone,
    required String specialization,
    required String strNumber,
    File? avatarFile,
  }) async {
    final formDataMap = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'specialization': specialization,
      'str_number': strNumber,
    };

    if (avatarFile != null) {
      formDataMap['file'] = await MultipartFile.fromFile(
        avatarFile.path,
        filename: avatarFile.path.split(RegExp(r'[/\\]')).last,
      );
    }

    final formData = FormData.fromMap(formDataMap);
    await apiService.dio.put('/api/v1/profile/doctor', data: formData);
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await apiService.dio.put(
      '/api/v1/profile/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(RegExp(r'[/\\]')).last,
      ),
    });
    final response = await apiService.dio.post(
      '/api/v1/profile/avatar',
      data: formData,
    );
    final data = response.data as Map<String, dynamic>;
    return (data['profile_picture_url'] ?? '') as String;
  }
}
