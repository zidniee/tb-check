import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/screening_report_dto.dart';

abstract class ScreeningRepository {
  Future<Either<ApiException, ScreeningReportDTO>> submitReport({
    required double probabilityScore,
    required String predictionStatus,
    required List<double> mfccMeanVector,
    required Map<String, dynamic> clinicalAnswers,
  });
  Future<Either<ApiException, List<ScreeningReportDTO>>> getMyReports({int limit = 100, int page = 1});
  Future<Either<ApiException, ScreeningReportDTO>> getReportById(String reportId);
}
