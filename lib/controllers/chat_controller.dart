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
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadChats();
    _socketService.connect();
    _socketService.onNewMessage(onNewMessage);
  }
  
  Future<void> loadChats({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        chats.clear();
      }
      
      if (!hasMore.value || isLoading.value) return;
      
      isLoading.value = true;
      
      final response = await _apiService.getChats(
        page: currentPage.value,
        limit: 20,
      );
      
      if (response['success'] == true) {
        final chatList = (response['chats'] as List)
            .map((chatJson) => ChatModel.fromJson(chatJson))
            .toList();
        
        if (refresh) {
          chats.value = chatList;
        } else {
          chats.addAll(chatList);
        }
        
        currentPage.value++;
        hasMore.value = chatList.length >= 20;
      }
    } catch (e) {
      print('Error loading chats: $e');
      Get.snackbar('Error', 'Failed to load chats');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshChats() async {
    await loadChats(refresh: true);
  }
  
  Future<void> archiveChat(String chatId) async {
    try {
      final response = await _apiService.archiveChat(chatId);
      if (response['success'] == true) {
        chats.removeWhere((chat) => chat.id == chatId);
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
        chats.removeWhere((chat) => chat.id == chatId);
        Get.snackbar('Success', 'Chat deleted');
      }
    } catch (e) {
      print('Error deleting chat: $e');
      Get.snackbar('Error', 'Failed to delete chat');
    }
  }
  
  Future<void> toggleMuteChat(String chatId) async {
    try {
      final chat = chats.firstWhere((c) => c.id == chatId);
      final response = chat.isMuted 
          ? await _apiService.unmuteChat(chatId)
          : await _apiService.muteChat(chatId, 3600000); // 1 hour
      
      if (response['success'] == true) {
        final index = chats.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          chats[index] = chat.copyWith(isMuted: !chat.isMuted);
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
        chats.removeWhere((chat) => 
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
    final index = chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final chat = chats[index];
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.id ?? '';
      
      // Update unread count
      final newUnreadCount = Map<String, int>.from(chat.unreadCount);
      if (message.sender.id != currentUserId) {
        newUnreadCount[currentUserId] = (newUnreadCount[currentUserId] ?? 0) + 1;
      }
      
      chats[index] = chat.copyWith(
        lastMessage: message,
        lastMessageAt: message.createdAt,
        unreadCount: newUnreadCount,
      );
      
      // Move chat to top
      final updatedChat = chats.removeAt(index);
      chats.insert(0, updatedChat);
    }
  }
  
  void markChatAsRead(String chatId) {
    final index = chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final chat = chats[index];
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.id ?? '';
      
      final newUnreadCount = Map<String, int>.from(chat.unreadCount);
      newUnreadCount[currentUserId] = 0;
      
      chats[index] = chat.copyWith(unreadCount: newUnreadCount);
    }
  }
  
  // Socket event handlers
  void onNewMessage(dynamic data) {
    final message = MessageModel.fromJson(data['message']);
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
