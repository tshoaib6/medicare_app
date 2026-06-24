import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/colors.dart';
import '../providers/user_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../core/widgets/info_button_widget.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _zipCodeCtrl = TextEditingController();
  final _birthYearCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _isDecisionMaker;
  String? _hasMedicarePartB;

  // Medicare Insurance Card Upload
  bool _insuranceCardFrontUploaded = false;
  bool _insuranceCardBackUploaded = false;
  bool _uploadingCard = false;
  String? _frontCardFileName;
  String? _backCardFileName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();

    _zipCodeCtrl.dispose();
    _birthYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.fetchCurrentUser();

      final user = userProvider.user;
      if (user != null) {
        _firstNameCtrl.text = user.firstName;
        _lastNameCtrl.text = user.lastName;
        _phoneCtrl.text = user.phone ?? '';
        _zipCodeCtrl.text = user.zipCode ?? '';
        _birthYearCtrl.text = user.birthYear?.toString() ?? '';
        _isDecisionMaker = user.isDecisionMaker ? 'yes' : 'no';
        _hasMedicarePartB = user.hasMedicarePartB ? 'yes' : 'no';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load user data: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required radio buttons
    if (_isDecisionMaker == null) {
      setState(() => _error = 'Please select whether you are a decision maker');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final userProvider = context.read<UserProvider>();

    try {
      await userProvider.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        zipCode: _zipCodeCtrl.text.trim(),
        birthYear: int.tryParse(_birthYearCtrl.text.trim()),
        isDecisionMaker: _isDecisionMaker == 'yes',
        hasMedicarePartB: _hasMedicarePartB == 'yes',
      );

      if (!mounted) return;

      // Show success message and navigate to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading && _firstNameCtrl.text.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header with Medicare+ Logo
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Icon(
                                          Icons.shield_outlined,
                                          size: 40,
                                          color: AppColors.info,
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Icon(
                                            Icons.favorite,
                                            size: 20,
                                            color: AppColors.destructive,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'myHealthCARE',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Complete your consumer information',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Helpline Call Card
                          _buildHelplineCard(theme),

                          const SizedBox(height: 16),

                          // Consumer Info Form Card
                          _buildConsumerInfoForm(theme),

                          const SizedBox(height: 16),

                          // Note at bottom
                          Text(
                            'Required fields are marked with an asterisk (*). Complete your myHealthCARE profile setup.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Info button positioned at top right
                Positioned(
                  top: 16,
                  right: 16,
                  child: const InfoButtonWidget(),
                ),
              ],
            ),
    );
  }

  Widget _buildHelplineCard(ThemeData theme) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Call our Medicare helpline for free consultation',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleCallNow(),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.info,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '1-800-MEDICARE',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(1-800-633-4227)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsumerInfoForm(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Text(
                  'Consumer Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your complete information to set up your health profile. Fields marked with * are required.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Error Message
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withValues(alpha: 0.1),
                  border: Border.all(
                      color: AppColors.destructive.withValues(alpha: 0.3)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _buildSectionTitle('Personal Information', theme),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'First Name *',
                    controller: _firstNameCtrl,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                    hintText: 'Enter your first name',
                  ),

                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Last Name *',
                    controller: _lastNameCtrl,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                    hintText: 'Enter your last name',
                  ),

                  const SizedBox(height: 24),

                  // Contact Information Section
                  _buildSectionTitle('Contact Information', theme),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Primary Phone Number *',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phoneNumber,
                    hintText: '123-456-7890',
                    onChanged: (value) {
                      final formatted = Validators.formatPhoneNumber(value);
                      if (formatted != value) {
                        _phoneCtrl.value = _phoneCtrl.value.copyWith(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Location Information Section
                  _buildSectionTitle('Location Information', theme),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Zip Code *',
                    controller: _zipCodeCtrl,
                    keyboardType: TextInputType.number,
                    validator: Validators.zipCode,
                    hintText: '12345',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                  ),

                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Birth Year *',
                    controller: _birthYearCtrl,
                    keyboardType: TextInputType.number,
                    validator: Validators.yearOfBirth,
                    hintText: '1950',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Additional Information Section
                  _buildSectionTitle('Additional Information', theme),
                  const SizedBox(height: 16),

                  // Decision Maker Radio Group
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you a decision maker? *',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This helps us understand your role in healthcare decisions.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Yes'),
                              value: 'yes',
                              groupValue: _isDecisionMaker,
                              onChanged: (value) {
                                setState(() => _isDecisionMaker = value);
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('No'),
                              value: 'no',
                              groupValue: _isDecisionMaker,
                              onChanged: (value) {
                                setState(() => _isDecisionMaker = value);
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Medicare Part B Radio Group
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Do you have Medicare Part B?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Medicare Part B covers medical insurance including doctor visits and outpatient care.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Yes'),
                              value: 'yes',
                              groupValue: _hasMedicarePartB,
                              onChanged: (value) {
                                setState(() => _hasMedicarePartB = value);
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('No'),
                              value: 'no',
                              groupValue: _hasMedicarePartB,
                              onChanged: (value) {
                                setState(() => _hasMedicarePartB = value);
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Medicare Documents Section
                  _buildMedicareDocumentsSection(theme),

                  const SizedBox(height: 32),

                  PrimaryButton(
                    label:
                        _loading ? 'Saving Information...' : 'Complete Profile',
                    loading: _loading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 16),

                  // Skip for now button
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).pushReplacementNamed(
                              DashboardScreen.routeName,
                            );
                          },
                    child: Text(
                      'Skip for now',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicareDocumentsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Medicare Insurance Card', theme),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_membership,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload Your Medicare Card',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Upload both sides of your Medicare health insurance card for verification and faster processing.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Front of Card
        _buildCardUploadTile(
          theme,
          title: 'Front of Medicare Card',
          subtitle: 'Upload the front side with your name and Medicare number',
          icon: Icons.credit_card,
          isUploaded: _insuranceCardFrontUploaded,
          fileName: _frontCardFileName,
          onTap: () => _pickInsuranceCard(true),
        ),

        const SizedBox(height: 16),

        // Back of Card
        _buildCardUploadTile(
          theme,
          title: 'Back of Medicare Card',
          subtitle: 'Upload the back side with additional details',
          icon: Icons.flip_to_back,
          isUploaded: _insuranceCardBackUploaded,
          fileName: _backCardFileName,
          onTap: () => _pickInsuranceCard(false),
        ),

        if (_insuranceCardFrontUploaded || _insuranceCardBackUploaded) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your Medicare card images have been uploaded successfully. They will be securely stored and used for verification purposes only.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardUploadTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    String? fileName,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _uploadingCard ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isUploaded ? Colors.green.shade300 : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
        ),
        child: Column(
          children: [
            if (isUploaded && fileName != null) ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fileName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? Colors.green.shade100
                        : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isUploaded ? Icons.check_circle : icon,
                    color: isUploaded ? Colors.green.shade600 : AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isUploaded
                              ? Colors.green.shade700
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUploaded ? 'Image uploaded successfully' : subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isUploaded
                              ? Colors.green.shade600
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_uploadingCard)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                    ),
                  )
                else
                  Icon(
                    isUploaded ? Icons.edit : Icons.upload,
                    color: isUploaded ? Colors.green.shade600 : AppColors.info,
                    size: 20,
                  ),
              ],
            ),
            if (!isUploaded) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Tap to upload photo',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickInsuranceCard(bool isFront) async {
    if (_uploadingCard) return;

    final String? source = await _showImageSourceDialog();
    if (source == null) return;

    setState(() => _uploadingCard = true);

    // Simulate upload delay
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      if (isFront) {
        _insuranceCardFrontUploaded = true;
        _frontCardFileName = 'medicare_card_front.jpg';
      } else {
        _insuranceCardBackUploaded = true;
        _backCardFileName = 'medicare_card_back.jpg';
      }
      _uploadingCard = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isFront ? "Front" : "Back"} of Medicare card uploaded successfully!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String?> _showImageSourceDialog() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_a_photo, color: AppColors.info),
                  const SizedBox(width: 12),
                  Text(
                    'Upload Medicare Card',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(Icons.camera_alt, color: Colors.blue.shade700),
                    ),
                    title: const Text('Take Photo'),
                    subtitle: const Text('Use camera to capture card'),
                    onTap: () => Navigator.pop(context, 'camera'),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.photo_library,
                          color: Colors.purple.shade700),
                    ),
                    title: const Text('Choose from Gallery'),
                    subtitle: const Text('Select existing photo'),
                    onTap: () => Navigator.pop(context, 'gallery'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCallNow() async {
    const phoneNumber = '1-800-633-4227';
    await Clipboard.setData(const ClipboardData(text: phoneNumber));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number $phoneNumber copied to clipboard'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Call',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
