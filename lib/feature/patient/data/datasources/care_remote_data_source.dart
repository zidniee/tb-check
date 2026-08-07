import '../../../../core/network/api_service.dart';
import '../models/care_models.dart';

abstract class CareRemoteDataSource {
  Future<TreatmentResponse> getTreatment();
  Future<TreatmentResponse> createTreatment(Map<String, dynamic> data);
  Future<TreatmentResponse> updateTreatment(Map<String, dynamic> data);
  Future<void> deleteTreatment();
  Future<List<ScheduleResponse>> getSchedules();
  Future<ScheduleResponse> addSchedule(String reminderTime);
  Future<ScheduleResponse> updateSchedule(String scheduleId, Map<String, dynamic> data);
  Future<void> deleteSchedule(String scheduleId);
  Future<LogResponse> confirmMedication(String scheduleId, String date);
  Future<List<LogResponse>> getHistory(String startDate, String endDate);
  Future<StatisticsResponse> getStatistics();
}

class CareRemoteDataSourceImpl implements CareRemoteDataSource {
  final ApiService apiService;

  CareRemoteDataSourceImpl({required this.apiService});

  @override
  Future<TreatmentResponse> getTreatment() async {
    final response = await apiService.dio.get('/api/v1/care');
    return TreatmentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TreatmentResponse> createTreatment(Map<String, dynamic> data) async {
    final response = await apiService.dio.post('/api/v1/care', data: data);
    return TreatmentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TreatmentResponse> updateTreatment(Map<String, dynamic> data) async {
    final response = await apiService.dio.put('/api/v1/care', data: data);
    return TreatmentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTreatment() async {
    await apiService.dio.delete('/api/v1/care');
  }

  @override
  Future<List<ScheduleResponse>> getSchedules() async {
    final response = await apiService.dio.get('/api/v1/care/schedules');
    final list = response.data as List<dynamic>;
    return list.map((e) => ScheduleResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ScheduleResponse> addSchedule(String reminderTime) async {
    final response = await apiService.dio.post('/api/v1/care/schedules', data: {
      'reminder_time': reminderTime,
    });
    return ScheduleResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ScheduleResponse> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    final response = await apiService.dio.put('/api/v1/care/schedules/$scheduleId', data: data);
    return ScheduleResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    await apiService.dio.delete('/api/v1/care/schedules/$scheduleId');
  }

  @override
  Future<LogResponse> confirmMedication(String scheduleId, String date) async {
    final response = await apiService.dio.post('/api/v1/care/logs', data: {
      'schedule_id': scheduleId,
      'date': date,
    });
    return LogResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<LogResponse>> getHistory(String startDate, String endDate) async {
    final response = await apiService.dio.get(
      '/api/v1/care/history',
      queryParameters: {
        'start_date': startDate,
        'end_date': endDate,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => LogResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<StatisticsResponse> getStatistics() async {
    final response = await apiService.dio.get('/api/v1/care/statistics');
    return StatisticsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
