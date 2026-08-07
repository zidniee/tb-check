import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/education_content.dart';

/// Card widget displaying a single education content item in the list.
///
/// Shows thumbnail, content type badge, title, summary, tags, duration,
/// and reading progress indicator if the user has started reading.
class EducationContentCard extends StatelessWidget {
  final EducationContent content;
  final VoidCallback onTap;

  const EducationContentCard({
    super.key,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail with content type badge
              _buildThumbnail(),

              // Content info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Summary
                    Text(
                      content.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags
                    if (content.tags.isNotEmpty) ...[
                      SizedBox(
                        height: 26,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: content.tags.length > 3 ? 3 : content.tags.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (_, i) => _buildTagChip(content.tags[i]),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Bottom row: duration + author + progress
                    Row(
                      children: [
                        Icon(
                          content.isArticle
                              ? Icons.schedule_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.durationFormatted,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            content.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        // Progress badge
                        if (content.userProgress != null)
                          _buildProgressBadge(content.userProgress!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        // Thumbnail image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            height: 160,
            width: double.infinity,
            color: AppColors.primaryLight,
            child: content.thumbnailUrl != null
                ? Image.network(
                    content.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderThumbnail(),
                  )
                : _buildPlaceholderThumbnail(),
          ),
        ),

        // Content type badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: content.isArticle
                  ? AppColors.primary.withOpacity(0.9)
                  : AppColors.secondary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  content.isArticle
                      ? Icons.article_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  content.isArticle ? 'Artikel' : 'Video',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Video play icon overlay
        if (content.isVideo)
          Positioned.fill(
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderThumbnail() {
    return Center(
      child: Icon(
        content.isArticle ? Icons.local_florist_rounded : Icons.videocam_rounded,
        size: 48,
        color: AppColors.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10,
          color: AppColors.secondaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressBadge(ReadingProgress progress) {
    final isComplete = progress.isCompleted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isComplete ? AppColors.successLight : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isComplete)
            const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success)
          else
            Text(
              '${progress.progressPercent}%',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (isComplete) ...[
            const SizedBox(width: 3),
            Text(
              'Selesai',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.successDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
