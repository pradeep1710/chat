import 'package:get/get.dart';

import '../services/api/api_service.dart';
import '../controllers/auth_controller.dart';

class StatusController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Observable variables
  final RxList<dynamic> _statuses = <dynamic>[].obs;
  final RxList<dynamic> _myStatuses = <dynamic>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  
  // Getters
  List<dynamic> get statuses => _statuses;
  List<dynamic> get myStatuses => _myStatuses;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  int get currentPage => _currentPage.value;
  
  @override
  void onInit() {
    super.onInit();
    loadStatuses();
    loadMyStatuses();
  }
  
  Future<void> loadStatuses({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMore.value = true;
        _statuses.clear();
      }
      
      if (!_hasMore.value || _isLoading.value) return;
      
      _isLoading.value = true;
      
      final response = await _apiService.getStatusFeed(
        page: _currentPage.value,
        limit: 20,
      );
      
      if (response['success'] == true) {
        final statusList = response['statuses'] as List? ?? [];
        
        if (refresh) {
          _statuses.value = statusList;
        } else {
          _statuses.addAll(statusList);
        }
        
        _currentPage.value++;
        _hasMore.value = statusList.length >= 20;
      }
    } catch (e) {
      print('Error loading statuses: $e');
      Get.snackbar('Error', 'Failed to load statuses');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> loadMyStatuses() async {
    try {
      final response = await _apiService.getMyStatuses();
      
      if (response['success'] == true) {
        _myStatuses.value = response['statuses'] as List? ?? [];
      }
    } catch (e) {
      print('Error loading my statuses: $e');
    }
  }
  
  Future<void> refreshStatuses() async {
    await Future.wait([
      loadStatuses(refresh: true),
      loadMyStatuses(),
    ]);
  }
  
  Future<void> createStatus({
    required String type,
    required String content,
    String? privacy,
    String? mediaPath,
  }) async {
    try {
      final response = await _apiService.createStatus(
        type: type,
        content: content,
        privacy: privacy,
        mediaPath: mediaPath,
      );
      
      if (response['success'] == true) {
        await loadMyStatuses();
        await loadStatuses(refresh: true);
        Get.snackbar('Success', 'Status created successfully');
      }
    } catch (e) {
      print('Error creating status: $e');
      Get.snackbar('Error', 'Failed to create status');
    }
  }
  
  Future<void> deleteStatus(String statusId) async {
    try {
      final response = await _apiService.deleteStatus(statusId);
      
      if (response['success'] == true) {
        _myStatuses.removeWhere((status) => status['id'] == statusId);
        _statuses.removeWhere((status) => status['id'] == statusId);
        Get.snackbar('Success', 'Status deleted');
      }
    } catch (e) {
      print('Error deleting status: $e');
      Get.snackbar('Error', 'Failed to delete status');
    }
  }
}
