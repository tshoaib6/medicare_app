import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

class QuestionnaireService {
  final ApiClient _apiClient = ApiClient();

  // =============================================================================
  // QUESTIONNAIRE CORE APIs - Following Exact API Documentation
  // =============================================================================

  /// GET /api/v1/plans/{id} - Get Plan Details
  Future<Map<String, dynamic>> getPlanDetails(int planId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.planDetails(planId),
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get plan details: $e');
    }
  }

  /// GET /api/v1/questionnaires - Get All Questionnaires
  Future<Map<String, dynamic>> getQuestionnaires({
    String? search,
    int? planId,
    bool? isActive,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (planId != null) queryParams['plan_id'] = planId.toString();
      if (isActive != null) queryParams['is_active'] = isActive.toString();

      final uri =
          '${ApiEndpoints.questionnaires}?${Uri(queryParameters: queryParams).query}';

      final response = await _apiClient.get<Map<String, dynamic>>(uri);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get questionnaires: $e');
    }
  }

  /// GET /api/v1/questionnaires/{id} - Get Questionnaire Details
  Future<Map<String, dynamic>> getQuestionnaire(int questionnaireId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.questionnaireDetails(questionnaireId),
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get questionnaire: $e');
    }
  }

  /// GET /api/v1/questionnaires/{id}/questions - Get Questionnaire Questions
  Future<Map<String, dynamic>> getQuestionnaireQuestions(
      int questionnaireId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.questionnaireQuestions(questionnaireId),
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get questionnaire questions: $e');
    }
  }

  // =============================================================================
  // QUESTIONNAIRE RESPONSE APIs - Core Feature Implementation
  // =============================================================================

  /// POST /api/v1/questionnaires/{id}/start - Start a Questionnaire
  Future<Map<String, dynamic>> startQuestionnaire(int questionnaireId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.startQuestionnaire(questionnaireId),
        data: {},
      );

      if (response.data == null) {
        throw Exception('No response received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to start questionnaire: $e');
    }
  }

  /// POST /api/v1/questionnaire-responses/{id}/answers - Submit Answers
  Future<Map<String, dynamic>> submitAnswers({
    required int responseId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.submitAnswers(responseId),
        data: {'answers': answers},
      );

      if (response.data == null) {
        throw Exception('No response received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to submit answers: $e');
    }
  }

  /// POST /api/v1/questionnaire-responses/{id}/complete - Complete Questionnaire
  Future<Map<String, dynamic>> completeQuestionnaire(int responseId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.completeQuestionnaire(responseId),
        data: {},
      );

      if (response.data == null) {
        throw Exception('No response received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to complete questionnaire: $e');
    }
  }

  /// GET /api/v1/my/questionnaire-responses - Get My Questionnaire Responses
  Future<Map<String, dynamic>> getMyQuestionnaireResponses({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri =
          '${ApiEndpoints.myQuestionnaireResponses}?${Uri(queryParameters: queryParams).query}';

      final response = await _apiClient.get<Map<String, dynamic>>(uri);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to fetch questionnaire responses: $e');
    }
  }

  /// GET /api/v1/questionnaire-responses/{id} - Get Specific Response Details
  Future<Map<String, dynamic>> getQuestionnaireResponse(int responseId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getQuestionnaireResponse(responseId),
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get questionnaire response: $e');
    }
  }

  // =============================================================================
  // HELPER METHODS - Answer Formatting & Validation
  // =============================================================================

  /// Convert UI answers to API format
  /// Following the exact API specification for answer submission
  List<Map<String, dynamic>> formatAnswersForAPI(Map<int, dynamic> uiAnswers) {
    final List<Map<String, dynamic>> apiAnswers = [];

    for (final entry in uiAnswers.entries) {
      final questionId = entry.key;
      final answer = entry.value;

      Map<String, dynamic> formattedAnswer = {
        'question_id': questionId,
        'answer_value': null,
        'answer_text': null,
      };

      if (answer is String && answer.isNotEmpty) {
        // Text answer
        formattedAnswer['answer_text'] = answer;
      } else if (answer is List && answer.isNotEmpty) {
        // Multiple choice answer - convert to option IDs
        formattedAnswer['answer_value'] = answer;
      } else if (answer != null) {
        // Single choice answer - wrap in array
        formattedAnswer['answer_value'] = [answer];
      }

      // Only include answers that have values
      if (formattedAnswer['answer_value'] != null ||
          formattedAnswer['answer_text'] != null) {
        apiAnswers.add(formattedAnswer);
      }
    }

    return apiAnswers;
  }

  /// Validate answers based on question requirements
  List<String> validateAnswers(
      Map<int, dynamic> answers, List<dynamic> questions) {
    final List<String> errors = [];

    for (final question in questions) {
      final questionId = question['id'] as int;
      final isRequired = question['is_required'] as bool? ?? false;
      final questionText =
          question['question_text'] as String? ?? 'Question $questionId';
      final questionType = question['type'] as String? ?? 'text';

      if (!isRequired) continue;

      final answer = answers[questionId];

      switch (questionType) {
        case 'single_choice':
          if (answer == null) {
            errors.add('$questionText is required');
          }
          break;
        case 'multiple_choice':
          if (answer == null || (answer is List && answer.isEmpty)) {
            errors.add('$questionText is required');
          }
          break;
        case 'text':
          if (answer == null || answer.toString().trim().isEmpty) {
            errors.add('$questionText is required');
          }
          break;
      }
    }

    return errors;
  }

  // =============================================================================
  // HIGH-LEVEL WORKFLOW METHODS
  // =============================================================================

  /// Complete questionnaire workflow - handles full submission process
  Future<Map<String, dynamic>> submitQuestionnaireWorkflow({
    required int responseId,
    required Map<int, dynamic> answers,
    required List<dynamic> questions,
  }) async {
    try {
      // 1. Validate answers
      final validationErrors = validateAnswers(answers, questions);
      if (validationErrors.isNotEmpty) {
        throw Exception('Validation failed: ${validationErrors.join(', ')}');
      }

      // 2. Format answers for API
      final formattedAnswers = formatAnswersForAPI(answers);

      if (formattedAnswers.isEmpty) {
        throw Exception('No valid answers to submit');
      }

      // 3. Submit answers
      final submitResult = await submitAnswers(
        responseId: responseId,
        answers: formattedAnswers,
      );

      // 4. Complete questionnaire
      final completeResult = await completeQuestionnaire(responseId);

      return {
        'success': true,
        'message': 'Questionnaire completed successfully',
        'submit_result': submitResult,
        'complete_result': completeResult,
      };
    } catch (e) {
      throw Exception('Failed to complete questionnaire workflow: $e');
    }
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use submitQuestionnaireWorkflow instead')
  Future<Map<String, dynamic>> submitQuestionnaireAnswers({
    required int questionnaireId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.submitQuestionnaireAnswers(questionnaireId),
        data: {'answers': answers},
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to submit questionnaire: $e');
    }
  }
}
