import '../network/api_client.dart';
import '../network/endpoints.dart';

class CompanyService {
  final ApiClient _client = ApiClient();

  /// Get list of all companies with optional search and pagination
  Future<Map<String, dynamic>> getCompanies({
    String? search,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.companies,
      query: queryParams.isNotEmpty ? queryParams : null,
    );
    return res.data!;
  }

  /// Get company details by ID
  Future<Map<String, dynamic>> getCompanyDetails(int id) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.companyDetails(id),
    );
    return res.data!;
  }
}
