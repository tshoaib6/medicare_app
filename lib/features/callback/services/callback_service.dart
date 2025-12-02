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
  /// Updated to match new simplified API specification
  Future<Map<String, dynamic>> submitCallbackRequest({
    required int userId,
    required int companyId,
    required String callDate,
    required String callTime,
    String? message,
    String? status,
    String? adminNotes,
  }) async {
    try {
      Map<String, dynamic> body = {
        'user_id': userId,
        'company_id': companyId,
        'call_date': callDate, // Format: YYYY-MM-DD
        'call_time': callTime, // Format: HH:MM (24-hour)
      };

      if (message != null && message.isNotEmpty) body['message'] = message;
      if (status != null && status.isNotEmpty) body['status'] = status;
      if (adminNotes != null && adminNotes.isNotEmpty)
        body['admin_notes'] = adminNotes;

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
