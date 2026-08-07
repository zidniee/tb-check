import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/patient_dashboard_dto.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  late final DashboardRepository _repository;

  DashboardProvider({DashboardRepository? repository}) {
    _repository = repository ??
        DashboardRepositoryImpl(
          remoteDataSource: DashboardRemoteDataSourceImpl(
            apiService: ApiService(),
          ),
        );
  }

  PatientDashboardDTO? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  PatientDashboardDTO? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getPatientDashboard();

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
