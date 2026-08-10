import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/cache_service.dart';
import '../../data/datasources/doctor_dashboard_remote_data_source.dart';
import '../../data/models/doctor_dashboard_dto.dart';
import '../../data/repositories/doctor_dashboard_repository_impl.dart';
import '../../domain/repositories/doctor_dashboard_repository.dart';

class DoctorDashboardProvider extends ChangeNotifier {
  late final DoctorDashboardRepository _repository;

  DoctorDashboardProvider({DoctorDashboardRepository? repository}) {
    _repository = repository ??
        DoctorDashboardRepositoryImpl(
          remoteDataSource: DoctorDashboardRemoteDataSourceImpl(
            apiService: ApiService(),
          ),
        );
  }

  DoctorDashboardDTO? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  DoctorDashboardDTO? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboard() async {
    // 1. Try to load cached dashboard data first for instant render
    try {
      final cachedStr = await CacheService().getCachedData('cache_doctor_dashboard');
      if (cachedStr != null && _dashboardData == null) {
        _dashboardData = DoctorDashboardDTO.fromJson(jsonDecode(cachedStr));
        notifyListeners();
      }
    } catch (_) {}

    // Only show loading spinner if we have no dashboard data at all
    if (_dashboardData == null) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _repository.getDoctorDashboard();

    _isLoading = false;

    result.fold(
      (failure) {
        // Only set error message if we don't have cached data to remain resilient
        if (_dashboardData == null) {
          _errorMessage = failure.message;
        }
        notifyListeners();
      },
      (data) {
        _dashboardData = data;
        _errorMessage = null;
        // Save to cache
        try {
          CacheService().cacheData('cache_doctor_dashboard', jsonEncode(data.toJson()));
        } catch (_) {}
        notifyListeners();
      },
    );
  }

  void clearDashboard() {
    _dashboardData = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
