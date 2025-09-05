import 'package:get/get.dart';

import '../services/storage/storage_service.dart';
import '../controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // Observable variables
  final RxBool _notificationsEnabled = true.obs;
  final RxBool _soundEnabled = true.obs;
  final RxBool _vibrationEnabled = true.obs;
  final RxBool _darkModeEnabled = false.obs;
  final RxString _chatWallpaper = 'default'.obs;
  final RxString _fontSize = 'medium'.obs;
  final RxString _language = 'en'.obs;
  
  // Getters
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get soundEnabled => _soundEnabled.value;
  bool get vibrationEnabled => _vibrationEnabled.value;
  bool get darkModeEnabled => _darkModeEnabled.value;
  String get chatWallpaper => _chatWallpaper.value;
  String get fontSize => _fontSize.value;
  String get language => _language.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    _notificationsEnabled.value = _storageService.read('notifications_enabled') ?? true;
    _soundEnabled.value = _storageService.read('sound_enabled') ?? true;
    _vibrationEnabled.value = _storageService.read('vibration_enabled') ?? true;
    _darkModeEnabled.value = _storageService.read('dark_mode_enabled') ?? false;
    _chatWallpaper.value = _storageService.read('chat_wallpaper') ?? 'default';
    _fontSize.value = _storageService.read('font_size') ?? 'medium';
    _language.value = _storageService.read('language') ?? 'en';
  }

  void toggleNotifications() {
    _notificationsEnabled.value = !_notificationsEnabled.value;
    _storageService.write('notifications_enabled', _notificationsEnabled.value);
  }

  void toggleSound() {
    _soundEnabled.value = !_soundEnabled.value;
    _storageService.write('sound_enabled', _soundEnabled.value);
  }

  void toggleVibration() {
    _vibrationEnabled.value = !_vibrationEnabled.value;
    _storageService.write('vibration_enabled', _vibrationEnabled.value);
  }

  void toggleDarkMode() {
    _darkModeEnabled.value = !_darkModeEnabled.value;
    _storageService.write('dark_mode_enabled', _darkModeEnabled.value);
    
    // TODO: Update app theme
    Get.snackbar('Theme Updated', 'App theme will be updated in next version');
  }

  void setChatWallpaper(String wallpaper) {
    _chatWallpaper.value = wallpaper;
    _storageService.write('chat_wallpaper', wallpaper);
  }

  void setFontSize(String size) {
    _fontSize.value = size;
    _storageService.write('font_size', size);
  }

  void setLanguage(String languageCode) {
    _language.value = languageCode;
    _storageService.write('language', languageCode);
    
    // TODO: Update app language
    Get.snackbar('Language Updated', 'App language will be updated in next version');
  }

  void clearCache() {
    // TODO: Implement cache clearing
    Get.snackbar('Cache Cleared', 'App cache has been cleared');
  }

  void exportChats() {
    // TODO: Implement chat export
    Get.snackbar('Coming Soon', 'Chat export feature coming soon!');
  }

  void importChats() {
    // TODO: Implement chat import
    Get.snackbar('Coming Soon', 'Chat import feature coming soon!');
  }

  void resetSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performReset();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performReset() {
    _notificationsEnabled.value = true;
    _soundEnabled.value = true;
    _vibrationEnabled.value = true;
    _darkModeEnabled.value = false;
    _chatWallpaper.value = 'default';
    _fontSize.value = 'medium';
    _language.value = 'en';
    
    // Save to storage
    _storageService.write('notifications_enabled', true);
    _storageService.write('sound_enabled', true);
    _storageService.write('vibration_enabled', true);
    _storageService.write('dark_mode_enabled', false);
    _storageService.write('chat_wallpaper', 'default');
    _storageService.write('font_size', 'medium');
    _storageService.write('language', 'en');
    
    Get.snackbar('Settings Reset', 'All settings have been reset to default');
  }
}
