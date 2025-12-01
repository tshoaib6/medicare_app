import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/otp_verification_screen.dart';
import '../../user/screens/edit_profile_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    _logoController.forward();
  }

  Future<void> _initializeApp() async {
    // Wait for animations and initialization
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2000)), // Minimum splash time
      _initializeAuthProvider(),
    ]);

    if (!mounted) return;
    _navigateToAppropriateScreen();
  }

  Future<void> _initializeAuthProvider() async {
    final authProvider = context.read<AuthProvider>();
    // The auth provider init is already called in main.dart,
    // but we wait for it to complete here
    while (authProvider.status == AuthStatus.loading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _navigateToAppropriateScreen() {
    final authProvider = context.read<AuthProvider>();

    switch (authProvider.status) {
      case AuthStatus.unauthenticated:
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        break;
      case AuthStatus.guest:
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
        break;
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
      case AuthStatus.loading:
        // Should not happen, but fallback to login
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        break;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and App Name Section
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // App Title with Fade Animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Medicare',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Healthcare Partner',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // Loading Animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _loadingController.value * 2.0 * 3.14159,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.accent1,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
