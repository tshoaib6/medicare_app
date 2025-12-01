import 'package:flutter/material.dart';
import '../../../services/medicare_api_service.dart';
import '../models/questionnaire_models.dart';
import '../models/questionnaire_response_models.dart';
import '../../dashboard/models/plan_model.dart';

class QuestionnaireScreen extends StatefulWidget {
  static const routeName = '/questionnaire';
  final int planId;
  final int questionnaireId;
  final int? responseId; // For continuing existing responses

  const QuestionnaireScreen({
    super.key,
    required this.planId,
    required this.questionnaireId,
    this.responseId,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _api = MedicareApiService.instance;

  Questionnaire? _questionnaire;
  PlanModel? _plan;
  QuestionnaireResponse? _questionnaireResponse;
  bool _loading = true;
  String? _error;

  int _currentQuestionIndex = 0;
  Map<int, dynamic> _answers = {};
  String? _validationError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);

      // Load plan and questionnaire data
      final planResponse = await _api.companies.getPlan(widget.planId);
      final questionnaireResponse =
          await _api.questionnaires.getQuestionnaire(widget.questionnaireId);

      final plan = PlanModel.fromJson(planResponse['data']);
      final questionnaire =
          Questionnaire.fromJson(questionnaireResponse['data']);

      QuestionnaireResponse? response;

      if (widget.responseId != null) {
        // Load existing response for continuation
        try {
          final responseData = await _api.questionnaires
              .getQuestionnaireResponse(widget.responseId!);
          response = QuestionnaireResponse.fromJson(responseData['data']);
          // TODO: Load existing answers if needed
        } catch (e) {
          // If response not found, continue without response tracking
          print('Could not load existing response: $e');
          response = null;
        }
      }

      // If no existing response, try to start a new one (but don't fail if API doesn't exist)
      if (response == null) {
        try {
          final startResponse = await _api.questionnaires
              .startQuestionnaire(widget.questionnaireId);
          response = QuestionnaireResponse.fromJson(startResponse['data']);
        } catch (e) {
          // If start questionnaire API doesn't exist, continue without response tracking
          print('Start questionnaire API not available: $e');
          response = null;
        }
      }

      setState(() {
        _plan = plan;
        _questionnaire = questionnaire;
        _questionnaireResponse = response;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _handleAnswerChange(int questionId, dynamic value) {
    setState(() {
      _answers[questionId] = value;
      _validationError = null;
    });

    // Auto-save answers (debounced)
    _autoSaveAnswers();
  }

  Future<void> _autoSaveAnswers() async {
    // Only auto-save if we have a valid response ID (API is working)
    if (_questionnaireResponse == null || _questionnaire == null) {
      // Silently skip auto-save if APIs are not available
      return;
    }

    try {
      // Convert current answers to API format
      final apiAnswers = _api.questionnaires.formatAnswersForAPI(_answers);

      if (apiAnswers.isNotEmpty) {
        // Submit answers silently
        await _api.questionnaires.submitAnswers(
          responseId: _questionnaireResponse!.id,
          answers: apiAnswers,
        );
      }
    } catch (e) {
      // Silent fail for auto-save - don't show errors to user
      debugPrint('Auto-save failed (API may not be implemented): $e');
    }
  }

  bool _validateCurrentAnswer() {
    if (_questionnaire == null) return false;

    final question = _questionnaire!.questions[_currentQuestionIndex];
    final answer = _answers[question.id];

    if (!question.isRequired) return true;

    switch (question.questionType) {
      case 'single_choice':
        return answer != null;
      case 'multiple_choice':
        return answer != null && (answer as List).isNotEmpty;
      case 'text':
        return answer != null && answer.toString().trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _handleNext() {
    if (!_validateCurrentAnswer()) {
      setState(() {
        _validationError = 'Please answer this question before continuing.';
      });
      return;
    }

    if (_currentQuestionIndex < _questionnaire!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _validationError = null;
      });
    } else {
      _completeQuestionnaire();
    }
  }

  void _handlePrevious() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _validationError = null;
      });
    }
  }

  Future<void> _completeQuestionnaire() async {
    if (_questionnaire == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid questionnaire state'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _submitting = true);

      // Use the comprehensive questionnaire completion workflow
      await _api.completeQuestionnaireWithTracking(
        questionnaireId: widget.questionnaireId,
        planId: widget.planId,
        answers: _answers,
      );

      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Questionnaire completed successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to company list screen
        Navigator.of(context).pushReplacementNamed(
          '/company-list',
          arguments: {
            'plan': _plan!,
            'questionnaireId': widget.questionnaireId,
            'responseId': _questionnaireResponse?.id ?? 0,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting questionnaire: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildQuestionWidget(Question question) {
    final answer = _answers[question.id];

    switch (question.questionType) {
      case 'single_choice':
        return _buildSingleChoiceQuestion(question, answer);
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(question, answer);
      case 'text':
        return _buildTextQuestion(question, answer);
      default:
        return const Text('Unsupported question type');
    }
  }

  Widget _buildSingleChoiceQuestion(Question question, dynamic answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        ...question.options.map(
          (option) => RadioListTile<String>(
            title: Text(option.label),
            value: option.value,
            groupValue: answer?.toString(),
            onChanged: (value) => _handleAnswerChange(question.id, value),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceQuestion(Question question, dynamic answer) {
    final selectedValues = List<String>.from(answer ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        ...question.options.map(
          (option) => CheckboxListTile(
            title: Text(option.label),
            value: selectedValues.contains(option.value),
            onChanged: (checked) {
              final newValues = List<String>.from(selectedValues);
              if (checked == true) {
                newValues.add(option.value);
              } else {
                newValues.remove(option.value);
              }
              _handleAnswerChange(question.id, newValues);
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildTextQuestion(Question question, dynamic answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: answer?.toString() ?? '',
          onChanged: (value) => _handleAnswerChange(question.id, value),
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your answer...',
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $_error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questionnaire == null || _plan == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: Text('No data available')),
      );
    }

    final progress =
        ((_currentQuestionIndex + 1) / _questionnaire!.questions.length) * 100;
    final currentQuestion = _questionnaire!.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
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
                    // Logo and Back
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          children: [
                            Icon(Icons.shield_outlined,
                                size: 24, color: Colors.blue.shade600),
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Icon(Icons.favorite,
                                  size: 12, color: Colors.red.shade500),
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
                    // Progress
                    Row(
                      children: [
                        Text(
                          '${_currentQuestionIndex + 1}/${_questionnaire!.questions.length}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 64,
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getPlanColor(_plan!.id),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _plan!.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'Application Questionnaire',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instructions
                  if (_questionnaire!.instructions.isNotEmpty) ...[
                    Text(
                      _questionnaire!.instructions,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Question Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${_currentQuestionIndex + 1}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (currentQuestion.isRequired)
                              const Text(
                                '* Required',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Question content
                        _buildQuestionWidget(currentQuestion),

                        const SizedBox(height: 20),

                        // Validation error
                        if (_validationError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _validationError!,
                                    style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Navigation buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    (_currentQuestionIndex == 0 || _submitting)
                                        ? null
                                        : _handlePrevious,
                                child: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _handleNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        _currentQuestionIndex ==
                                                _questionnaire!
                                                        .questions.length -
                                                    1
                                            ? 'Complete'
                                            : 'Next',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Help text
                  Center(
                    child: Text(
                      'Need help? Contact our support team at 1-800-MEDICARE',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
