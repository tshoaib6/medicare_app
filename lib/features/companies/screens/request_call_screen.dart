import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/medicare_api_service.dart';
import '../../dashboard/models/plan_model.dart' as plan_model;
import '../models/company_model.dart';
import '../../auth/providers/user_provider.dart';

class RequestCallScreen extends StatefulWidget {
  static const routeName = '/request-call';

  final CompanyModel company;
  final plan_model.PlanModel plan;
  final int questionnaireId;
  final int responseId;

  const RequestCallScreen({
    super.key,
    required this.company,
    required this.plan,
    required this.questionnaireId,
    required this.responseId,
  });

  @override
  State<RequestCallScreen> createState() => _RequestCallScreenState();
}

class _RequestCallScreenState extends State<RequestCallScreen> {
  final _api = MedicareApiService.instance;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedTimeZone;
  bool _isSubmitting = false;
  String _errorMessage = '';
  bool _userInfoLoaded = false;

  // Available time slots
  final List<String> _timeSlots = [
    '8:00 AM',
    '8:30 AM',
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
    '6:00 PM',
    '6:30 PM',
    '7:00 PM',
    '7:30 PM'
  ];

  final List<String> _timeZones = [
    'Eastern Time (ET)',
    'Central Time (CT)',
    'Mountain Time (MT)',
    'Pacific Time (PT)',
    'Alaska Time (AKT)',
    'Hawaii Time (HT)'
  ];

  @override
  void initState() {
    super.initState();
    _logCallRequestPageView();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInformation();
    });
  }

  Future<void> _loadUserInformation() async {
    if (_userInfoLoaded) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // If user is null, try to fetch current user
      if (userProvider.user == null) {
        await userProvider.fetchCurrentUser();
      }

      final user = userProvider.user;
      if (user != null && mounted) {
        setState(() {
          // Auto-populate name from user profile
          _nameController.text = user.fullName;

          // Auto-populate phone if available
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
            _phoneController.text = user.phoneNumber!;
          }

          // Auto-populate email
          _emailController.text = user.email;

          _userInfoLoaded = true;
        });
      }
    } catch (e) {
      // If user loading fails, just continue with empty fields
      debugPrint('Failed to load user information: $e');
      setState(() => _userInfoLoaded = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _logCallRequestPageView() async {
    try {
      await _api.activities.logActivity(
        action: 'call_request_page_viewed',
        description: 'User viewed call request page for ${widget.company.name}',
        metadata: {
          'company_id': widget.company.id,
          'company_name': widget.company.name,
          'plan_id': widget.plan.id,
        },
      );
    } catch (e) {
      debugPrint('Failed to log call request page view: $e');
    }
  }

  DateTime get _tomorrowDate {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  DateTime get _maxDate {
    return DateTime.now().add(const Duration(days: 30));
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number.');
      return false;
    }
    if (_selectedDate == null) {
      setState(() => _errorMessage = 'Please select a date for your call.');
      return false;
    }
    if (_selectedTime == null) {
      setState(() => _errorMessage = 'Please select a time for your call.');
      return false;
    }
    if (_selectedTimeZone == null) {
      setState(() => _errorMessage = 'Please select your time zone.');
      return false;
    }
    setState(() => _errorMessage = '');
    return true;
  }

  Future<void> _submitCallRequest() async {
    // Validate form first
    if (!_formKey.currentState!.validate() || !_validateForm()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final time24 = _convertTo24HourFormat(_selectedTime!);

      debugPrint('Submitting callback request with:');
      debugPrint('Company ID: ${widget.company.id}');
      debugPrint('Name: ${_nameController.text.trim()}');
      debugPrint('Phone: ${_phoneController.text.trim()}');
      debugPrint('Date: $dateStr');
      debugPrint('Date: $dateStr');
      debugPrint('Time: $time24');

      // Get user ID from provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        setState(() =>
            _errorMessage = 'Please log in to submit a callback request.');
        return;
      }

      final response = await _api.submitCallbackRequestWithDetails(
        userId: userProvider.user!.id,
        companyId: widget.company.id,
        companyName: widget.company.name,
        callDate: dateStr,
        callTime: time24,
        message: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
      );

      debugPrint('API Response: $response');

      if (mounted) {
        if (response['success'] == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => _SuccessDialog(
              companyName: widget.company.name,
              scheduledDate: _formatDate(_selectedDate!),
              scheduledTime: _selectedTime!,
              onClose: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          );
        } else {
          // Handle API error response
          String errorMessage =
              response['message'] ?? 'Failed to submit request';

          if (response['errors'] != null) {
            final errors = response['errors'];
            if (errors is Map) {
              errorMessage = errors.values
                  .where((e) => e is List)
                  .expand((list) => list as List)
                  .join('\n');
            } else if (errors is String) {
              errorMessage = errors;
            } else if (errors is List) {
              errorMessage = errors.join('\n');
            }
          }

          setState(() => _errorMessage = errorMessage);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error submitting callback request: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() => _errorMessage =
            'Network error. Please check your connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _convertTo24HourFormat(String time12) {
    final timeParts = time12.split(' ');
    final timeString = timeParts[0];
    final period = timeParts[1];

    final hourMinute = timeString.split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = hourMinute[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageTitle(),
                        const SizedBox(height: 24),
                        _buildPersonalInfoForm(),
                        const SizedBox(height: 20),
                        _buildCallSummaryCard(),
                        const SizedBox(height: 20),
                        _buildSchedulingForm(),
                        const SizedBox(height: 20),
                        _buildWhatToExpectCard(),
                        const SizedBox(height: 20),
                        _buildImportantNotes(),
                        const SizedBox(height: 20),
                      ],
                    ),
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
                Icon(Icons.phone, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.company.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Your Call',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Request a callback from ${widget.company.name} and our Medicare specialists will contact you at your preferred time.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name field - auto-populated from user profile
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: const Icon(Icons.person, size: 20),
                    helperText: userProvider.user != null
                        ? 'Auto-filled from your profile'
                        : null,
                    helperStyle:
                        TextStyle(color: Colors.green.shade600, fontSize: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() => _errorMessage = '');
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Phone field - auto-populated from user profile
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: const Icon(Icons.phone, size: 20),
                    helperText: userProvider.user?.phoneNumber != null
                        ? 'Auto-filled from your profile'
                        : 'Please enter your phone number',
                    helperStyle: TextStyle(
                        color: userProvider.user?.phoneNumber != null
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                        fontSize: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() => _errorMessage = '');
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Email field - auto-populated from user profile
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, size: 20),
                    helperText: userProvider.user != null
                        ? 'Auto-filled from your profile'
                        : null,
                    helperStyle:
                        TextStyle(color: Colors.green.shade600, fontSize: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  readOnly: userProvider.user !=
                      null, // Make read-only if from profile
                );
              },
            ),
            const SizedBox(height: 16),

            // Message field (optional)
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Additional Message (optional)',
                hintText: 'Tell us about your specific needs or questions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallSummaryCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Call Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryItem('Company', widget.company.name),
            if (_nameController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSummaryItem('Contact Name', _nameController.text),
            ],
            if (_phoneController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSummaryItem('Phone Number', _phoneController.text),
            ],
            if (_selectedDate != null) ...[
              const SizedBox(height: 12),
              _buildSummaryItem('Date', _formatDate(_selectedDate!)),
            ],
            if (_selectedTime != null && _selectedTimeZone != null) ...[
              const SizedBox(height: 12),
              _buildSummaryItem('Time', '$_selectedTime ($_selectedTimeZone)'),
            ],
            const SizedBox(height: 12),
            _buildSummaryItem('Company Phone', widget.company.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulingForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Select Your Preferred Call Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Selection
            _buildDatePicker(),
            const SizedBox(height: 20),

            // Time Selection
            _buildTimePicker(),
            const SizedBox(height: 20),

            // Time Zone Selection
            _buildTimeZonePicker(),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCallRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting Request...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 18),
                          SizedBox(width: 8),
                          Text('Request Call'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Date *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDatePicker(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Select a date',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedDate != null
                        ? Colors.black87
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Available dates: Tomorrow through next 30 days',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Time *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTime,
          decoration: InputDecoration(
            hintText: 'Select a time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _timeSlots.map((time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(time),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTime = value;
              _errorMessage = '';
            });
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Available Monday - Friday, 8:00 AM - 8:00 PM',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeZonePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Time Zone *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTimeZone,
          decoration: InputDecoration(
            hintText: 'Select your time zone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _timeZones.map((tz) {
            return DropdownMenuItem<String>(
              value: tz,
              child: Text(tz),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTimeZone = value;
              _errorMessage = '';
            });
          },
        ),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tomorrowDate,
      firstDate: _tomorrowDate,
      lastDate: _maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _errorMessage = '';
      });
    }
  }

  Widget _buildWhatToExpectCard() {
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
                  'What to Expect',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...[
              'Confirmation: You\'ll receive an email confirmation with your scheduled call details.',
              'Preparation: Our specialist will review your questionnaire responses beforehand.',
              'Discussion: The call typically lasts 15-30 minutes to discuss your options.',
              'Follow-up: You\'ll receive personalized plan recommendations via email.',
            ].map((item) => _buildExpectationItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpectationItem(String text) {
    final parts = text.split(': ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                children: [
                  TextSpan(
                    text: '${parts[0]}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: parts[1]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Important Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Call requests must be submitted at least 24 hours in advance',
            'You can reschedule or cancel your appointment by calling ${widget.company.phone}',
            'Please ensure you\'re available at the requested time to receive the call',
          ].map((note) => _buildNoteItem(note)),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '• $note',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String companyName;
  final String scheduledDate;
  final String scheduledTime;
  final VoidCallback onClose;

  const _SuccessDialog({
    required this.companyName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.green.shade600,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Call Request Submitted!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your call with $companyName has been scheduled for:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  scheduledDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scheduledTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You will receive an email confirmation shortly.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}
