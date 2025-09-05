import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api/api_service.dart';
import '../services/storage/storage_service.dart';
import '../services/socket/socket_service.dart';
import '../core/constants/app_config.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final SocketService _socketService = Get.find<SocketService>();
  
  // Observable variables
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _phoneNumber = ''.obs;
  final RxString _otp = ''.obs;
  final RxString _authToken = ''.obs;
  
  // Getters
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  String get phoneNumber => _phoneNumber.value;
  String get otp => _otp.value;
  String get authToken => _authToken.value;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      final token = _storageService.read(AppConfig.authTokenKey);
      final userData = _storageService.read(AppConfig.userDataKey);
      
      if (token != null && userData != null) {
        _authToken.value = token;
        _currentUser.value = UserModel.fromJson(userData);
        _isAuthenticated.value = true;
        
        // Set API token
        _apiService.setAuthToken(token);
        
        // Connect to socket
        await _socketService.connect(token);
        
        debugPrint('User already authenticated');
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      await logout();
    }
  }
  
  // Phone number validation
  bool isValidPhoneNumber(String phone) {
    // Basic phone number validation
    final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone);
  }
  
  // Send OTP
  Future<bool> sendOtp(String phoneNumber) async {
    if (!isValidPhoneNumber(phoneNumber)) {
      Get.snackbar(
        'Invalid Phone Number',
        'Please enter a valid phone number with country code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    try {
      _isLoading.value = true;
      _phoneNumber.value = phoneNumber;
      
      final response = await _apiService.sendOtp(phoneNumber);
      
      if (response['success'] == true) {
        Get.snackbar(
          'OTP Sent',
          'Verification code sent to $phoneNumber',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to send OTP',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Verify OTP
  Future<bool> verifyOtp(String otp, String username) async {
    if (otp.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    if (username.isEmpty || username.length < 3) {
      Get.snackbar(
        'Invalid Username',
        'Username must be at least 3 characters long',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    try {
      _isLoading.value = true;
      _otp.value = otp;
      
      final response = await _apiService.verifyOtp(_phoneNumber.value, otp, username);
      
      if (response['success'] == true) {
        final token = response['token'];
        final userData = response['user'];
        
        // Save auth data
        await _storageService.write(AppConfig.authTokenKey, token);
        await _storageService.write(AppConfig.userDataKey, userData);
        
        // Update state
        _authToken.value = token;
        _currentUser.value = UserModel.fromJson(userData);
        _isAuthenticated.value = true;
        
        // Set API token
        _apiService.setAuthToken(token);
        
        // Connect to socket
        await _socketService.connect(token);
        
        Get.snackbar(
          'Welcome!',
          'Authentication successful',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate to home
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Invalid OTP',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      Get.snackbar(
        'Error',
        'Failed to verify OTP. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
    String? username,
    String? status,
    String? profilePicture,
    Map<String, String>? privacySettings,
  }) async {
    try {
      _isLoading.value = true;
      
      final response = await _apiService.updateProfile(
        username: username,
        status: status,
        profilePicture: profilePicture,
        privacySettings: privacySettings,
      );
      
      if (response['success'] == true) {
        final updatedUser = UserModel.fromJson(response['user']);
        _currentUser.value = updatedUser;
        
        // Update stored user data
        await _storageService.write(AppConfig.userDataKey, updatedUser.toJson());
        
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to update profile',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      
      // Call logout API
      try {
        await _apiService.logout();
      } catch (e) {
        debugPrint('Error calling logout API: $e');
      }
      
      // Disconnect socket
      await _socketService.disconnect();
      
      // Clear stored data
      await _storageService.remove(AppConfig.authTokenKey);
      await _storageService.remove(AppConfig.userDataKey);
      
      // Reset state
      _currentUser.value = null;
      _isAuthenticated.value = false;
      _authToken.value = '';
      _phoneNumber.value = '';
      _otp.value = '';
      
      // Clear API token
      _apiService.clearAuthToken();
      
      // Navigate to phone auth
      Get.offAllNamed(AppRoutes.phoneAuth);
      
      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      final response = await _apiService.getProfile();
      
      if (response['success'] == true) {
        final updatedUser = UserModel.fromJson(response['user']);
        _currentUser.value = updatedUser;
        
        // Update stored user data
        await _storageService.write(AppConfig.userDataKey, updatedUser.toJson());
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }
  
  // Check if user is logged in
  bool isLoggedIn() {
    return _isAuthenticated.value && _currentUser.value != null;
  }
}