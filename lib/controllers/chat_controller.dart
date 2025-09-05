import 'package:get/get.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/api/api_service.dart';
import '../services/socket/socket_service.dart';
import '../controllers/auth_controller.dart';

class ChatController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  
  // Observable variables
  final RxList<ChatModel> _chats = <ChatModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  
  // Getters
  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  int get currentPage => _currentPage.value;
  
  @override
  void onInit() {
    super.onInit();
    loadChats();
  }
  
  Future<void> loadChats({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMore.value = true;
        _chats.clear();
      }
      
      if (!_hasMore.value || _isLoading.value) return;
      
      _isLoading.value = true;
      
      final response = await _apiService.getChats(
        page: _currentPage.value,
        limit: 20,
      );
      
      if (response['success'] == true) {
        final chatList = (response['chats'] as List)
            .map((chatJson) => ChatModel.fromJson(chatJson))
            .toList();
        
        if (refresh) {
          _chats.value = chatList;
        } else {
          _chats.addAll(chatList);
        }
        
        _currentPage.value++;
        _hasMore.value = chatList.length >= 20;
      }
    } catch (e) {
      print('Error loading chats: $e');
      Get.snackbar('Error', 'Failed to load chats');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> refreshChats() async {
    await loadChats(refresh: true);
  }
  
  Future<void> archiveChat(String chatId) async {
    try {
      final response = await _apiService.archiveChat(chatId);
      if (response['success'] == true) {
        _chats.removeWhere((chat) => chat.id == chatId);
        Get.snackbar('Success', 'Chat archived');
      }
    } catch (e) {
      print('Error archiving chat: $e');
      Get.snackbar('Error', 'Failed to archive chat');
    }
  }
  
  Future<void> deleteChat(String chatId) async {
    try {
      final response = await _apiService.deleteChat(chatId);
      if (response['success'] == true) {
        _chats.removeWhere((chat) => chat.id == chatId);
        Get.snackbar('Success', 'Chat deleted');
      }
    } catch (e) {
      print('Error deleting chat: $e');
      Get.snackbar('Error', 'Failed to delete chat');
    }
  }
  
  Future<void> toggleMuteChat(String chatId) async {
    try {
      final chat = _chats.firstWhere((c) => c.id == chatId);
      final response = chat.isMuted 
          ? await _apiService.unmuteChat(chatId)
          : await _apiService.muteChat(chatId, 3600000); // 1 hour
      
      if (response['success'] == true) {
        final index = _chats.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          _chats[index] = chat.copyWith(isMuted: !chat.isMuted);
        }
        Get.snackbar('Success', chat.isMuted ? 'Chat unmuted' : 'Chat muted');
      }
    } catch (e) {
      print('Error toggling mute: $e');
      Get.snackbar('Error', 'Failed to update chat settings');
    }
  }
  
  Future<void> blockUser(String userId) async {
    try {
      final response = await _apiService.blockUser(userId);
      if (response['success'] == true) {
        // Remove chats with blocked user
        _chats.removeWhere((chat) => 
            chat.type == ChatType.private && 
            chat.participants.any((p) => p.id == userId));
        Get.snackbar('Success', 'User blocked');
      }
    } catch (e) {
      print('Error blocking user: $e');
      Get.snackbar('Error', 'Failed to block user');
    }
  }
  
  void updateChatLastMessage(String chatId, MessageModel message) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final chat = _chats[index];
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.id ?? '';
      
      // Update unread count
      final newUnreadCount = Map<String, int>.from(chat.unreadCount);
      if (message.sender.id != currentUserId) {
        newUnreadCount[currentUserId] = (newUnreadCount[currentUserId] ?? 0) + 1;
      }
      
      _chats[index] = chat.copyWith(
        lastMessage: message,
        lastMessageAt: message.createdAt,
        unreadCount: newUnreadCount,
      );
      
      // Move chat to top
      final updatedChat = _chats.removeAt(index);
      _chats.insert(0, updatedChat);
    }
  }
  
  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final chat = _chats[index];
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.id ?? '';
      
      final newUnreadCount = Map<String, int>.from(chat.unreadCount);
      newUnreadCount[currentUserId] = 0;
      
      _chats[index] = chat.copyWith(unreadCount: newUnreadCount);
    }
  }
  
  // Socket event handlers
  void onNewMessage(MessageModel message) {
    print('New message received: ${message.content}');
    updateChatLastMessage(message.chatId, message);
  }
  
  void onMessageDelivered(String messageId) {
    print('Message delivered: $messageId');
    // Update message status in UI if needed
  }
  
  void onMessageRead(String messageId, dynamic readBy) {
    print('Message read: $messageId by $readBy');
    // Update message status in UI if needed
  }
  
  void onUserTyping(String userId, String chatId) {
    print('User typing: $userId in $chatId');
    // Update typing indicator in UI if needed
  }
  
  void onUserStoppedTyping(String userId, String chatId) {
    print('User stopped typing: $userId in $chatId');
    // Remove typing indicator in UI if needed
  }
}
