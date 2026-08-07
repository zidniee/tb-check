import '../../../../core/network/api_service.dart';

abstract class DoctorDashboardRemoteDataSource {
  Future<Map<String, dynamic>> getDoctorDashboard();
}

class DoctorDashboardRemoteDataSourceImpl implements DoctorDashboardRemoteDataSource {
  final ApiService apiService;

  DoctorDashboardRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> getDoctorDashboard() async {
    final response = await apiService.dio.get('/api/v1/doctor/dashboard');
    return response.data as Map<String, dynamic>;
  }
}
