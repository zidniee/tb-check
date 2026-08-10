import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/appointment_models.dart';

abstract class AppointmentRepository {
  Future<Either<ApiException, List<DoctorSchedule>>> getSchedulesByDoctor(String doctorId);
  Future<Either<ApiException, Appointment>> createAppointment(CreateAppointmentRequest req);
  Future<Either<ApiException, List<Appointment>>> getMyAppointments({String? status});
  Future<Either<ApiException, Appointment>> getAppointmentById(String id);
  Future<Either<ApiException, Appointment>> reschedule(String id, RescheduleRequest req);
  Future<Either<ApiException, Appointment>> cancel(String id, CancelRequest req);
  Future<Either<ApiException, AppointmentHistoryResponse>> getHistory({
    String? status,
    int? month,
    int? year,
    int page,
    int pageSize,
  });
  Future<Either<ApiException, AppointmentDashboard>> getDashboard();
}
