import '../network/api_client.dart';
import '../network/endpoints.dart';

class PlanService {
  final ApiClient _client = ApiClient();

  /// Get list of all plans with optional filters
  Future<Map<String, dynamic>> getPlans({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? coverage,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (coverage != null && coverage.isNotEmpty)
      queryParams['coverage'] = coverage;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.plans,
      query: queryParams.isNotEmpty ? queryParams : null,
    );
    return res.data!;
  }

  /// Get plan details by ID
  Future<Map<String, dynamic>> getPlanDetails(int id) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.planDetails(id),
    );
    return res.data!;
  }
}
