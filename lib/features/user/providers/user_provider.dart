import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthProvider _authProvider;

  UserProvider(this._authProvider);

  UserModel? get user => _authProvider.user;

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    final updated = await _userService.updateProfile(payload);
    _authProvider.applyUpdatedUser(updated);
    notifyListeners();
  }
}
