import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api/api_service.dart';
import '../services/storage/storage_service.dart';

class SearchController extends GetxController with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Controllers
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  late TabController tabController;
  
  // Observable variables
  final RxString _searchQuery = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxList<String> _recentSearches = <String>[].obs;
  final RxList<dynamic> _allResults = <dynamic>[].obs;
  final RxList<dynamic> _chatResults = <dynamic>[].obs;
  final RxList<dynamic> _messageResults = <dynamic>[].obs;
  final RxList<dynamic> _userResults = <dynamic>[].obs;
  final RxList<dynamic> _communityResults = <dynamic>[].obs;
  
  // Debounce timer
  Timer? _debounceTimer;
  
  // Getters
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _isLoading.value;
  List<String> get recentSearches => _recentSearches;
  List<dynamic> get allResults => _allResults;
  List<dynamic> get chatResults => _chatResults;
  List<dynamic> get messageResults => _messageResults;
  List<dynamic> get userResults => _userResults;
  List<dynamic> get communityResults => _communityResults;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    _loadRecentSearches();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    tabController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    _searchQuery.value = query;
    
    if (query.isEmpty) {
      _clearResults();
      return;
    }
    
    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      performSearch(query);
    });
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    _searchQuery.value = query;
    searchController.text = query;
    
    // Add to recent searches
    _addRecentSearch(query);
    
    try {
      _isLoading.value = true;
      _clearResults();
      
      // Perform parallel searches
      final futures = [
        _searchChats(query),
        _searchMessages(query),
        _searchUsers(query),
        _searchCommunities(query),
      ];
      
      await Future.wait(futures);
      
      // Combine all results for "All" tab
      _combineAllResults();
      
    } catch (e) {
      print('Error performing search: $e');
      Get.snackbar('Error', 'Failed to perform search');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _searchChats(String query) async {
    try {
      // TODO: Replace with actual API call
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockChats = _generateMockChats(query);
      _chatResults.value = mockChats;
    } catch (e) {
      print('Error searching chats: $e');
    }
  }

  Future<void> _searchMessages(String query) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final mockMessages = _generateMockMessages(query);
      _messageResults.value = mockMessages;
    } catch (e) {
      print('Error searching messages: $e');
    }
  }

  Future<void> _searchUsers(String query) async {
    try {
      final response = await _apiService.searchUsers(query, limit: 20);
      
      if (response['success'] == true) {
        _userResults.value = response['users'] ?? [];
      }
    } catch (e) {
      print('Error searching users: $e');
      // Fallback to mock data
      final mockUsers = _generateMockUsers(query);
      _userResults.value = mockUsers;
    }
  }

  Future<void> _searchCommunities(String query) async {
    try {
      final response = await _apiService.searchCommunities(query, limit: 20);
      
      if (response['success'] == true) {
        _communityResults.value = response['communities'] ?? [];
      }
    } catch (e) {
      print('Error searching communities: $e');
      // Fallback to mock data
      final mockCommunities = _generateMockCommunities(query);
      _communityResults.value = mockCommunities;
    }
  }

  void _combineAllResults() {
    final allResults = <dynamic>[];
    
    // Add chats
    for (var chat in _chatResults.take(3)) {
      allResults.add({...chat, 'type': 'chat'});
    }
    
    // Add messages
    for (var message in _messageResults.take(3)) {
      allResults.add({...message, 'type': 'message'});
    }
    
    // Add users
    for (var user in _userResults.take(3)) {
      allResults.add({...user, 'type': 'user'});
    }
    
    // Add communities
    for (var community in _communityResults.take(3)) {
      allResults.add({...community, 'type': 'community'});
    }
    
    _allResults.value = allResults;
  }

  void _clearResults() {
    _allResults.clear();
    _chatResults.clear();
    _messageResults.clear();
    _userResults.clear();
    _communityResults.clear();
  }

  void _addRecentSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    
    // Remove if already exists
    _recentSearches.remove(trimmedQuery);
    
    // Add to beginning
    _recentSearches.insert(0, trimmedQuery);
    
    // Keep only last 10 searches
    if (_recentSearches.length > 10) {
      _recentSearches.removeRange(10, _recentSearches.length);
    }
    
    _saveRecentSearches();
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    _saveRecentSearches();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    _saveRecentSearches();
  }

  void _loadRecentSearches() {
    final searches = _storageService.read('recent_searches') as List<dynamic>?;
    if (searches != null) {
      _recentSearches.value = searches.cast<String>();
    }
  }

  void _saveRecentSearches() {
    _storageService.write('recent_searches', _recentSearches.toList());
  }

  // Mock data generators (replace with actual API calls)
  List<dynamic> _generateMockChats(String query) {
    final chats = [
      {
        'id': 'chat_1',
        'name': 'John Doe',
        'profilePicture': null,
        'lastMessage': 'Hey, how are you?',
        'unreadCount': 2,
        'type': 'private',
      },
      {
        'id': 'chat_2',
        'name': 'Work Group',
        'profilePicture': null,
        'lastMessage': 'Meeting at 3 PM',
        'unreadCount': 0,
        'type': 'group',
      },
      {
        'id': 'chat_3',
        'name': 'Family',
        'profilePicture': null,
        'lastMessage': 'Dinner tonight?',
        'unreadCount': 1,
        'type': 'group',
      },
    ];
    
    return chats.where((chat) => 
      chat['name'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<dynamic> _generateMockMessages(String query) {
    final messages = [
      {
        'id': 'msg_1',
        'content': 'Hello, how are you doing today?',
        'sender': {
          'id': 'user_1',
          'username': 'John Doe',
          'profilePicture': null,
        },
        'chatId': 'chat_1',
        'chatName': 'John Doe',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'msg_2',
        'content': 'Can we schedule a meeting for tomorrow?',
        'sender': {
          'id': 'user_2',
          'username': 'Jane Smith',
          'profilePicture': null,
        },
        'chatId': 'chat_2',
        'chatName': 'Work Group',
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': 'msg_3',
        'content': 'What time is the family dinner?',
        'sender': {
          'id': 'user_3',
          'username': 'Mom',
          'profilePicture': null,
        },
        'chatId': 'chat_3',
        'chatName': 'Family',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
    ];
    
    return messages.where((message) => 
      message['content'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<dynamic> _generateMockUsers(String query) {
    final users = [
      {
        'id': 'user_1',
        'username': 'john_doe',
        'profilePicture': null,
        'status': 'Hey there! I am using ChatApp',
        'isOnline': true,
      },
      {
        'id': 'user_2',
        'username': 'jane_smith',
        'profilePicture': null,
        'status': 'Working from home',
        'isOnline': false,
      },
      {
        'id': 'user_3',
        'username': 'mike_wilson',
        'profilePicture': null,
        'status': 'Available',
        'isOnline': true,
      },
    ];
    
    return users.where((user) => 
      user['username'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<dynamic> _generateMockCommunities(String query) {
    final communities = [
      {
        'id': 'comm_1',
        'name': 'Tech Enthusiasts',
        'description': 'A community for tech lovers',
        'profilePicture': null,
        'memberCount': 1250,
        'isMember': false,
        'isPublic': true,
      },
      {
        'id': 'comm_2',
        'name': 'Flutter Developers',
        'description': 'Learn and share Flutter knowledge',
        'profilePicture': null,
        'memberCount': 890,
        'isMember': true,
        'isPublic': true,
      },
      {
        'id': 'comm_3',
        'name': 'Photography Club',
        'description': 'Share your amazing photos',
        'profilePicture': null,
        'memberCount': 567,
        'isMember': false,
        'isPublic': true,
      },
    ];
    
    return communities.where((community) => 
      community['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
      community['description'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}