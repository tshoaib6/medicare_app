import '../network/api_client.dart';
import '../network/endpoints.dart';

class UserService {
  final ApiClient _client = ApiClient();

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    int? yearOfBirth,
    String? zipCode,
    bool? isDecisionMaker,
    bool? hasMedicarePartB,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{};

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (yearOfBirth != null) data['year_of_birth'] = yearOfBirth;
    if (zipCode != null) data['zip_code'] = zipCode;
    if (isDecisionMaker != null) data['is_decision_maker'] = isDecisionMaker;
    if (hasMedicarePartB != null)
      data['has_medicare_part_b'] = hasMedicarePartB;
    if (additionalData != null) data.addAll(additionalData);

    final res = await _client.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: data,
    );
    return res.data!;
  }

  /// Get current user profile (alias for AuthService.fetchMe for convenience)
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.me,
    );
    return res.data!;
  }
}
