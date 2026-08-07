import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/education_provider.dart';
import '../widgets/herbal_clause_banner.dart';
import '../widgets/education_content_card.dart';
import '../widgets/education_search_bar.dart';
import '../widgets/content_type_filter.dart';
import 'education_detail_page.dart';
import 'education_stats_page.dart';

/// Main encyclopedia page listing all phytochemical herbal education content.
///
/// Implements FR-012: Ensiklopedia Fitokimia Herbal with search, filter,
/// and mandatory Herbal Clause banner (SRS §3.3.1).
class EducationListPage extends StatefulWidget {
  const EducationListPage({super.key});

  @override
  State<EducationListPage> createState() => _EducationListPageState();
}

class _EducationListPageState extends State<EducationListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial content after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EducationProvider>().fetchContents();
    });

    // Infinite scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<EducationProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Ensiklopedia Fitokimia',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          // Stats icon
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded,
                color: AppColors.textPrimary, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EducationStatsPage()),
              );
            },
            tooltip: 'Statistik Belajar',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<EducationProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchContents(
                  contentType: provider.activeContentTypeFilter,
                );
              },
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                // Fixed top section: banner + search + filter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // 1. Herbal Clause Banner (MANDATORY per SRS §3.3.1)
                        const HerbalClauseBanner(),
                        const SizedBox(height: 16),

                        // 2. Search Bar
                        EducationSearchBar(
                          initialValue: provider.searchKeyword,
                          onSearch: (keyword) {
                            provider.searchContents(keyword);
                          },
                        ),
                        const SizedBox(height: 14),

                        // 3. Content Type Filter Tabs
                        ContentTypeFilter(
                          activeFilter: provider.activeContentTypeFilter,
                          onFilterChanged: (type) {
                            provider.setContentTypeFilter(type);
                          },
                        ),
                        const SizedBox(height: 6),

                        // Content count
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            provider.isLoading && provider.contents.isEmpty
                                ? 'Memuat konten...'
                                : '${provider.totalItems} konten ditemukan',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content list
                if (provider.isLoading && provider.contents.isEmpty)
                  _buildShimmerList()
                else if (provider.error != null && provider.contents.isEmpty)
                  _buildErrorState(provider.error!)
                else if (provider.contents.isEmpty)
                  _buildEmptyState()
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= provider.contents.length) {
                            // Loading more indicator
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          }

                          final content = provider.contents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: EducationContentCard(
                              content: content,
                              onTap: () => _navigateToDetail(content.contentId),
                            ),
                          );
                        },
                        childCount: provider.contents.length +
                            (provider.hasMore ? 1 : 0),
                      ),
                    ),
                  ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  void _navigateToDetail(String contentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EducationDetailPage(contentId: contentId),
      ),
    );
  }

  Widget _buildShimmerList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Shimmer.fromColors(
              baseColor: AppColors.border.withOpacity(0.4),
              highlightColor: Colors.white,
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
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
                'Gagal Memuat Konten',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<EducationProvider>().fetchContents();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_florist_rounded,
                size: 72,
                color: AppColors.success.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak Ada Konten',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ditemukan konten yang sesuai dengan pencarian Anda. Coba kata kunci lain.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
