import 'package:flutter/material.dart';
import '../../../services/medicare_api_service.dart';
import '../models/questionnaire_response_models.dart';

class QuestionnaireResponsesScreen extends StatefulWidget {
  static const routeName = '/questionnaire-responses';

  const QuestionnaireResponsesScreen({super.key});

  @override
  State<QuestionnaireResponsesScreen> createState() =>
      _QuestionnaireResponsesScreenState();
}

class _QuestionnaireResponsesScreenState
    extends State<QuestionnaireResponsesScreen> {
  final _api = MedicareApiService.instance;

  QuestionnaireResponseList? _responseList;
  bool _loading = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses({int page = 1}) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final responsesData =
          await _api.questionnaires.getMyQuestionnaireResponses(
        page: page,
        perPage: 10,
      );

      setState(() {
        _responseList = QuestionnaireResponseList.fromJson(responsesData);
        _currentPage = page;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshResponses() async {
    await _loadResponses(page: _currentPage);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade500;
      case 'in_progress':
        return Colors.orange.shade500;
      case 'pending':
        return Colors.grey.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  Widget _buildResponseCard(QuestionnaireResponse response) {
    final statusColor = _getStatusColor(response.status);
    final statusIcon = _getStatusIcon(response.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            response.isCompleted ? () => _showResponseDetails(response) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          response.questionnaire?.title ??
                              'Questionnaire #${response.questionnaireId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (response.questionnaire?.plan != null)
                          Text(
                            response.questionnaire!.plan!.name,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          response.statusDisplay,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar for in-progress responses
              if (response.isInProgress) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: response.completionPercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${response.completionPercentage}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Response details
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    response.startedAt != null
                        ? 'Started ${_formatDateTime(response.startedAt!)}'
                        : 'No start time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (response.isCompleted && response.duration != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${response.timeTaken} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),

              if (response.isInProgress) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _continueQuestionnaire(response),
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Continue'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade600,
                          side: BorderSide(color: Colors.blue.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _showResponseDetails(QuestionnaireResponse response) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Response Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildDetailRow('Questionnaire',
                          response.questionnaire?.title ?? 'Unknown'),
                      if (response.questionnaire?.plan != null)
                        _buildDetailRow(
                            'Plan', response.questionnaire!.plan!.name),
                      _buildDetailRow('Status', response.statusDisplay),
                      _buildDetailRow(
                          'Completion', '${response.completionPercentage}%'),
                      if (response.startedAt != null)
                        _buildDetailRow('Started',
                            _formatFullDateTime(response.startedAt!)),
                      if (response.completedAt != null)
                        _buildDetailRow('Completed',
                            _formatFullDateTime(response.completedAt!)),
                      if (response.timeTaken != null)
                        _buildDetailRow(
                            'Duration', '${response.timeTaken} minutes'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _continueQuestionnaire(QuestionnaireResponse response) {
    Navigator.pushNamed(
      context,
      '/questionnaire',
      arguments: {
        'planId': response.questionnaire?.plan?.id ?? 0,
        'questionnaireId': response.questionnaireId,
        'responseId': response.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Questionnaires'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshResponses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading questionnaire responses...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading responses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshResponses,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_responseList?.isEmpty == true) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No questionnaires yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Start comparing Medicare plans to begin your first questionnaire.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
                child: const Text('Browse Plans'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshResponses,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_responseList != null) ...[
            Text(
              'Your Questionnaire History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            ..._responseList!.data.map(_buildResponseCard),

            // Pagination
            if (_responseList!.hasNextPage ||
                _responseList!.hasPreviousPage) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _responseList!.hasPreviousPage
                        ? () => _loadResponses(page: _currentPage - 1)
                        : null,
                    child: const Text('Previous'),
                  ),
                  Text(
                    'Page $_currentPage${_responseList!.totalPages != null ? ' of ${_responseList!.totalPages}' : ''}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  ElevatedButton(
                    onPressed: _responseList!.hasNextPage
                        ? () => _loadResponses(page: _currentPage + 1)
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
