import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  bool _isDecisionMaker = false;
  bool _hasMedicarePartB = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstNameCtrl.text = user.firstName;
      _lastNameCtrl.text = user.lastName;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phoneNumber ?? '';
      _yearCtrl.text = user.yearOfBirth?.toString() ?? '';
      _zipCtrl.text = user.zipCode ?? '';
      _isDecisionMaker = user.isDecisionMaker;
      _hasMedicarePartB = user.hasMedicarePartB;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _yearCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final userProvider = context.read<UserProvider>();
    try {
      final payload = {
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim(),
        'year_of_birth':
            _yearCtrl.text.trim().isEmpty ? null : int.tryParse(_yearCtrl.text.trim()),
        'zip_code': _zipCtrl.text.trim(),
        'is_decision_maker': _isDecisionMaker,
        'has_medicare_part_b': _hasMedicarePartB,
      };
      await userProvider.updateProfile(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        DashboardScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tell us about yourself', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'We use this information to personalize your Medicare plan options.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.destructive),
                        ),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'First name',
                        controller: _firstNameCtrl,
                        validator: (v) => Validators.required(v, fieldName: 'First name'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Last name',
                        controller: _lastNameCtrl,
                        validator: (v) => Validators.required(v, fieldName: 'Last name'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Email (read-only)',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Email changes are managed through support.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Phone number',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            Validators.required(v, fieldName: 'Phone number'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Year of birth',
                        controller: _yearCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Year of birth is required';
                          }
                          final year = int.tryParse(v);
                          if (year == null || year < 1900 || year > DateTime.now().year) {
                            return 'Enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Zip code',
                        controller: _zipCtrl,
                        keyboardType: TextInputType.text,
                        validator: (v) =>
                            Validators.required(v, fieldName: 'Zip code'),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Are you the primary decision maker?'),
                        value: _isDecisionMaker,
                        onChanged: (val) {
                          setState(() => _isDecisionMaker = val);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Do you have Medicare Part B?'),
                        value: _hasMedicarePartB,
                        onChanged: (val) {
                          setState(() => _hasMedicarePartB = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Save profile',
                        loading: _loading,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
