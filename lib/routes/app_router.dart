import 'package:flutter/material.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/auth/screens/edit_profile_screen.dart';
import '../features/questionnaire/screens/questionnaire_screen.dart';
import '../features/questionnaire/screens/questionnaire_responses_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case SignUpScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case OtpVerificationScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OtpVerificationScreen());
      case ForgotPasswordScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case ResetPasswordScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
          settings: settings,
        );
      case EditProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case QuestionnaireScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuestionnaireScreen(
            planId: args['planId'] as int,
            questionnaireId: args['questionnaireId'] as int,
            responseId: args['responseId'] as int?,
          ),
        );
      case QuestionnaireResponsesScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => const QuestionnaireResponsesScreen());
      case DashboardScreen.routeName:
      default:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
    }
  }
}
