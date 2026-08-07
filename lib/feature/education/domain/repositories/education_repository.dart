import '../entities/education_content.dart';
import '../entities/learning_stats.dart';

/// Abstract contract for education data operations.
///
/// Implemented by [EducationRepositoryImpl] in the data layer.
/// Mirrors the backend `EducationClient` interface contract.
abstract class EducationRepository {
  /// Fetches a paginated list of education contents.
  ///
  /// [contentType] filters by 'article' or 'video'. Null returns all.
  Future<EducationContentListResult> getContents({
    String? contentType,
    int page = 1,
    int pageSize = 10,
  });

  /// Fetches full detail of a single content by ID, including user progress.
  Future<EducationContent> getContentById(String contentId);

  /// Searches contents by keyword across title, summary, body, and tags.
  Future<List<EducationContent>> searchContents(String keyword, {int limit = 10});

  /// Updates reading/watching progress for the current user.
  Future<void> updateProgress(
    String contentId, {
    required bool isCompleted,
    required int progressPercent,
    required int lastPosition,
  });

  /// Fetches aggregate learning statistics for the current user.
  Future<LearningStats> getLearningStats();
}

/// Wrapper for paginated content list results.
class EducationContentListResult {
  final List<EducationContent> contents;
  final int page;
  final int pageSize;
  final int total;

  const EducationContentListResult({
    required this.contents,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  bool get hasMore => page * pageSize < total;
}
