import 'package:flutter/material.dart';

enum UserRole { patient, doctor }

class AuthProvider extends ChangeNotifier {
  // Login & Shared State
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  UserRole _userRole = UserRole.patient;

  String? _emailError;
  String? _passwordError;
  String? _loginError;

  // Sign Up State
  String _name = '';
  String _phoneNo = '';
  String _confirmPassword = '';
  bool _obscureConfirmPassword = true;

  String? _nameError;
  String? _phoneNoError;
  String? _confirmPasswordError;
  String? _signUpError;

  // Getters
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  UserRole get userRole => _userRole;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get loginError => _loginError;

  // Sign Up Getters
  String get name => _name;
  String get phoneNo => _phoneNo;
  String get confirmPassword => _confirmPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  String? get nameError => _nameError;
  String? get phoneNoError => _phoneNoError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get signUpError => _signUpError;

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

  // Validation
  bool validateEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (_email.isEmpty) {
      _emailError = 'Email cannot be empty';
      notifyListeners();
      return false;
    } else if (!emailRegex.hasMatch(_email)) {
      _emailError = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }
    _emailError = null;
    notifyListeners();
    return true;
  }

  bool validatePassword() {
    if (_password.isEmpty) {
      _passwordError = 'Password cannot be empty';
      notifyListeners();
      return false;
    } else if (_password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }
    _passwordError = null;
    notifyListeners();
    return true;
  }

  bool validateName() {
    if (_name.isEmpty) {
      _nameError = 'Name cannot be empty';
      notifyListeners();
      return false;
    } else if (_name.length < 3) {
      _nameError = 'Name must be at least 3 characters';
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
      _phoneNoError = 'Phone number cannot be empty';
      notifyListeners();
      return false;
    } else if (!phoneRegex.hasMatch(_phoneNo)) {
      _phoneNoError = 'Please enter a valid phone number';
      notifyListeners();
      return false;
    } else if (_phoneNo.length < 9) {
      _phoneNoError = 'Phone number must be at least 9 digits';
      notifyListeners();
      return false;
    }
    _phoneNoError = null;
    notifyListeners();
    return true;
  }

  bool validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      notifyListeners();
      return false;
    } else if (_confirmPassword != _password) {
      _confirmPasswordError = 'Passwords do not match';
      notifyListeners();
      return false;
    }
    _confirmPasswordError = null;
    notifyListeners();
    return true;
  }

  // Simulated Login Request
  Future<bool> login() async {
    _loginError = null;
    
    final isEmailValid = validateEmail();
    final isPasswordValid = validatePassword();

    if (!isEmailValid || !isPasswordValid) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple mockup check: credentials are demo@email.com or doctor@email.com / password123
    if (_email == 'demo@email.com' && _password == 'password123') {
      _userRole = UserRole.patient;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (_email == 'doctor@email.com' && _password == 'password123') {
      _userRole = UserRole.doctor;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _loginError = 'Invalid email or password. Use demo@email.com or doctor@email.com / password123';
      notifyListeners();
      return false;
    }
  }

  // Simulated Sign Up Request
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

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true; // Simulate successful registration
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
}
