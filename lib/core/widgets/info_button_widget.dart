import 'package:flutter/material.dart';

/// Reusable information button widget that can be added to any screen
/// Shows contextual information based on the screen it's placed on
class InfoButtonWidget extends StatefulWidget {
  final String? title;
  final String? description;
  final List<String>? tips;
  final Color? buttonColor;
  final Color? backgroundColor;
  final bool showInHeader;

  const InfoButtonWidget({
    super.key,
    this.title,
    this.description,
    this.tips,
    this.buttonColor,
    this.backgroundColor,
    this.showInHeader = false,
  });

  @override
  State<InfoButtonWidget> createState() => _InfoButtonWidgetState();
}

class _InfoButtonWidgetState extends State<InfoButtonWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.showInHeader) {
      // Return just the icon button for header usage
      return IconButton(
        onPressed: () => _showInfoModal(context),
        icon: Icon(
          Icons.info_outline,
          color: widget.buttonColor ?? Colors.grey.shade600,
        ),
        tooltip: 'Information',
      );
    }

    // Return floating action button without Positioned wrapper
    // The parent widget should handle positioning
    return FloatingActionButton.small(
      onPressed: () => _showInfoModal(context),
      backgroundColor: widget.backgroundColor ?? Colors.white,
      elevation: 2,
      child: Icon(
        Icons.info_outline,
        color: widget.buttonColor ?? Colors.blue.shade600,
      ),
    );
  }

  void _showInfoModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _buildInfoDialog(context),
    );
  }

  Widget _buildInfoDialog(BuildContext context) {
    final screenName = _getScreenName(context);
    final title = widget.title ?? '$screenName Information';
    final description =
        widget.description ?? _getDefaultDescription(screenName);
    final tips = widget.tips ?? _getDefaultTips(screenName);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            if (tips.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Tips:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScreenName(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route?.settings.name != null) {
      final routeName = route!.settings.name!;
      // Convert route name to readable screen name
      switch (routeName) {
        case '/dashboard':
          return 'Dashboard';
        case '/questionnaire':
          return 'Questionnaire';
        case '/questionnaire-responses':
          return 'My Questionnaires';
        case '/companies':
          return 'Companies';
        case '/company-details':
          return 'Company Details';
        case '/request-call':
          return 'Request Call';
        case '/profile':
        case '/edit-profile':
          return 'Profile';
        case '/login':
          return 'Login';
        case '/signup':
          return 'Sign Up';
        case '/forgot-password':
          return 'Password Recovery';
        case '/reset-password':
          return 'Reset Password';
        case '/otp-verification':
          return 'Verification';
        default:
          return 'Screen';
      }
    }
    return 'Screen';
  }

  String _getDefaultDescription(String screenName) {
    switch (screenName) {
      case 'Dashboard':
        return 'Welcome to your Medicare+ Dashboard. This is your central hub for managing all your Medicare benefits and healthcare needs. Browse available plans, compare options, and access quick actions.';

      case 'Questionnaire':
        return 'Complete this questionnaire to help us find the best Medicare plan for your specific needs. Answer all questions honestly for personalized recommendations.';

      case 'My Questionnaires':
        return 'View all your completed questionnaires and their results. You can also continue any questionnaires you started but haven\'t finished yet.';

      case 'Companies':
        return 'Browse Medicare insurance companies and providers. Compare ratings, specialties, and services to find the right provider for your healthcare needs.';

      case 'Company Details':
        return 'View detailed information about this Medicare provider, including their plans, ratings, contact information, and available services.';

      case 'Request Call':
        return 'Schedule a call with a Medicare specialist who can help answer your questions and guide you through the enrollment process.';

      case 'Profile':
        return 'Manage your personal information, preferences, and account settings. Keep your profile up to date for better Medicare recommendations.';

      case 'Login':
        return 'Sign in to your Medicare+ account to access personalized plan recommendations, saved preferences, and your application history.';

      case 'Sign Up':
        return 'Create your Medicare+ account to get started with personalized Medicare plan recommendations and expert guidance.';

      case 'Password Recovery':
        return 'Recover access to your account by entering your email address. We\'ll send you instructions to reset your password.';

      case 'Reset Password':
        return 'Create a new secure password for your account. Choose a strong password that you haven\'t used elsewhere.';

      case 'Verification':
        return 'Enter the verification code sent to your email or phone to confirm your identity and secure your account.';

      default:
        return 'This screen provides important functionality for managing your Medicare benefits and healthcare options.';
    }
  }

  List<String> _getDefaultTips(String screenName) {
    switch (screenName) {
      case 'Dashboard':
        return [
          'Use the search function to quickly find specific plans',
          'Bookmark your favorite plans for easy comparison',
          'Check the enrollment deadline notice for important dates',
          'Complete questionnaires to get personalized recommendations'
        ];

      case 'Questionnaire':
        return [
          'Answer all required questions to get accurate results',
          'You can save and continue later if needed',
          'Be honest about your health needs for better matches',
          'Review your answers before submitting'
        ];

      case 'My Questionnaires':
        return [
          'Completed questionnaires show your personalized results',
          'You can retake questionnaires if your needs change',
          'Use results to compare and choose the best plan'
        ];

      case 'Companies':
        return [
          'Sort by ratings to see top-rated providers',
          'Filter by specialty to find specific services',
          'Read reviews and ratings from other members',
          'Contact companies directly for detailed information'
        ];

      case 'Company Details':
        return [
          'Review all available plans from this provider',
          'Check network coverage in your area',
          'Compare costs and benefits carefully',
          'Schedule a call for personalized assistance'
        ];

      case 'Request Call':
        return [
          'Choose a convenient time for your consultation',
          'Prepare questions about specific plans',
          'Have your Medicare card ready if available',
          'Calls are free and without obligation'
        ];

      case 'Profile':
        return [
          'Keep your contact information current',
          'Update your health preferences as they change',
          'Review your privacy settings regularly',
          'Enable notifications for important updates'
        ];

      case 'Login':
        return [
          'Use the same email you registered with',
          'Check your spam folder if you don\'t receive emails',
          'Enable two-factor authentication for security'
        ];

      case 'Sign Up':
        return [
          'Use a valid email address you check regularly',
          'Create a strong, unique password',
          'Provide accurate information for better recommendations',
          'Review the terms of service before agreeing'
        ];

      default:
        return [
          'Navigate using the menu or back button',
          'Contact support if you need help',
          'Save your progress regularly'
        ];
    }
  }
}

/// Helper widget to easily add info button to any screen's app bar
class InfoAppBarAction extends StatelessWidget {
  final String? title;
  final String? description;
  final List<String>? tips;
  final Color? iconColor;

  const InfoAppBarAction({
    super.key,
    this.title,
    this.description,
    this.tips,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InfoButtonWidget(
      title: title,
      description: description,
      tips: tips,
      buttonColor: iconColor,
      showInHeader: true,
    );
  }
}
