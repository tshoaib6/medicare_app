import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  loading,
  unauthenticated,
  emailUnverified,
  profileIncomplete,
  authenticated,
  guest,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiClient _client = ApiClient();

  UserModel? _user;
  String? _token;
  AuthStatus _status = AuthStatus.loading;
  String? _tempEmail; // For OTP verification

  UserModel? get user => _user;
  String? get token => _token;
  AuthStatus get status => _status;
  String? get tempEmail => _tempEmail;

  bool get isGuest => _status == AuthStatus.guest;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isProfileComplete => _user?.isProfileComplete ?? false;

  Future<void> init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // Try to get stored token
      final storedToken = await _client.getStoredToken();
      if (storedToken == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _token = storedToken;
      _client.setToken(_token);

      // Fetch user data
      _user = await _authService.fetchMe();
      _deriveStatusFromUser();
    } catch (e) {
      // Token expired or invalid
      await _clearAuthData();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _deriveStatusFromUser() {
    if (_user == null) {
      _status = AuthStatus.unauthenticated;
      return;
    }

    if (_user!.isGuest) {
      _status = AuthStatus.guest;
    } else if (!_user!.isEmailVerified) {
      _status = AuthStatus.emailUnverified;
    } else if (!_user!.isProfileComplete) {
      _status = AuthStatus.profileIncomplete;
    } else {
      _status = AuthStatus.authenticated;
    }
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required int yearOfBirth,
  }) async {
    try {
      final (user, token) = await _authService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        yearOfBirth: yearOfBirth,
      );

      _user = user;
      _tempEmail = email;

      if (token.isNotEmpty) {
        _token = token;
        _client.setToken(token);
      }

      _deriveStatusFromUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final (user, token) = await _authService.login(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      _user = user;
      _tempEmail = email;

      if (token.isNotEmpty) {
        _token = token;
        _client.setToken(token);
      }

      _deriveStatusFromUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> googleLogin() async {
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Failed to get Google ID token');

      final (user, token) = await _authService.googleLogin(idToken: idToken);

      _user = user;
      _token = token;
      _client.setToken(token);

      _deriveStatusFromUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendOtp({String? email}) async {
    try {
      final emailToUse = email ?? _tempEmail ?? _user?.email;
      if (emailToUse == null) throw Exception('No email available for OTP');

      await _authService.sendOtp(email: emailToUse);
      _tempEmail = emailToUse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp(String code, {String? email}) async {
    try {
      final emailToUse = email ?? _tempEmail ?? _user?.email;
      if (emailToUse == null)
        throw Exception('No email available for OTP verification');

      final (user, token) = await _authService.verifyOtp(
        email: emailToUse,
        code: code,
      );

      _user = user;
      if (token.isNotEmpty) {
        _token = token;
        _client.setToken(token);
      }

      _deriveStatusFromUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email: email);
      _tempEmail = email;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String code,
    required String password,
    String? email,
  }) async {
    try {
      final emailToUse = email ?? _tempEmail;
      if (emailToUse == null)
        throw Exception('No email available for password reset');

      await _authService.resetPassword(
        email: emailToUse,
        code: code,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout();
      }
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await _clearAuthData();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void setGuestMode() {
    _user = null;
    _token = null;
    _tempEmail = null;
    _status = AuthStatus.guest;
    _client.clearToken();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_token == null) return;

    try {
      _client.setToken(_token);
      _user = await _authService.fetchMe();
      _deriveStatusFromUser();
      notifyListeners();
    } catch (e) {
      // Token might be expired
      await _clearAuthData();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  void applyUpdatedUser(UserModel user) {
    _user = user;
    _deriveStatusFromUser();
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    _user = null;
    _token = null;
    _tempEmail = null;
    _client.clearToken();
  }
}
