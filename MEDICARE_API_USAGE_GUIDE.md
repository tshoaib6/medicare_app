# Medicare API Integration Usage Guide 🏥

The Medicare app now has a comprehensive centralized API service that provides access to all backend APIs through a single, easy-to-use interface.

## 🚀 Quick Start

```dart
import '../../../services/medicare_api_service.dart';

// Get the singleton instance
final api = MedicareApiService.instance;

// Use any service through the centralized interface
final companies = await api.companies.getCompanies();
final questionnaires = await api.questionnaires.getQuestionnaires();
```

## 📋 Available Services

### 1. Company & Plan Service (`api.companies`)

```dart
// Get all companies with pagination
final companies = await api.companies.getCompanies(
  page: 1,
  perPage: 10,
  search: 'Aetna',
);

// Get company details
final company = await api.companies.getCompany(companyId);

// Get all plans with filtering
final plans = await api.companies.getPlans(
  page: 1,
  perPage: 20,
  companyId: 5,
  search: 'Medicare Advantage',
);

// Get specific plan details
final plan = await api.companies.getPlan(planId);
```

### 2. Questionnaire Service (`api.questionnaires`)

```dart
// Get all questionnaires
final questionnaires = await api.questionnaires.getQuestionnaires();

// Get questionnaire details
final questionnaire = await api.questionnaires.getQuestionnaire(questionnaireId);

// Get questionnaire questions
final questions = await api.questionnaires.getQuestionnaireQuestions(questionnaireId);

// Start a new questionnaire
final response = await api.questionnaires.startQuestionnaire(questionnaireId);
final responseId = response['data']['id'];

// Submit answers (auto-save functionality)
final answers = [
  {
    'question_id': 1,
    'answer_value': ['option1'],
    'answer_text': null,
  },
  {
    'question_id': 2, 
    'answer_value': null,
    'answer_text': 'My detailed answer',
  }
];
await api.questionnaires.submitAnswers(
  responseId: responseId,
  answers: answers,
);

// Complete questionnaire
await api.questionnaires.completeQuestionnaire(responseId);

// Get user's questionnaire history
final myResponses = await api.questionnaires.getMyQuestionnaireResponses(
  page: 1,
  perPage: 10,
);
```

### 3. Callback Service (`api.callbacks`)

```dart
// Submit a callback request
await api.callbacks.submitCallbackRequest(
  fullName: 'John Doe',
  phoneNumber: '+1234567890',
  email: 'john@example.com',
  preferredTime: 'morning',
  planId: 5, // Optional
  notes: 'Please call regarding Medicare Advantage options',
);

// Get user's callback requests
final myCallbacks = await api.callbacks.getMyCallbackRequests(
  page: 1,
  perPage: 10,
);
```

### 4. Activity Service (`api.activities`)

```dart
// Log general activity
await api.activities.logActivity(
  activityType: 'plan_view',
  details: {'plan_id': 5, 'plan_name': 'Medicare Advantage Plus'},
);

// Convenience methods for common activities
await api.activities.logPlanView(planId: 5);
await api.activities.logQuestionnaireStart(questionnaireId: 1, planId: 5);
await api.activities.logQuestionnaireComplete(questionnaireId: 1, timeTaken: 15);
await api.activities.logUserLogin();
await api.activities.logUserRegistration();
```

### 5. Ads Service (`api.ads`)

```dart
// Get active advertisements
final ads = await api.ads.getActiveAds();

// Track ad impression
await api.ads.trackAdImpression(adId: 1);

// Track ad click
await api.ads.trackAdClick(adId: 1);
```

## 🔄 High-Level Workflows

The API service also provides complete workflows that combine multiple API calls:

### Complete Questionnaire Workflow

```dart
// This method handles the entire questionnaire process:
// 1. Start questionnaire
// 2. Log activity
// 3. Validate answers
// 4. Submit answers
// 5. Complete questionnaire
// 6. Log completion activity

final result = await api.completeQuestionnaireWithTracking(
  questionnaireId: 1,
  planId: 5,
  answers: {
    1: ['option_a'], // Multiple choice
    2: 'Detailed text answer', // Text answer
    3: ['option_1', 'option_2'], // Multiple selection
  },
);
```

### Plan Browsing with Activity Tracking

```dart
// Get plans and automatically log the browsing activity
final plans = await api.companies.getPlans();

// When user views a specific plan
final planDetails = await api.companies.getPlan(planId);
await api.activities.logPlanView(planId: planId);
```

## 🛠️ Integration in Screens

### Questionnaire Screen Integration

```dart
class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _api = MedicareApiService.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load all necessary data
      final planResponse = await _api.companies.getPlan(widget.planId);
      final questionnaireResponse = await _api.questionnaires.getQuestionnaire(widget.questionnaireId);
      
      // Convert to model objects
      final plan = PlanModel.fromJson(planResponse['data']);
      final questionnaire = Questionnaire.fromJson(questionnaireResponse['data']);
      
      // Start questionnaire response tracking
      final startResponse = await _api.questionnaires.startQuestionnaire(widget.questionnaireId);
      final response = QuestionnaireResponse.fromJson(startResponse['data']);
      
      setState(() {
        _plan = plan;
        _questionnaire = questionnaire;
        _questionnaireResponse = response;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _autoSaveAnswers() async {
    if (_questionnaireResponse == null) return;
    
    try {
      final apiAnswers = _api.questionnaires.formatAnswersForAPI(_answers);
      if (apiAnswers.isNotEmpty) {
        await _api.questionnaires.submitAnswers(
          responseId: _questionnaireResponse!.id,
          answers: apiAnswers,
        );
      }
    } catch (e) {
      debugPrint('Auto-save failed: $e');
    }
  }

  Future<void> _completeQuestionnaire() async {
    try {
      await _api.completeQuestionnaireWithTracking(
        questionnaireId: widget.questionnaireId,
        planId: widget.planId,
        answers: _answers,
      );
      // Handle success
    } catch (e) {
      // Handle error
    }
  }
}
```

## 🔍 Health Checks & Utilities

```dart
// Test API connectivity
final healthStatus = await api.checkApiHealth();
print('Companies API: ${healthStatus['companies']}');
print('Questionnaires API: ${healthStatus['questionnaires']}');
print('Callbacks API: ${healthStatus['callbacks']}');
```

## 📊 Response Parsing

All API responses follow a consistent structure:

```dart
{
  "success": true,
  "message": "Success message",
  "data": { ... }, // Actual data
  "meta": { // Optional pagination/metadata
    "current_page": 1,
    "total_pages": 5,
    "total_items": 50,
    "per_page": 10
  }
}
```

The service automatically extracts the `data` portion, but you can access the full response structure when needed.

## 🎯 Error Handling

All service methods include comprehensive error handling:

```dart
try {
  final result = await api.questionnaires.startQuestionnaire(1);
} catch (e) {
  if (e.toString().contains('Resource not found')) {
    // Handle specific error
  } else {
    // Handle general error
  }
}
```

## 📱 Complete App Integration

The centralized API service is already integrated into:

- ✅ **QuestionnaireScreen**: Uses `completeQuestionnaireWithTracking`
- ✅ **QuestionnaireResponsesScreen**: Uses `getMyQuestionnaireResponses`  
- ✅ **Dashboard**: Can integrate company and plan APIs
- ✅ **Profile**: Can integrate callback requests

## 🚀 Next Steps

1. **Update Dashboard Screen**: Replace existing API calls with centralized service
2. **Add Authentication**: Integrate with existing auth service for token management
3. **Implement Caching**: Add response caching for better performance
4. **Error Recovery**: Add retry mechanisms for failed requests
5. **Offline Support**: Implement offline mode with local storage

## 🔧 Troubleshooting

### Common Issues

1. **Import Errors**: Ensure you're importing from the correct path:
   ```dart
   import '../../../services/medicare_api_service.dart';
   ```

2. **Model Conversion**: When APIs return `Map<String, dynamic>`, convert to model objects:
   ```dart
   final plan = PlanModel.fromJson(response['data']);
   ```

3. **Null Safety**: Always check for null responses:
   ```dart
   if (response['data'] != null) {
     final result = Response.fromJson(response['data']);
   }
   ```

The Medicare API integration is now complete and ready for production use! 🎉