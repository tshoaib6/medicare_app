import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

/// Activity Service - Handles all activity logging related APIs
/// Following the exact API specification from the documentation
class ActivityService {
  final ApiClient _apiClient = ApiClient();

  // =============================================================================
  // ACTIVITY LOGGING APIs
  // =============================================================================

  /// POST /api/v1/activities/log - Log User Activity
  Future<Map<String, dynamic>> logActivity({
    required String action,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Map<String, dynamic> body = {
        'action': action,
      };

      if (description != null) body['description'] = description;
      if (metadata != null) body['metadata'] = metadata;

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.logActivity,
        data: body,
      );

      if (response.data == null) {
        throw Exception('No response received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to log activity: $e');
    }
  }

  /// GET /api/v1/my/activities - Get My Activities
  Future<Map<String, dynamic>> getMyActivities({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri =
          '${ApiEndpoints.myActivities}?${Uri(queryParameters: queryParams).query}';

      final response = await _apiClient.get<Map<String, dynamic>>(uri);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  // =============================================================================
  // CONVENIENCE METHODS - Pre-defined Activity Types
  // =============================================================================

  /// Log plan view activity
  Future<void> logPlanView(int planId, String planName) async {
    try {
      await logActivity(
        action: 'plan_viewed',
        description: 'User viewed plan: $planName',
        metadata: {
          'plan_id': planId,
          'plan_name': planName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail for activity logging
      print('Failed to log plan view: $e');
    }
  }

  /// Log questionnaire start activity
  Future<void> logQuestionnaireStart(int questionnaireId, int planId) async {
    await logActivity(
      action: 'questionnaire_started',
      description: 'User started questionnaire for plan',
      metadata: {
        'questionnaire_id': questionnaireId,
        'plan_id': planId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log questionnaire completion activity
  Future<void> logQuestionnaireComplete(
      int questionnaireId, int timeTaken) async {
    await logActivity(
      action: 'questionnaire_completed',
      description: 'User completed questionnaire',
      metadata: {
        'questionnaire_id': questionnaireId,
        'time_taken_minutes': timeTaken,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log callback request activity
  Future<void> logCallbackRequest(int? planId, String preferredTime) async {
    await logActivity(
      action: 'callback_requested',
      description: 'User requested callback',
      metadata: {
        'plan_id': planId,
        'preferred_time': preferredTime,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log user registration activity
  Future<void> logUserRegistration() async {
    await logActivity(
      action: 'user_registered',
      description: 'New user registered',
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log user login activity
  Future<void> logUserLogin() async {
    await logActivity(
      action: 'user_login',
      description: 'User logged in',
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
