import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final ApiClient _apiClient;
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserProvider(this._apiClient);

  // Getters
  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> fetchCurrentUser() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');
      // The /auth/me endpoint wraps user data in a 'user' object
      final userData = response.data!['user'] as Map<String, dynamic>;
      _user = UserModel.fromJson(userData);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> loadProfile() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response =
          await _apiClient.get<Map<String, dynamic>>('/user/profile');
      _user = UserModel.fromJson(response.data!);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? zipCode,
    int? birthYear,
    bool? isDecisionMaker,
    bool? hasMedicarePartB,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final data = <String, dynamic>{};

      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phone != null) data['phone_number'] = phone;
      if (zipCode != null) data['zip_code'] = zipCode;
      if (birthYear != null) data['year_of_birth'] = birthYear;
      if (isDecisionMaker != null) data['is_decision_maker'] = isDecisionMaker;
      if (hasMedicarePartB != null)
        data['has_medicare_part_b'] = hasMedicarePartB;

      final response = await _apiClient
          .put<Map<String, dynamic>>('/user/profile', data: data);

      // Handle response - check if it's wrapped in 'user' object or direct
      final userData = response.data!.containsKey('user')
          ? response.data!['user'] as Map<String, dynamic>
          : response.data!;
      _user = UserModel.fromJson(userData);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> uploadProfilePicture(String imagePath) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final data = {
        'profile_picture': imagePath,
      };

      final response = await _apiClient
          .post<Map<String, dynamic>>('/user/profile-picture', data: data);
      _user = UserModel.fromJson(response.data!);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _apiClient.delete('/user/account');
      clearUser();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateNotificationSettings({
    bool? emailNotifications,
    bool? smsNotifications,
    bool? planUpdates,
    bool? marketingEmails,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final data = <String, dynamic>{};

      if (emailNotifications != null)
        data['email_notifications'] = emailNotifications;
      if (smsNotifications != null)
        data['sms_notifications'] = smsNotifications;
      if (planUpdates != null) data['plan_updates'] = planUpdates;
      if (marketingEmails != null) data['marketing_emails'] = marketingEmails;

      final response = await _apiClient
          .put<Map<String, dynamic>>('/user/notification-settings', data: data);
      _user = UserModel.fromJson(response.data!);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}
