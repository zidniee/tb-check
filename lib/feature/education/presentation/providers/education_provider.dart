import 'package:flutter/material.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/learning_stats.dart';
import '../../domain/repositories/education_repository.dart';

/// State management for the Education feature using ChangeNotifier.
///
/// Manages content listing, search, filtering, detail, progress tracking,
/// and learning statistics. Follows the same pattern as [AuthProvider].
class EducationProvider extends ChangeNotifier {
  final EducationRepository _repository;

  EducationProvider({required EducationRepository repository})
      : _repository = repository;

  // ─────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────

  // Content list
  List<EducationContent> _contents = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalItems = 0;
  int _pageSize = 10;
  bool _hasMore = true;

  // Filters & search
  String? _activeContentTypeFilter; // null = all, 'article', 'video'
  String _searchKeyword = '';
  bool _isSearching = false;

  // Detail
  EducationContent? _selectedContent;
  bool _isLoadingDetail = false;
  String? _detailError;

  // Stats
  LearningStats? _stats;
  bool _isLoadingStats = false;

  // ─────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────

  List<EducationContent> get contents {
    if (_activeContentTypeFilter == null || _activeContentTypeFilter!.isEmpty) {
      return _contents;
    }
    final targetType = _activeContentTypeFilter!.toLowerCase() == 'video'
        ? EducationContentType.video
        : EducationContentType.article;
    return _contents.where((c) => c.contentType == targetType).toList();
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalItems => contents.length;
  bool get hasMore => _hasMore;

  String? get activeContentTypeFilter => _activeContentTypeFilter;
  String get searchKeyword => _searchKeyword;
  bool get isSearching => _isSearching;

  EducationContent? get selectedContent => _selectedContent;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  LearningStats? get stats => _stats;
  bool get isLoadingStats => _isLoadingStats;

  // ─────────────────────────────────────────────────
  // CONTENT LIST ACTIONS
  // ─────────────────────────────────────────────────

  /// Fetches the initial page of contents. Resets pagination.
  Future<void> fetchContents({String? contentType}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _activeContentTypeFilter = contentType;
    notifyListeners();

    try {
      final result = await _repository.getContents(
        contentType: contentType,
        page: 1,
        pageSize: _pageSize,
      );
      _contents = result.contents;
      _totalItems = result.total;
      _hasMore = result.hasMore;
    } catch (e) {
      _error = e.toString();
      _contents = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Loads the next page of contents (infinite scroll).
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _repository.getContents(
        contentType: _activeContentTypeFilter,
        page: nextPage,
        pageSize: _pageSize,
      );
      _contents.addAll(result.contents);
      _currentPage = nextPage;
      _hasMore = result.hasMore;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sets the content type filter and re-fetches.
  Future<void> setContentTypeFilter(String? type) async {
    if (_activeContentTypeFilter == type) return;
    _searchKeyword = '';
    await fetchContents(contentType: type);
  }

  // ─────────────────────────────────────────────────
  // SEARCH ACTIONS
  // ─────────────────────────────────────────────────

  /// Searches contents by keyword. Empty keyword resets to full list.
  Future<void> searchContents(String keyword) async {
    _searchKeyword = keyword;

    if (keyword.trim().isEmpty) {
      await fetchContents(contentType: _activeContentTypeFilter);
      return;
    }

    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _repository.searchContents(keyword);
      _contents = results;
      _totalItems = results.length;
      _hasMore = false;
    } catch (e) {
      _error = e.toString();
    }

    _isSearching = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────
  // DETAIL ACTIONS
  // ─────────────────────────────────────────────────

  /// Fetches full detail of a content item.
  Future<void> fetchContentDetail(String contentId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _selectedContent = null;
    notifyListeners();

    try {
      _selectedContent = await _repository.getContentById(contentId);
    } catch (e) {
      _detailError = e.toString();
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// Clears the selected content detail.
  void clearDetail() {
    _selectedContent = null;
    _detailError = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────
  // PROGRESS ACTIONS
  // ─────────────────────────────────────────────────

  /// Updates reading/watching progress for a content item.
  Future<void> updateReadingProgress(
    String contentId, {
    required bool isCompleted,
    required int progressPercent,
    required int lastPosition,
  }) async {
    // 1. Create the new ReadingProgress entity
    final newProgress = ReadingProgress(
      isCompleted: isCompleted,
      progressPercent: progressPercent,
      lastPosition: lastPosition,
      startedAt: DateTime.now(),
    );

    // 2. Optimistically update local selected content state to reflect change instantly
    if (_selectedContent?.contentId == contentId) {
      _selectedContent = _selectedContent!.copyWith(userProgress: newProgress);
    }

    // 3. Optimistically update list state to match the change
    final index = _contents.indexWhere((c) => c.contentId == contentId);
    if (index != -1) {
      _contents[index] = _contents[index].copyWith(userProgress: newProgress);
    }
    notifyListeners();

    try {
      // 4. Save to remote repository
      await _repository.updateProgress(
        contentId,
        isCompleted: isCompleted,
        progressPercent: progressPercent,
        lastPosition: lastPosition,
      );

      // Refresh learning stats in background
      await fetchLearningStats();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────
  // STATS ACTIONS
  // ─────────────────────────────────────────────────

  /// Fetches learning statistics for the current user.
  Future<void> fetchLearningStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _stats = await _repository.getLearningStats();
    } catch (e) {
      _error = e.toString();
    }

    _isLoadingStats = false;
    notifyListeners();
  }
}
