import 'package:get_storage/get_storage.dart';

class StorageService {
  late GetStorage _box;
  
  StorageService() {
    _box = GetStorage();
  }
  
  // Generic methods
  T? read<T>(String key) {
    try {
      return _box.read<T>(key);
    } catch (e) {
      print('StorageService - Error reading $key: $e');
      return null;
    }
  }
  
  Future<void> write(String key, dynamic value) async {
    try {
      await _box.write(key, value);
    } catch (e) {
      print('StorageService - Error writing $key: $e');
    }
  }
  
  Future<void> remove(String key) async {
    try {
      await _box.remove(key);
    } catch (e) {
      print('StorageService - Error removing $key: $e');
    }
  }
  
  Future<void> clear() async {
    try {
      await _box.erase();
    } catch (e) {
      print('StorageService - Error clearing storage: $e');
    }
  }
  
  bool hasData(String key) {
    return _box.hasData(key);
  }
  
  List<String> getKeys() {
    return _box.getKeys().cast<String>();
  }
  
  Map<String, dynamic> getAll() {
    final keys = getKeys();
    final Map<String, dynamic> data = {};
    
    for (final key in keys) {
      data[key] = read(key);
    }
    
    return data;
  }
}