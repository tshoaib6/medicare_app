import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/user_provider.dart';
import 'core/network/api_client.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/providers/plan_provider.dart';
import 'features/chat/providers/tawk_provider.dart';
import 'routes/app_router.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIConsultantApp());
}

class AIConsultantApp extends StatelessWidget {
  const AIConsultantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..init(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(ApiClient()),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider<PlanProvider>(
          create: (_) => PlanProvider(),
        ),
        ChangeNotifierProvider<TawkProvider>(
          create: (_) => TawkProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Gorilla Consultant',
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const _AppWrapper(),
      ),
    );
  }
}

class _AppWrapper extends StatefulWidget {
  const _AppWrapper({super.key});

  @override
  State<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<_AppWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeTawk();
  }

  void _initializeTawk() {
    if (mounted) {
      final tawkProvider = context.read<TawkProvider>();
      tawkProvider.initializeTawk();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
