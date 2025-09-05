import 'package:get/get.dart';

class ChatController extends GetxController {
  // Placeholder methods for socket service
  void onNewMessage(dynamic message) {
    print('New message received: $message');
  }
  
  void onMessageDelivered(String messageId) {
    print('Message delivered: $messageId');
  }
  
  void onMessageRead(String messageId, dynamic readBy) {
    print('Message read: $messageId by $readBy');
  }
  
  void onUserTyping(String userId, String chatId) {
    print('User typing: $userId in $chatId');
  }
  
  void onUserStoppedTyping(String userId, String chatId) {
    print('User stopped typing: $userId in $chatId');
  }
}
