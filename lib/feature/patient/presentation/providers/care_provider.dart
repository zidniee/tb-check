import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get treatment
      try {
        _treatment = await _dataSource.getTreatment();
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          _treatment = null;
        } else {
          rethrow;
        }
      }

      if (_treatment != null) {
        // 2. Fetch schedules
        _schedules = await _dataSource.getSchedules();

        // 3. Fetch statistics
        _statistics = await _dataSource.getStatistics();

        // 4. Fetch today's logs
        final now = DateTime.now();
        final dateStr = _formatDate(now);
        _todayLogs = await _dataSource.getHistory(dateStr, dateStr);
      } else {
        _schedules = [];
        _statistics = null;
        _todayLogs = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
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
