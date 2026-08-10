import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/models/doctor_profile_dto.dart';
import '../../data/models/patient_profile_dto.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  late final ProfileRepository _profileRepository;
  final SecureStorageService _storage = SecureStorageService();

  ProfileProvider({ProfileRepository? repository}) {
    _profileRepository = repository ??
        ProfileRepositoryImpl(
          remoteDataSource: ProfileRemoteDataSourceImpl(
            apiService: ApiService(),
          ),
        );
    loadLocalProfile();
  }

  // Database fields for patient profile
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _gender = 'L';
  String _birthDate = '';
  String _address = '';
  String _nik = '';
  String _kkNumber = '';
  bool _bcgVaccinated = false;
  String? _profilePicturePath;

  // Location fields
  double? _latitude;
  double? _longitude;

  // Doctor-specific fields
  String _doctorName = '';
  String _doctorSpecialization = '';
  String _doctorStrNumber = '';
  String _doctorPhone = '';

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get fullName => _fullName;
  String get email => _email;
  String get phone => _phone;
  String get gender {
    if (_gender == 'L' || _gender == 'M' || _gender.toLowerCase() == 'laki-laki') {
      return 'Laki-laki';
    } else if (_gender == 'P' || _gender == 'F' || _gender.toLowerCase() == 'perempuan') {
      return 'Perempuan';
    }
    return 'Laki-laki';
  }
  String get birthDate => _birthDate;
  String get address => _address;
  String get nik => _nik;
  String get kkNumber => _kkNumber;

  String get maskedNik {
    if (_nik.length <= 4) return _nik;
    return '*' * (_nik.length - 4) + _nik.substring(_nik.length - 4);
  }

  String get maskedKkNumber {
    if (_kkNumber.length <= 4) return _kkNumber;
    return '*' * (_kkNumber.length - 4) + _kkNumber.substring(_kkNumber.length - 4);
  }

  bool get bcgVaccinated => _bcgVaccinated;
  String? get profilePicturePath => _profilePicturePath;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Doctor Getters
  String get doctorName => _doctorName;
  String get doctorSpecialization => _doctorSpecialization;
  String get doctorStrNumber => _doctorStrNumber;
  String get doctorPhone => _doctorPhone;

  Future<void> loadLocalProfile() async {
    try {
      final jsonString = await _storage.getProfileData();
      final localAvatar = await _storage.getLocalAvatarPath();
      final savedEmail = await _storage.getUserEmail();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _email = savedEmail;
      }

      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        if (json.containsKey('patient_id')) {
          final profileData = PatientProfileDTO.fromJson(json);
          _fullName = profileData.fullName;
          if (profileData.email.isNotEmpty && profileData.email.contains('@')) {
            _email = profileData.email;
          }
          _phone = profileData.phone;
          _gender = profileData.gender;
          _birthDate = profileData.birthDate;
          _address = profileData.address;
          _nik = profileData.nik;
          _kkNumber = profileData.kkNumber;
          _bcgVaccinated = profileData.bcgVaccinated;
          _latitude = profileData.latitude;
          _longitude = profileData.longitude;
          _profilePicturePath = (localAvatar != null && File(localAvatar).existsSync())
              ? localAvatar
              : profileData.profilePictureUrl;
        } else if (json.containsKey('doctor_id')) {
          final profileData = DoctorProfileDTO.fromJson(json);
          _doctorName = profileData.fullName;
          if (profileData.email.isNotEmpty && profileData.email.contains('@')) {
            _email = profileData.email;
          }
          _doctorPhone = profileData.phone;
          _doctorSpecialization = profileData.specialization;
          _doctorStrNumber = profileData.strNumber;
          _profilePicturePath = (localAvatar != null && File(localAvatar).existsSync())
              ? localAvatar
              : profileData.profilePictureUrl;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchProfile() async {
    if (_fullName.isEmpty && _doctorName.isEmpty) {
      await loadLocalProfile();
    }

    if (_fullName.isEmpty && _doctorName.isEmpty) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final savedEmail = await _storage.getUserEmail();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _email = savedEmail;
    }

    final result = await _profileRepository.getMyProfile();

    _isLoading = false;

    await result.fold(
      (failure) async {
        if (_fullName.isEmpty && _doctorName.isEmpty) {
          _errorMessage = failure.message;
        }
        notifyListeners();
      },
      (profileData) async {
        final localAvatar = await _storage.getLocalAvatarPath();
        final hasValidLocalAvatar = localAvatar != null && File(localAvatar).existsSync();

        if (profileData is PatientProfileDTO) {
          _fullName = profileData.fullName;
          if (profileData.email.isNotEmpty && profileData.email.contains('@')) {
            _email = profileData.email;
          }
          _phone = profileData.phone;
          _gender = profileData.gender;
          _birthDate = profileData.birthDate;
          _address = profileData.address;
          _nik = profileData.nik;
          _kkNumber = profileData.kkNumber;
          _bcgVaccinated = profileData.bcgVaccinated;
          _latitude = profileData.latitude;
          _longitude = profileData.longitude;
          _profilePicturePath = hasValidLocalAvatar ? localAvatar : profileData.profilePictureUrl;

          await _storage.saveProfileData(jsonEncode(profileData.toJson()));
          if (profileData.profilePictureUrl.isNotEmpty) {
            await _syncAvatarImage(profileData.profilePictureUrl);
          }
        } else if (profileData is DoctorProfileDTO) {
          _doctorName = profileData.fullName;
          if (profileData.email.isNotEmpty && profileData.email.contains('@')) {
            _email = profileData.email;
          }
          _doctorPhone = profileData.phone;
          _doctorSpecialization = profileData.specialization;
          _doctorStrNumber = profileData.strNumber;
          _profilePicturePath = hasValidLocalAvatar ? localAvatar : profileData.profilePictureUrl;

          await _storage.saveProfileData(jsonEncode(profileData.toJson()));
          if (profileData.profilePictureUrl.isNotEmpty) {
            await _syncAvatarImage(profileData.profilePictureUrl);
          }
        }
        notifyListeners();
      },
    );
  }

  Future<void> _syncAvatarImage(String url) async {
    try {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final docDir = await getApplicationDocumentsDirectory();
        final savePath = '${docDir.path}/user_avatar.jpg';

        final isInternalApi = url.startsWith(EnvConfig.apiBaseUrl);
        final dio = isInternalApi ? ApiService().dio : Dio();

        await dio.download(url, savePath);

        if (File(savePath).existsSync()) {
          try {
            final bytes = await File(savePath).readAsBytes();
            final decoded = img.decodeImage(bytes);
            if (decoded != null) {
              final oriented = img.bakeOrientation(decoded);
              final fixedBytes = img.encodeJpg(oriented, quality: 85);
              await File(savePath).writeAsBytes(fixedBytes);
            }
          } catch (_) {}

          _profilePicturePath = savePath;
          await _storage.saveLocalAvatarPath(savePath);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error syncing avatar image: $e');
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String birthDate,
    required String address,
    required String nik,
    required String kkNumber,
    required bool bcgVaccinated,
    String? profilePicturePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    File? avatarFile;
    if (profilePicturePath != null && !profilePicturePath.startsWith('http')) {
      avatarFile = File(profilePicturePath);
    }

    final result = await _profileRepository.updatePatientProfile(
      fullName: fullName,
      phone: phone,
      gender: gender,
      birthDate: birthDate,
      address: address,
      nik: nik,
      kkNumber: kkNumber,
      bcgVaccinated: bcgVaccinated,
      avatarFile: avatarFile,
    );

    _isLoading = false;

    return await result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) async {
        _fullName = fullName;
        _phone = phone;
        _gender = gender;
        _birthDate = birthDate;
        _address = address;
        _nik = nik;
        _kkNumber = kkNumber;
        _bcgVaccinated = bcgVaccinated;

        if (profilePicturePath != null && File(profilePicturePath).existsSync()) {
          try {
            final docDir = await getApplicationDocumentsDirectory();
            final permanentPath = '${docDir.path}/user_avatar.jpg';
            await File(profilePicturePath).copy(permanentPath);
            _profilePicturePath = permanentPath;
            await _storage.saveLocalAvatarPath(permanentPath);
          } catch (_) {
            _profilePicturePath = profilePicturePath;
            await _storage.saveLocalAvatarPath(profilePicturePath);
          }
        }
        await fetchProfile();
        return true;
      },
    );
  }

  Future<bool> updateDoctorProfile({
    required String fullName,
    required String phone,
    required String specialization,
    required String strNumber,
    String? profilePicturePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    File? avatarFile;
    if (profilePicturePath != null && !profilePicturePath.startsWith('http')) {
      avatarFile = File(profilePicturePath);
    }

    final result = await _profileRepository.updateDoctorProfile(
      fullName: fullName,
      phone: phone,
      specialization: specialization,
      strNumber: strNumber,
      avatarFile: avatarFile,
    );

    _isLoading = false;

    return await result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) async {
        _doctorName = fullName;
        _doctorPhone = phone;
        _doctorSpecialization = specialization;
        _doctorStrNumber = strNumber;

        if (profilePicturePath != null && File(profilePicturePath).existsSync()) {
          try {
            final docDir = await getApplicationDocumentsDirectory();
            final permanentPath = '${docDir.path}/user_avatar.jpg';
            await File(profilePicturePath).copy(permanentPath);
            _profilePicturePath = permanentPath;
            await _storage.saveLocalAvatarPath(permanentPath);
          } catch (_) {
            _profilePicturePath = profilePicturePath;
            await _storage.saveLocalAvatarPath(profilePicturePath);
          }
        }
        await fetchProfile();
        return true;
      },
    );
  }

  Future<bool> updateGPSLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await _profileRepository.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return result.fold(
        (_) => false,
        (_) {
          _latitude = position.latitude;
          _longitude = position.longitude;
          notifyListeners();
          return true;
        },
      );
    } catch (_) {
      return false;
    }
  }

  void clearProfile() {
    _fullName = '';
    _phone = '';
    _gender = 'L';
    _birthDate = '';
    _address = '';
    _nik = '';
    _kkNumber = '';
    _bcgVaccinated = false;
    _profilePicturePath = null;
    _latitude = null;
    _longitude = null;
    _doctorName = '';
    _doctorSpecialization = '';
    _doctorStrNumber = '';
    _doctorPhone = '';
    _errorMessage = null;
    _storage.saveProfileData('');
    _storage.saveLocalAvatarPath('');
    notifyListeners();
  }
}
