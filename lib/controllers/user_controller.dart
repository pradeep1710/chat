import 'package:get/get.dart';

class UserController extends GetxController {
  // Placeholder methods for socket service
  void updateUserOnlineStatus(String userId, bool isOnline) {
    print('User online status updated: $userId - $isOnline');
  }
  
  void updateUserOfflineStatus(String userId, String lastSeen) {
    print('User offline status updated: $userId - $lastSeen');
  }
}
