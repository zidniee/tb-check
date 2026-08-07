import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../entities/care_entities.dart';

abstract class CareRepository {
  Future<Either<ApiException, TreatmentEntity>> getTreatment();
  Future<Either<ApiException, TreatmentEntity>> createTreatment(Map<String, dynamic> data);
  Future<Either<ApiException, TreatmentEntity>> updateTreatment(Map<String, dynamic> data);
  Future<Either<ApiException, void>> deleteTreatment();
  
  Future<Either<ApiException, List<ScheduleEntity>>> getSchedules();
  Future<Either<ApiException, ScheduleEntity>> addSchedule(String reminderTime);
  Future<Either<ApiException, ScheduleEntity>> updateSchedule(String scheduleId, Map<String, dynamic> data);
  Future<Either<ApiException, void>> deleteSchedule(String scheduleId);
  
  Future<Either<ApiException, LogEntity>> confirmMedication(String scheduleId, String date);
  Future<Either<ApiException, List<LogEntity>>> getHistory(String startDate, String endDate);
  Future<Either<ApiException, CareStatisticsEntity>> getStatistics();
}
