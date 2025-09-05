import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;

import '../../core/constants/app_config.dart';

class ApiService {
  late Dio _dio;
  String? _authToken;

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        print('API Request: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            'API Response: ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        _handleError(error);
        handler.next(error);
      },
    ));
  }

  void _handleError(DioException error) {
    String message = 'An error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          message = 'Unauthorized. Please login again.';
          // Handle logout
        } else if (error.response?.statusCode == 404) {
          message = 'Resource not found.';
        } else if (error.response?.statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = error.response?.data['message'] ?? 'Request failed';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.unknown:
        message = 'No internet connection';
        break;
      default:
        message = 'Something went wrong';
    }

    getx.Get.snackbar('Error', message);
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Authentication APIs
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/send-otp',
          data: {'phoneNumber': phoneNumber, 'username': "User"});
      return response.data;
    } catch (e) {
      log("eror ssfa $e");
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String phoneNumber, String otp, String username) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'username': username,
      });
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? status,
    String? profilePicture,
    Map<String, String>? privacySettings,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (status != null) data['status'] = status;
      if (profilePicture != null) data['profilePicture'] = profilePicture;
      if (privacySettings != null) data['privacySettings'] = privacySettings;

      final response = await _dio.put('/user/profile', data: data);
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // Chat APIs
  Future<Map<String, dynamic>> getChats({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/chat', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> createPrivateChat(String userId) async {
    try {
      final response = await _dio.post('/chat/private', data: {
        'userId': userId,
      });
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getChatMessages(String chatId,
      {int page = 1, int limit = 50, String? before}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (before != null) queryParams['before'] = before;

      final response = await _dio.get('/chat/$chatId/messages',
          queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // User APIs
  Future<Map<String, dynamic>> searchUsers(String query,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/user/search', queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> blockUser(String userId) async {
    try {
      final response = await _dio.post('/user/block/$userId');
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> unblockUser(String userId) async {
    try {
      final response = await _dio.post('/user/unblock/$userId');
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // Media APIs
  Future<Map<String, dynamic>> uploadMedia(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post('/media/upload', data: formData);
      return response.data;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(dynamic e) {
    if (e is DioException) {
      return Exception(e.response?.data['message'] ?? e.message);
    }
    return Exception(e.toString());
  }
}
