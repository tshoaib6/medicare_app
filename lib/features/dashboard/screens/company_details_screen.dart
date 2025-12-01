import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/company_model.dart';

class CompanyDetailsScreen extends StatelessWidget {
  static const routeName = '/company-details';

  final CompanyModel company;
  final PlanModel? plan;

  const CompanyDetailsScreen({
    super.key,
    required this.company,
    this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Light blue background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Hero Section
                    _buildHeroSection(),

                    const SizedBox(height: 16),

                    // Company Stats
                    _buildCompanyStats(theme),

                    const SizedBox(height: 16),

                    // Contact Information
                    _buildContactCard(theme),

                    if (plan != null) ...[
                      const SizedBox(height: 16),
                      // Plan Match
                      _buildPlanMatch(theme),
                    ],

                    const SizedBox(height: 16),

                    // Features & Benefits
                    _buildFeaturesBenefits(theme),

                    const SizedBox(height: 16),

                    // Bottom Actions
                    _buildBottomActions(context, theme),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Back button and logo
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    padding: const EdgeInsets.all(8),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 24,
                        color: AppColors.info,
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Icon(
                          Icons.favorite,
                          size: 12,
                          color: AppColors.destructive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MediCare+',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Rating
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  company.rating.toString(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(company.imageUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  company.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyStats(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.military_tech_outlined,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Text(
                  'Company Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    company.founded ?? '1853',
                    'Founded',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    company.members ?? '22.1M',
                    'Members',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    company.states ?? '50 states',
                    'Coverage',
                    AppColors.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: AppColors.border),
            const SizedBox(height: 16),

            // Specialties
            Text(
              'Specialties',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: company.specialties
                  .map(
                    (specialty) => Chip(
                      label: Text(
                        specialty,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppColors.accent2,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.phone,
              company.phone,
              '24/7 Support',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.location_on_outlined,
              'Nationwide',
              'Service Area',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.people_outline,
              company.members ?? '22.1 million',
              'Active Members',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value, String subtitle) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanMatch(ThemeData theme) {
    if (plan == null) return const SizedBox.shrink();

    return Card(
      color: Colors.green.shade50,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perfect Match',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade900,
                        ),
                      ),
                      Text(
                        plan!.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This provider offers excellent coverage for your selected plan type.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesBenefits(ThemeData theme) {
    final features = company.features ??
        [
          'Nationwide Provider Network',
          'Prescription Drug Coverage',
          'Preventive Care Services',
          'Wellness Programs',
          'Care Coordination',
          'Telehealth Services'
        ];

    final benefits = company.benefits ??
        [
          '\$0 copay for preventive care',
          'Prescription drug coverage included',
          'Access to wellness programs',
          'Nationwide emergency coverage',
          '24/7 member support'
        ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Key Features & Benefits',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Plan Features
            Text(
              'Plan Features',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => _buildFeatureItem(feature)),

            const SizedBox(height: 16),

            // Member Benefits
            Text(
              'Member Benefits',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...benefits.map((benefit) => _buildFeatureItem(benefit)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 12,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.info, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Ready to Get Started?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Contact ${company.name} to learn more about your coverage options and get personalized assistance.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Call Now Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Call Now',
                  onPressed: () => _handleCallNow(context),
                  icon: Icons.phone,
                ),
              ),

              const SizedBox(height: 12),

              // Request Call Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Request a Call',
                  onPressed: () => _handleRequestCall(context),
                  outlined: true,
                  icon: Icons.calendar_today,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Available Monday - Friday, 8 AM - 8 PM EST',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCallNow(BuildContext context) async {
    // Copy phone number to clipboard and show snackbar
    await Clipboard.setData(ClipboardData(text: company.phone));

    // Show snackbar with call instructions
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number ${company.phone} copied to clipboard'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Call',
            textColor: Colors.white,
            onPressed: () {
              // The user can manually dial the number
            },
          ),
        ),
      );
    }
  }

  void _handleRequestCall(BuildContext context) {
    // Navigate to callback request screen or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request a Call'),
        content: Text(
            'We will have ${company.name} call you back at your convenience.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to callback request form
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
