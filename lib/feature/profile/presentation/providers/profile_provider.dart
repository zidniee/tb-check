import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  // Database fields for patient profile
  String _fullName = 'Ahmad Pasien';
  String _phone = '08123456789';
  String _gender = 'Laki-laki';
  String _birthDate = '1995-06-15'; // YYYY-MM-DD
  String _address = 'Jl. Slamet Riyadi No. 124, Surakarta';
  String _nik = '1234567890123456';
  String _kkNumber = '1234567890123456';
  bool _bcgVaccinated = true;
  String? _profilePicturePath;

  // Doctor-specific fields
  String _doctorName = 'Dr. Dian Sp.P';
  String _doctorSpecialization = 'Spesialis Paru (Sp.P)';
  String _doctorStrNumber = 'STR-12345678';
  String _doctorPhone = '08129876543';

  bool _isLoading = false;

  // Getters
  String get fullName => _fullName;
  String get phone => _phone;
  String get gender => _gender;
  String get birthDate => _birthDate;
  String get address => _address;
  String get nik => _nik;
  String get kkNumber => _kkNumber;
  bool get bcgVaccinated => _bcgVaccinated;
  String? get profilePicturePath => _profilePicturePath;
  bool get isLoading => _isLoading;

  // Doctor Getters
  String get doctorName => _doctorName;
  String get doctorSpecialization => _doctorSpecialization;
  String get doctorStrNumber => _doctorStrNumber;
  String get doctorPhone => _doctorPhone;

  // Simulate updating patient profile in database
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
    notifyListeners();

    // Simulate database delay
    await Future.delayed(const Duration(milliseconds: 800));

    _fullName = fullName;
    _phone = phone;
    _gender = gender;
    _birthDate = birthDate;
    _address = address;
    _nik = nik;
    _kkNumber = kkNumber;
    _bcgVaccinated = bcgVaccinated;
    _profilePicturePath = profilePicturePath;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Simulate updating doctor profile in database
  Future<bool> updateDoctorProfile({
    required String fullName,
    required String phone,
    required String specialization,
    required String strNumber,
    String? profilePicturePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate database delay
    await Future.delayed(const Duration(milliseconds: 800));

    _doctorName = fullName;
    _doctorPhone = phone;
    _doctorSpecialization = specialization;
    _doctorStrNumber = strNumber;
    _profilePicturePath = profilePicturePath;

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
