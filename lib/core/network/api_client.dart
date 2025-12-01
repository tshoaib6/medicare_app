import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'endpoints.dart';
import 'exceptions.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors for better error handling and logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle token expiry
          if (error.response?.statusCode == 401) {
            _clearStoredToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  String? _token;

  static const String _tokenKey = 'auth_token';

  void setToken(String? token) {
    _token = token;
    if (token != null) {
      _storeToken(token);
    }
  }

  void clearToken() {
    _token = null;
    _clearStoredToken();
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _token = null;
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      _token = token;
    }
    return token;
  }

  Options _options() {
    final headers = <String, dynamic>{};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return Options(headers: headers);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      final res =
          await _dio.get<T>(path, queryParameters: query, options: _options());
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(String path,
      {dynamic data, Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.post<T>(path,
          data: data, queryParameters: query, options: _options());
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      final res = await _dio.put<T>(path, data: data, options: _options());
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      final res = await _dio.delete<T>(path, options: _options());
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    // Handle different types of errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
            'Request timeout. Please check your connection.');

      case DioExceptionType.connectionError:
        return const NetworkException(
            'No internet connection. Please check your network.');

      case DioExceptionType.badResponse:
        return _handleHttpError(status, data);

      default:
        return ApiException(
            _extractErrorMessage(data) ?? 'An unexpected error occurred');
    }
  }

  ApiException _handleHttpError(int? statusCode, dynamic data) {
    final message = _extractErrorMessage(data);

    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Bad request',
            errors: _extractValidationErrors(data), statusCode: statusCode);
      case 401:
        return const AuthenticationException(
            'Session expired. Please login again.');
      case 403:
        return const ForbiddenException('Access denied');
      case 404:
        return const NotFoundException('Resource not found');
      case 422:
        return ValidationException(message ?? 'Validation failed',
            errors: _extractValidationErrors(data), statusCode: statusCode);
      case 500:
        return const ServerException('Server error. Please try again later.');
      default:
        return ApiException(message ?? 'Something went wrong',
            statusCode: statusCode);
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      // Try different possible message fields
      return data['message'] ?? data['error'] ?? data['detail'];
    }
    return null;
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final result = <String, List<String>>{};

      errors.forEach((key, value) {
        if (value is List) {
          result[key.toString()] = value.map((e) => e.toString()).toList();
        } else {
          result[key.toString()] = [value.toString()];
        }
      });

      return result;
    }
    return null;
  }
}
