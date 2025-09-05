import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageController extends GetxController {
  late GetStorage _box;
  
  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }
  
  // Generic read/write methods
  T? read<T>(String key) {
    try {
      return _box.read<T>(key);
    } catch (e) {
      print('Error reading from storage: $e');
      return null;
    }
  }
  
  Future<void> write(String key, dynamic value) async {
    try {
      await _box.write(key, value);
    } catch (e) {
      print('Error writing to storage: $e');
    }
  }
  
  Future<void> remove(String key) async {
    try {
      await _box.remove(key);
    } catch (e) {
      print('Error removing from storage: $e');
    }
  }
  
  Future<void> clear() async {
    try {
      await _box.erase();
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }
  
  bool hasData(String key) {
    return _box.hasData(key);
  }
  
  // App-specific storage methods
  Future<void> saveAuthToken(String token) async {
    await write('auth_token', token);
  }
  
  String? getAuthToken() {
    return read<String>('auth_token');
  }
  
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await write('user_data', userData);
  }
  
  Map<String, dynamic>? getUserData() {
    return read<Map<String, dynamic>>('user_data');
  }
  
  Future<void> saveChatCache(String chatId, List<Map<String, dynamic>> messages) async {
    await write('chat_cache_$chatId', messages);
  }
  
  List<Map<String, dynamic>>? getChatCache(String chatId) {
    return read<List<Map<String, dynamic>>>('chat_cache_$chatId');
  }
  
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await write('app_settings', settings);
  }
  
  Map<String, dynamic>? getAppSettings() {
    return read<Map<String, dynamic>>('app_settings');
  }
}