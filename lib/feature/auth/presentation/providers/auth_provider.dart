import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/cache_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../../notification/data/datasources/notification_remote_data_source.dart';

enum UserRole { patient, doctor }

class AuthProvider extends ChangeNotifier {
  late final AuthRepository _authRepository;
  late final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  AuthProvider({AuthRepository? authRepository}) {
    _authRepository = authRepository ??
        AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(
            apiService: ApiService(),
            googleSignIn: GoogleSignIn.instance,
          ),
          storageService: SecureStorageService(),
        );

    _loginWithGoogleUseCase = LoginWithGoogleUseCase(_authRepository);
  }

  // Login & Shared State
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  UserRole _userRole = UserRole.patient;
  bool _isUnverified = false;

  String? _emailError;
  String? _passwordError;
  String? _loginError;

  // Sign Up State
  String _name = '';
  String _phoneNo = '';
  String _confirmPassword = '';
  bool _obscureConfirmPassword = true;
  UserRole _signUpRole = UserRole.patient;

  String? _nameError;
  String? _phoneNoError;
  String? _confirmPasswordError;
  String? _signUpError;

  // Rate Limit Countdown State
  int _rateLimitSeconds = 0;
  Timer? _rateLimitTimer;

  // Getters
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  UserRole get userRole => _userRole;
  bool get isUnverified => _isUnverified;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get loginError => _loginError;

  // Sign Up Getters
  String get name => _name;
  String get phoneNo => _phoneNo;
  String get confirmPassword => _confirmPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  UserRole get signUpRole => _signUpRole;

  String? get nameError => _nameError;
  String? get phoneNoError => _phoneNoError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get signUpError => _signUpError;

  int get rateLimitSeconds => _rateLimitSeconds;

  // Setters & Actions (Login/Shared)
  void setEmail(String value) {
    _email = value;
    if (_emailError != null) {
      validateEmail();
    }
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    if (_passwordError != null) {
      validatePassword();
    }
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  // Setters & Actions (Sign Up)
  void setName(String value) {
    _name = value;
    if (_nameError != null) {
      validateName();
    }
    notifyListeners();
  }

  void setPhoneNo(String value) {
    _phoneNo = value;
    if (_phoneNoError != null) {
      validatePhoneNo();
    }
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    if (_confirmPasswordError != null) {
      validateConfirmPassword();
    }
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setSignUpRole(UserRole role) {
    _signUpRole = role;
    notifyListeners();
  }

  // Validation
  bool validateEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (_email.isEmpty) {
      _emailError = 'Email tidak boleh kosong';
      notifyListeners();
      return false;
    } else if (!emailRegex.hasMatch(_email)) {
      _emailError = 'Masukkan alamat email yang valid';
      notifyListeners();
      return false;
    }
    _emailError = null;
    notifyListeners();
    return true;
  }

  bool validatePassword() {
    if (_password.isEmpty) {
      _passwordError = 'Password tidak boleh kosong';
      notifyListeners();
      return false;
    } else if (_password.length < 6) {
      _passwordError = 'Password minimal 6 karakter';
      notifyListeners();
      return false;
    }
    _passwordError = null;
    notifyListeners();
    return true;
  }

  bool validateName() {
    if (_name.isEmpty) {
      _nameError = 'Nama tidak boleh kosong';
      notifyListeners();
      return false;
    } else if (_name.length < 3) {
      _nameError = 'Nama minimal 3 karakter';
      notifyListeners();
      return false;
    }
    _nameError = null;
    notifyListeners();
    return true;
  }

  bool validatePhoneNo() {
    final phoneRegex = RegExp(r'^[+0-9]+$');
    if (_phoneNo.isEmpty) {
      _phoneNoError = 'Nomor telepon tidak boleh kosong';
      notifyListeners();
      return false;
    } else if (!phoneRegex.hasMatch(_phoneNo)) {
      _phoneNoError = 'Masukkan nomor telepon yang valid';
      notifyListeners();
      return false;
    } else if (_phoneNo.length < 9) {
      _phoneNoError = 'Nomor telepon minimal 9 digit';
      notifyListeners();
      return false;
    }
    _phoneNoError = null;
    notifyListeners();
    return true;
  }

  bool validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Konfirmasi password tidak boleh kosong';
      notifyListeners();
      return false;
    } else if (_confirmPassword != _password) {
      _confirmPasswordError = 'Password tidak cocok';
      notifyListeners();
      return false;
    }
    _confirmPasswordError = null;
    notifyListeners();
    return true;
  }

  // Real API Login Request
  Future<bool> login() async {
    _loginError = null;
    _isUnverified = false;

    final isEmailValid = validateEmail();
    final isPasswordValid = validatePassword();

    if (!isEmailValid || !isPasswordValid) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.login(
      email: _email,
      password: _password,
    );

    _isLoading = false;

    return result.fold(
      (failure) {
        if (failure is ForbiddenException) {
          _isUnverified = true;
          _loginError = 'Email belum diverifikasi. Silakan masukkan OTP.';
        } else if (failure is RateLimitException) {
          _startRateLimitCountdown(60);
          _loginError = failure.message;
        } else {
          _loginError = failure.message;
        }
        notifyListeners();
        return false;
      },
      (authResponse) {
        _userRole = authResponse.user.role == 'DOCTOR' ? UserRole.doctor : UserRole.patient;
        notifyListeners();
        return true;
      },
    );
  }

  // Google Sign-In Request
  Future<bool> loginWithGoogle() async {
    _loginError = null;
    _isLoading = true;
    notifyListeners();

    final result = await _loginWithGoogleUseCase();

    _isLoading = false;

    return result.fold(
      (failure) async {
        _loginError = failure.message;
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}
        notifyListeners();
        return false;
      },
      (authResponse) {
        _userRole = authResponse.user.role == 'DOCTOR' ? UserRole.doctor : UserRole.patient;
        notifyListeners();
        return true;
      },
    );
  }

  // Real API Sign Up Request
  Future<bool> signUp() async {
    _signUpError = null;

    final isNameValid = validateName();
    final isEmailValid = validateEmail();
    final isPhoneValid = validatePhoneNo();
    final isPasswordValid = validatePassword();
    final isConfirmPasswordValid = validateConfirmPassword();

    if (!isNameValid || !isEmailValid || !isPhoneValid || !isPasswordValid || !isConfirmPasswordValid) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final roleStr = _signUpRole == UserRole.doctor ? 'DOCTOR' : 'PATIENT';
    final result = await _authRepository.register(
      name: _name,
      email: _email,
      password: _password,
      role: roleStr,
      phoneNumber: _phoneNo,
    );

    _isLoading = false;

    return result.fold(
      (failure) {
        if (failure is RateLimitException) {
          _startRateLimitCountdown(60);
        }
        _signUpError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _isUnverified = true;
        notifyListeners();
        return true;
      },
    );
  }

  // OTP Verification Request
  Future<bool> verifyOTP(String otp) async {
    _isLoading = true;
    _loginError = null;
    _signUpError = null;
    notifyListeners();

    final result = await _authRepository.verifyEmail(
      email: _email,
      otp: otp,
    );

    _isLoading = false;

    return result.fold(
      (failure) {
        _loginError = failure.message;
        _signUpError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _isUnverified = false;
        notifyListeners();
        return true;
      },
    );
  }

  // Resend OTP Request
  Future<bool> resendOTP() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.resendOTP(email: _email);

    _isLoading = false;

    return result.fold(
      (failure) {
        if (failure is RateLimitException) {
          _startRateLimitCountdown(60);
        }
        _loginError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        notifyListeners();
        return true;
      },
    );
  }

  // Forgot Password Request
  Future<bool> forgotPassword(String targetEmail) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.forgotPassword(email: targetEmail);

    _isLoading = false;

    return result.fold(
      (failure) {
        if (failure is RateLimitException) {
          _startRateLimitCountdown(60);
        }
        _loginError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _email = targetEmail;
        notifyListeners();
        return true;
      },
    );
  }

  // Reset Password Request
  Future<bool> resetPassword({
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.resetPassword(
      email: _email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;

    return result.fold(
      (failure) {
        _loginError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        notifyListeners();
        return true;
      },
    );
  }

  void _startRateLimitCountdown(int seconds) {
    _rateLimitSeconds = seconds;
    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rateLimitSeconds > 0) {
        _rateLimitSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');
      if (deviceId != null && deviceId.isNotEmpty) {
        final notifDS = NotificationRemoteDataSourceImpl(apiService: ApiService());
        await notifDS.unregisterDeviceToken(deviceId: deviceId);
      }
    } catch (_) {}

    // Clear all business data caches
    try {
      await CacheService().clearAllCache();
    } catch (_) {}

    await _authRepository.logout();

    _userRole = UserRole.patient;
    _isUnverified = false;
    clearErrors();
    _isLoading = false;
    notifyListeners();
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    _loginError = null;
    _nameError = null;
    _phoneNoError = null;
    _confirmPasswordError = null;
    _signUpError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _rateLimitTimer?.cancel();
    super.dispose();
  }
}
