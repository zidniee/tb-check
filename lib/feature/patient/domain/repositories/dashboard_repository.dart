import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/patient_dashboard_dto.dart';

abstract class DashboardRepository {
  Future<Either<ApiException, PatientDashboardDTO>> getPatientDashboard();
}
