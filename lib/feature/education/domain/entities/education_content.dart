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
  final List<ScientificReference> references;

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
    this.references = const [],
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
    List<ScientificReference>? references,
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
      references: references ?? this.references,
    );
  }

  factory EducationContent.fromJson(Map<String, dynamic> json) {
    return EducationContent(
      contentId: (json['content_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      body: json['body'] as String?,
      contentType: (json['content_type'] as String?)?.toLowerCase() == 'video'
          ? EducationContentType.video
          : EducationContentType.article,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      youtubeVideoId: json['youtube_video_id'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e as String).toList(),
      sourceUrl: json['source_url'] as String?,
      authorName: (json['author_name'] ?? '') as String,
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'] as String) : null,
      userProgress: json['user_progress'] != null ? ReadingProgress.fromJson(json['user_progress'] as Map<String, dynamic>) : null,
      references: (json['references'] as List<dynamic>? ?? const [])
          .map((e) => ScientificReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'title': title,
      'summary': summary,
      'body': body,
      'content_type': contentType == EducationContentType.video ? 'video' : 'article',
      'image_url': imageUrl,
      'video_url': videoUrl,
      'youtube_video_id': youtubeVideoId,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'tags': tags,
      'source_url': sourceUrl,
      'author_name': authorName,
      'published_at': publishedAt?.toIso8601String(),
      'user_progress': userProgress?.toJson(),
      'references': references.map((e) => e.toJson()).toList(),
    };
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

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      isCompleted: (json['is_completed'] as bool?) ?? false,
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
      lastPosition: (json['last_position'] as num?)?.toInt() ?? 0,
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_completed': isCompleted,
      'progress_percent': progressPercent,
      'last_position': lastPosition,
      'started_at': startedAt?.toIso8601String(),
    };
  }
}

/// Represents a scientific reference / publication for the phytochemical herbal encyclopedia.
class ScientificReference {
  final String referenceId;
  final String? compoundId;
  final String? contentId;
  final String journalName;
  final int year;
  final String? doi;
  final String? url;

  const ScientificReference({
    required this.referenceId,
    this.compoundId,
    this.contentId,
    required this.journalName,
    required this.year,
    this.doi,
    this.url,
  });

  factory ScientificReference.fromJson(Map<String, dynamic> json) {
    return ScientificReference(
      referenceId: (json['reference_id'] ?? json['id'] ?? '') as String,
      compoundId: json['compound_id'] as String?,
      contentId: json['content_id'] as String?,
      journalName: (json['journal_name'] ?? '') as String,
      year: (json['year'] as num?)?.toInt() ?? 2026,
      doi: json['doi'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_id': referenceId,
      'compound_id': compoundId,
      'content_id': contentId,
      'journal_name': journalName,
      'year': year,
      'doi': doi,
      'url': url,
    };
  }
}
