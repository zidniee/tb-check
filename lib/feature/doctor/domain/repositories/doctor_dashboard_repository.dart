import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/doctor_dashboard_dto.dart';

abstract class DoctorDashboardRepository {
  Future<Either<ApiException, DoctorDashboardDTO>> getDoctorDashboard();
}
