import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

import '../../../core/theme/colors.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _yearCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() {
        _error = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      await auth.signup(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        phoneNumber: Validators.unformatPhoneNumber(_phoneCtrl.text.trim()),
        yearOfBirth: int.parse(_yearCtrl.text.trim()),
      );

      if (!mounted) return;

      // Navigate based on auth status
      switch (auth.status) {
        case AuthStatus.emailUnverified:
          Navigator.of(context)
              .pushReplacementNamed(OtpVerificationScreen.routeName);
          break;
        default:
          // Handle other cases
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _googleSignUp() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      await auth.googleLogin();

      if (!mounted) return;

      // Navigate based on status after Google signup
      switch (auth.status) {
        case AuthStatus.profileIncomplete:
          Navigator.of(context).pushReplacementNamed('/edit-profile');
          break;
        case AuthStatus.authenticated:
          Navigator.of(context).pushReplacementNamed('/dashboard');
          break;
        default:
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Google sign-up failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                          'Join thousands who found their perfect plan',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Signup Card
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
                              'Create Account',
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
                                          .withValues(alpha: 0.3)),
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

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Name fields row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          label: 'First name',
                                          controller: _firstNameCtrl,
                                          validator: (v) => Validators.name(v,
                                              fieldName: 'First name'),
                                          prefixIcon: Icons.person_outline,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: AppTextField(
                                          label: 'Last name',
                                          controller: _lastNameCtrl,
                                          validator: (v) => Validators.name(v,
                                              fieldName: 'Last name'),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  AppTextField(
                                    label: 'Email',
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.email,
                                    prefixIcon: Icons.email_outlined,
                                  ),

                                  const SizedBox(height: 20),

                                  AppTextField(
                                    label: 'Phone number',
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    validator: Validators.phoneNumber,
                                    prefixIcon: Icons.phone_outlined,
                                    onChanged: (_) => _formatPhoneNumber(),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(
                                          12), // Allow for dashes
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          label: 'Year of birth',
                                          controller: _yearCtrl,
                                          keyboardType: TextInputType.number,
                                          validator: Validators.yearOfBirth,
                                          prefixIcon: Icons.cake_outlined,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(4),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  AppTextField(
                                    label: 'Password',
                                    controller: _passwordCtrl,
                                    obscureText: true,
                                    validator: Validators.password,
                                    prefixIcon: Icons.lock_outline,
                                  ),

                                  const SizedBox(height: 20),

                                  AppTextField(
                                    label: 'Confirm password',
                                    controller: _confirmCtrl,
                                    obscureText: true,
                                    validator: (value) =>
                                        Validators.confirmPassword(
                                            value, _passwordCtrl.text),
                                    prefixIcon: Icons.lock_outline,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Create Account Button
                            PrimaryButton(
                              label: 'Create account',
                              loading: _loading,
                              onPressed: _submit,
                            ),

                            const SizedBox(height: 16),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(color: AppColors.border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(color: AppColors.border)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Google Sign Up Button
                            PrimaryButton(
                              label: 'Sign up with Google',
                              loading: _googleLoading,
                              onPressed: _googleSignUp,
                              outlined: true,
                              icon: Icons.g_mobiledata,
                            ),

                            const SizedBox(height: 32),

                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Sign in',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
}
