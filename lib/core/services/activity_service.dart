import '../network/api_client.dart';
import '../network/endpoints.dart';

class ActivityService {
  final ApiClient _client = ApiClient();

  /// Get user's activity history
  Future<Map<String, dynamic>> getMyActivities({
    int? page,
    int? perPage,
    String? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (dateFrom != null && dateFrom.isNotEmpty)
      queryParams['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.myActivities,
      query: queryParams.isNotEmpty ? queryParams : null,
    );
    return res.data!;
  }

  /// Log user activity
  Future<Map<String, dynamic>> logActivity({
    required String type,
    required String description,
    Map<String, dynamic>? metadata,
    String? entityType,
    String? entityId,
  }) async {
    final data = <String, dynamic>{
      'type': type,
      'description': description,
    };

    if (metadata != null) data['metadata'] = metadata;
    if (entityType != null && entityType.isNotEmpty)
      data['entity_type'] = entityType;
    if (entityId != null && entityId.isNotEmpty) data['entity_id'] = entityId;

    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.logActivity,
      data: data,
    );
    return res.data!;
  }
}
