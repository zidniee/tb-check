import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../shared/widgets/custom_button.dart';

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
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  int _secondsRemaining = 59;
  Timer? _timer;
  bool _isVerifying = false;
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

  void _resendCode() {
    if (_secondsRemaining == 0) {
      setState(() {
        _errorMessage = null;
        _startTimer();
      });
      SnackBarUtils.showInfo(context, 'OTP code resent to ${widget.email}');
    }
  }

  void _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      setState(() {
        _errorMessage = 'Please enter all 4 digits';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (code == '1234') {
      SnackBarUtils.showSuccess(context, 'Verification Successful!');
      // Simulating returning successfully to main app entry/dashboard
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _errorMessage = 'Invalid OTP code. Try entering 1234';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 40),
              
              // Title "Enter OTP"
              Text(
                'Enter OTP',
                style: AppTextStyles.headingSubtitle.copyWith(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "We've sent an OTP code to your email,\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 4-Digit OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 64,
                    height: 64,
                    child: KeyboardListener(
                      focusNode: FocusNode(), // Dummy focus node for key interception
                      onKeyEvent: (event) {
                        // Handle backspace when text field is empty to move backward
                        if (event is KeyDownEvent && 
                            event.logicalKey == LogicalKeyboardKey.backspace && 
                            _controllers[index].text.isEmpty && 
                            index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.headingSubtitle.copyWith(
                          fontSize: 24,
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
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                          ),
                          fillColor: AppColors.background,
                          filled: true,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 3) {
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
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Resend Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsRemaining > 0 
                      ? "We will resend the code in "
                      : "Didn't receive the code? ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _secondsRemaining == 0 ? _resendCode : null,
                    child: Text(
                      _secondsRemaining > 0
                        ? "${_secondsRemaining} s"
                        : "Resend Code",
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Error Message
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
              
              const SizedBox(height: 48),

              // Verify Button
              CustomButton(
                text: 'Verify',
                isLoading: _isVerifying,
                onPressed: _verifyCode,
              ),
              const SizedBox(height: 32),

              // Redirect back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an Account! ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate back to Login (pop until the login/root screen)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text(
                      'Login',
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
