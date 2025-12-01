import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/user_provider.dart';
import 'core/network/api_client.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/providers/plan_provider.dart';
import 'routes/app_router.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicareApp());
}

class MedicareApp extends StatelessWidget {
  const MedicareApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'Medicare',
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const SplashScreen(),
      ),
    );
  }
}
