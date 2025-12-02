import 'package:flutter/material.dart';
import 'lib/services/medicare_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Testing Callback Request Submission...');

  try {
    final api = MedicareApiService.instance;

    final result = await api.submitCallbackRequestWithDetails(
      userId: 1,
      companyId: 1,
      companyName: 'Test Insurance Company',
      callDate: '2024-12-03',
      callTime: '14:30',
      message: 'Test callback request',
    );

    print('API Response: $result');

    if (result['success'] == true) {
      print('✅ Callback request submitted successfully!');
    } else {
      print('❌ Callback request failed: ${result['message']}');
    }
  } catch (e) {
    print('❌ Error during callback submission: $e');
  }

  print('Test completed.');
}
