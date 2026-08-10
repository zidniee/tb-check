import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/cache_service.dart';
import '../../data/datasources/care_remote_data_source.dart';
import '../../data/models/care_models.dart';

class CareProvider extends ChangeNotifier {
  final CareRemoteDataSource _dataSource;

  CareProvider({CareRemoteDataSource? dataSource})
      : _dataSource = dataSource ??
            CareRemoteDataSourceImpl(
              apiService: ApiService(),
            );

  TreatmentResponse? _treatment;
  List<ScheduleResponse> _schedules = [];
  List<LogResponse> _todayLogs = [];
  StatisticsResponse? _statistics;

  bool _isLoading = false;
  String? _errorMessage;

  TreatmentResponse? get treatment => _treatment;
  List<ScheduleResponse> get schedules => _schedules;
  List<LogResponse> get todayLogs => _todayLogs;
  StatisticsResponse? get statistics => _statistics;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasActiveTreatment => _treatment != null && _treatment!.isActive;

  Future<void> loadCareData() async {
    final cache = CacheService();
    
    // 1. Try to load cached data for instant render
    try {
      final now = DateTime.now();
      final dateStr = _formatDate(now);
      final cachedTreatmentStr = await cache.getCachedData('cache_treatment');
      final cachedSchedulesStr = await cache.getCachedData('cache_schedules');
      final cachedStatsStr = await cache.getCachedData('cache_statistics');
      final cachedTodayLogsStr = await cache.getCachedData('cache_history_${dateStr}_$dateStr');

      if (cachedTreatmentStr != null) {
        _treatment = TreatmentResponse.fromJson(jsonDecode(cachedTreatmentStr));
      }
      if (cachedSchedulesStr != null) {
        final List<dynamic> list = jsonDecode(cachedSchedulesStr);
        _schedules = list.map((e) => ScheduleResponse.fromJson(e)).toList();
      }
      if (cachedStatsStr != null) {
        _statistics = StatisticsResponse.fromJson(jsonDecode(cachedStatsStr));
      }
      if (cachedTodayLogsStr != null) {
        final List<dynamic> list = jsonDecode(cachedTodayLogsStr);
        _todayLogs = list.map((e) => LogResponse.fromJson(e)).toList();
      }

      if (_treatment != null) {
        notifyListeners();
      }
    } catch (_) {}

    _errorMessage = null;

    try {
      // 2. Get treatment from server
      try {
        _treatment = await _dataSource.getTreatment();
        if (_treatment != null) {
          await cache.cacheData('cache_treatment', jsonEncode(_treatment!.toJson()));
        }
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          _treatment = null;
          await cache.clearCache('cache_treatment');
        } else {
          rethrow;
        }
      }

      if (_treatment != null) {
        // 3. Fetch schedules
        _schedules = await _dataSource.getSchedules();
        final jsonSchedules = _schedules.map((e) => e.toJson()).toList();
        await cache.cacheData('cache_schedules', jsonEncode(jsonSchedules));

        // 4. Fetch statistics
        _statistics = await _dataSource.getStatistics();
        if (_statistics != null) {
          await cache.cacheData('cache_statistics', jsonEncode(_statistics!.toJson()));
        }

        // 5. Fetch today's logs
        final now = DateTime.now();
        final dateStr = _formatDate(now);
        _todayLogs = await _dataSource.getHistory(dateStr, dateStr);
        final jsonLogs = _todayLogs.map((e) => e.toJson()).toList();
        await cache.cacheData('cache_history_${dateStr}_$dateStr', jsonEncode(jsonLogs));
      } else {
        _schedules = [];
        _statistics = null;
        _todayLogs = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      // Only set error message if we have no cached data, otherwise remain resilient
      if (_treatment == null) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  Future<bool> setupTreatment({required String timezone, required String startDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _treatment = await _dataSource.createTreatment({
        'start_date': startDate,
        'timezone': timezone,
        'reminder_enabled': true,
      });
      await loadCareData();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTreatmentReminder(bool reminderEnabled) async {
    if (_treatment == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _treatment = await _dataSource.updateTreatment({
        'start_date': _treatment!.startDate,
        'timezone': _treatment!.timezone,
        'reminder_enabled': reminderEnabled,
      });
      // Update cache
      final cache = CacheService();
      await cache.cacheData('cache_treatment', jsonEncode(_treatment!.toJson()));
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTreatment() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dataSource.deleteTreatment();
      _treatment = null;
      _schedules = [];
      _statistics = null;
      _todayLogs = [];
      
      // Clear cache
      final cache = CacheService();
      await cache.clearCache('cache_treatment');
      await cache.clearCache('cache_schedules');
      await cache.clearCache('cache_statistics');
      final dateStr = _formatDate(DateTime.now());
      await cache.clearCache('cache_history_${dateStr}_$dateStr');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSchedule(String reminderTime) async {
    try {
      await _dataSource.addSchedule(reminderTime);
      await loadCareData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _dataSource.deleteSchedule(scheduleId);
      await loadCareData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmMedication(String scheduleId) async {
    try {
      final now = DateTime.now();
      final dateStr = _formatDate(now);
      await _dataSource.confirmMedication(scheduleId, dateStr);
      await loadCareData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
