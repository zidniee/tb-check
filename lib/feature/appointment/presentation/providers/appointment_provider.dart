import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/appointment_remote_data_source.dart';
import '../../data/models/appointment_models.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repository;

  AppointmentProvider({AppointmentRepository? repository})
      : _repository = repository ??
            AppointmentRepositoryImpl(
              remoteDataSource: AppointmentRemoteDataSourceImpl(
                apiService: ApiService(),
              ),
            );

  bool _isLoading = false;
  String? _errorMessage;

  List<DoctorSchedule> _schedules = [];
  List<Appointment> _myAppointments = [];
  AppointmentHistoryResponse? _historyResponse;
  AppointmentDashboard? _dashboard;
  Appointment? _currentAppointment;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DoctorSchedule> get schedules => _schedules;
  List<Appointment> get myAppointments => _myAppointments;
  AppointmentHistoryResponse? get historyResponse => _historyResponse;
  AppointmentDashboard? get dashboard => _dashboard;
  Appointment? get currentAppointment => _currentAppointment;

  Future<void> loadSchedules(String doctorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getSchedulesByDoctor(doctorId);
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _schedules = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createAppointment(CreateAppointmentRequest req) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.createAppointment(req);
    bool success = false;
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) {
        success = true;
        loadDashboard(); // Refresh dashboard data
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> loadMyAppointments({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getMyAppointments(status: status);
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _myAppointments = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAppointmentById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAppointmentById(id);
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _currentAppointment = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> rescheduleAppointment(String id, RescheduleRequest req) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.reschedule(id, req);
    bool success = false;
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) {
        success = true;
        _currentAppointment = data;
        loadDashboard();
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> cancelAppointment(String id, CancelRequest req) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.cancel(id, req);
    bool success = false;
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) {
        success = true;
        _currentAppointment = data;
        loadDashboard();
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> loadHistory({
    String? status,
    int? month,
    int? year,
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getHistory(
      status: status,
      month: month,
      year: year,
      page: page,
      pageSize: pageSize,
    );
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _historyResponse = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getDashboard();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _dashboard = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
