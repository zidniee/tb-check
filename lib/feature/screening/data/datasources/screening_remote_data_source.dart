import '../../../../core/network/api_service.dart';
import '../models/screening_report_dto.dart';

abstract class ScreeningRemoteDataSource {
  Future<ScreeningReportDTO> submitReport({
    required double probabilityScore,
    required String predictionStatus,
    required List<double> mfccMeanVector,
    required Map<String, dynamic> clinicalAnswers,
  });
  Future<List<ScreeningReportDTO>> getMyReports({int limit = 100, int page = 1});
  Future<ScreeningReportDTO> getReportById(String reportId);
}

class ScreeningRemoteDataSourceImpl implements ScreeningRemoteDataSource {
  final ApiService apiService;

  ScreeningRemoteDataSourceImpl({required this.apiService});

  @override
  Future<ScreeningReportDTO> submitReport({
    required double probabilityScore,
    required String predictionStatus,
    required List<double> mfccMeanVector,
    required Map<String, dynamic> clinicalAnswers,
  }) async {
    final response = await apiService.dio.post(
      '/api/v1/screening/reports',
      data: {
        'probability_score': probabilityScore,
        'prediction_status': predictionStatus,
        'mfcc_mean_vector': mfccMeanVector,
        'clinical_answers': clinicalAnswers,
      },
    );
    return ScreeningReportDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ScreeningReportDTO>> getMyReports({int limit = 100, int page = 1}) async {
    final response = await apiService.dio.get(
      '/api/v1/screening/reports',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => ScreeningReportDTO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ScreeningReportDTO> getReportById(String reportId) async {
    final response = await apiService.dio.get('/api/v1/screening/reports/$reportId');
    return ScreeningReportDTO.fromJson(response.data as Map<String, dynamic>);
  }
}
