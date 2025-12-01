import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/validators.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../../../core/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  bool _facebookLoading = false;
  bool _appleLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _formatPhoneNumber() {
    final text = _phoneCtrl.text;
    final formatted = Validators.formatPhoneNumber(text);
    if (formatted != text) {
      _phoneCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate phone number format
    final cleanedPhone = _phoneCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedPhone.length != 10) {
      setState(() {
        _error = 'Please enter a valid 10-digit phone number';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      // Login with phone number
      await auth.login(
        phoneNumber: cleanedPhone,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      _navigateBasedOnStatus(auth.status);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      await auth.googleLogin();

      if (!mounted) return;
      _navigateBasedOnStatus(auth.status);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Google sign-in failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _googleLoading = false;
        });
      }
    }
  }

  Future<void> _facebookLogin() async {
    setState(() {
      _facebookLoading = true;
      _error = null;
    });

    try {
      // Simulate Facebook login for demo
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _error = 'Demo: Facebook sign-in requires OAuth integration';
      });
    } finally {
      if (mounted) {
        setState(() {
          _facebookLoading = false;
        });
      }
    }
  }

  Future<void> _appleLogin() async {
    setState(() {
      _appleLoading = true;
      _error = null;
    });

    try {
      // Simulate Apple login for demo
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _error = 'Demo: Apple sign-in requires OAuth integration';
      });
    } finally {
      if (mounted) {
        setState(() {
          _appleLoading = false;
        });
      }
    }
  }

  void _navigateBasedOnStatus(AuthStatus status) {
    switch (status) {
      case AuthStatus.emailUnverified:
        Navigator.of(context)
            .pushReplacementNamed(OtpVerificationScreen.routeName);
        break;
      case AuthStatus.profileIncomplete:
        Navigator.of(context).pushReplacementNamed(EditProfileScreen.routeName);
        break;
      case AuthStatus.authenticated:
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
        break;
      default:
        // Handle other cases or stay on login
        break;
    }
  }

  void _continueAsGuest() {
    final auth = context.read<AuthProvider>();
    auth.setGuestMode();
    Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Logo Section
                    Column(
                      children: [
                        // Medicare Logo with Shield and Heart
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 48,
                                  color: AppColors.info,
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Icon(
                                    Icons.favorite,
                                    size: 24,
                                    color: AppColors.destructive,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Medicare +',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back to your health portal',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Login Card
                    Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Sign In',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Error Message
                            if (_error != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.destructive
                                      .withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: AppColors.destructive
                                        .withValues(alpha: 0.3),
                                  ),
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

                            // Login Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Phone Number Field
                                  Text(
                                    'Phone Number',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    label: '',
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    validator: Validators.phoneNumber,
                                    hintText: '123-456-7890',
                                    onChanged: (_) => _formatPhoneNumber(),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(
                                          12), // Allow for dashes
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  Text(
                                    'Password',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    label: '',
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    validator: (value) => Validators.required(
                                        value,
                                        fieldName: 'Password'),
                                    hintText: 'Enter your password',
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Sign In Button
                                  PrimaryButton(
                                    label:
                                        _loading ? 'Signing In...' : 'Sign In',
                                    loading: _loading,
                                    onPressed: _submit,
                                  ),

                                  const SizedBox(height: 24),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                          child:
                                              Divider(color: AppColors.border)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          'Or continue with',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child:
                                              Divider(color: AppColors.border)),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Social Login Buttons
                                  _buildSocialButton(
                                    onPressed: _googleLogin,
                                    loading: _googleLoading,
                                    icon: _buildGoogleIcon(),
                                    label: 'Sign in with Google',
                                  ),

                                  const SizedBox(height: 12),

                                  _buildSocialButton(
                                    onPressed: _facebookLogin,
                                    loading: _facebookLoading,
                                    icon: Icon(Icons.facebook,
                                        color: Color(0xFF1877F2), size: 20),
                                    label: 'Sign in with Facebook',
                                  ),

                                  const SizedBox(height: 12),

                                  _buildSocialButton(
                                    onPressed: _appleLogin,
                                    loading: _appleLoading,
                                    icon: Icon(Icons.apple,
                                        color: Colors.black, size: 20),
                                    label: 'Sign in with Apple',
                                  ),

                                  const SizedBox(height: 24),

                                  // Guest Mode Button
                                  PrimaryButton(
                                    label: 'Continue as Guest',
                                    onPressed: _continueAsGuest,
                                    outlined: true,
                                  ),

                                  const SizedBox(height: 16),

                                  // Forgot Password Link
                                  Center(
                                    child: TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed(
                                              ForgotPasswordScreen.routeName),
                                      child: Text(
                                        'Forgot your password?',
                                        style: TextStyle(
                                          color: AppColors.info,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Sign Up Link
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Don\'t have an account? ',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.of(context)
                                              .pushNamed(
                                                  SignUpScreen.routeName),
                                          child: Text(
                                            'Sign up',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppColors.info,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required bool loading,
    required Widget icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon,
        label: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.9167, size.height * 0.5)
        ..cubicTo(
            size.width * 0.9167,
            size.height * 0.4375,
            size.width * 0.8958,
            size.height * 0.3854,
            size.width * 0.8542,
            size.height * 0.3333)
        ..lineTo(size.width * 0.5, size.height * 0.3333)
        ..lineTo(size.width * 0.5, size.height * 0.6667)
        ..lineTo(size.width * 0.7917, size.height * 0.6667)
        ..cubicTo(
            size.width * 0.7708,
            size.height * 0.7292,
            size.width * 0.7292,
            size.height * 0.7708,
            size.width * 0.6667,
            size.height * 0.7917)
        ..cubicTo(
            size.width * 0.6042,
            size.height * 0.8125,
            size.width * 0.5417,
            size.height * 0.8125,
            size.width * 0.4792,
            size.height * 0.7917)
        ..cubicTo(
            size.width * 0.4167,
            size.height * 0.7708,
            size.width * 0.3750,
            size.height * 0.7292,
            size.width * 0.3542,
            size.height * 0.6667)
        ..lineTo(size.width * 0.1667, size.height * 0.7708)
        ..cubicTo(
            size.width * 0.2083,
            size.height * 0.8958,
            size.width * 0.2917,
            size.height * 1,
            size.width * 0.5,
            size.height * 1)
        ..cubicTo(size.width * 0.7708, size.height * 1, size.width * 1,
            size.height * 0.7708, size.width * 1, size.height * 0.5)
        ..close(),
      paint,
    );

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 1)
        ..cubicTo(size.width * 0.2917, size.height * 1, size.width * 0.2083,
            size.height * 0.8958, size.width * 0.1667, size.height * 0.7708)
        ..lineTo(size.width * 0.3542, size.height * 0.6667)
        ..cubicTo(
            size.width * 0.3750,
            size.height * 0.7292,
            size.width * 0.4167,
            size.height * 0.7708,
            size.width * 0.4792,
            size.height * 0.7917)
        ..cubicTo(
            size.width * 0.5417,
            size.height * 0.8125,
            size.width * 0.6042,
            size.height * 0.8125,
            size.width * 0.6667,
            size.height * 0.7917)
        ..lineTo(size.width * 0.8333, size.height * 0.8958)
        ..cubicTo(
            size.width * 0.7708,
            size.height * 0.9583,
            size.width * 0.6458,
            size.height * 1,
            size.width * 0.5,
            size.height * 1)
        ..close(),
      paint,
    );

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.1667, size.height * 0.2292)
        ..cubicTo(
            size.width * 0.2083,
            size.height * 0.1042,
            size.width * 0.2917,
            size.height * 0,
            size.width * 0.5,
            size.height * 0)
        ..cubicTo(size.width * 0.6458, size.height * 0, size.width * 0.7708,
            size.height * 0.0417, size.width * 0.8333, size.height * 0.1042)
        ..lineTo(size.width * 0.6667, size.height * 0.2083)
        ..cubicTo(
            size.width * 0.6042,
            size.height * 0.1875,
            size.width * 0.5417,
            size.height * 0.1875,
            size.width * 0.4792,
            size.height * 0.2083)
        ..cubicTo(
            size.width * 0.4167,
            size.height * 0.2292,
            size.width * 0.3750,
            size.height * 0.2708,
            size.width * 0.3542,
            size.height * 0.3333)
        ..lineTo(size.width * 0.1667, size.height * 0.2292)
        ..close(),
      paint,
    );

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.3333)
        ..lineTo(size.width * 0.8542, size.height * 0.3333)
        ..lineTo(size.width * 0.8333, size.height * 0.1042)
        ..cubicTo(
            size.width * 0.7708,
            size.height * 0.0417,
            size.width * 0.6458,
            size.height * 0,
            size.width * 0.5,
            size.height * 0)
        ..cubicTo(size.width * 0.2917, size.height * 0, size.width * 0.2083,
            size.height * 0.1042, size.width * 0.1667, size.height * 0.2292)
        ..lineTo(size.width * 0.3542, size.height * 0.3333)
        ..cubicTo(
            size.width * 0.3750,
            size.height * 0.2708,
            size.width * 0.4167,
            size.height * 0.2292,
            size.width * 0.4792,
            size.height * 0.2083)
        ..cubicTo(
            size.width * 0.5417,
            size.height * 0.1875,
            size.width * 0.6042,
            size.height * 0.1875,
            size.width * 0.6667,
            size.height * 0.2083)
        ..lineTo(size.width * 0.5, size.height * 0.3333)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
