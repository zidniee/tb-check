import '../../../../core/network/api_service.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/learning_stats.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_data_source.dart';

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource _remoteDatasource;

  EducationRepositoryImpl({
    EducationRemoteDataSource? remoteDatasource,
  })  : _remoteDatasource = remoteDatasource ?? EducationRemoteDataSourceImpl(apiService: ApiService());

  @override
  Future<EducationContentListResult> getContents({
    String? contentType,
    int page = 1,
    int pageSize = 10,
  }) async {
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
  }

  @override
  Future<EducationContent> getContentById(String contentId) async {
    return await _remoteDatasource.getContentById(contentId);
  }

  @override
  Future<List<EducationContent>> searchContents(String keyword, {int limit = 10}) async {
    return await _remoteDatasource.searchContents(keyword, limit: limit);
  }

  @override
  Future<void> updateProgress(
    String contentId, {
    required bool isCompleted,
    required int progressPercent,
    required int lastPosition,
  }) async {
    await _remoteDatasource.updateProgress(
      contentId,
      isCompleted: isCompleted,
      progressPercent: progressPercent,
      lastPosition: lastPosition,
    );
  }

  @override
  Future<LearningStats> getLearningStats() async {
    return await _remoteDatasource.getLearningStats();
  }
}
