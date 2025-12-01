class ApiEndpoints {
  // Base URL - Update this to your actual API endpoint
  // For local development with Android emulator use: http://10.0.2.2:8000/api/v1
  // For local development with iOS simulator use: http://localhost:8000/api/v1
  // static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // 📖 API Documentation & Health
  static const String root = '/';
  static const String health = '/health';

  // 🔐 Authentication Endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String sendOtp = '/auth/email/verify/request';
  static const String verifyOtp = '/auth/email/verify/confirm';
  static const String forgotPassword = '/auth/password/forgot';
  static const String resetPassword = '/auth/password/reset';

  // 🏢 Public Company & Plan Browsing
  static const String companies = '/companies';
  static String companyDetails(int id) => '/companies/$id';
  static const String plans = '/plans';
  static String planDetails(int id) => '/plans/$id';

  // 📝 Public Questionnaire Access
  static const String questionnaires = '/questionnaires';
  static String questionnaireDetails(int id) => '/questionnaires/$id';
  static String questionnaireQuestions(int id) =>
      '/questionnaires/$id/questions';

  // 📊 Questionnaire Responses (Protected)
  static const String myQuestionnaireResponses = '/my/questionnaire-responses';

  // Alternative endpoints - adjust based on your actual API
  static String startQuestionnaire(int questionnaireId) =>
      '/questionnaires/$questionnaireId/responses'; // Alternative endpoint
  static String submitQuestionnaireAnswers(int questionnaireId) =>
      '/questionnaires/$questionnaireId/submit'; // Existing endpoint

  // Future endpoints when backend implements them
  static String submitAnswers(int responseId) =>
      '/questionnaire-responses/$responseId/answers';
  static String completeQuestionnaire(int responseId) =>
      '/questionnaire-responses/$responseId/complete';
  static String getQuestionnaireResponse(int responseId) =>
      '/questionnaire-responses/$responseId';

  // 📢 Public Ads
  static const String activeAds = '/ads/active';
  static String adImpression(int id) => '/ads/$id/impression';
  static String adClick(int id) => '/ads/$id/click';

  // 🔒 PROTECTED ENDPOINTS (Require Bearer Token)

  // 👤 User Profile & Authentication
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String updateProfile = '/user/profile';

  // 📞 User Callback Requests
  static const String myCallbackRequests = '/my/callback-requests';
  static const String createCallbackRequest = '/callback-requests';

  // 📊 User Activity Logs
  static const String myActivities = '/my/activities';
  static const String logActivity = '/activities/log';
}
