import '../../../../core/network/api_service.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/learning_stats.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_mock_datasource.dart';
import '../datasources/education_remote_data_source.dart';

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource _remoteDatasource;
  final EducationMockDatasource _mockDatasource;

  EducationRepositoryImpl({
    EducationRemoteDataSource? remoteDatasource,
    EducationMockDatasource? mockDatasource,
  })  : _remoteDatasource = remoteDatasource ?? EducationRemoteDataSourceImpl(apiService: ApiService()),
        _mockDatasource = mockDatasource ?? EducationMockDatasource();

  @override
  Future<EducationContentListResult> getContents({
    String? contentType,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await _remoteDatasource.getContents(
        contentType: contentType,
        page: page,
        pageSize: pageSize,
      );

      return EducationContentListResult(
        contents: result['contents'] as List<EducationContent>,
        page: result['page'] as int,
        pageSize: result['page_size'] as int,
        total: result['total'] as int,
      );
    } catch (_) {
      // Fallback to mock data if remote fails/offline
      final result = await _mockDatasource.getContents(
        contentType: contentType,
        page: page,
        pageSize: pageSize,
      );

      return EducationContentListResult(
        contents: result['contents'] as List<EducationContent>,
        page: result['page'] as int,
        pageSize: result['page_size'] as int,
        total: result['total'] as int,
      );
    }
  }

  @override
  Future<EducationContent> getContentById(String contentId) async {
    try {
      return await _remoteDatasource.getContentById(contentId);
    } catch (_) {
      return await _mockDatasource.getContentById(contentId);
    }
  }

  @override
  Future<List<EducationContent>> searchContents(String keyword, {int limit = 10}) async {
    try {
      return await _remoteDatasource.searchContents(keyword, limit: limit);
    } catch (_) {
      return await _mockDatasource.searchContents(keyword, limit: limit);
    }
  }

  @override
  Future<void> updateProgress(
    String contentId, {
    required bool isCompleted,
    required int progressPercent,
    required int lastPosition,
  }) async {
    try {
      await _remoteDatasource.updateProgress(
        contentId,
        isCompleted: isCompleted,
        progressPercent: progressPercent,
        lastPosition: lastPosition,
      );
    } catch (_) {
      await _mockDatasource.updateProgress(
        contentId,
        isCompleted: isCompleted,
        progressPercent: progressPercent,
        lastPosition: lastPosition,
      );
    }
  }

  @override
  Future<LearningStats> getLearningStats() async {
    try {
      return await _remoteDatasource.getLearningStats();
    } catch (_) {
      return await _mockDatasource.getLearningStats();
    }
  }
}
