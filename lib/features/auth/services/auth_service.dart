import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<(UserModel, String)> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required int yearOfBirth,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.signup,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone_number': phoneNumber,
        'year_of_birth': yearOfBirth,
      },
    );
    final data = res.data!;
    final user = UserModel.fromJson(data['user'] ?? data['data']);
    final token = (data['token'] ?? data['access_token'] ?? '') as String;
    return (user, token);
  }

  Future<(UserModel, String)> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final data = <String, dynamic>{
      'password': password,
    };

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      data['phone_number'] = phoneNumber;
    } else if (email != null && email.isNotEmpty) {
      data['email'] = email;
    } else {
      throw Exception('Either phone number or email is required');
    }

    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: data,
    );
    final responseData = res.data!;
    final user =
        UserModel.fromJson(responseData['user'] ?? responseData['data']);
    final token =
        (responseData['token'] ?? responseData['access_token'] ?? '') as String;
    return (user, token);
  }

  Future<(UserModel, String)> googleLogin({
    required String idToken,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.googleAuth,
      data: {
        'id_token': idToken,
      },
    );
    final data = res.data!;
    final user = UserModel.fromJson(data['user'] ?? data['data']);
    final token = (data['token'] ?? data['access_token'] ?? '') as String;
    return (user, token);
  }

  Future<void> logout() async {
    await _client.post(ApiEndpoints.logout);
  }

  Future<UserModel> fetchMe() async {
    final res = await _client.get<Map<String, dynamic>>(ApiEndpoints.me);
    final data = res.data!;
    return UserModel.fromJson(data['user'] ?? data['data'] ?? data);
  }

  Future<void> sendOtp({required String email}) async {
    await _client.post(
      ApiEndpoints.sendOtp,
      data: {
        'email': email,
      },
    );
  }

  Future<(UserModel, String)> verifyOtp({
    required String email,
    required String code,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: {
        'email': email,
        'code': code,
      },
    );
    final data = res.data!;
    final user = UserModel.fromJson(data['user'] ?? data['data']);
    final token = (data['token'] ?? data['access_token'] ?? '') as String;
    return (user, token);
  }

  Future<void> forgotPassword({required String email}) async {
    await _client.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _client.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': password,
      },
    );
  }
}
