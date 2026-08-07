/// Represents an education content item from the phytochemical herbal encyclopedia.
///
/// Maps to the `education_contents` table in the backend database.
/// Supports both article and video content types.
enum EducationContentType { article, video }

class EducationContent {
  final String contentId;
  final String title;
  final String summary;
  final String? body;
  final EducationContentType contentType;
  final String? imageUrl;
  final String? videoUrl;
  final String? youtubeVideoId;
  final String? thumbnailUrl;
  final int durationSeconds;
  final List<String> tags;
  final String? sourceUrl;
  final String authorName;
  final DateTime? publishedAt;

  /// Optional user reading progress (populated when user is authenticated).
  final ReadingProgress? userProgress;

  const EducationContent({
    required this.contentId,
    required this.title,
    required this.summary,
    this.body,
    required this.contentType,
    this.imageUrl,
    this.videoUrl,
    this.youtubeVideoId,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.tags,
    this.sourceUrl,
    required this.authorName,
    this.publishedAt,
    this.userProgress,
  });

  bool get isArticle => contentType == EducationContentType.article;
  bool get isVideo => contentType == EducationContentType.video;

  /// Human-readable duration: "4 menit baca" for articles, "3:45" for videos.
  String get durationFormatted {
    if (isArticle) {
      final minutes = (durationSeconds / 60).ceil();
      return '$minutes menit baca';
    } else {
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Tags joined as comma-separated string.
  String get formattedTags => tags.join(', ');

  /// Creates a copy with optional overrides.
  EducationContent copyWith({
    String? contentId,
    String? title,
    String? summary,
    String? body,
    EducationContentType? contentType,
    String? imageUrl,
    String? videoUrl,
    String? youtubeVideoId,
    String? thumbnailUrl,
    int? durationSeconds,
    List<String>? tags,
    String? sourceUrl,
    String? authorName,
    DateTime? publishedAt,
    ReadingProgress? userProgress,
  }) {
    return EducationContent(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      contentType: contentType ?? this.contentType,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      tags: tags ?? this.tags,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      authorName: authorName ?? this.authorName,
      publishedAt: publishedAt ?? this.publishedAt,
      userProgress: userProgress ?? this.userProgress,
    );
  }
}

/// Represents a user's reading/watching progress for a specific content.
class ReadingProgress {
  final bool isCompleted;
  final int progressPercent;
  final int lastPosition;
  final DateTime? startedAt;

  const ReadingProgress({
    required this.isCompleted,
    required this.progressPercent,
    required this.lastPosition,
    this.startedAt,
  });
}
