// Import existing services
import '../features/questionnaire/services/questionnaire_service.dart';
import '../features/companies/services/company_plan_service.dart';
import '../features/callback/services/callback_service.dart';
import '../features/activity/services/activity_service.dart';
import '../features/ads/services/ads_service.dart';

/// Medicare API Service - Central hub for all API services
/// Following the exact API specification from the comprehensive documentation
///
/// This class provides a single entry point for all Medicare app APIs
/// and handles authentication token management across all services
class MedicareApiService {
  // Service instances
  late final CompanyPlanService _companyPlanService;
  late final QuestionnaireService _questionnaireService;
  late final CallbackService _callbackService;
  late final ActivityService _activityService;
  late final AdsService _adsService;

  // Singleton pattern
  static MedicareApiService? _instance;

  MedicareApiService._() {
    _companyPlanService = CompanyPlanService();
    _questionnaireService = QuestionnaireService();
    _callbackService = CallbackService();
    _activityService = ActivityService();
    _adsService = AdsService();
  }

  static MedicareApiService get instance {
    _instance ??= MedicareApiService._();
    return _instance!;
  }

  // =============================================================================
  // SERVICE ACCESSORS
  // =============================================================================

  /// Access to company and plan APIs
  CompanyPlanService get companies => _companyPlanService;

  /// Access to questionnaire APIs
  QuestionnaireService get questionnaires => _questionnaireService;

  /// Access to callback request APIs
  CallbackService get callbacks => _callbackService;

  /// Access to activity logging APIs
  ActivityService get activities => _activityService;

  /// Access to ads APIs
  AdsService get ads => _adsService;

  // =============================================================================
  // COMMON WORKFLOWS - High-level API combinations
  // =============================================================================

  /// Complete questionnaire workflow with activity tracking
  Future<Map<String, dynamic>> completeQuestionnaireWithTracking({
    required int questionnaireId,
    required int planId,
    required Map<int, dynamic> answers,
  }) async {
    try {
      final startTime = DateTime.now();

      // 1. Start questionnaire
      final startResult =
          await questionnaires.startQuestionnaire(questionnaireId);
      final responseId = startResult['data']['id'] as int;

      // 2. Log start activity
      try {
        await activities.logQuestionnaireStart(questionnaireId, planId);
      } catch (e) {
        print('Failed to log questionnaire start: $e');
      }

      // 3. Get questions for validation
      final questionsResult =
          await questionnaires.getQuestionnaireQuestions(questionnaireId);
      final questions = questionsResult['data'] as List<dynamic>;

      // 4. Complete questionnaire
      final completeResult = await questionnaires.submitQuestionnaireWorkflow(
        responseId: responseId,
        answers: answers,
        questions: questions,
      );

      // 5. Log completion activity
      try {
        final endTime = DateTime.now();
        final timeTaken = endTime.difference(startTime).inMinutes;
        await activities.logQuestionnaireComplete(questionnaireId, timeTaken);
      } catch (e) {
        print('Failed to log questionnaire completion: $e');
      }

      return completeResult;
    } catch (e) {
      throw Exception('Questionnaire completion failed: $e');
    }
  }

  /// Submit callback request with activity tracking
  Future<Map<String, dynamic>> submitCallbackWithTracking({
    required String name,
    required String phoneNumber,
    required String preferredTime,
    String? email,
    String? message,
    int? planId,
  }) async {
    try {
      // 1. Submit callback request
      final callbackResult = await callbacks.submitCallbackRequest(
        name: name,
        phoneNumber: phoneNumber,
        preferredTime: preferredTime,
        email: email,
        message: message,
        planId: planId,
      );

      // 2. Log callback activity
      try {
        await activities.logCallbackRequest(planId, preferredTime);
      } catch (e) {
        print('Failed to log callback activity: $e');
      }

      return callbackResult;
    } catch (e) {
      throw Exception('Callback request failed: $e');
    }
  }

  /// View plan with activity tracking and ad loading
  Future<Map<String, dynamic>> viewPlanWithTracking(int planId) async {
    try {
      // 1. Get plan details
      final planResult = await companies.getPlan(planId);
      final planData = planResult['data'];
      final planName = planData['name'] as String;

      // 2. Log plan view activity
      try {
        await activities.logPlanView(planId, planName);
      } catch (e) {
        print('Failed to log plan view: $e');
      }

      // 3. Load related ads (if any)
      try {
        final adsResult = await ads.getActiveAds();
        planResult['related_ads'] = adsResult['data'];
      } catch (e) {
        print('Failed to load ads: $e');
        planResult['related_ads'] = [];
      }

      return planResult;
    } catch (e) {
      throw Exception('Failed to view plan: $e');
    }
  }

  // =============================================================================
  // HEALTH CHECK & UTILITIES
  // =============================================================================

  /// Test API connectivity and authentication
  Future<Map<String, String>> checkApiHealth() async {
    Map<String, String> status = {};

    // Auth testing removed - integrate with existing auth service as needed

    try {
      // Test companies endpoint
      await companies.getCompanies(page: 1, perPage: 1);
      status['companies'] = 'OK';
    } catch (e) {
      status['companies'] = 'FAILED: $e';
    }

    try {
      // Test questionnaires endpoint
      await questionnaires.getQuestionnaires(page: 1, perPage: 1);
      status['questionnaires'] = 'OK';
    } catch (e) {
      status['questionnaires'] = 'FAILED: $e';
    }

    try {
      // Test ads endpoint (public)
      await ads.getActiveAds();
      status['ads'] = 'OK';
    } catch (e) {
      status['ads'] = 'FAILED: $e';
    }

    return status;
  }

  /// Complete questionnaire-to-company workflow
  Future<Map<String, dynamic>> getCompaniesAfterQuestionnaire({
    required int questionnaireId,
    required int planId,
    String? search,
    String? specialty = 'all',
    String? sortBy = 'rating',
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      // 1. Log activity for company browsing
      try {
        await activities.logActivity(
          action: 'company_browsing_start',
          description:
              'User started browsing companies after questionnaire completion',
          metadata: {
            'questionnaire_id': questionnaireId,
            'plan_id': planId,
            'search': search ?? '',
            'specialty': specialty ?? 'all',
            'sort_by': sortBy ?? 'rating',
          },
        );
      } catch (e) {
        print('Failed to log company browsing activity: $e');
      }

      // 2. Get companies with enhanced filtering
      final companiesResult = await companies.getCompaniesForSelection(
        search: search,
        specialty: specialty != 'all' ? specialty : null,
        sortBy: sortBy,
        page: page,
        perPage: perPage,
      );

      return companiesResult;
    } catch (e) {
      throw Exception('Failed to get companies after questionnaire: $e');
    }
  }

  /// Log company selection activity
  Future<void> logCompanySelection({
    required int companyId,
    required String companyName,
    required int questionnaireId,
    required int planId,
  }) async {
    try {
      await activities.logActivity(
        action: 'company_selected',
        description: 'User selected a company for plan enrollment',
        metadata: {
          'company_id': companyId,
          'company_name': companyName,
          'questionnaire_id': questionnaireId,
          'plan_id': planId,
          'selection_timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to log company selection: $e');
    }
  }

  /// Request callback for a specific company (convenience method)
  Future<void> requestCallback({
    required int companyId,
    required String name,
    required String phone,
    required String preferredTime,
    String? notes,
  }) async {
    try {
      await callbacks.submitCallbackRequest(
        name: name,
        phoneNumber: phone,
        preferredTime: preferredTime,
        planId: companyId, // Using companyId as planId for callback
        message: notes,
      );

      // Log the callback request activity
      await activities.logActivity(
        action: 'callback_requested',
        description: 'Callback requested for company ID: $companyId',
        metadata: {
          'company_id': companyId,
          'customer_name': name,
          'customer_phone': phone,
          'preferred_time': preferredTime,
          'notes': notes ?? '',
          'request_timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to request callback: $e');
    }
  }

  /// Get API service information
  Map<String, String> getApiInfo() {
    return {
      'base_url': 'http://10.0.2.2:8000/api/v1', // From endpoints
      'version': '1.0.0',
      'services': 'auth, companies, questionnaires, callbacks, activities, ads',
      'documentation': 'Medicare Admin Panel - Flutter API Documentation',
      'implementation_date': '2025-12-02',
    };
  }
}
