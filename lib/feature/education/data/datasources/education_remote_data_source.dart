import '../../../../core/network/api_service.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/learning_stats.dart';

abstract class EducationRemoteDataSource {
  Future<Map<String, dynamic>> getContents({
    String? contentType,
    int page = 1,
    int pageSize = 10,
  });
  Future<EducationContent> getContentById(String contentId);
  Future<List<EducationContent>> searchContents(String keyword, {int limit = 10});
  Future<void> updateProgress(
    String contentId, {
    required bool isCompleted,
    required int progressPercent,
    required int lastPosition,
  });
  Future<LearningStats> getLearningStats();
}

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final ApiService apiService;

  EducationRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> getContents({
    String? contentType,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await apiService.dio.get(
      '/api/v1/education',
      queryParameters: {
        if (contentType != null && contentType.isNotEmpty) 'content_type': contentType,
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final rawContents = (data['contents'] as List<dynamic>?) ?? [];
    final contents = rawContents.map((json) => _mapJsonToEducationContent(json as Map<String, dynamic>)).toList();

    return {
      'contents': contents,
      'page': (data['page'] as num?)?.toInt() ?? page,
      'page_size': (data['page_size'] as num?)?.toInt() ?? pageSize,
      'total': (data['total'] as num?)?.toInt() ?? contents.length,
    };
  }

  @override
  Future<EducationContent> getContentById(String contentId) async {
    final response = await apiService.dio.get('/api/v1/education/$contentId');
    return _mapJsonToEducationContent(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<EducationContent>> searchContents(String keyword, {int limit = 10}) async {
    final response = await apiService.dio.get(
      '/api/v1/education/search',
      queryParameters: {
        'q': keyword,
        'limit': limit,
        'offset': 0,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final rawContents = (data['contents'] as List<dynamic>?) ?? [];
    return rawContents.map((json) => _mapJsonToEducationContent(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> updateProgress(
    String contentId, {
    required bool isCompleted,
    required int progressPercent,
    required int lastPosition,
  }) async {
    await apiService.dio.put(
      '/api/v1/education/$contentId/progress',
      data: {
        'progress_percent': progressPercent,
        'last_position': lastPosition,
      },
    );
  }

  @override
  Future<LearningStats> getLearningStats() async {
    // 1. Get total contents from /api/v1/education
    final contentsData = await getContents(page: 1, pageSize: 1);
    final totalContents = contentsData['total'] as int? ?? 0;

    // 2. Get user progress from /api/v1/education/progress
    final response = await apiService.dio.get('/api/v1/education/progress');
    final list = response.data as List<dynamic>? ?? [];

    final totalStarted = list.length;
    int totalCompleted = 0;
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final isCompleted = (map['is_completed'] as bool?) ?? false;
      if (isCompleted) {
        totalCompleted++;
      }
    }

    final overallPercent = totalContents > 0
        ? ((totalCompleted / totalContents) * 100).round()
        : 0;

    return LearningStats(
      totalContents: totalContents,
      totalStarted: totalStarted,
      totalCompleted: totalCompleted,
      overallPercent: overallPercent > 100 ? 100 : overallPercent,
    );
  }

  EducationContent _mapJsonToEducationContent(Map<String, dynamic> json) {
    final typeStr = (json['content_type'] ?? 'article') as String;
    final type = typeStr.toLowerCase() == 'video'
        ? EducationContentType.video
        : EducationContentType.article;

    ReadingProgress? userProgress;
    if (json['user_progress'] != null) {
      final pJson = json['user_progress'] as Map<String, dynamic>;
      userProgress = ReadingProgress(
        isCompleted: (pJson['is_completed'] as bool?) ?? false,
        progressPercent: (pJson['progress_percent'] as num?)?.toInt() ?? 0,
        lastPosition: (pJson['last_position'] as num?)?.toInt() ?? 0,
        startedAt: pJson['started_at'] != null
            ? DateTime.parse(pJson['started_at'] as String)
            : null,
      );
    }

    final rawRefs = (json['references'] as List<dynamic>?) ?? [];
    final references = rawRefs.map((e) => ScientificReference.fromJson(e as Map<String, dynamic>)).toList();

    return EducationContent(
      contentId: (json['content_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      body: json['body'] as String?,
      contentType: type,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      youtubeVideoId: json['youtube_video_id'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 180,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sourceUrl: json['source_url'] as String?,
      authorName: (json['author_name'] ?? 'Tim TBCheck') as String,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      userProgress: userProgress,
      references: references,
    );
  }
}
