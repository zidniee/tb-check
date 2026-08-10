import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/storage/cache_service.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/hospital_remote_data_source.dart';
import '../../data/models/hospital_dto.dart';
import '../../data/repositories/hospital_repository_impl.dart';
import '../../domain/repositories/hospital_repository.dart';

class HospitalProvider extends ChangeNotifier {
  late final HospitalRepository _hospitalRepository;
  
  bool _isLoading = false;
  List<HospitalDTO> _hospitals = [];
  List<HospitalDTO> _filteredHospitals = [];
  String? _errorMessage;
  Position? _userPosition;
  final Map<String, double> _hospitalDistances = {}; // Distances in meters

  HospitalProvider({HospitalRepository? repository}) {
    _hospitalRepository = repository ??
        HospitalRepositoryImpl(
          remoteDataSource: HospitalRemoteDataSourceImpl(
            apiService: ApiService(),
          ),
        );
  }

  // Getters
  bool get isLoading => _isLoading;
  List<HospitalDTO> get hospitals => _hospitals;
  List<HospitalDTO> get filteredHospitals => _filteredHospitals;
  String? get errorMessage => _errorMessage;
  Position? get userPosition => _userPosition;
  Map<String, double> get hospitalDistances => _hospitalDistances;

  /// Fetches all hospitals from the remote source
  Future<void> fetchHospitals() async {
    _errorMessage = null;

    // 1. Try to load cached hospitals instantly
    try {
      final cachedStr = await CacheService().getCachedData('cache_hospitals');
      if (cachedStr != null && _hospitals.isEmpty) {
        final List<dynamic> jsonList = jsonDecode(cachedStr);
        _hospitals = jsonList.map((e) => HospitalDTO.fromJson(e as Map<String, dynamic>)).toList();
        _filteredHospitals = List.from(_hospitals);
        if (_userPosition != null) {
          _calculateDistancesAndSort();
        }
        notifyListeners();
      }
    } catch (_) {}

    // Only show loading if we have no hospitals yet
    if (_hospitals.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    final result = await _hospitalRepository.getAllHospitals();

    result.fold(
      (failure) {
        if (_hospitals.isEmpty) {
          _errorMessage = failure.message;
          _hospitals = [];
          _filteredHospitals = [];
        }
      },
      (data) {
        _hospitals = data.where((h) => h.isActive).toList();
        _filteredHospitals = List.from(_hospitals);

        // Save to cache
        try {
          final jsonList = _hospitals.map((e) => e.toJson()).toList();
          CacheService().cacheData('cache_hospitals', jsonEncode(jsonList));
        } catch (_) {}
        
        // If we already have the user position, calculate distances and sort immediately
        if (_userPosition != null) {
          _calculateDistancesAndSort();
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Searches hospitals by name
  void searchHospitals(String query) {
    if (query.isEmpty) {
      _filteredHospitals = List.from(_hospitals);
    } else {
      _filteredHospitals = _hospitals
          .where((h) => h.hospitalName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Requests location permission and updates user position to sort hospitals by distance
  Future<bool> determinePositionAndSort() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Layanan lokasi (GPS) dinonaktifkan. Silakan aktifkan GPS Anda.';
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Izin lokasi ditolak.';
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Izin lokasi ditolak secara permanen. Silakan aktifkan dari pengaturan.';
        notifyListeners();
        return false;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _calculateDistancesAndSort();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mendapatkan lokasi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Internal helper to calculate distances and sort the lists
  void _calculateDistancesAndSort() {
    if (_userPosition == null) return;

    for (var hospital in _hospitals) {
      final distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        hospital.latitude,
        hospital.longitude,
      );
      _hospitalDistances[hospital.hospitalId] = distance;
    }

    // Sort original and filtered lists by distance
    _hospitals.sort((a, b) {
      final distA = _hospitalDistances[a.hospitalId] ?? double.infinity;
      final distB = _hospitalDistances[b.hospitalId] ?? double.infinity;
      return distA.compareTo(distB);
    });

    _filteredHospitals.sort((a, b) {
      final distA = _hospitalDistances[a.hospitalId] ?? double.infinity;
      final distB = _hospitalDistances[b.hospitalId] ?? double.infinity;
      return distA.compareTo(distB);
    });
  }

  /// Helper to get formatted distance string for UI
  String getFormattedDistance(String hospitalId) {
    final distanceInMeters = _hospitalDistances[hospitalId];
    if (distanceInMeters == null) return '';

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }
}
