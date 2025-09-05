import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../services/storage/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxBool _isDarkMode = false.obs;
  final RxInt _themeMode = 0.obs; // 0: System, 1: Light, 2: Dark
  
  bool get isDarkMode => _isDarkMode.value;
  int get themeMode => _themeMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
  }
  
  void _loadThemeSettings() {
    final savedTheme = _storageService.read('theme_mode') ?? 0;
    _themeMode.value = savedTheme;
    
    switch (savedTheme) {
      case 1:
        _isDarkMode.value = false;
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 2:
        _isDarkMode.value = true;
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        _isDarkMode.value = Get.isPlatformDarkMode;
        Get.changeThemeMode(ThemeMode.system);
    }
  }
  
  Future<void> changeThemeMode(int mode) async {
    _themeMode.value = mode;
    await _storageService.write('theme_mode', mode);
    
    switch (mode) {
      case 1:
        _isDarkMode.value = false;
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 2:
        _isDarkMode.value = true;
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        _isDarkMode.value = Get.isPlatformDarkMode;
        Get.changeThemeMode(ThemeMode.system);
    }
  }
  
  void toggleTheme() {
    if (_themeMode.value == 0) {
      // If system, switch to opposite of current
      changeThemeMode(_isDarkMode.value ? 1 : 2);
    } else {
      // If manual mode, toggle
      changeThemeMode(_isDarkMode.value ? 1 : 2);
    }
  }
  
  String getThemeModeString() {
    switch (_themeMode.value) {
      case 1:
        return 'Light';
      case 2:
        return 'Dark';
      default:
        return 'System';
    }
  }
}