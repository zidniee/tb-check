import '../../../../core/network/api_service.dart';
import '../models/nearest_doctor_dto.dart';

abstract class DoctorRemoteDataSource {
  Future<List<NearestDoctorDTO>> getNearestDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  });
  Future<Map<String, dynamic>> getDoctorById(String doctorId);
  Future<void> updateAvailability({
    required String onlineStatus,
    required bool acceptingPatient,
  });
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final ApiService apiService;

  DoctorRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<NearestDoctorDTO>> getNearestDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    final response = await apiService.dio.get(
      '/api/v1/doctors/nearest',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'radius_km': radiusKm,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => NearestDoctorDTO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> getDoctorById(String doctorId) async {
    final response = await apiService.dio.get('/api/v1/doctors/$doctorId');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> updateAvailability({
    required String onlineStatus,
    required bool acceptingPatient,
  }) async {
    await apiService.dio.put(
      '/api/v1/doctors/availability',
      data: {
        'online_status': onlineStatus,
        'accepting_patient': acceptingPatient,
      },
    );
  }
}
