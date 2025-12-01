import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../auth/models/user_model.dart';

class UserService {
  final ApiClient _client = ApiClient();

  Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    final res = await _client.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: payload,
    );
    final data = res.data!;
    return UserModel.fromJson(data['user']);
  }
}
