import '../../../../core/network/api_service.dart';
import '../../../doctor/data/models/nearest_doctor_dto.dart';
import '../models/appointment_models.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<DoctorSchedule>> getSchedulesByDoctor(String doctorId);
  Future<Appointment> createAppointment(CreateAppointmentRequest req);
  Future<List<Appointment>> getMyAppointments({String? status});
  Future<Appointment> getAppointmentById(String id);
  Future<Appointment> reschedule(String id, RescheduleRequest req);
  Future<Appointment> cancel(String id, CancelRequest req);
  Future<AppointmentHistoryResponse> getHistory({
    String? status,
    int? month,
    int? year,
    int page = 1,
    int pageSize = 10,
  });
  Future<AppointmentDashboard> getDashboard();
  Future<List<NearestDoctorDTO>> getNearestDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  });
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiService apiService;

  AppointmentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<DoctorSchedule>> getSchedulesByDoctor(String doctorId) async {
    final res = await apiService.dio.get('/api/v1/doctors/$doctorId/schedules');
    return (res.data as List<dynamic>)
        .map((e) => DoctorSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Appointment> createAppointment(CreateAppointmentRequest req) async {
    final res = await apiService.dio.post('/api/v1/appointments', data: req.toJson());
    return Appointment.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<Appointment>> getMyAppointments({String? status}) async {
    final res = await apiService.dio.get('/api/v1/appointments',
        queryParameters: {if (status != null) 'status': status});
    return (res.data as List<dynamic>)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Appointment> getAppointmentById(String id) async {
    final res = await apiService.dio.get('/api/v1/appointments/$id');
    return Appointment.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Appointment> reschedule(String id, RescheduleRequest req) async {
    final res = await apiService.dio.put('/api/v1/appointments/$id', data: req.toJson());
    return Appointment.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Appointment> cancel(String id, CancelRequest req) async {
    final res = await apiService.dio.delete('/api/v1/appointments/$id', data: req.toJson());
    return Appointment.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AppointmentHistoryResponse> getHistory({
    String? status,
    int? month,
    int? year,
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await apiService.dio.get('/api/v1/appointments/history', queryParameters: {
      if (status != null) 'status': status,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      'page': page,
      'page_size': pageSize,
    });
    return AppointmentHistoryResponse.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AppointmentDashboard> getDashboard() async {
    final res = await apiService.dio.get('/api/v1/appointments/dashboard');
    return AppointmentDashboard.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<NearestDoctorDTO>> getNearestDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    final res = await apiService.dio.get(
      '/api/v1/doctors/nearest',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'radius_km': radiusKm,
      },
    );
    final list = res.data as List<dynamic>;
    return list.map((e) => NearestDoctorDTO.fromJson(e as Map<String, dynamic>)).toList();
  }
}
