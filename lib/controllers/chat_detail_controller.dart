import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/api/api_service.dart';
import '../services/socket/socket_service.dart';
import '../controllers/auth_controller.dart';

class ChatDetailController extends GetxController {
  final ChatModel chat;
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  final AuthController _authController = Get.find<AuthController>();
  
  // Controllers
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  
  // Observable variables
  final RxList<MessageModel> _messages = <MessageModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxString _messageText = ''.obs;
  final RxList<String> _typingUsers = <String>[].obs;
  final RxnString _replyToMessage = RxnString();
  
  // Getters
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  int get currentPage => _currentPage.value;
  String get messageText => _messageText.value;
  List<String> get typingUsers => _typingUsers;
  String? get replyToMessage => _replyToMessage.value;

  ChatDetailController({required this.chat});

  @override
  void onInit() {
    super.onInit();
    loadMessages();
    _setupScrollListener();
    _joinChat();
  }

  @override
  void onClose() {
    messageController.dispose();
    messageFocusNode.dispose();
    scrollController.dispose();
    _leaveChat();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        loadMessages();
      }
    });
  }

  void _joinChat() {
    _socketService.joinChat(chat.id);
  }

  void _leaveChat() {
    _socketService.leaveChat(chat.id);
  }

  Future<void> loadMessages({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMore.value = true;
        _messages.clear();
      }
      
      if (!_hasMore.value || _isLoading.value) return;
      
      _isLoading.value = true;
      
      final response = await _apiService.getChatMessages(
        chat.id,
        page: _currentPage.value,
        limit: 50,
      );
      
      if (response['success'] == true) {
        final messageList = (response['messages'] as List)
            .map((messageJson) => MessageModel.fromJson(messageJson))
            .toList();
        
        if (refresh) {
          _messages.value = messageList;
        } else {
          _messages.addAll(messageList);
        }
        
        _currentPage.value++;
        _hasMore.value = messageList.length >= 50;
      }
    } catch (e) {
      print('Error loading messages: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      _isLoading.value = false;
    }
  }

  void onMessageChanged(String text) {
    _messageText.value = text;
    
    // Handle typing indicators
    if (text.isNotEmpty) {
      _socketService.startTyping(chat.id);
    } else {
      _socketService.stopTyping(chat.id);
    }
  }

  Future<void> sendMessage({String? mediaPath, String? mediaType}) async {
    final content = messageController.text.trim();
    if (content.isEmpty && mediaPath == null) return;

    final tempMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chat.id,
      sender: _authController.currentUser!,
      content: content,
      type: mediaType != null ? _getMessageTypeFromString(mediaType) : MessageType.text,
      mentions: [],
      status: MessageStatus.sending,
      readBy: [],
      isEdited: false,
      isDeleted: false,
      isStarred: false,
      starredBy: [],
      reactions: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Add message to UI immediately
    _messages.insert(0, tempMessage);
    messageController.clear();
    _messageText.value = '';
    _replyToMessage.value = null;

    // Scroll to bottom
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    try {
      // Send via socket
      final messageData = {
        'chatId': chat.id,
        'content': content,
        'type': mediaType ?? 'text',
        if (mediaPath != null) 'mediaPath': mediaPath,
        if (_replyToMessage.value != null) 'replyTo': _replyToMessage.value,
      };
      
      _socketService.sendMessage(messageData);
      
      // Update message status to sent
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = tempMessage.copyWith(status: MessageStatus.sent);
      }
    } catch (e) {
      print('Error sending message: $e');
      
      // Update message status to failed
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = tempMessage.copyWith(status: MessageStatus.failed);
      }
      
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  MessageType _getMessageTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'document':
        return MessageType.document;
      case 'voice':
        return MessageType.voice;
      case 'location':
        return MessageType.location;
      case 'contact':
        return MessageType.contact;
      default:
        return MessageType.text;
    }
  }

  void replyToMessage(MessageModel message) {
    _replyToMessage.value = message.id;
    messageFocusNode.requestFocus();
  }

  void editMessage(MessageModel message) {
    messageController.text = message.content;
    messageFocusNode.requestFocus();
    // TODO: Implement edit mode
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      // Remove from UI immediately
      _messages.removeWhere((m) => m.id == messageId);
      
      // TODO: Call API to delete message
      Get.snackbar('Success', 'Message deleted');
    } catch (e) {
      print('Error deleting message: $e');
      Get.snackbar('Error', 'Failed to delete message');
    }
  }

  Future<void> toggleStarMessage(String messageId) async {
    try {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final message = _messages[index];
        _messages[index] = message.copyWith(isStarred: !message.isStarred);
      }
      
      // TODO: Call API to star/unstar message
    } catch (e) {
      print('Error toggling star: $e');
      Get.snackbar('Error', 'Failed to update message');
    }
  }

  void toggleMute() {
    // TODO: Implement mute toggle
    Get.snackbar('Success', chat.isMuted ? 'Chat unmuted' : 'Chat muted');
  }

  Future<void> clearChat() async {
    try {
      _messages.clear();
      // TODO: Call API to clear chat
      Get.snackbar('Success', 'Chat cleared');
    } catch (e) {
      print('Error clearing chat: $e');
      Get.snackbar('Error', 'Failed to clear chat');
    }
  }

  Future<void> deleteChat() async {
    try {
      // TODO: Call API to delete chat
      Get.back(); // Go back to chat list
      Get.snackbar('Success', 'Chat deleted');
    } catch (e) {
      print('Error deleting chat: $e');
      Get.snackbar('Error', 'Failed to delete chat');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final response = await _apiService.blockUser(userId);
      if (response['success'] == true) {
        Get.back(); // Go back to chat list
        Get.snackbar('Success', 'User blocked');
      }
    } catch (e) {
      print('Error blocking user: $e');
      Get.snackbar('Error', 'Failed to block user');
    }
  }

  // Media handling methods
  Future<void> pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        await _uploadAndSendMedia(image.path, 'image');
      }
    } catch (e) {
      print('Error picking from gallery: $e');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        await _uploadAndSendMedia(image.path, 'image');
      }
    } catch (e) {
      print('Error taking photo: $e');
      Get.snackbar('Error', 'Failed to take photo');
    }
  }

  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.single.path != null) {
        await _uploadAndSendMedia(result.files.single.path!, 'document');
      }
    } catch (e) {
      print('Error picking document: $e');
      Get.snackbar('Error', 'Failed to pick document');
    }
  }

  Future<void> pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      
      if (result != null && result.files.single.path != null) {
        await _uploadAndSendMedia(result.files.single.path!, 'audio');
      }
    } catch (e) {
      print('Error picking audio: $e');
      Get.snackbar('Error', 'Failed to pick audio');
    }
  }

  Future<void> shareLocation() async {
    // TODO: Implement location sharing
    Get.snackbar('Coming Soon', 'Location sharing coming soon!');
  }

  Future<void> shareContact() async {
    // TODO: Implement contact sharing
    Get.snackbar('Coming Soon', 'Contact sharing coming soon!');
  }

  Future<void> _uploadAndSendMedia(String filePath, String mediaType) async {
    try {
      // Show uploading indicator
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Uploading...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Upload media
      final response = await _apiService.uploadMedia(filePath);
      
      Get.back(); // Close uploading dialog
      
      if (response['success'] == true) {
        final mediaUrl = response['url'];
        await sendMessage(mediaPath: mediaUrl, mediaType: mediaType);
      } else {
        Get.snackbar('Error', 'Failed to upload media');
      }
    } catch (e) {
      Get.back(); // Close uploading dialog
      print('Error uploading media: $e');
      Get.snackbar('Error', 'Failed to upload media');
    }
  }

  // Socket event handlers
  void onNewMessage(MessageModel message) {
    if (message.chatId == chat.id) {
      // Check if message already exists (avoid duplicates)
      if (!_messages.any((m) => m.id == message.id)) {
        _messages.insert(0, message);
        
        // Mark as read if chat is active
        _socketService.markMessageAsRead(message.id, chat.id);
      }
    }
  }

  void onUserTyping(String userId, String username) {
    if (!_typingUsers.contains(username)) {
      _typingUsers.add(username);
    }
  }

  void onUserStoppedTyping(String userId, String username) {
    _typingUsers.remove(username);
  }
}