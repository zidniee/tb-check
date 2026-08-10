import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/education_content.dart';
import '../providers/education_provider.dart';
import '../widgets/herbal_clause_banner.dart';

/// Detail page for a single education content item (article or video).
///
/// - **Article mode:** Hero image + HTML body + scroll-based progress tracking
/// - **Video mode:** YouTube thumbnail + video info + completion button
///
/// Both modes display the mandatory Herbal Clause banner (SRS §3.3.1).
class EducationDetailPage extends StatefulWidget {
  final String contentId;

  const EducationDetailPage({super.key, required this.contentId});

  @override
  State<EducationDetailPage> createState() => _EducationDetailPageState();
}

class _EducationDetailPageState extends State<EducationDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  YoutubePlayerController? _ytController;

  bool _hasScrolledToLastPosition = false;
  int _lastSavedPercent = 0;
  late EducationProvider _educationProvider;

  @override
  void initState() {
    super.initState();
    _educationProvider = context.read<EducationProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _educationProvider.fetchContentDetail(widget.contentId);
    });
    _scrollController.addListener(_onScroll);
  }

  void _initYoutubeController(String videoId) {
    if (_ytController != null) return;
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
      ),
    );
  }

  void _saveProgressOnExit() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll > 0) {
        final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        final percent = (progress * 100).round();

        final content = _educationProvider.selectedContent;
        if (content != null && content.isArticle) {
          final existingProgress = content.userProgress;
          if (existingProgress == null || !existingProgress.isCompleted) {
            _educationProvider.updateReadingProgress(
              content.contentId,
              isCompleted: percent >= 95,
              progressPercent: percent,
              lastPosition: currentScroll.round(),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _ytController?.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll > 0) {
      final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      final percent = (progress * 100).round();

      setState(() {
        _scrollProgress = progress;
      });

      // Automatically save progress in increments of 10%
      if (percent >= _lastSavedPercent + 10 && percent < 95) {
        _lastSavedPercent = percent;
        _saveProgressLocally(percent, currentScroll.round());
      }
    }
  }

  void _saveProgressLocally(int percent, int position) {
    final content = _educationProvider.selectedContent;
    if (content == null || !content.isArticle) return;

    final existingProgress = content.userProgress;
    if (existingProgress != null && existingProgress.isCompleted) return;

    _educationProvider.updateReadingProgress(
      content.contentId,
      isCompleted: percent >= 95,
      progressPercent: percent,
      lastPosition: position,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EducationProvider>(
      builder: (context, provider, _) {
        final content = provider.selectedContent;

        if (provider.isLoadingDetail) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: _buildLoadingState(),
          );
        }

        if (provider.detailError != null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: _buildErrorState(provider.detailError!),
          );
        }

        if (content == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: SizedBox.shrink(),
          );
        }

        if (content.isArticle &&
            !_hasScrolledToLastPosition) {
          _hasScrolledToLastPosition = true;
          final lastPosition = content.userProgress?.lastPosition ?? 0;
          _lastSavedPercent = content.userProgress?.progressPercent ?? 0;
          if (lastPosition > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 250), () {
                if (mounted && _scrollController.hasClients) {
                  _scrollController.animateTo(
                    lastPosition.toDouble(),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  );
                }
              });
            });
          }
        }

        if (content.isVideo) {
          return _buildVideoLayout(context, content, provider);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: _buildArticleLayout(context, content, provider),
          bottomNavigationBar: _buildBottomBar(context, content, provider),
        );
      },
    );
  }

  Widget _buildArticleLayout(
    BuildContext context,
    EducationContent content,
    EducationProvider provider,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero image / Video thumbnail
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: _buildBackButton(),
          flexibleSpace: FlexibleSpaceBar(background: _buildHeroImage(content)),
        ),

        // Content body
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Content type badge + duration
                Row(
                  children: [
                    _buildTypeBadge(content),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      content.durationFormatted,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  content.title,
                  style: AppTextStyles.h5.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Author & date
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E2D3D), Color(0xFF3D6285)],
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.authorName,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (content.publishedAt != null)
                          Text(
                            '${content.publishedAt!.day}/${content.publishedAt!.month}/${content.publishedAt!.year}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Tags
                if (content.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: content.tags
                        .map((tag) => _buildTagChip(tag))
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                ],

                // Herbal Clause Banner (MANDATORY per SRS §3.3.1)
                const HerbalClauseBanner.compact(),
                const SizedBox(height: 20),

                // Article body
                _buildArticleBody(content),

                // Source reference
                if (content.sourceUrl != null &&
                    content.sourceUrl!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSourceReference(content.sourceUrl!),
                ],

                // Scientific references list from backend
                _buildScientificReferencesSection(content.references),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoLayout(
    BuildContext context,
    EducationContent content,
    EducationProvider provider,
  ) {
    if (content.youtubeVideoId != null) {
      _initYoutubeController(content.youtubeVideoId!);
    }

    final progress = content.userProgress;
    final isCompleted = progress?.isCompleted ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            _saveProgressOnExit();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Video Edukasi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Fixed Video Player (Eliminates scroll lag because it's stationary at the top)
          if (_ytController != null)
            YoutubePlayer(controller: _ytController!, aspectRatio: 16 / 9)
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

          // 2. Scrollable description and metadata
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    content.title,
                    style: AppTextStyles.h5.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Author & date & tags
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E2D3D), Color(0xFF3D6285)],
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.authorName,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (content.publishedAt != null)
                            Text(
                              '${content.publishedAt!.day}/${content.publishedAt!.month}/${content.publishedAt!.year}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  if (content.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: content.tags
                          .map((tag) => _buildTagChip(tag))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Herbal Clause Banner (MANDATORY per SRS §3.3.1)
                  const HerbalClauseBanner.compact(),
                  const SizedBox(height: 20),

                  // Video description text card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keterangan',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.summary,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: AppColors.textPrimary.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scientific references list from backend
                  _buildScientificReferencesSection(content.references),

                  // Mark completed button (Placed inline here to prevent bottom overlaps)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isCompleted
                          ? null
                          : () async {
                              await provider.updateReadingProgress(
                                content.contentId,
                                isCompleted: true,
                                progressPercent: 100,
                                lastPosition: 0,
                              );
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.done_all_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: Text(
                        isCompleted
                            ? 'Sudah Selesai Ditonton'
                            : 'Tandai Selesai Ditonton',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? AppColors.success
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.success.withOpacity(
                          0.7,
                        ),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            _saveProgressOnExit();
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildHeroImage(EducationContent content) {
    final imageUrl = content.imageUrl ?? content.thumbnailUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primaryLight,
              child: Center(
                child: Icon(
                  content.isArticle
                      ? Icons.local_florist_rounded
                      : Icons.videocam_rounded,
                  size: 64,
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
            ),
          )
        else
          Container(
            color: AppColors.primaryLight,
            child: Center(
              child: Icon(
                Icons.local_florist_rounded,
                size: 64,
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ),
        // Gradient overlay for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
            ),
          ),
        ),
        // Video play button overlay
        if (content.isVideo)
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeBadge(EducationContent content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: content.isArticle
            ? AppColors.primaryLight
            : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            content.isArticle
                ? Icons.article_rounded
                : Icons.play_arrow_rounded,
            size: 14,
            color: content.isArticle ? AppColors.primary : AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            content.isArticle ? 'Artikel' : 'Video',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: content.isArticle
                  ? AppColors.primaryDark
                  : AppColors.secondaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: AppColors.secondaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildArticleBody(EducationContent content) {
    if (content.body == null || content.body!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          content.summary,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
      );
    }

    // Parse and render HTML body content
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: _HtmlRenderer(body: content.body!),
    );
  }

  Widget _buildSourceReference(String sourceUrl) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(sourceUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka tautan: $sourceUrl')),
          );
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.science_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sumber Ilmiah',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sourceUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScientificReferencesSection(List<ScientificReference> references) {
    if (references.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'REFERENSI ILMIAH',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: references.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final ref = references[index];
            final displayUrl = ref.url ?? (ref.doi != null ? 'https://doi.org/${ref.doi}' : null);

            return InkWell(
              onTap: displayUrl != null && displayUrl.isNotEmpty
                  ? () async {
                      final uri = Uri.parse(displayUrl);
                      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tidak dapat membuka tautan: $displayUrl')),
                        );
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withOpacity(0.8)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.science_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.journalName,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tahun Terbit: ${ref.year}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (ref.doi != null && ref.doi!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'DOI: ${ref.doi}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (displayUrl != null && displayUrl.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.open_in_new_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    EducationContent content,
    EducationProvider provider,
  ) {
    final progress = content.userProgress;
    final isCompleted = progress?.isCompleted ?? false;
    final progressPercent = content.isArticle
        ? (_scrollProgress * 100).round()
        : (progress?.progressPercent ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isCompleted ? 1.0 : progressPercent / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isCompleted ? '100%' : '$progressPercent%',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isCompleted
                    ? null
                    : () async {
                        await provider.updateReadingProgress(
                          content.contentId,
                          isCompleted: true,
                          progressPercent: 100,
                          lastPosition: _scrollController.hasClients
                              ? _scrollController.position.pixels.round()
                              : 0,
                        );
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.done_all_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  isCompleted
                      ? 'Sudah Selesai Dibaca'
                      : content.isArticle
                      ? 'Tandai Selesai Dibaca'
                      : 'Tandai Selesai Ditonton',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.success.withOpacity(0.7),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Detail',
              style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<EducationProvider>().fetchContentDetail(
                  widget.contentId,
                );
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────
// HTML RENDERER USING FLUTTER_WIDGET_FROM_HTML
// ─────────────────────────────────────────────────────────

class _HtmlRenderer extends StatelessWidget {
  final String body;

  const _HtmlRenderer({required this.body});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      body,
      textStyle: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.6,
      ),

      // ── Render mode: column for better Sliver compatibility ──
      renderMode: RenderMode.column,

      // ── Loading placeholder while heavy HTML is being parsed ──
      onLoadingBuilder: (context, element, loadingProgress) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
                value: loadingProgress,
              ),
            ),
          ),
        );
      },

      // ── Custom styling for HTML elements ──
      customStylesBuilder: (element) {
        switch (element.localName) {
          // Headings
          case 'h1':
            return {
              'font-size': '22px',
              'font-weight': 'bold',
              'line-height': '1.3',
              'margin': '16px 0 10px 0',
              'color': '#1E2D3D',
            };
          case 'h2':
            return {
              'font-size': '18px',
              'font-weight': 'bold',
              'line-height': '1.4',
              'margin': '14px 0 8px 0',
              'color': '#1E2D3D',
            };
          case 'h3':
            return {
              'font-size': '15px',
              'font-weight': 'bold',
              'line-height': '1.3',
              'margin': '12px 0 6px 0',
              'color': '#1E2D3D',
            };

          // Links
          case 'a':
            return {
              'color': '#4E7BA7',
              'text-decoration': 'underline',
            };

          // Lists
          case 'ul':
          case 'ol':
            return {
              'margin': '8px 0',
              'padding': '0 0 0 8px',
            };
          case 'li':
            return {
              'margin': '4px 0',
              'font-size': '14px',
              'line-height': '1.6',
            };

          // Bold & emphasis
          case 'strong':
          case 'b':
            return {
              'font-weight': 'bold',
              'color': '#1E2D3D',
            };
          case 'em':
          case 'i':
            return {
              'font-style': 'italic',
            };

          // Tables
          case 'table':
            return {
              'border': '1px solid #E2E8F0',
              'border-collapse': 'collapse',
              'width': '100%',
              'margin': '12px 0',
            };
          case 'td':
            return {
              'border': '1px solid #E2E8F0',
              'padding': '8px 10px',
              'font-size': '11px',
              'vertical-align': 'top',
            };
          case 'th':
            return {
              'border': '1px solid #E2E8F0',
              'padding': '8px 10px',
              'font-size': '11px',
              'font-weight': 'bold',
              'background-color': '#E8EEF5',
              'color': '#3D6285',
            };

          // Blockquote
          case 'blockquote':
            return {
              'background-color': '#FFF9C4',
              'border-left': '4px solid #FBC02D',
              'border-radius': '10px',
              'padding': '12px 16px',
              'margin': '12px 0',
              'font-size': '12px',
              'color': '#5D4037',
              'line-height': '1.45',
            };

          // Horizontal rule
          case 'hr':
            return {
              'border': 'none',
              'border-top': '1px solid #E2E8F0',
              'margin': '16px 0',
            };

          // Images
          case 'img':
            return {
              'margin': '12px 0',
              'border-radius': '10px',
              'max-width': '100%',
            };

          // Paragraphs
          case 'p':
            return {
              'margin': '6px 0',
              'line-height': '1.6',
            };

          default:
            return null;
        }
      },

      // ── Custom widget builder for images & tables ──
      customWidgetBuilder: (element) {
        // Wrap tables in horizontal scroll for small screens
        if (element.localName == 'table') {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: HtmlWidget(
              element.outerHtml,
              textStyle: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }
        return null;
      },

      // ── Handle image error with a fallback widget ──
      onErrorBuilder: (context, element, error) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_rounded,
                size: 32,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat konten',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },

      // ── Handle tapped URLs ──
      onTapUrl: (url) {
        launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        return true;
      },
    );
  }
}
