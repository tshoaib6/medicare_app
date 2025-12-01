import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/primary_button.dart';

import '../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';
import '../../user/screens/edit_profile_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  static const routeName = '/otp';
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _loading = false;
  bool _resendLoading = false;
  String? _error;
  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    // Auto-verify when all 6 digits are entered
    if (_otpCode.length == 6) {
      _verify();
    }
  }

  Future<void> _verify() async {
    final code = _otpCode;
    if (code.length != 6) {
      setState(() => _error = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      await auth.verifyOtp(code);

      if (!mounted) return;

      switch (auth.status) {
        case AuthStatus.profileIncomplete:
          Navigator.of(context)
              .pushReplacementNamed(EditProfileScreen.routeName);
          break;
        case AuthStatus.authenticated:
          Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
          break;
        default:
          break;
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Provide more user-friendly error messages
        if (errorMessage.contains('Resource not found') ||
            errorMessage.contains('404')) {
          errorMessage =
              'OTP verification service is not available. Please contact support.';
        } else if (errorMessage.contains('Invalid') ||
            errorMessage.contains('wrong')) {
          errorMessage = 'Invalid verification code. Please try again.';
        } else if (errorMessage.contains('expired')) {
          errorMessage =
              'Verification code has expired. Please request a new code.';
        } else if (errorMessage.contains('timeout') ||
            errorMessage.contains('network')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        }

        setState(() => _error = errorMessage);
        // Clear OTP fields on error
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;

    setState(() {
      _resendLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      await auth.sendOtp();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Verification code resent. Please check your email.'),
          backgroundColor: AppColors.success,
        ),
      );
      _startCountdown();
    } catch (e) {
      if (!mounted) return;

      setState(() => _error = 'Failed to resend code: $e');
    } finally {
      if (mounted) {
        setState(() => _resendLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();
    final email = auth.tempEmail ?? auth.user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Verify your email',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to $email. Enter it below to verify your account.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.border, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.border, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.destructive, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                          ),
                          onChanged: (value) => _onOtpChanged(index, value),
                          onTap: () {
                            _otpControllers[index].selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: _otpControllers[index].text.length),
                            );
                          },
                          onEditingComplete: () {
                            if (index < 5 &&
                                _otpControllers[index].text.isNotEmpty) {
                              _focusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withValues(alpha: 0.1),
                        border: Border.all(
                            color:
                                AppColors.destructive.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.destructive,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Verify Button
                  PrimaryButton(
                    label: 'Verify email',
                    loading: _loading,
                    onPressed: _otpCode.length == 6 ? _verify : null,
                  ),

                  const SizedBox(height: 24),

                  // Resend Section
                  Center(
                    child: Column(
                      children: [
                        if (!_canResend) ...[
                          Text(
                            'Didn\'t receive the code?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Resend code in $_countdown seconds',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Didn\'t receive the code?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _resendLoading ? null : _resend,
                            child: _resendLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(
                                    'Resend code',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
