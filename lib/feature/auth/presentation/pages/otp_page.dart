import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  
  int _secondsRemaining = 59;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resendCode() async {
    if (_secondsRemaining == 0) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.resendOTP();
      if (success) {
        setState(() {
          _errorMessage = null;
          _startTimer();
        });
        if (mounted) {
          SnackBarUtils.showInfo(context, 'Kode OTP baru berhasil dikirim ke ${widget.email}');
        }
      } else {
        setState(() {
          _errorMessage = authProvider.loginError ?? 'Gagal mengirim ulang OTP';
        });
      }
    }
  }

  void _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < _otpLength) {
      setState(() {
        _errorMessage = 'Masukkan semua $_otpLength digit kode OTP';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOTP(code);

    if (!mounted) return;

    if (success) {
      SnackBarUtils.showSuccess(context, 'Verifikasi Email Berhasil!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _errorMessage = authProvider.loginError ?? authProvider.signUpError ?? 'Kode OTP salah atau kadaluarsa';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              Text(
                'Verifikasi OTP',
                style: AppTextStyles.headingSubtitle.copyWith(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Kami telah mengirimkan 6 digit kode OTP ke email Anda:\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // 6-Digit OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: 44,
                    height: 54,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.headingSubtitle.copyWith(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                        ),
                        fillColor: AppColors.background,
                        filled: true,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < _otpLength - 1) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                          }
                        } else {
                          if (index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsRemaining > 0 
                      ? "Kirim ulang kode dalam "
                      : "Belum menerima kode? ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _secondsRemaining == 0 ? _resendCode : null,
                    child: Text(
                      _secondsRemaining > 0
                        ? "$_secondsRemaining detik"
                        : "Kirim Ulang",
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              
              const SizedBox(height: 36),

              CustomButton(
                text: 'Verifikasi',
                isLoading: authProvider.isLoading,
                onPressed: _verifyCode,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah Punya Akun? ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text(
                      'Masuk',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
