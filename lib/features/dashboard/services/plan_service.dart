import '../../../core/network/api_client.dart';
import '../models/plan_model.dart';

class PlanService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PlanModel>> getPlans({
    int page = 1,
    int perPage = 15,
    String? search,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/plans');

    final data = response.data!['data'] as Map<String, dynamic>;
    final plansList = data['data'] as List<dynamic>;

    return plansList
        .map((json) => PlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PlanModel> getPlanById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/plans/$id');
    final data = response.data!['data'] as Map<String, dynamic>;
    return PlanModel.fromJson(data);
  }

  Future<PlanModel> getPlanBySlug(String slug) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/plans/slug/$slug');
    final data = response.data!['data'] as Map<String, dynamic>;
    return PlanModel.fromJson(data);
  }
}
