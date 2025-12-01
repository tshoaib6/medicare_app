import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/medicare_api_service.dart';
import '../../dashboard/models/plan_model.dart' as plan_model;
import '../models/company_model.dart';

class CompanyDetailsScreen extends StatefulWidget {
  static const routeName = '/company-details';

  final CompanyModel company;
  final plan_model.PlanModel plan;
  final int questionnaireId;
  final int responseId;

  const CompanyDetailsScreen({
    super.key,
    required this.company,
    required this.plan,
    required this.questionnaireId,
    required this.responseId,
  });

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  final _api = MedicareApiService.instance;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _logCompanyView();
  }

  Future<void> _logCompanyView() async {
    try {
      await _api.activities.logActivity(
        action: 'company_viewed',
        description: 'Company details viewed: ${widget.company.name}',
        metadata: {
          'company_id': widget.company.id,
          'company_name': widget.company.name,
          'plan_id': widget.plan.id,
          'questionnaire_id': widget.questionnaireId,
          'response_id': widget.responseId,
        },
      );
    } catch (e) {
      // Log error but don't show to user
      debugPrint('Failed to log company view: $e');
    }
  }

  Future<void> _handleCallNow() async {
    try {
      final phoneUrl = Uri.parse('tel:${widget.company.phone}');
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);

        // Log the call action
        await _api.activities.logActivity(
          action: 'company_called',
          description: 'User called company: ${widget.company.name}',
          metadata: {
            'company_id': widget.company.id,
            'company_name': widget.company.name,
            'phone': widget.company.phone,
            'plan_id': widget.plan.id,
          },
        );
      } else {
        // Fallback: copy to clipboard and show snackbar
        await Clipboard.setData(ClipboardData(text: widget.company.phone));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Phone number ${widget.company.phone} copied to clipboard'),
              backgroundColor: Colors.blue.shade600,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to make call: ${widget.company.phone}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Future<void> _handleRequestCall() async {
    setState(() => _loading = true);

    try {
      // Show callback request dialog
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) =>
            _CallbackRequestDialog(companyName: widget.company.name),
      );

      if (result != null) {
        // Submit callback request via API
        await _api.requestCallback(
          companyId: widget.company.id,
          name: result['name']!,
          phone: result['phone']!,
          preferredTime: result['preferredTime']!,
          notes: result['notes'],
        );

        // Log the callback request
        await _api.activities.logActivity(
          action: 'callback_requested',
          description: 'Callback requested for company: ${widget.company.name}',
          metadata: {
            'company_id': widget.company.id,
            'company_name': widget.company.name,
            'plan_id': widget.plan.id,
            'customer_name': result['name'],
            'customer_phone': result['phone'],
            'preferred_time': result['preferredTime'],
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Callback request submitted successfully!'),
              backgroundColor: Colors.green.shade600,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to submit callback request. Please try again.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeroSection(),
                      const SizedBox(height: 16),
                      _buildCompanyStatsCard(),
                      const SizedBox(height: 16),
                      _buildContactCard(),
                      const SizedBox(height: 16),
                      _buildPlanMatchCard(),
                      const SizedBox(height: 16),
                      _buildFeaturesCard(),
                      const SizedBox(height: 16),
                      _buildBottomActions(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Stack(
                      children: [
                        Icon(Icons.shield,
                            color: Colors.blue.shade600, size: 24),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Icon(Icons.favorite,
                              color: Colors.red.shade500, size: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'MediCare+',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade400, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.company.rating,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            child: widget.company.displayImageUrl != null
                ? Image.network(
                    widget.company.displayImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImageFallback(),
                  )
                : _buildImageFallback(),
          ),
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.company.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.company.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: Colors.blue.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 48,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              widget.company.name,
              style: TextStyle(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Company Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    widget.company.founded ?? '1853',
                    'Founded',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    widget.company.members ?? '22.1M',
                    'Members',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    widget.company.states ?? '50 states',
                    'Coverage',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Specialties',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.company.specialties.map((specialty) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    specialty,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.phone,
              widget.company.formattedPhone,
              '24/7 Support',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.location_on,
              'Nationwide',
              'Service Area',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.people,
              widget.company.members ?? '22.1 million',
              'Active Members',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 16),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
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

  Widget _buildPlanMatchCard() {
    return Card(
      color: Colors.green.shade50,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
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
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfect Match',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.plan.title,
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
    );
  }

  Widget _buildFeaturesCard() {
    final defaultFeatures = [
      'Nationwide Provider Network',
      'Prescription Drug Coverage',
      'Preventive Care Services',
      'Wellness Programs',
      'Care Coordination',
      'Telehealth Services'
    ];

    final defaultBenefits = [
      '\$0 copay for preventive care',
      'Prescription drug coverage included',
      'Access to wellness programs',
      'Nationwide emergency coverage',
      '24/7 member support'
    ];

    final features = widget.company.features ?? defaultFeatures;
    final benefits = widget.company.benefits ?? defaultBenefits;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Key Features & Benefits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureSection('Plan Features', features),
            const SizedBox(height: 16),
            _buildFeatureSection('Member Benefits', benefits),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Ready to Get Started?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact ${widget.company.name} to learn more about your coverage options and get personalized assistance.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleCallNow,
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _handleRequestCall,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calendar_today, size: 16),
                label: Text(_loading ? 'Processing...' : 'Request to Call'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade300),
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
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
    );
  }
}

class _CallbackRequestDialog extends StatefulWidget {
  final String companyName;

  const _CallbackRequestDialog({required this.companyName});

  @override
  State<_CallbackRequestDialog> createState() => _CallbackRequestDialogState();
}

class _CallbackRequestDialogState extends State<_CallbackRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _preferredTime = 'Morning (9 AM - 12 PM)';

  final List<String> _timeOptions = [
    'Morning (9 AM - 12 PM)',
    'Afternoon (12 PM - 5 PM)',
    'Evening (5 PM - 8 PM)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request Callback from ${widget.companyName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _preferredTime,
              decoration: const InputDecoration(
                labelText: 'Preferred Call Time',
                border: OutlineInputBorder(),
              ),
              items: _timeOptions.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _preferredTime = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'preferredTime': _preferredTime,
                'notes': _notesController.text.trim(),
              });
            }
          },
          child: const Text('Submit Request'),
        ),
      ],
    );
  }
}
