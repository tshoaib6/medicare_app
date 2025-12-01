import '../network/api_client.dart';
import '../network/endpoints.dart';

class CallbackService {
  final ApiClient _client = ApiClient();

  /// Get user's callback requests
  Future<Map<String, dynamic>> getMyCallbackRequests({
    int? page,
    int? perPage,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.myCallbackRequests,
      query: queryParams.isNotEmpty ? queryParams : null,
    );
    return res.data!;
  }

  /// Create new callback request
  Future<Map<String, dynamic>> createCallbackRequest({
    required String name,
    required String phoneNumber,
    required String preferredTime,
    String? message,
    String? companyId,
    String? planId,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'phone_number': phoneNumber,
      'preferred_time': preferredTime,
    };

    if (message != null && message.isNotEmpty) data['message'] = message;
    if (companyId != null && companyId.isNotEmpty)
      data['company_id'] = companyId;
    if (planId != null && planId.isNotEmpty) data['plan_id'] = planId;
    if (additionalData != null) data.addAll(additionalData);

    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.createCallbackRequest,
      data: data,
    );
    return res.data!;
  }
}
