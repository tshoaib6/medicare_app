import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/edit_profile_screen.dart';
import '../providers/plan_provider.dart';
import '../../questionnaire/screens/questionnaire_screen.dart';
import '../../../services/medicare_api_service.dart';
import '../../ads/models/ad_model.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showInfo = false;
  bool _showPopupAd = false;
  String? _selectedPlan;
  final _api = MedicareApiService.instance;
  AdModel? _currentAd;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _loadUserProfile();
    _loadAds();
  }

  void _loadPlans() {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    planProvider.loadPlans();
  }

  void _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // If AuthProvider has user data but UserProvider doesn't, sync it
      if (authProvider.user != null && userProvider.user == null) {
        userProvider.setUser(authProvider.user!);
      }
      // Also try to load fresh profile data
      await userProvider.loadProfile();
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint('Error loading user profile: $e');
    }
  }

  void _loadAds() async {
    try {
      final adsResponse = await _api.ads.getActiveAds();
      final ads = adsResponse['data'] as List<dynamic>;

      if (ads.isNotEmpty) {
        // Convert to AdModel and show the first active ad as popup
        final adData = ads.first as Map<String, dynamic>;
        final ad = AdModel.fromJson(adData);

        if (ad.isCurrentlyActive && ad.hasValidContent) {
          setState(() {
            _currentAd = ad;
            _showPopupAd = true;
          });

          // Track ad impression
          try {
            await _api.ads.trackAdImpression(ad.id);
          } catch (e) {
            debugPrint('Failed to track ad impression: $e');
          }
        } else {
          setState(() {
            _showPopupAd = false;
          });
        }
      } else {
        setState(() {
          _showPopupAd = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading ads: $e');
      setState(() {
        _showPopupAd = false;
      });
    }
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'U';
    final names = fullName.trim().split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return names.first[0].toUpperCase();
  }

  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMainContent()),
            ],
          ),

          // Info button
          if (!_showPopupAd)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              right: 16,
              child: _buildInfoButton(),
            ),

          // Info modal
          if (_showInfo && !_showPopupAd) _buildInfoModal(),

          // Popup Ad
          if (_showPopupAd) _buildPopupAd(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, child) {
        // Try to get user from AuthProvider first, then UserProvider
        final user = authProvider.user ?? userProvider.user;
        final fullName = user != null && user.firstName.isNotEmpty
            ? '${user.firstName} ${user.lastName}'.trim()
            : 'Guest User';

        return Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  // Logo
                  Row(
                    children: [
                      Stack(
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 32, color: Colors.blue.shade600),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Icon(Icons.favorite,
                                size: 16, color: Colors.red.shade500),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'MediCare+',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Header buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                        iconSize: 20,
                      ),
                      IconButton(
                        onPressed: () => setState(() => _showInfo = true),
                        icon: const Icon(Icons.settings_outlined),
                        iconSize: 20,
                      ),
                      // User dropdown
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'profile':
                              Navigator.of(context)
                                  .pushNamed(EditProfileScreen.routeName);
                              break;
                            case 'questionnaires':
                              Navigator.of(context)
                                  .pushNamed('/questionnaire-responses');
                              break;
                            case 'logout':
                              _logout();
                              break;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue.shade600,
                                child: Text(
                                  _getInitials(fullName),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                fullName.split(' ').first,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 16),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 16),
                                SizedBox(width: 12),
                                Text('Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'questionnaires',
                            child: Row(
                              children: [
                                Icon(Icons.quiz_outlined, size: 16),
                                SizedBox(width: 12),
                                Text('My Questionnaires'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 16, color: Colors.red),
                                const SizedBox(width: 12),
                                const Text('Logout',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, child) {
        // Try to get user from AuthProvider first, then UserProvider
        final user = authProvider.user ?? userProvider.user;
        final firstName = user != null && user.firstName.isNotEmpty
            ? user.firstName
            : 'Guest';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(firstName),
              const SizedBox(height: 32),
              // Available Plans
              _buildAvailablePlans(),
              // Quick Actions
              _buildQuickActions(),
              // Notice
              _buildNotice(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(String firstName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $firstName!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find your perfect Medicare plan today',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePlans() {
    return Consumer<PlanProvider>(
      builder: (context, planProvider, child) {
        if (planProvider.loading && planProvider.plans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badge
            Row(
              children: [
                const Text(
                  'Available Medicare Plans',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Enrollment Open',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (planProvider.plans.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No plans available at the moment.'),
              )
            else
              // Plan cards list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: planProvider.plans.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final plan = planProvider.plans[index];
                  final isExpanded = _selectedPlan == plan.id.toString();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlan = isExpanded ? null : plan.id.toString();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isExpanded
                              ? Colors.blue.shade300
                              : Colors.grey.shade200,
                          width: isExpanded ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Plan header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Plan icon
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getPlanColor(plan.id),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getPlanIcon(plan.id),
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Plan info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            plan.description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (plan.company != null) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  plan.company!.name,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 12,
                                                      color: Colors
                                                          .orange.shade400,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      plan.company!.rating,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Expand arrow
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.25 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Expanded content
                          if (isExpanded) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Key Benefits
                                  const Text(
                                    'Key Benefits:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...plan.benefits.map((benefit) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade600,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                benefit,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 16),

                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Handle learn more
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade600,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Learn More',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            // Fetch questionnaire for this specific plan
                                            try {
                                              // Show loading indicator
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );

                                              // Get questionnaires for this plan
                                              final questionnaireResponse =
                                                  await MedicareApiService
                                                      .instance.questionnaires
                                                      .getQuestionnaires(
                                                planId: plan.id,
                                                status: 'active',
                                                page: 1,
                                                perPage: 1,
                                              );

                                              // Close loading dialog
                                              Navigator.of(context).pop();

                                              // Handle new paginated API response structure
                                              List questionnaires = [];

                                              if (questionnaireResponse[
                                                          'success'] ==
                                                      true &&
                                                  questionnaireResponse[
                                                          'data'] !=
                                                      null) {
                                                final responseData =
                                                    questionnaireResponse[
                                                        'data'];
                                                if (responseData is Map &&
                                                    responseData['data']
                                                        is List) {
                                                  // New paginated structure: data.data contains the questionnaires
                                                  questionnaires =
                                                      responseData['data']
                                                          as List;
                                                } else if (responseData
                                                    is List) {
                                                  // Fallback for direct list response
                                                  questionnaires = responseData;
                                                } else if (responseData
                                                    is Map) {
                                                  // Single questionnaire object
                                                  questionnaires = [
                                                    responseData
                                                  ];
                                                }
                                              }

                                              if (questionnaires.isNotEmpty) {
                                                final questionnaireId =
                                                    questionnaires.first['id']
                                                        as int;

                                                Navigator.pushNamed(
                                                  context,
                                                  QuestionnaireScreen.routeName,
                                                  arguments: {
                                                    'planId': plan.id,
                                                    'questionnaireId':
                                                        questionnaireId,
                                                    'responseId':
                                                        null, // New questionnaire
                                                  },
                                                );
                                              } else {
                                                // No questionnaire found for this plan
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'No questionnaire available for ${plan.title}'),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              // Close loading dialog if still open
                                              if (Navigator.canPop(context)) {
                                                Navigator.of(context).pop();
                                              }

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error loading questionnaire: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Compare Plans',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Collapsed view - show availability and view details
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: plan.isActive
                                          ? Colors.green.shade600
                                          : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      plan.isActive
                                          ? 'Available'
                                          : 'Coming Soon',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedPlan = plan.id.toString();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'View Details',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Color _getPlanColor(int planId) {
    switch (planId % 5) {
      case 0:
        return Colors.blue.shade500;
      case 1:
        return Colors.green.shade500;
      case 2:
        return Colors.purple.shade500;
      case 3:
        return Colors.orange.shade500;
      default:
        return Colors.teal.shade500;
    }
  }

  IconData _getPlanIcon(int planId) {
    switch (planId % 5) {
      case 0:
        return Icons.shield_outlined;
      case 1:
        return Icons.medication_outlined;
      case 2:
        return Icons.local_hospital_outlined;
      case 3:
        return Icons.health_and_safety_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              icon: Icons.search,
              label: 'Find Plans',
              onTap: () => Navigator.of(context).pushNamed('/plans'),
            ),
            _buildQuickActionCard(
              icon: Icons.compare_arrows,
              label: 'Compare Plans',
              onTap: () => Navigator.of(context).pushNamed('/compare'),
            ),
            _buildQuickActionCard(
              icon: Icons.favorite,
              label: 'My Favorites',
              onTap: () => Navigator.of(context).pushNamed('/favorites'),
            ),
            _buildQuickActionCard(
              icon: Icons.support_agent,
              label: 'Get Help',
              onTap: () => Navigator.of(context).pushNamed('/support'),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade600),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Important Notice',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Medicare Open Enrollment ends December 7th. Review your plan options before the deadline.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton() {
    return FloatingActionButton.small(
      onPressed: () => setState(() => _showInfo = true),
      backgroundColor: Colors.white,
      child: Icon(Icons.info_outline, color: Colors.blue.shade600),
    );
  }

  Widget _buildInfoModal() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Dashboard Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _showInfo = false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to your Medicare+ Dashboard. This is your central hub for managing all your Medicare benefits and healthcare needs.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupAd() {
    if (_currentAd == null) return const SizedBox.shrink();

    final ad = _currentAd!;
    final title = ad.title.isNotEmpty ? ad.title : 'Special Offer';
    final description = ad.description.isNotEmpty
        ? ad.description
        : 'Don\'t miss this opportunity!';
    final buttonText = ad.safeButtonText;
    final imageUrl = ad.displayImageUrl;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: () => setState(() => _showPopupAd = false),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
                // Ad content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Ad image (if available)
                      if (imageUrl != null && imageUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image,
                                  size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Ad title
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Ad description
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action button
                      ElevatedButton(
                        onPressed: () => _handleAdClick(),
                        child: Text(buttonText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAdClick() async {
    if (_currentAd == null) return;

    final adId = _currentAd!.id;
    final targetUrl = _currentAd!.targetUrl;

    // Track ad click
    try {
      await _api.ads.trackAdClick(adId);
    } catch (e) {
      debugPrint('Failed to track ad click: $e');
    }

    // Close the popup
    setState(() => _showPopupAd = false);

    // Handle ad action (navigate to URL, specific screen, etc.)
    if (targetUrl != null && targetUrl.isNotEmpty) {
      // Could launch URL or navigate to specific screen based on target_url
      debugPrint('Ad clicked - Target URL: $targetUrl');
      // For now, just show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirecting to: $targetUrl'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }
}
