import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

/// Companies & Plans Service - Handles all company and plan related APIs
/// Following the exact API specification from the documentation
class CompanyPlanService {
  final ApiClient _apiClient = ApiClient();

  // =============================================================================
  // COMPANIES APIs
  // =============================================================================

  /// GET /api/v1/companies - Get All Companies
  Future<Map<String, dynamic>> getCompanies({
    String? search,
    String? specialty,
    String? sortBy,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (specialty != null && specialty.isNotEmpty && specialty != 'all') {
        queryParams['specialty'] = specialty;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      final uri =
          '${ApiEndpoints.companies}?${Uri(queryParameters: queryParams).query}';

      final response = await _apiClient.get<Map<String, dynamic>>(uri);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get companies: $e');
    }
  }

  /// GET /api/v1/companies/{id} - Get Company Details
  Future<Map<String, dynamic>> getCompany(int companyId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.companyDetails(companyId),
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get company details: $e');
    }
  }

  // =============================================================================
  // PLANS APIs
  // =============================================================================

  /// GET /api/v1/plans - Get All Plans
  Future<Map<String, dynamic>> getPlans({
    String? search,
    int? companyId,
    String? type,
    bool? isAvailable,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (companyId != null) queryParams['company_id'] = companyId.toString();
      if (type != null) queryParams['type'] = type;
      if (isAvailable != null)
        queryParams['is_available'] = isAvailable.toString();

      final uri =
          '${ApiEndpoints.plans}?${Uri(queryParameters: queryParams).query}';

      final response = await _apiClient.get<Map<String, dynamic>>(uri);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get plans: $e');
    }
  }

  /// GET /api/v1/plans/{id} - Get Plan Details
  Future<Map<String, dynamic>> getPlan(int planId) async {
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

  // =============================================================================
  // ENHANCED METHODS - For Company List Screen
  // =============================================================================

  /// Get filtered and sorted companies for provider selection
  Future<Map<String, dynamic>> getCompaniesForSelection({
    String? search,
    String? specialty,
    String? sortBy = 'rating',
    int page = 1,
    int perPage = 50,
  }) async {
    return await getCompanies(
      search: search,
      specialty: specialty,
      sortBy: sortBy,
      page: page,
      perPage: perPage,
    );
  }

  /// Get companies by questionnaire completion (could be used for recommendations)
  Future<Map<String, dynamic>> getRecommendedCompanies({
    required int questionnaireId,
    required int planId,
    int page = 1,
    int perPage = 20,
  }) async {
    // For now, return all companies sorted by rating
    // In future, this could use ML/AI recommendations based on questionnaire answers
    return await getCompanies(
      sortBy: 'rating',
      page: page,
      perPage: perPage,
    );
  }
}
