import 'package:get/get.dart';

import '../services/api/api_service.dart';

class CommunityController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Observable variables
  final RxList<dynamic> _communities = <dynamic>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxString _searchQuery = ''.obs;
  
  // Getters
  List<dynamic> get communities => _communities;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  int get currentPage => _currentPage.value;
  String get searchQuery => _searchQuery.value;
  
  @override
  void onInit() {
    super.onInit();
    loadCommunities();
  }
  
  Future<void> loadCommunities({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMore.value = true;
        _communities.clear();
      }
      
      if (!_hasMore.value || _isLoading.value) return;
      
      _isLoading.value = true;
      
      Map<String, dynamic> response;
      
      if (_searchQuery.value.isNotEmpty) {
        response = await _apiService.searchCommunities(
          _searchQuery.value,
          page: _currentPage.value,
          limit: 20,
        );
      } else {
        response = await _apiService.getUserCommunities(
          page: _currentPage.value,
          limit: 20,
        );
      }
      
      if (response['success'] == true) {
        final communityList = response['communities'] as List? ?? [];
        
        if (refresh) {
          _communities.value = communityList;
        } else {
          _communities.addAll(communityList);
        }
        
        _currentPage.value++;
        _hasMore.value = communityList.length >= 20;
      }
    } catch (e) {
      print('Error loading communities: $e');
      Get.snackbar('Error', 'Failed to load communities');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> refreshCommunities() async {
    await loadCommunities(refresh: true);
  }
  
  void searchCommunities(String query) {
    _searchQuery.value = query;
    loadCommunities(refresh: true);
  }
  
  Future<void> joinCommunity(String communityId) async {
    try {
      final response = await _apiService.joinCommunity(communityId);
      
      if (response['success'] == true) {
        // Update community in list
        final index = _communities.indexWhere((c) => c['id'] == communityId);
        if (index != -1) {
          _communities[index] = {
            ..._communities[index],
            'isMember': true,
            'memberCount': (_communities[index]['memberCount'] ?? 0) + 1,
          };
        }
        Get.snackbar('Success', 'Joined community successfully');
      }
    } catch (e) {
      print('Error joining community: $e');
      Get.snackbar('Error', 'Failed to join community');
    }
  }
  
  Future<void> leaveCommunity(String communityId) async {
    try {
      final response = await _apiService.leaveCommunity(communityId);
      
      if (response['success'] == true) {
        // Update community in list
        final index = _communities.indexWhere((c) => c['id'] == communityId);
        if (index != -1) {
          _communities[index] = {
            ..._communities[index],
            'isMember': false,
            'memberCount': (_communities[index]['memberCount'] ?? 1) - 1,
          };
        }
        Get.snackbar('Success', 'Left community successfully');
      }
    } catch (e) {
      print('Error leaving community: $e');
      Get.snackbar('Error', 'Failed to leave community');
    }
  }
  
  Future<void> muteCommunity(String communityId) async {
    try {
      final response = await _apiService.muteCommunity(communityId);
      
      if (response['success'] == true) {
        Get.snackbar('Success', 'Community muted');
      }
    } catch (e) {
      print('Error muting community: $e');
      Get.snackbar('Error', 'Failed to mute community');
    }
  }
}
