import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get/get.dart';

import '../../core/constants/app_config.dart';
import '../../models/message_model.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/user_controller.dart';

class SocketService extends GetxService {
  io.Socket? _socket;
  final RxBool _isConnected = false.obs;
  
  bool get isConnected => _isConnected.value;
  io.Socket? get socket => _socket;
  
  Future<void> connect(String authToken) async {
    try {
      if (_socket != null && _socket!.connected) {
        print('Socket already connected');
        return;
      }
      
      _socket = io.io(
        AppConfig.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': authToken})
            .enableAutoConnect()
            .build(),
      );
      
      _setupSocketListeners();
      
      print('Connecting to socket...');
    } catch (e) {
      print('Error connecting to socket: $e');
    }
  }
  
  void _setupSocketListeners() {
    _socket?.on('connect', (data) {
      print('Connected to socket');
      _isConnected.value = true;
    });
    
    _socket?.on('disconnect', (data) {
      print('Disconnected from socket');
      _isConnected.value = false;
    });
    
    _socket?.on('error', (error) {
      print('Socket error: $error');
    });
    
    _socket?.on('connect_error', (error) {
      print('Socket connection error: $error');
      _isConnected.value = false;
    });
    
    // Message events
    _socket?.on('new_message', (data) {
      print('New message received: $data');
      _handleNewMessage(data);
    });
    
    _socket?.on('message_delivered', (data) {
      print('Message delivered: $data');
      _handleMessageDelivered(data);
    });
    
    _socket?.on('message_read', (data) {
      print('Message read: $data');
      _handleMessageRead(data);
    });
    
    // Typing events
    _socket?.on('user_typing', (data) {
      print('User typing: $data');
      _handleUserTyping(data);
    });
    
    _socket?.on('user_stopped_typing', (data) {
      print('User stopped typing: $data');
      _handleUserStoppedTyping(data);
    });
    
    // User status events
    _socket?.on('user_online_status_updated', (data) {
      print('User online status updated: $data');
      _handleUserOnlineStatus(data);
    });
    
    _socket?.on('user_offline', (data) {
      print('User offline: $data');
      _handleUserOffline(data);
    });
  }
  
  // Message handling
  void _handleNewMessage(dynamic data) {
    try {
      final message = MessageModel.fromJson(data['message']);
      // Notify controllers about new message
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().onNewMessage(message);
      }
    } catch (e) {
      print('Error handling new message: $e');
    }
  }
  
  void _handleMessageDelivered(dynamic data) {
    try {
      final messageId = data['messageId'];
      // Update message status
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().onMessageDelivered(messageId);
      }
    } catch (e) {
      print('Error handling message delivered: $e');
    }
  }
  
  void _handleMessageRead(dynamic data) {
    try {
      final messageId = data['messageId'];
      final readBy = data['readBy'];
      // Update message status
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().onMessageRead(messageId, readBy);
      }
    } catch (e) {
      print('Error handling message read: $e');
    }
  }
  
  // Typing indicators
  void _handleUserTyping(dynamic data) {
    try {
      final userId = data['userId'];
      final chatId = data['chatId'];
      // Update typing status
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().onUserTyping(userId, chatId);
      }
    } catch (e) {
      print('Error handling user typing: $e');
    }
  }
  
  void _handleUserStoppedTyping(dynamic data) {
    try {
      final userId = data['userId'];
      final chatId = data['chatId'];
      // Update typing status
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().onUserStoppedTyping(userId, chatId);
      }
    } catch (e) {
      print('Error handling user stopped typing: $e');
    }
  }
  
  // User status
  void _handleUserOnlineStatus(dynamic data) {
    try {
      final userId = data['userId'];
      final isOnline = data['isOnline'];
      // Update user online status
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().updateUserOnlineStatus(userId, isOnline);
      }
    } catch (e) {
      print('Error handling user online status: $e');
    }
  }
  
  void _handleUserOffline(dynamic data) {
    try {
      final userId = data['userId'];
      final lastSeen = data['lastSeen'];
      // Update user offline status
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().updateUserOfflineStatus(userId, lastSeen);
      }
    } catch (e) {
      print('Error handling user offline: $e');
    }
  }
  
  // Socket events
  void joinChat(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('join_chat', chatId);
      print('Joined chat: $chatId');
    }
  }
  
  void leaveChat(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('leave_chat', chatId);
      print('Left chat: $chatId');
    }
  }
  
  void sendMessage(Map<String, dynamic> messageData) {
    if (_socket?.connected == true) {
      _socket?.emit('send_message', messageData);
      print('Message sent: $messageData');
    }
  }
  
  void startTyping(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('typing_start', {'chatId': chatId});
    }
  }
  
  void stopTyping(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('typing_stop', {'chatId': chatId});
    }
  }
  
  void markMessageAsRead(String messageId, String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('mark_message_read', {
        'messageId': messageId,
        'chatId': chatId,
      });
    }
  }
  
  void updateOnlineStatus(bool isOnline) {
    if (_socket?.connected == true) {
      _socket?.emit('update_online_status', {'isOnline': isOnline});
    }
  }
  
  void updateStatus(String status) {
    if (_socket?.connected == true) {
      _socket?.emit('update_status', {'status': status});
    }
  }
  
  void joinGroup(String groupId) {
    if (_socket?.connected == true) {
      _socket?.emit('join_group', groupId);
    }
  }
  
  void joinCommunity(String communityId) {
    if (_socket?.connected == true) {
      _socket?.emit('join_community', communityId);
    }
  }
  
  Future<void> disconnect() async {
    try {
      if (_socket?.connected == true) {
        _socket?.disconnect();
      }
      _socket?.dispose();
      _socket = null;
      _isConnected.value = false;
      print('Socket disconnected');
    } catch (e) {
      print('Error disconnecting socket: $e');
    }
  }
  
  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}