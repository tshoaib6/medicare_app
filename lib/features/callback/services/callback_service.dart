import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

/// Callback Service - Handles all callback request related APIs
/// Following the exact API specification from the documentation
class CallbackService {
  final ApiClient _apiClient = ApiClient();

  // =============================================================================
  // CALLBACK REQUEST APIs
  // =============================================================================

  /// POST /api/v1/callback-requests - Submit Callback Request
  Future<Map<String, dynamic>> submitCallbackRequest({
    required String name,
    required String phoneNumber,
    required String preferredTime,
    String? email,
    String? message,
    int? planId,
  }) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
        'phone_number': phoneNumber,
        'preferred_time': preferredTime,
      };

      if (email != null) body['email'] = email;
      if (message != null) body['message'] = message;
      if (planId != null) body['plan_id'] = planId;

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.createCallbackRequest,
        data: body,
      );

      if (response.data == null) {
        throw Exception('No response received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to submit callback request: $e');
    }
  }

  /// GET /api/v1/my/callback-requests - Get My Callback Requests
  Future<Map<String, dynamic>> getMyCallbackRequests({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri =
          '${ApiEndpoints.myCallbackRequests}?${Uri(queryParameters: queryParams).query}';

      final response = await _apiClient.get<Map<String, dynamic>>(uri);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get callback requests: $e');
    }
  }
}
