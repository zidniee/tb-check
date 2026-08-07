import '../../../../core/network/api_service.dart';

abstract class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> getPatientDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiService apiService;

  DashboardRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> getPatientDashboard() async {
    final response = await apiService.dio.get('/api/v1/patient/dashboard');
    return response.data as Map<String, dynamic>;
  }
}
