import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getDoctorDashboard();

    _isLoading = false;

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (data) {
        _dashboardData = data;
        notifyListeners();
      },
    );
  }
}
