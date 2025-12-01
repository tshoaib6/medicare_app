import '../network/api_client.dart';
import '../network/endpoints.dart';

class QuestionnaireService {
  final ApiClient _client = ApiClient();

  /// Get list of questionnaires
  Future<Map<String, dynamic>> getQuestionnaires({
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.questionnaires,
      query: queryParams.isNotEmpty ? queryParams : null,
    );
    return res.data!;
  }

  /// Get questionnaire details by ID
  Future<Map<String, dynamic>> getQuestionnaireDetails(int id) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.questionnaireDetails(id),
    );
    return res.data!;
  }

  /// Get questionnaire questions by questionnaire ID
  Future<Map<String, dynamic>> getQuestionnaireQuestions(int id) async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.questionnaireQuestions(id),
    );
    return res.data!;
  }
}
