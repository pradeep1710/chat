import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/constants/app_config.dart';
import '../services/storage/storage_service.dart';

class AppController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // Observable variables
  final RxBool _isInitialized = false.obs;
  final RxBool _isFirstTime = true.obs;
  final RxBool _isOnline = true.obs;
  final RxString _currentLanguage = 'en'.obs;
  final RxInt _currentTheme = 0.obs; // 0: System, 1: Light, 2: Dark
  
  // Getters
  bool get isInitialized => _isInitialized.value;
  bool get isFirstTime => _isFirstTime.value;
  bool get isOnline => _isOnline.value;
  String get currentLanguage => _currentLanguage.value;
  int get currentTheme => _currentTheme.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
    _setupConnectivityListener();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Load app settings
      await _loadAppSettings();
      
      // Mark as initialized
      _isInitialized.value = true;
      
      debugPrint('App initialized successfully');
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }
  
  Future<void> _loadAppSettings() async {
    try {
      // Load first time flag
      _isFirstTime.value = _storageService.read('is_first_time') ?? true;
      
      // Load language preference
      _currentLanguage.value = _storageService.read('language') ?? 'en';
      
      // Load theme preference
      _currentTheme.value = _storageService.read('theme') ?? 0;
      
    } catch (e) {
      debugPrint('Error loading app settings: $e');
    }
  }
  
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _isOnline.value = result != ConnectivityResult.none;
      
      if (_isOnline.value) {
        Get.snackbar(
          'Connection Restored',
          'You are back online',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'No Internet Connection',
          'Please check your internet connection',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }
  
  // App settings methods
  Future<void> setFirstTimeComplete() async {
    _isFirstTime.value = false;
    await _storageService.write('is_first_time', false);
  }
  
  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage.value = languageCode;
    await _storageService.write('language', languageCode);
    
    // Update GetX locale
    Get.updateLocale(Locale(languageCode));
  }
  
  Future<void> changeTheme(int themeMode) async {
    _currentTheme.value = themeMode;
    await _storageService.write('theme', themeMode);
    
    // Update GetX theme
    switch (themeMode) {
      case 1:
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 2:
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }
  
  // Utility methods
  void showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: AppConfig.mediumAnimation,
    );
  }
  
  void showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: AppConfig.longAnimation,
    );
  }
  
  void showInfoMessage(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: AppConfig.mediumAnimation,
    );
  }
  
  // Loading dialog methods
  void showLoading([String? message]) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Loading...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}