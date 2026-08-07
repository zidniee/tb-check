import '../../../../core/network/api_service.dart';
import '../models/patient_monitoring_dto.dart';

abstract class MonitoringRemoteDataSource {
  Future<List<PatientMonitoringDTO>> getMyPatients({int limit = 100, int page = 1});
  Future<PatientMonitoringDTO> getPatientMonitoring(String patientId);
  Future<void> updatePatientMonitoring({
    required String patientId,
    required String followupStatus,
    String? notes,
  });
  Future<Map<String, dynamic>> getClinicalTrends(String patientId);
}

class MonitoringRemoteDataSourceImpl implements MonitoringRemoteDataSource {
  final ApiService apiService;

  MonitoringRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<PatientMonitoringDTO>> getMyPatients({int limit = 100, int page = 1}) async {
    final response = await apiService.dio.get(
      '/api/v1/monitoring/patients',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => PatientMonitoringDTO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PatientMonitoringDTO> getPatientMonitoring(String patientId) async {
    final response = await apiService.dio.get('/api/v1/monitoring/patients/$patientId');
    return PatientMonitoringDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> updatePatientMonitoring({
    required String patientId,
    required String followupStatus,
    String? notes,
  }) async {
    await apiService.dio.put(
      '/api/v1/monitoring/patients/$patientId',
      data: {
        'followup_status': followupStatus,
        'notes': notes,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getClinicalTrends(String patientId) async {
    final response = await apiService.dio.get('/api/v1/monitoring/patients/$patientId/trends');
    return response.data as Map<String, dynamic>;
  }
}
