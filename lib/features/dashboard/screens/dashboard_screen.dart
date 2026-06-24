import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/edit_profile_screen.dart';
import '../providers/plan_provider.dart';
import '../../questionnaire/screens/questionnaire_screen.dart';
import '../../../services/medicare_api_service.dart';
import '../../ads/models/ad_model.dart';
import '../../../core/widgets/info_button_widget.dart';
import '../../subscription/screens/subscription_screen.dart';
import '../../chat/widgets/tawk_widgets.dart';
import '../../companies/models/company_model.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _profileAlertKeyPrefix = 'dashboard_profile_alert_shown_';

  bool _showPopupAd = false;
  String? _selectedPlan;
  int _selectedTabIndex = 0;
  bool _marketLoading = false;
  String? _marketError;
  List<CompanyModel> _marketCompanies = [];
  final _api = MedicareApiService.instance;
  AdModel? _currentAd;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _loadUserProfile();
    _loadAds();
    _loadMarketplaceCompanies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowProfileReviewAlert();
    });
  }

  Future<void> _loadMarketplaceCompanies() async {
    try {
      setState(() {
        _marketLoading = true;
        _marketError = null;
      });

      final response = await _api.companies.getCompanies(
        page: 1,
        perPage: 50,
        sortBy: 'rating',
      );

      final companiesData = _extractCompaniesData(response);
      final companies =
          companiesData.map((json) => CompanyModel.fromJson(json)).toList();

      if (!mounted) return;
      setState(() {
        _marketCompanies = companies;
        _marketLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _marketError = e.toString();
        _marketLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractCompaniesData(
      Map<String, dynamic> response) {
    final rawData = response['data'];

    if (rawData is List) {
      return rawData
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (rawData is Map<String, dynamic>) {
      final dynamic nestedList =
          rawData['data'] ?? rawData['companies'] ?? rawData['items'];
      if (nestedList is List) {
        return nestedList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  Future<void> _checkAndShowProfileReviewAlert() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user == null || !user.isProfileComplete) return;

      final prefs = await SharedPreferences.getInstance();
      final key = '$_profileAlertKeyPrefix${user.id}';
      final lastShownAt = prefs.getInt(key);
      final now = DateTime.now();

      if (lastShownAt != null) {
        final lastShownDate =
            DateTime.fromMillisecondsSinceEpoch(lastShownAt, isUtc: false);
        final daysPassed = now.difference(lastShownDate).inDays;
        if (daysPassed < 30) {
          return;
        }
      }

      if (!mounted) return;

      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Profile Check-In'),
          content: const Text(
            'Has anything changed in your personal information in the past 30 days?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, Review Benefits'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Update Profile'),
            ),
          ],
        ),
      );

      await prefs.setInt(key, now.millisecondsSinceEpoch);

      if (shouldUpdate == true && mounted) {
        Navigator.of(context).pushNamed(EditProfileScreen.routeName);
      }
    } catch (e) {
      debugPrint('Error while showing profile review alert: $e');
    }
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
      // Also clear user provider data
      context.read<UserProvider>().clearUser();
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
              child: const InfoButtonWidget(),
            ),

          // Popup Ad
          if (_showPopupAd) _buildPopupAd(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      // Gorilla Consultant Chat Support
      floatingActionButton: TawkChatFAB(
        visitorName: _getUserName(),
        visitorEmail: _getUserEmail(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedTabIndex,
      selectedItemColor: Colors.blue.shade700,
      unselectedItemColor: const Color(0xFF6B7280),
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            label: 'Active Plans'),
        BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined), label: 'Market'),
        BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined), label: 'Benefits'),
        BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined), label: 'Consult'),
        BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined), label: 'Subscription'),
      ],
    );
  }

  /// Get current user's name for chat
  String? _getUserName() {
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        final firstName = authProvider.user!.firstName;
        final lastName = authProvider.user!.lastName;
        if (firstName.isNotEmpty) {
          return '$firstName $lastName'.trim();
        }
      }
    } catch (e) {
      debugPrint('Error getting user name: $e');
    }
    return null;
  }

  /// Get current user's email for chat
  String? _getUserEmail() {
    try {
      final authProvider = context.read<AuthProvider>();
      return authProvider.user?.email;
    } catch (e) {
      debugPrint('Error getting user email: $e');
    }
    return null;
  }

  Widget _buildHeader() {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, child) {
        // Determine user display based on auth status
        String fullName;
        if (authProvider.isGuest) {
          fullName = 'Guest User';
        } else if (authProvider.isAuthenticated ||
            authProvider.status == AuthStatus.profileIncomplete) {
          final user = authProvider.user;
          fullName = user != null && user.firstName.isNotEmpty
              ? '${user.firstName} ${user.lastName}'.trim()
              : 'User';
        } else {
          fullName = 'Guest User';
        }

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
                        'myHealthCARE',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
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
                      const InfoAppBarAction(),
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
                            case 'login':
                              Navigator.of(context)
                                  .pushNamed(LoginScreen.routeName);
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
                          if (!authProvider.isGuest) ...[
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
                                  Icon(Icons.logout,
                                      size: 16, color: Colors.red),
                                  const SizedBox(width: 12),
                                  const Text('Logout',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ] else ...[
                            PopupMenuItem(
                              value: 'login',
                              child: Row(
                                children: [
                                  Icon(Icons.login,
                                      size: 16, color: Colors.blue.shade600),
                                  const SizedBox(width: 12),
                                  Text('Sign In',
                                      style: TextStyle(
                                          color: Colors.blue.shade600)),
                                ],
                              ),
                            ),
                          ],
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
        // Determine first name based on auth status
        String firstName;
        if (authProvider.isGuest) {
          firstName = 'Guest';
        } else if (authProvider.isAuthenticated ||
            authProvider.status == AuthStatus.profileIncomplete) {
          final user = authProvider.user;
          firstName = user != null && user.firstName.isNotEmpty
              ? user.firstName
              : 'User';
        } else {
          firstName = 'Guest';
        }

        final age = _resolveAge(authProvider, userProvider);
        switch (_selectedTabIndex) {
          case 0:
            return _buildHomeTab(firstName: firstName, age: age);
          case 1:
            return _buildActivePlansTab();
          case 2:
            return _buildMarketplaceTab();
          case 3:
            return _buildOtherBenefitsTab();
          case 4:
            return _buildFreeConsultationTab();
          case 5:
            return _buildSubscriptionTab();
          default:
            return _buildHomeTab(firstName: firstName, age: age);
        }
      },
    );
  }

  int? _resolveAge(AuthProvider authProvider, UserProvider userProvider) {
    final year =
        userProvider.user?.yearOfBirth ?? authProvider.user?.yearOfBirth;
    if (year == null) return null;
    final age = DateTime.now().year - year;
    if (age < 0 || age > 120) return null;
    return age;
  }

  Widget _buildHomeTab({required String firstName, int? age}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(firstName, age: age),
          const SizedBox(height: 16),
          _buildProfileChunk(),
          const SizedBox(height: 16),
          _buildQualificationChunk(),
          const SizedBox(height: 16),
          _buildFeedNewsChunk(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActivePlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Plans',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap any plan to view details, compare plans, and start your questionnaire.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          _buildAvailablePlans(),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    final medicareCompanies = _marketCompanies
        .where((company) => company.specialties
            .any((s) => s.toLowerCase().contains('medicare')))
        .toList();
    final nonMedicareCompanies = _marketCompanies
        .where((company) => !company.specialties
            .any((s) => s.toLowerCase().contains('medicare')))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Place',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse company cards by category.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          if (_marketLoading)
            const Center(child: CircularProgressIndicator())
          else if (_marketError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unable to load providers right now.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _marketError!,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _loadMarketplaceCompanies,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_marketCompanies.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text('No providers found.'),
            )
          else ...[
            _buildCompanyCardGroup(
              title: 'Medicare Beneficiaries',
              companies: medicareCompanies,
              badgeColor: const Color(0xFFE0F2FE),
              badgeTextColor: const Color(0xFF075985),
            ),
            const SizedBox(height: 12),
            _buildCompanyCardGroup(
              title: 'Non Medicare Beneficiaries',
              companies: nonMedicareCompanies,
              badgeColor: const Color(0xFFF1F5F9),
              badgeTextColor: const Color(0xFF334155),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyCardGroup({
    required String title,
    required List<CompanyModel> companies,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (companies.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'No providers in this category.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          ...companies.map(
            (company) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                ),
                title: Text(
                  company.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        company.rating,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Provider',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openMarketplaceCompany(company),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMarketplaceCompany(CompanyModel company) async {
    try {
      final planProvider = context.read<PlanProvider>();
      if (planProvider.plans.isEmpty) {
        await planProvider.loadPlans(refresh: true);
      }

      if (!mounted) return;

      if (planProvider.plans.isEmpty) {
        _showFeatureSnack('No plans available to open providers right now.');
        return;
      }

      final selectedPlan = planProvider.plans.firstWhere(
        (plan) => plan.isActive,
        orElse: () => planProvider.plans.first,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final questionnaireResponse =
          await MedicareApiService.instance.questionnaires.getQuestionnaires(
        planId: selectedPlan.id,
        status: 'active',
        page: 1,
        perPage: 1,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      List questionnaires = [];
      if (questionnaireResponse['success'] == true &&
          questionnaireResponse['data'] != null) {
        final responseData = questionnaireResponse['data'];
        if (responseData is Map && responseData['data'] is List) {
          questionnaires = responseData['data'] as List;
        } else if (responseData is List) {
          questionnaires = responseData;
        } else if (responseData is Map) {
          questionnaires = [responseData];
        }
      }

      if (questionnaires.isEmpty) {
        _showFeatureSnack(
            'No questionnaire available for ${selectedPlan.title}.');
        return;
      }

      final questionnaireId = questionnaires.first['id'] as int;

      Navigator.pushNamed(
        context,
        '/company-list',
        arguments: {
          'plan': selectedPlan,
          'questionnaireId': questionnaireId,
          'responseId': 0,
          'initialSearch': company.name,
        },
      );
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showFeatureSnack('Unable to open providers: $e');
    }
  }

  Widget _buildOtherBenefitsTab() {
    const benefits = [
      'Durable Medical Equipment',
      'Rx Drug Plans',
      'Zero Dollar Health Plan',
      'Grocery Cards',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Other Eligible Benefits',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'All items are kept as read links as discussed in your screenshot.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          _buildLinkListCard(title: 'Benefits Library', items: benefits),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _showFeatureSnack('Calling support to learn more...'),
              icon: const Icon(Icons.call_outlined),
              label: const Text('CLICK / CALL NOW to learn more'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeConsultationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Free Consultation',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Ask Gorilla AI',
            subtitle: 'Use instant answers for Medicare guidance.',
            icon: Icons.smart_toy_outlined,
            onTap: () => _showFeatureSnack('Use Ask Gorilla AI from this tab.'),
          ),
          _buildActionTile(
            title: 'Live Agent',
            subtitle: 'Open chat with our support consultant.',
            icon: Icons.support_agent,
            onTap: () => _showFeatureSnack(
                'Use the chat button to connect to a live agent.'),
          ),
          _buildActionTile(
            title: 'FAQ',
            subtitle: '3 attempts are allowed each month.',
            icon: Icons.quiz_outlined,
            onTap: () =>
                _showFeatureSnack('FAQ section will be connected soon.'),
          ),
          _buildActionTile(
            title: 'Request a Call Back',
            subtitle: 'Leave a message and we will call you back.',
            icon: Icons.call,
            onTap: () => _showFeatureSnack(
                'Call back request flow will be linked here.'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubscriptionSection(),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Emergency Services',
            subtitle: 'Direct support path for urgent insurance questions.',
            icon: Icons.emergency_outlined,
            onTap: () => _showFeatureSnack(
                'Emergency services flow will be linked here.'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(String firstName, {int? age}) {
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
            'Welcome ($firstName)',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            age == null ? 'Age: Not added yet' : 'Age: $age',
            style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'We are glad that you are here.',
            style: TextStyle(fontSize: 15, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Do you know what benefits you can qualify for?',
            style: TextStyle(fontSize: 15, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileChunk() {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, child) {
        final user = userProvider.user ?? authProvider.user;
        final isComplete = user?.isProfileComplete ?? false;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Icon(
                isComplete
                    ? Icons.verified_user_outlined
                    : Icons.person_outline,
                color:
                    isComplete ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isComplete
                      ? 'Your profile is complete. Keep it updated every month.'
                      : 'Complete/update your profile!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(EditProfileScreen.routeName),
                child: Text(isComplete ? 'Review' : 'Complete'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQualificationChunk() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'Qualification assistant is ready. Start with your plan and benefit preferences.',
        style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
      ),
    );
  }

  Widget _buildFeedNewsChunk() {
    const items = [
      'Reading Page 1: Read about Medicare Advantage plans',
      'Reading Page 2: Read about other eligible benefits seniors can get',
      'Reading Page 3: CMS highlights (2026 Medicare fact sheet)',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feed / News',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.article_outlined, size: 20),
              title: Text(item, style: const TextStyle(fontSize: 13)),
              onTap: () =>
                  _showFeatureSnack('Reading content will be linked here.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkListCard(
      {required String title, required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link_outlined, size: 18),
              title: Text(item, style: const TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => _showFeatureSnack('Opening: $item'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showFeatureSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  Widget _buildSubscriptionSection() {
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
          const Text(
            'Subscription',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get Consultancy for \$5/month',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(SubscriptionScreen.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Learn More',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
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
